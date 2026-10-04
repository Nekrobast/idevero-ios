import XCTest
import SwiftData
@testable import Idevero

final class PhysicalV6RemediationTests: XCTestCase {
    private func frame(_ text: String, status: String = "DEFINED") -> SemanticDomainFrame {
        SemanticDomainFrame(primaryJobStatus: status, primaryJobCandidates: [], actors: [], entities: [], relationships: [], workflows: [text], decisions: [], constraints: [], contextItems: [SemanticDomainItem(kind: "WORKFLOW", text: text, epistemicStatus: "ESTABLISHED", decisionRelevance: "HIGH")])
    }

    func testOpenSectorRequestCannotEstablishModelChosenWorkflow() throws {
        for request in ["Quiero crear una app para ceramistas", "Quiero una app para organizar una feria"] {
            let text = "La clasificación semanal de encargos es imprescindible para este oficio"
            let context = DomainContextBuilder().build(frame: frame(text), language: .spanish, originalRequest: request, resolvedTask: "APPLICATION", resolvedDomain: "unknown")
            XCTAssertFalse(context?.calibratedItems?.contains { $0.status == .established && $0.text == text } == true)
            XCTAssertEqual(context?.primaryJobStatus, "UNDERSPECIFIED")
        }
    }

    func testUnconfirmedAppleWorkflowHasConditionalLanguageAndScope() throws {
        let text = "clasificación semanal de encargos"
        let finding = SemanticFinding(concept: text, reason: "Este proceso es esencial para decidir el orden de cada encargo profesional.", lens: "Dominio", semanticRole: "CORE_WORKFLOW", anchor: text)
        let values = AppleDiscoveryMerger(store: try KnowledgeStore.load()).merge(local: [], findings: [finding], request: "Quiero una app para ceramistas", frame: frame(text))
        XCTAssertFalse(values.contains { $0.state == .included })
        XCTAssertFalse(values.contains { $0.reason.contains("es esencial") })
    }

    func testPrimaryQuestionPrecedesDetailsEvenWhenModelClaimsDefined() {
        let selected = AppleUnknownSelector().select([SemanticUnknown(question: "¿Qué herramienta de comunicación se utiliza actualmente?", reason: "Cambia la configuración de una integración operativa posterior.", architectureImpact: "HIGH", workflowImpact: "HIGH", scopeImpact: "HIGH")], frame: frame("clasificación de encargos", status: "UNDERSPECIFIED"), findings: [])
        XCTAssertEqual(selected.count, 1)
        XCTAssertTrue(selected.first?.contains("problema principal") == true)
    }

    func testExplicitTechnicalHoldoutsAreSafeButInternalRolesRemainBlocked() {
        let policy = UserFacingTextPolicy(language: .english)
        for literal in ["CUSTOMER_REFERENCE_KEY", "DEVICE_SERIAL_NUMBER", "X509_CERT_CHAIN"] {
            XCTAssertTrue(policy.isSafeDisplay(literal), literal)
        }
        XCTAssertFalse(policy.isSafeDisplay("CORE_WORKFLOW"))
        XCTAssertFalse(policy.isSafeDisplay("PRIMARY_JOB_A"))
    }

    func testExplicitTechnicalLiteralsSurviveActualLocalCompilation() async throws {
        for literal in ["CUSTOMER_REFERENCE_KEY", "DEVICE_SERIAL_NUMBER", "X509_CERT_CHAIN"] {
            let result = try await LocalExpertProvider().analyze("I want an inventory app using the field \(literal).")
            XCTAssertTrue(result.prompt.contains(literal))
        }
    }

    func testEnglishLocalPipelineHasEnglishOutcomeFindingsAndPlaceholders() async throws {
        let result = try await LocalExpertProvider().analyze("I want to create an app for music tutors to manage lessons and learning plans.")
        XCTAssertFalse(result.outcome.contains("Facilitar"))
        XCTAssertFalse(result.unknowns.joined().contains("USUARIO PRINCIPAL"))
        XCTAssertFalse(result.discoveries.contains { $0.reason.contains("Define") && $0.reason.contains("usuario") })
        XCTAssertFalse(result.prompt.contains("Facilitar"))
        XCTAssertFalse(result.prompt.contains("[ALCANCE INICIAL]"))
    }

