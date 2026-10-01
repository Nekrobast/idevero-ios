import XCTest
@testable import Idevero

final class LocalExpertProviderTests: XCTestCase {
    private var provider: LocalExpertProvider { LocalExpertProvider() }

    func testKnowledgeInventoryMatchesWebV3() throws {
        let store = try KnowledgeStore.load()
        XCTAssertEqual(store.concepts.count, 128); XCTAssertEqual(store.relationships.count, 54)
        XCTAssertEqual(store.domains.count, 38); XCTAssertEqual(store.strategies.count + store.strategyAliases.count, 30)
        XCTAssertEqual(Set(store.concepts.map(\.id)).count, 128)
    }

    func testRequiredRoutingCases() throws {
        let cases: [(String,String)] = [
            ("app para apicultores","APPLICATION"), ("comprar bicicleta","SHOPPING"),
            ("móvil por 500 € con buenas fotos","SHOPPING"), ("imagen samurái bajo lluvia","IMAGE"),
            ("quitar una persona de una foto","IMAGE_EDITING"), ("email de agradecimiento corto","EMAIL"),
            ("Excel stock","SPREADSHEET"), ("Japón 7 días","TRAVEL"), ("rutina gimnasio","FITNESS"),
            ("marketplace segunda mano","SHOPPING"), ("landing clínica dental","WEB"),
            ("automatizar facturas","AUTOMATION"), ("resumir contrato","DOCUMENT"),
            ("presentación comercial","PRESENTATION"), ("Work mejora aplicación existente","APPLICATION"),
            ("plan meals one week","PLANNING"), ("organiza torneo","PLANNING")
        ]
        for (input, task) in cases { XCTAssertEqual(try provider.analyze(input, decisions: .init()).task, task, input) }
    }

    func testAmbiguousFragmentDoesNotInventDomain() throws {
        let result = try provider.analyze("algo para organizarlo", decisions: .init())
        XCTAssertEqual(result.task, "GENERAL"); XCTAssertEqual(result.domain, "unknown")
    }

    func testApplicationGetsProductDepth() throws {
        let result = try provider.analyze("app para apicultores", decisions: .init())
        XCTAssertEqual(result.elaboration, .project)
        XCTAssertTrue(result.discoveries.contains { $0.concept.localizedCaseInsensitiveContains("flujo") })
        XCTAssertGreaterThan(result.prompt.count, 500)
    }

    func testEmailStaysCompact() throws {
        let result = try provider.analyze("email de agradecimiento corto", decisions: .init())
        XCTAssertEqual(result.elaboration, .light); XCTAssertLessThan(result.prompt.count, 650)
    }

    func testProductCompilerUsesNaturalRequestFraming() throws {
        let result = try provider.analyze("Quiero crear una app para apicultores", decisions: .init())
        XCTAssertTrue(result.prompt.contains("Encargo original: «Quiero crear una app para apicultores»"))
        XCTAssertFalse(result.prompt.contains("Diseña y especifica Quiero"))
    }

    func testAppleOnlyFindingsReceiveDomainSection() throws {
        var analysis = try provider.analyze("app para trabajo de campo", decisions: .init())
        analysis.discoveries.append(Discovery(id: "APPLE_TEST", concept: "Historial de inspecciones por unidad", reason: "Relaciona cada revisión con el estado de la unidad y las incidencias detectadas.", lens: "Dominio operativo", priority: .highValue, provenance: .appleModel, state: .included, dependencies: [], confidence: "HIGH", sourceProvenance: [.appleModel], semanticRole: SemanticRole.coreWorkflow.rawValue, anchor: "inspecciones"))
        let prompt = SpecializedCompiler().compile(analysis)
        XCTAssertTrue(prompt.contains("Contexto del dominio"))
        XCTAssertTrue(prompt.contains("Historial de inspecciones por unidad"))
    }

    func testSpreadsheetUsesSpecializedCompiler() throws {
        let result = try provider.analyze("Excel stock", decisions: .init())
        XCTAssertTrue(result.prompt.contains("libro de cálculo")); XCTAssertTrue(result.prompt.contains("fórmulas"))
    }

    func testImageUsesVisualDirection() throws {
        let result = try provider.analyze("imagen samurái bajo lluvia", decisions: .init())
        XCTAssertTrue(result.prompt.contains("dirección artística")); XCTAssertFalse(result.prompt.contains("base de datos"))
    }

    func testImageEditUsesPreservationContract() throws {
        let result = try provider.analyze("quitar una persona de una foto", decisions: .init())
        XCTAssertTrue(result.prompt.contains("conserva idénticos rostros")); XCTAssertEqual(result.task, "IMAGE_EDITING")
    }

    func testWorkRemainsTargetNotTask() throws {
        let result = try provider.analyze("Work mejora aplicación existente", decisions: .init())
        XCTAssertEqual(result.task, "APPLICATION"); XCTAssertEqual(result.target, "CHATGPT WORK")
        XCTAssertTrue(result.prompt.contains("Ejecución en ChatGPT Work"))
    }

    func testExclusionAndLockSurviveReanalysis() throws {
        let first = try provider.analyze("app gastos", decisions: .init()), excluded = try XCTUnwrap(first.discoveries.first?.id), locked = try XCTUnwrap(first.discoveries.dropFirst().first?.id)
        let second = try provider.analyze("app gastos", decisions: .init(locked: [locked], excluded: [excluded]))
        XCTAssertEqual(second.discoveries.first { $0.id == excluded }?.state, .excluded)
        XCTAssertEqual(second.discoveries.first { $0.id == locked }?.state, .locked)
    }

    func testRegenerateKeepsAnalysisIdentityAndStates() throws {
        var first = try provider.analyze("Excel stock", decisions: .init())
        first.discoveries[0].state = .locked
        let rebuilt = try provider.recompile(first)
        XCTAssertEqual(rebuilt.analysisID, first.analysisID); XCTAssertEqual(rebuilt.discoveries[0].state, .locked)
    }

    func testHistoricalRoundTripPreservesAnalysis() throws {
        let original = try provider.analyze("app gastos", decisions: .init())
        let record = PromptRecord(analysis: original), restored = record.reconstructedAnalysis()
        XCTAssertEqual(restored.input, original.input); XCTAssertEqual(restored.task, original.task)
        XCTAssertEqual(restored.discoveries, original.discoveries); XCTAssertEqual(restored.prompt, original.prompt)
    }

    func testLegacyHistoryDoesNotInventUnavailableFields() {
        let analysis = PromptAnalysis(analysisID: UUID(), title: "Legacy", input: "old", task: "GENERAL", intent: "TRANSFORM", domain: "unknown", secondaryDomains: [], target: "CHATGPT", outcome: "", elaboration: .light, discoveries: [], unknowns: [], prompt: "saved", qualityNotes: [], intelligenceMode: "LOCAL EXPERT", analyzedAt: .now)
        let record = PromptRecord(analysis: analysis); record.analysisData = Data(); record.discoveriesData = Data()
        let restored = record.reconstructedAnalysis()
        XCTAssertEqual(restored.prompt, "saved"); XCTAssertTrue(restored.unknowns.isEmpty); XCTAssertTrue(restored.discoveries.isEmpty)
    }

    func testQuestionBudgetIsReduced() throws {
        XCTAssertLessThanOrEqual(try provider.analyze("app gastos", decisions: .init()).unknowns.count, 3)
        XCTAssertLessThanOrEqual(try provider.analyze("email gracias", decisions: .init()).unknowns.count, 1)
    }
}
