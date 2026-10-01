import XCTest
@testable import Idevero

final class FoundationQualityV4Tests: XCTestCase {
    private let provider = LocalExpertProvider()

    private var naturalFrame: SemanticDomainFrame {
        SemanticDomainFrame(
            primaryJobStatus: "UNDERSPECIFIED",
            primaryJobCandidates: ["gestionar el trabajo diario", "seguir la evolución de las unidades", "planificar intervenciones profesionales"],
            actors: ["profesional responsable"],
            entities: ["unidad gestionada", "registro histórico"],
            relationships: ["cada unidad conserva su historial de revisiones"],
            workflows: ["revisión periódica de cada unidad"],
            decisions: ["decidir la siguiente intervención"],
            constraints: ["trabajo condicionado por la temporada"]
        )
    }

    private func context() throws -> DomainContext {
        try XCTUnwrap(DomainContextBuilder().build(frame: naturalFrame, language: .spanish))
    }

    private func analysis(domainContext: DomainContext?, unknowns: [String] = []) throws -> PromptAnalysis {
        let local = try provider.analyze("Quiero una app para un sector profesional", decisions: .init())
        return PromptAnalysis(
            analysisID: local.analysisID, title: local.title, input: local.input, task: local.task,
            intent: local.intent, domain: local.domain, secondaryDomains: local.secondaryDomains,
            target: local.target, outcome: local.outcome, elaboration: local.elaboration,
            discoveries: local.discoveries, unknowns: unknowns, prompt: "", qualityNotes: local.qualityNotes,
            intelligenceMode: "APPLE AUGMENTED + LOCAL EXPERT", analyzedAt: local.analyzedAt,
            domainContext: domainContext
        )
    }

    func testDomainFrameSurvivesIntoPromptAnalysisAndCodableSnapshot() throws {
        let original = try analysis(domainContext: context())
        let decoded = try JSONDecoder().decode(PromptAnalysis.self, from: JSONEncoder().encode(original))
        XCTAssertEqual(decoded.domainContext, original.domainContext)
        XCTAssertEqual(decoded.domainContext?.workflows.first, "revisión periódica de cada unidad")
    }

    func testDomainFrameSurvivesHistoryAndRegenerate() throws {
        let original = try analysis(domainContext: context())
        let restored = PromptRecord(analysis: original).reconstructedAnalysis()
        XCTAssertEqual(restored.domainContext, original.domainContext)
        let regenerated = try provider.recompile(restored)
        XCTAssertEqual(regenerated.domainContext, original.domainContext)
        XCTAssertTrue(regenerated.prompt.contains("Contexto del dominio"))
    }

