import XCTest
@testable import Idevero

final class FoundationQualityV5Tests: XCTestCase {
    // CI contract for deterministic Quality V5 gates; physical semantics remain device evidence.
    private let provider = LocalExpertProvider()

    private func frame(status: String = "UNDERSPECIFIED", items: [SemanticDomainItem] = []) -> SemanticDomainFrame {
        SemanticDomainFrame(
            primaryJobStatus: status,
            primaryJobCandidates: [],
            actors: ["profesionales"],
            entities: ["unidades gestionadas"],
            relationships: ["cada unidad conserva un historial de revisiones"],
            workflows: ["revisión periódica de cada unidad"],
            decisions: ["decidir la siguiente intervención según el estado observado"],
            constraints: [],
            contextItems: items
        )
    }

    func testEpistemicCalibrationOmitsUnsupportedAndLowValueContext() {
        let items = [
            SemanticDomainItem(kind: "ENTITY", text: "unidades gestionadas", epistemicStatus: "ESTABLISHED", decisionRelevance: "HIGH"),
            SemanticDomainItem(kind: "RELATIONSHIP", text: "una asociación regional comparte todos los registros", epistemicStatus: "CASE_DEPENDENT", decisionRelevance: "MEDIUM"),
            SemanticDomainItem(kind: "REGULATION", text: "una institución concreta supervisa cada operación", epistemicStatus: "UNSUPPORTED", decisionRelevance: "HIGH"),
            SemanticDomainItem(kind: "ENTITY", text: "preferencia decorativa", epistemicStatus: "ESTABLISHED", decisionRelevance: "LOW")
        ]
        let context = DomainContextBuilder().build(frame: frame(items: items), language: .spanish)
        XCTAssertEqual(context?.calibratedItems?.count, 2)
        XCTAssertEqual(context?.calibratedItems?.first?.status, .established)
        XCTAssertFalse(context?.calibratedItems?.contains(where: { $0.text.contains("institución") }) ?? true)
    }

    func testCompilerFramesCaseDependentContextAsConditional() async throws {
        var analysis = try await provider.analyze("Quiero una app para profesionales de mantenimiento")
        analysis.domainContext = DomainContext(
            language: "es", primaryJobStatus: "UNDERSPECIFIED", primaryJobCandidates: [], actors: [], entities: [], relationships: [], workflows: [], decisions: [], constraints: [],
            calibratedItems: [
                DomainContextItem(kind: "ENTITY", text: "cada activo conserva un estado operativo", status: .established, decisionRelevance: "HIGH"),
                DomainContextItem(kind: "WORKFLOW", text: "coordinar trabajos con proveedores externos", status: .caseDependent, decisionRelevance: "MEDIUM")
            ]
        )
        let prompt = SpecializedCompiler().compile(analysis)
        XCTAssertTrue(prompt.contains("Contexto inferido que conviene validar"))
        XCTAssertFalse(prompt.contains("Conocimiento sectorial fiable"))
        XCTAssertTrue(prompt.contains("Patrones que dependen del caso"))
        XCTAssertTrue(prompt.contains("Puede ser relevante, según el objetivo elegido"))
        XCTAssertFalse(prompt.contains("\n- coordinar trabajos con proveedores externos"))
    }

    func testGenericRequirementWithDomainNounIsRejected() throws {
        let store = try KnowledgeStore.load()
        let finding = SemanticFinding(
            concept: "Recuperación de datos de las unidades",
            reason: "Permite recuperar la información de las unidades si se pierde por un error.",
            lens: "Dominio", semanticRole: "FAILURE_MODE", anchor: "unidades gestionadas",
            domainSpecificity: "LOW", professionalRelevance: "MEDIUM", domainMechanism: "recuperación genérica de datos"
        )
        let result = AppleDiscoveryMerger(store: store).merge(local: [], findings: [finding], request: "Quiero una app para profesionales", frame: frame(status: "DEFINED"))
        XCTAssertTrue(result.isEmpty)
    }

    func testAnchoredProfessionalMechanismSurvives() throws {
        let store = try KnowledgeStore.load()
        let finding = SemanticFinding(
            concept: "Historial de revisiones por unidad",
            reason: "Relaciona cada revisión con el estado observado para decidir la siguiente intervención profesional.",
            lens: "Dominio", semanticRole: "CORE_WORKFLOW", anchor: "revisión periódica de cada unidad",
            domainSpecificity: "HIGH", professionalRelevance: "HIGH", domainMechanism: "la revisión periódica de cada unidad determina la siguiente intervención"
        )
        let result = AppleDiscoveryMerger(store: store).merge(local: [], findings: [finding], request: "Quiero una app para profesionales", frame: frame(status: "DEFINED"))
        XCTAssertEqual(result.count, 1)
    }