    func testSpanishPipelineAndSimpleEmailStaySpanishAndProportionate() async throws {
        let result = try await LocalExpertProvider().analyze("Quiero crear una app para gestionar lecciones")
        XCTAssertTrue(result.outcome.contains("Facilitar"))
        let email = try await LocalExpertProvider().analyze("Escribe un email a mi jefe para pedir vacaciones del 10 al 20 de agosto, educado y directo")
        XCTAssertEqual(email.task, "EMAIL")
        XCTAssertLessThan(email.prompt.count, 700)
    }

    func testMachinePerspectivesUseDisplayLabelsForUnseenIdentifiers() {
        for language in [DisplayLanguage.spanish, .english] {
            for identifier in ["field_service_grid", "clinical_case_index"] {
                let value = DisplayLocalization(language: language).lens(identifier + " · Data")
                XCTAssertFalse(value.contains(identifier))
                XCTAssertFalse(value.contains("_"))
            }
        }
    }

    @MainActor
    func testRealViewModelDecisionsSurvivePersistenceAndMissingReanalysisFindings() async throws {
        let coordinator = IntelligenceCoordinator(foundation: V6ChangingProvider())
        let model = CreateViewModel(coordinator: coordinator)
        model.idea = "Quiero una app para gestionar reparaciones de equipos"
        await model.generate()
        let original = try XCTUnwrap(model.analysis)
        await model.setState(.included, id: "choice-include")
        await model.setState(.excluded, id: "choice-exclude")
        await model.setState(.locked, id: "choice-lock")
        let chosen = try XCTUnwrap(model.analysis)
        XCTAssertTrue(chosen.prompt.contains("adaptación visual entre dispositivos"))
        XCTAssertTrue(chosen.prompt.contains("unidades de trabajo identificables"))
        XCTAssertFalse(chosen.prompt.contains("inicio del proceso"))
        let container = try ModelContainer(for: PromptRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        try PromptRecord.upsert(chosen, in: context)
        try PromptRecord.upsert(chosen, in: context)
        let restored = CreateViewModel(coordinator: coordinator)
        restored.analysis = try context.fetch(FetchDescriptor<PromptRecord>()).first?.reconstructedAnalysis()
        restored.idea = model.idea
        await restored.reanalyze()
        let next = try XCTUnwrap(restored.analysis)
        XCTAssertEqual(next.analysisID, original.analysisID)
        XCTAssertTrue(next.discoveries.contains { $0.concept == "adaptación visual entre dispositivos" && $0.provenance == .userAccepted })
        XCTAssertTrue(next.discoveries.contains { $0.concept == "inicio del proceso" && $0.state == .excluded })
        XCTAssertTrue(next.discoveries.contains { $0.concept == "unidades de trabajo identificables" && $0.provenance == .userLocked })
        XCTAssertTrue(next.prompt.contains("adaptación visual entre dispositivos"))
        XCTAssertTrue(next.prompt.contains("unidades de trabajo identificables"))
        try PromptRecord.upsert(next, in: context)
        XCTAssertEqual(try context.fetch(FetchDescriptor<PromptRecord>()).count, 1)
    }

    @MainActor
    func testRegenerateExposesBusyStateAndRejectsDoubleTap() async throws {
        let local = V6SlowCompiler()
        let model = CreateViewModel(coordinator: IntelligenceCoordinator(local: local, foundation: V6Unavailable()))
        model.analysis = try await LocalExpertProvider().analyze("Quiero una app para gestionar reparaciones")
        let first = Task { await model.regenerate() }
        try await Task.sleep(nanoseconds: 20_000_000)
        XCTAssertTrue(model.isGenerating)
        let second = Task { await model.regenerate() }
        await first.value
        await second.value
        XCTAssertFalse(model.isGenerating)
        XCTAssertEqual(local.calls, 1)
    }

    @MainActor
    func testEquivalentAppleParaphraseRetainsAuthorityWithoutMergingDistinctConcepts() async throws {
        let model = CreateViewModel(coordinator: IntelligenceCoordinator(foundation: V6ParaphraseProvider()))
        model.idea = "Quiero una app para gestionar reparaciones"
        await model.generate()
        await model.setState(.locked, id: "initial")
        await model.reanalyze()
        let values = try XCTUnwrap(model.analysis).discoveries
        XCTAssertEqual(values.filter { $0.state == .locked }.count, 1)
        XCTAssertTrue(values.contains { $0.concept == "Registro histórico de inspecciones de cada unidad" && $0.state == .locked })
        XCTAssertTrue(values.contains { $0.concept == "Calendario comercial" && $0.state != .locked })
    }

    func testExcludedFindingCannotReturnThroughDomainContext() async throws {
        var analysis = try await LocalExpertProvider().analyze("Quiero una app para gestionar reparaciones")
        let text = "historial de inspecciones por unidad"
        analysis.discoveries = [Discovery(id: "excluded", concept: text, reason: "Conserva los estados anteriores de la unidad para comparar intervenciones.", lens: "Datos", priority: .outOfScope, provenance: .appleModel, state: .excluded, dependencies: [], confidence: "HIGH", semanticRole: "CORE_WORKFLOW", anchor: text)]
        analysis.domainContext = DomainContext(language: "es", primaryJobStatus: "DEFINED", primaryJobCandidates: [], actors: [], entities: [], relationships: [], workflows: [text], decisions: [], constraints: [], calibratedItems: [DomainContextItem(kind: "WORKFLOW", text: text, status: .established, decisionRelevance: "HIGH")], lifecycle: .valid)
        XCTAssertFalse(SpecializedCompiler().compile(analysis).contains(text))
    }

    func testActualModelBoundaryOverridesUnfoundedDefinedAndPrioritizesObjective() {
        for request in ["Quiero una app para restauradores", "I want an app for landscape designers"] {
            let language = DisplayLanguage.detect(in: request)
            let validated = frame(language == .spanish ? "clasificación diaria de encargos" : "daily classification of jobs").validated(for: request)
            XCTAssertEqual(validated.primaryJobStatus, "UNDERSPECIFIED")
            let questions = AppleUnknownSelector().select([], frame: validated, findings: [], language: language)
            XCTAssertEqual(questions.count, 1)
            XCTAssertTrue(questions[0].contains(language == .spanish ? "problema principal" : "primary problem"))
        }
    }

    func testExplicitWorkflowEvidenceRemainsUsable() throws {
        let request = "Quiero una app para registrar inspecciones de equipos"
        let text = "registrar inspecciones de equipos"
        let validated = frame(text).validated(for: request)
        XCTAssertEqual(validated.primaryJobStatus, "DEFINED")
        let finding = SemanticFinding(concept: text, reason: "Conserva cada inspección para comparar el estado observado del equipo.", lens: "Dominio", semanticRole: "CORE_WORKFLOW", anchor: text)
        let merged = AppleDiscoveryMerger(store: try KnowledgeStore.load()).merge(local: [], findings: [finding], request: request, frame: validated)
        XCTAssertEqual(merged.first?.state, .included)
    }

    func testUncalibratedModelFrameCannotBypassRequestGrounding() throws {
        var raw = frame("clasificación diaria de encargos")
        raw.contextItems = []
        let validated = raw.validated(for: "Quiero una app para restauradores")
        let finding = SemanticFinding(concept: "clasificación diaria de encargos", reason: "Este proceso es necesario para decidir el orden de los encargos del oficio.", lens: "Dominio", semanticRole: "CORE_WORKFLOW", anchor: "clasificación diaria de encargos")
        let merged = AppleDiscoveryMerger(store: try KnowledgeStore.load()).merge(local: [], findings: [finding], request: "Quiero una app para restauradores", frame: validated)
        XCTAssertEqual(merged.first?.state, .optional)
        XCTAssertEqual(merged.first?.confidence, "LOW")
        XCTAssertFalse(merged.first?.reason.contains("necesario") == true)
    }

    func testAuthoredEnglishCatalogCoversEveryLocalResource() throws {
        let store = try KnowledgeStore.load()
        for strategy in store.strategies {
            XCTAssertNotNil(LocalKnowledgeLocalization.strategyLabels[strategy.id])
            for index in strategy.candidates.indices {
                XCTAssertNotNil(LocalKnowledgeLocalization.candidate(strategy: strategy.id, index: index), "\(strategy.id):\(index)")
            }
        }
        for concept in store.concepts { XCTAssertNotNil(LocalKnowledgeLocalization.conceptReasons[concept.id], concept.id) }
    }

    func testEnglishHoldoutsDoNotLeakSpanishThroughOtherCompilers() async throws {
        for request in ["I want an app to manage tasks", "I need an email requesting a meeting", "I want a spreadsheet to track expenses", "I want to research battery options", "I want to plan a project"] {
            let analysis = try await LocalExpertProvider().analyze(request)
            for forbidden in ["Facilitar", "Resultado esperado", "Criterios y requisitos", "Escribe", "Mantén", "Verificar:", "[USUARIO", "[ALCANCE"] {
                XCTAssertFalse(analysis.prompt.contains(forbidden), request)
            }
            XCTAssertTrue(analysis.discoveries.allSatisfy { UserFacingTextPolicy(language: .english).isSafeDisplay($0.reason) })
        }
    }

    @MainActor
    func testSameRequestGeneratePreservesDecisionsAndDifferentRequestDoesNot() async throws {
        let model = CreateViewModel(coordinator: IntelligenceCoordinator(foundation: V6ChangingProvider()))
        model.idea = "Quiero una app para gestionar reparaciones"
        await model.generate()
        await model.setState(.locked, id: "choice-lock")
        let id = model.analysis?.analysisID
        await model.generate()
        XCTAssertEqual(model.analysis?.analysisID, id)
        XCTAssertTrue(model.analysis?.discoveries.contains { $0.provenance == .userLocked } == true)
        model.idea = "Quiero crear una página web"
        await model.generate()
        XCTAssertNotEqual(model.analysis?.analysisID, id)
        XCTAssertFalse(model.analysis?.discoveries.contains { $0.provenance == .userLocked } == true)
    }

    func testModelGeneratedTechnicalMetadataIsNotUserContent() {
        let text = "CUSTOMER_INTERNAL_ROUTING_LAYER"
        let context = DomainContextBuilder().build(frame: frame(text), language: .english, originalRequest: "I want an app for workshops", resolvedTask: "APPLICATION", resolvedDomain: "unknown")
        XCTAssertFalse(context?.calibratedItems?.contains { $0.text == text } == true)
    }

    func testConditionalWordingAcrossBothLanguages() {
        for text in ["Es imprescindible y debe incorporarse", "Es necesario y esencial", "It is essential and must be included", "It is necessary and mandatory"] {
            let value = EpistemicText.conditional(text)
            XCTAssertNil(value.range(of: "\\b(imprescindible|debe|necesario|esencial|essential|must|necessary|mandatory)\\b", options: [.regularExpression, .caseInsensitive]))
        }
    }

    func testTechnicalNamesAreExecutionConstraintsWhileSchemaStatesRemainInternal() async throws {
        let policy = UserFacingTextPolicy(language: .english)
        for state in DomainKnowledgeStatus.allCases where state.rawValue.contains("_") {
            XCTAssertFalse(policy.isSafeDisplay(state.rawValue))
        }
        let result = try await LocalExpertProvider().analyze("I want an app where each delivery uses DELIVERY_REFERENCE_KEY and each document uses DOCUMENT_TRACE_ID.")
        XCTAssertTrue(result.prompt.contains("Explicit technical literals — preserve exactly"))
        XCTAssertTrue(result.prompt.contains("\n- DELIVERY_REFERENCE_KEY"))
        XCTAssertTrue(result.prompt.contains("\n- DOCUMENT_TRACE_ID"))
    }
}

private actor V6ParaphraseProvider: IntelligenceProvider {
    nonisolated let name = "Equivalent wording fixture"
    private var calls = 0
    func availability() async -> IntelligenceAvailability { .ready }
    func analyze(_ request: String) async throws -> PromptAnalysis {
        calls += 1
        var analysis = try await LocalExpertProvider().analyze(request)
        let concept = calls == 1 ? "Historial de revisiones por unidad" : "Registro histórico de inspecciones de cada unidad"
        analysis.discoveries = [Discovery(id: calls == 1 ? "initial" : "new-id", concept: concept, reason: "Conserva el estado observado para apoyar la siguiente decisión profesional.", lens: "Dominio", priority: .highValue, provenance: .appleModel, state: .included, dependencies: [], confidence: "HIGH", semanticRole: "CORE_WORKFLOW", anchor: "unidad")]
        analysis.discoveries.append(Discovery(id: "distinct", concept: "Calendario comercial", reason: "Organiza acciones comerciales independientes de las inspecciones.", lens: "Contexto", priority: .optional, provenance: .appleModel, state: .optional, dependencies: [], confidence: "MEDIUM", semanticRole: "OPTIONAL_FEATURE", anchor: "unidad"))
        return analysis
    }
}

private actor V6ChangingProvider: IntelligenceProvider {
    nonisolated let name = "V6 deterministic Foundation boundary"
    private var calls = 0
    func availability() async -> IntelligenceAvailability { .ready }
    func analyze(_ request: String) async throws -> PromptAnalysis {
        calls += 1
        var analysis = try await LocalExpertProvider().analyze(request)
        if calls == 1 {
            analysis.discoveries = [
                Discovery(id: "choice-include", concept: "adaptación visual entre dispositivos", reason: "Permite completar el mismo trabajo en pantallas de diferentes tamaños.", lens: "Producto", priority: .optional, provenance: .localKnowledge, state: .optional, dependencies: [], confidence: "MEDIUM"),
                Discovery(id: "choice-exclude", concept: "inicio del proceso", reason: "Define qué acción inicia el flujo seleccionado por el usuario.", lens: "Flujo", priority: .highValue, provenance: .localKnowledge, state: .included, dependencies: [], confidence: "MEDIUM"),
                Discovery(id: "choice-lock", concept: "unidades de trabajo identificables", reason: "Vincula cada intervención con la unidad sobre la que se realiza.", lens: "Datos", priority: .highValue, provenance: .localKnowledge, state: .included, dependencies: [], confidence: "HIGH")
            ]
        } else { analysis.discoveries = [] }
        return analysis
    }
}

private struct V6Unavailable: IntelligenceProvider {
    let name = "Unavailable fixture"
    func availability() async -> IntelligenceAvailability { .unavailable("fixture") }
    func analyze(_ request: String) async throws -> PromptAnalysis { throw IntelligenceError.emptyRequest }
}

private final class V6SlowCompiler: LocalIntelligenceProvider, @unchecked Sendable {
    let name = "Slow deterministic compiler"
    private let lock = NSLock()
    private var count = 0
    var calls: Int { lock.lock(); defer { lock.unlock() }; return count }
    func availability() async -> IntelligenceAvailability { .ready }
    func analyze(_ request: String) async throws -> PromptAnalysis { try await LocalExpertProvider().analyze(request) }
    func analyze(_ request: String, decisions: DiscoveryDecisions) throws -> PromptAnalysis { try LocalExpertProvider().analyze(request, decisions: decisions) }
    func recompile(_ analysis: PromptAnalysis) throws -> PromptAnalysis {
        lock.lock(); count += 1; lock.unlock()
        Thread.sleep(forTimeInterval: 0.15)
        return try LocalExpertProvider().recompile(analysis)
    }
}