    func testLegacyAnalysisWithoutDomainContextDecodesAsNil() throws {
        let current = try analysis(domainContext: context())
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(current)) as? [String: Any])
        object.removeValue(forKey: "domainContext")
        let legacy = try JSONDecoder().decode(PromptAnalysis.self, from: JSONSerialization.data(withJSONObject: object))
        XCTAssertNil(legacy.domainContext)
    }

    func testLanguageDetectionAndDisplayContract() {
        XCTAssertEqual(DisplayLanguage.detect(in: "Quiero una app para apicultores"), .spanish)
        XCTAssertEqual(DisplayLanguage.detect(in: "I want an app for independent electricians"), .english)
        XCTAssertFalse(UserFacingTextPolicy(language: .spanish).isSafeDisplay("What determines the seasonal capacity limits?"))
        XCTAssertFalse(UserFacingTextPolicy(language: .english).isSafeDisplay("¿Qué trabajo debe realizar primero la aplicación?"))
    }

    func testMachineCandidatesAndLabelsAreRejected() throws {
        let frame = SemanticDomainFrame(
            primaryJobStatus: "UNDERSPECIFIED",
            primaryJobCandidates: ["PRIMARY_JOB_A", "PRIMARY_JOB_B"], actors: [], entities: [], relationships: [], workflows: [], decisions: [], constraints: []
        )
        let built = try XCTUnwrap(DomainContextBuilder().build(frame: frame, language: .spanish))
        XCTAssertTrue(built.primaryJobCandidates.isEmpty)
        let finding = SemanticFinding(concept: "CERTIFICATION_REQUEST", reason: "Permite acceder al mercado cuando la regulación aplicable exige una certificación verificable.", lens: "DECISION_INPUT", semanticRole: "DECISION_INPUT", anchor: "unidad gestionada")
        let merged = AppleDiscoveryMerger(store: try KnowledgeStore.load()).merge(local: [], findings: [finding], request: "Quiero una app para un sector profesional", frame: naturalFrame)
        XCTAssertTrue(merged.isEmpty)
    }

    func testMachineUnknownIsNotShownAndInvalidJobsUseNaturalFallback() {
        let frame = SemanticDomainFrame(
            primaryJobStatus: "UNDERSPECIFIED",
            primaryJobCandidates: ["PRIMARY_JOB_A", "PRIMARY_JOB_B"], actors: [], entities: [], relationships: [], workflows: [], decisions: [], constraints: []
        )
        let raw = SemanticUnknown(question: "What determines SEASONAL_CAPACITY_LIMIT?", reason: "The answer changes the workflow and product scope materially.", architectureImpact: "HIGH", workflowImpact: "HIGH", scopeImpact: "HIGH")
        let selected = AppleUnknownSelector().select([raw], frame: frame, findings: [], language: .spanish)
        XCTAssertEqual(selected, ["¿Cuál es el problema principal que debe resolver primero la aplicación?"])
        XCTAssertFalse(selected.joined().contains("PRIMARY_JOB"))
    }

    func testRawSemanticRoleNeverBecomesDisplayLens() throws {
        let finding = SemanticFinding(concept: "Estado de la unidad", reason: "Conserva la evolución de cada unidad para apoyar la siguiente decisión profesional.", lens: "DECISION_INPUT", semanticRole: "DECISION_INPUT", anchor: "decidir la siguiente intervención")
        let result = AppleDiscoveryMerger(store: try KnowledgeStore.load()).merge(local: [], findings: [finding], request: "Quiero una app para un sector profesional", frame: naturalFrame)
        XCTAssertEqual(result.first?.lens, "Decisión profesional")
        XCTAssertNotEqual(result.first?.lens, "DECISION_INPUT")
    }

    func testDomainContextRemainsUsefulWhenAllAppleRequirementsAreRejected() throws {
        let value = try analysis(domainContext: context(), unknowns: ["¿Cuál es el problema principal que debe resolver primero la aplicación?"])
        let prompt = SpecializedCompiler().compile(value)
        XCTAssertTrue(prompt.contains("unidad gestionada"))
        XCTAssertTrue(prompt.contains("revisión periódica"))
        XCTAssertTrue(prompt.contains("no conviertas automáticamente cada elemento en una función"))
        XCTAssertTrue(prompt.contains("¿Cuál es el problema principal"))
    }

    func testFinalPromptContainsNoInternalMachineTokens() throws {
        let prompt = SpecializedCompiler().compile(try analysis(domainContext: context(), unknowns: ["¿Cuál es el problema principal que debe resolver primero la aplicación?"]))
        XCTAssertNil(prompt.range(of: "\\b[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)+\\b", options: .regularExpression))
    }

    func testEnglishContextAndUnknownStayEnglish() throws {
        let frame = SemanticDomainFrame(
            primaryJobStatus: "UNDERSPECIFIED",
            primaryJobCandidates: ["manage daily service calls", "track installation histories"],
            actors: ["independent electrician"], entities: ["customer installation", "service record"],
            relationships: ["each installation has a service history"], workflows: ["inspect and repair an installation"],
            decisions: ["choose the next safe intervention"], constraints: ["electrical safety requirements"]
        )
        let context = try XCTUnwrap(DomainContextBuilder().build(frame: frame, language: .english))
        let base = try provider.analyze("I want an app for independent electricians", decisions: .init())
        let value = PromptAnalysis(analysisID: base.analysisID, title: base.title, input: base.input, task: base.task, intent: base.intent, domain: base.domain, secondaryDomains: base.secondaryDomains, target: base.target, outcome: base.outcome, elaboration: base.elaboration, discoveries: base.discoveries, unknowns: AppleUnknownSelector().select([], frame: frame, findings: [], language: .english), prompt: "", qualityNotes: base.qualityNotes, intelligenceMode: "APPLE AUGMENTED + LOCAL EXPERT", analyzedAt: base.analyzedAt, domainContext: context)
        let prompt = SpecializedCompiler().compile(value)
        XCTAssertTrue(prompt.contains("Domain context"))
        XCTAssertTrue(prompt.contains("Which primary job"))
        XCTAssertFalse(prompt.contains("¿"))
    }

    func testCrossDomainHoldoutKeepsSafeContextAndNaturalUnknown() throws {
        let sectors = ["apicultura", "veterinaria", "ascensores", "entrenamiento", "bodega", "fotografía", "limpieza industrial", "autoescuela", "climatización", "vivero"]
        for sector in sectors {
            let request = "Quiero una app para \(sector)"
            let local = try provider.analyze(request, decisions: .init())
            XCTAssertEqual(local.task, "APPLICATION")
            let built = try XCTUnwrap(DomainContextBuilder().build(frame: naturalFrame, language: .detect(in: request)))
            XCTAssertFalse(built.entities.isEmpty)
            let questions = AppleUnknownSelector().select([], frame: naturalFrame, findings: [], language: .spanish)
            XCTAssertTrue(questions.first?.hasPrefix("¿") == true)
            XCTAssertFalse(questions.joined().contains("_"))
        }
    }
}