    func testPrimaryAmbiguitySuppressesPrematureDownstreamQuestions() {
        let questions = [
            SemanticUnknown(question: "¿Cuál es la escala anual exacta de cada ubicación?", reason: "Podría cambiar un detalle operativo posterior del producto.", architectureImpact: "MEDIUM", workflowImpact: "MEDIUM", scopeImpact: "MEDIUM", level: "DOMAIN_DETAIL", dependsOnPrimaryJob: true),
            SemanticUnknown(question: "¿Qué dirección principal debe tener el producto?", reason: "Cambia el workflow, el alcance y el modelo de información.", architectureImpact: "HIGH", workflowImpact: "HIGH", scopeImpact: "HIGH", level: "PRODUCT_DIRECTION", dependsOnPrimaryJob: false)
        ]
        let selected = AppleUnknownSelector().select(questions, frame: frame(), findings: [], language: .spanish)
        XCTAssertEqual(selected.count, 1)
        XCTAssertFalse(selected[0].contains("escala anual"))
    }

    func testSparseFrameDoesNotRequireSectionCompleteness() {
        let items = [SemanticDomainItem(kind: "ENTITY", text: "unidades inspeccionadas", epistemicStatus: "ESTABLISHED", decisionRelevance: "HIGH")]
        let context = DomainContextBuilder().build(frame: frame(items: items), language: .spanish)
        XCTAssertEqual(context?.calibratedItems?.count, 1)
    }

    func testSpanishDisplayLocalizationRemovesObservedEnglishLabels() {
        let display = DisplayLocalization(language: .spanish)
        XCTAssertEqual(display.task("APPLICATION"), "Aplicación")
        XCTAssertEqual(display.lens("Product · Engineering · Quality"), "Producto · Ingeniería · Calidad")
        XCTAssertFalse(display.text("responsive y happy path").contains("happy path"))
        XCTAssertFalse(display.text("responsive y happy path").contains("responsive"))
    }

    func testEnglishDisplayLocalizationPreservesNaturalEnglish() {
        let display = DisplayLocalization(language: .english)
        XCTAssertEqual(display.task("APPLICATION"), "Application")
        XCTAssertEqual(display.lens("Product · Engineering"), "Product · Engineering")
    }

    func testCalibratedDomainContextCodableRoundTripAndLegacyCompatibility() throws {
        let original = DomainContext(language: "es", primaryJobStatus: "UNDERSPECIFIED", primaryJobCandidates: [], actors: [], entities: [], relationships: [], workflows: [], decisions: [], constraints: [], calibratedItems: [DomainContextItem(kind: "ENTITY", text: "unidad profesional", status: .established, decisionRelevance: "HIGH")])
        let data = try JSONEncoder().encode(original)
        XCTAssertEqual(try JSONDecoder().decode(DomainContext.self, from: data).calibratedItems?.count, 1)
        let legacy = #"{"language":"es","primaryJobStatus":"DEFINED","primaryJobCandidates":[],"actors":[],"entities":[],"relationships":[],"workflows":[],"decisions":[],"constraints":[]}"#.data(using: .utf8)!
        XCTAssertNil(try JSONDecoder().decode(DomainContext.self, from: legacy).calibratedItems)
    }

    func testSimpleEmailRemainsCompact() async throws {
        let analysis = try await provider.analyze("Escribe un email corto de agradecimiento")
        XCTAssertEqual(analysis.task, "EMAIL")
        XCTAssertLessThan(analysis.prompt.count, 700)
    }

    func testTenDomainHoldoutAcceptsSparseFramesWithoutFabricatingCompleteness() {
        let requests = ["apicultura", "clínica veterinaria", "mantenimiento de ascensores", "entrenadores personales", "pequeña bodega", "fotógrafos de bodas", "limpieza industrial", "autoescuela", "climatización", "vivero de plantas"]
        for request in requests {
            let items = [SemanticDomainItem(kind: "ENTITY", text: "unidad central de \(request)", epistemicStatus: "CASE_DEPENDENT", decisionRelevance: "MEDIUM")]
            let context = DomainContextBuilder().build(frame: frame(items: items), language: .spanish)
            XCTAssertEqual(context?.calibratedItems?.count, 1, request)
        }
    }
}
