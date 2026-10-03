import XCTest
import SwiftData
@testable import Idevero

final class ReleaseCandidateTests: XCTestCase {
    private let local = LocalExpertProvider()

    func testDiscoveryControlTransitionMatrixAffectsCompilation() async throws {
        let states: [(DiscoveryState, DiscoveryState, Bool)] = [
            (.optional, .included, true), (.excluded, .included, true),
            (.included, .excluded, false), (.locked, .locked, true)
        ]
        for (initial, target, expected) in states {
            let discovery = Discovery(id: "matrix-\(initial.rawValue)", concept: "Historial operativo", reason: "Conserva decisiones previas.", lens: "Operación", priority: initial == .excluded ? .outOfScope : .optional, provenance: .localKnowledge, state: initial, dependencies: [], confidence: "HIGH")
            var analysis = try await local.analyze("app para controlar operaciones")
            analysis.discoveries = [DiscoverySemantics.transition(discovery, to: target)]
            XCTAssertEqual(try local.recompile(analysis).prompt.contains(discovery.concept), expected, "\(initial) → \(target)")
        }
    }

    @MainActor
    func testPersistedAnalysisUpgradeRoundTripIsIdempotent() async throws {
        let container = try ModelContainer(for: PromptRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        var analysis = try await local.analyze("Excel para controlar stock")
        analysis.discoveries[0] = DiscoverySemantics.transition(try XCTUnwrap(analysis.discoveries.first), to: .locked)
        _ = try PromptRecord.upsert(analysis, in: context)
        _ = try PromptRecord.upsert(analysis, in: context)
        let records = try context.fetch(FetchDescriptor<PromptRecord>())
        XCTAssertEqual(records.count, 1)
        let restored = try XCTUnwrap(records.first).reconstructedAnalysis()
        XCTAssertEqual(restored.analysisID, analysis.analysisID)
        XCTAssertEqual(restored.discoveries.first?.state, .locked)
        XCTAssertEqual(restored.prompt, analysis.prompt)
    }

    func testLegacy027SnapshotWithoutDomainContextDecodesAndRecompiles() async throws {
        let source = try await local.analyze("Quiero una app sencilla")
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(source)) as? [String: Any])
        json.removeValue(forKey: "domainContext")
        let restored = try JSONDecoder().decode(PromptAnalysis.self, from: JSONSerialization.data(withJSONObject: json))
        XCTAssertNil(restored.domainContext)
        XCTAssertEqual(restored.analysisID, source.analysisID)
        XCTAssertFalse(try local.recompile(restored).prompt.isEmpty)
    }

    func testLocalExpertOfflineRegressionMatrix() throws {
        let requests = ["Quiero una app para organizar gastos", "web para restaurante", "email corto de agradecimiento", "investiga un smartphone por 500 euros", "mejora este texto", "Excel para controlar stock", "mejora mi aplicación existente usando ChatGPT Work", "mensaje breve para mi jefe"]
        let results = try requests.map { try local.analyze($0, decisions: .init()) }
        XCTAssertEqual(results.count, requests.count)
        XCTAssertTrue(results.allSatisfy { !$0.prompt.isEmpty && $0.intelligenceMode == "LOCAL EXPERT" })
        XCTAssertEqual(results[2].task, "EMAIL")
        XCTAssertEqual(results[5].task, "SPREADSHEET")
        XCTAssertEqual(results[6].target, "CHATGPT WORK")
    }

    // Separate release holdout: 12 category-driven requests; no exact-output matching.
    func testReleaseHoldoutTwelveDiverseRequests() throws {
        let requests = [
            "Quiero crear una app para profesionales",
            "Quiero crear una app para técnicos de mantenimiento industrial",
            "Escribe un email breve de agradecimiento",
            "Crea una web para un restaurante",
            "Investiga opciones de aislamiento térmico para una vivienda",
            "Analiza una hoja de cálculo de ventas y resume tendencias",
            "Build a simple website for a local bakery",
            "Integra HL7_FHIR e ISO_27001 en el diseño técnico",
            "Relaciona SKU_ID y VAT_ID sin exponer tokens internos",
            "logo",
            "Crea una app y una web para gestionar reservas",
            "Mejora mi aplicación existente sin rehacer su arquitectura"
        ]
        let results = try requests.map { try local.analyze($0, decisions: .init()) }
        XCTAssertEqual(results.count, 12)
        XCTAssertTrue(results.allSatisfy { !$0.prompt.isEmpty && !$0.task.isEmpty && !$0.intent.isEmpty })
        XCTAssertGreaterThan(Set(results.map(\.task)).count, 5)
        XCTAssertTrue(results.allSatisfy { $0.unknowns.count <= 3 })
    }

    func testDisplayAndEpistemicSafetyInCompiledDomainContext() async throws {
        var analysis = try await local.analyze("Quiero una app para profesionales")
        analysis.domainContext = DomainContext(language: "es", primaryJobStatus: "UNDERSPECIFIED", primaryJobCandidates: [], actors: [], entities: [], relationships: [], workflows: [], decisions: [], constraints: [], calibratedItems: [DomainContextItem(kind: "ENTITY", text: "unidad operativa", status: .established, decisionRelevance: "HIGH")], lifecycle: .valid)
        let prompt = SpecializedCompiler().compile(analysis)
        XCTAssertFalse(prompt.contains("Conocimiento sectorial fiable"))
        XCTAssertFalse(prompt.contains("PRIMARY_JOB_A"))
        XCTAssertTrue(prompt.contains("conviene validar"))
    }
}

@MainActor
final class ReleaseConcurrencyStressTests: XCTestCase {
    func testLatestOfManyOverlappingGenerationsOwnsState() async {
        let model = CreateViewModel(coordinator: IntelligenceCoordinator(foundation: RCOrderedProvider()))
        var tasks: [Task<Void, Never>] = []
        for index in 0..<8 {
            model.idea = "request-\(index)"
            tasks.append(Task { await model.generate() })
            try? await Task.sleep(nanoseconds: 2_000_000)
        }
        for task in tasks { await task.value }
        XCTAssertEqual(model.analysis?.input, "request-7")
        XCTAssertEqual(model.analysis?.prompt, "result-request-7")
        XCTAssertFalse(model.isGenerating)
    }

    func testCancelledSupersededGenerationCannotRestoreErrorOrResult() async {
        let model = CreateViewModel(coordinator: IntelligenceCoordinator(foundation: RCOrderedProvider()))
        model.idea = "request-0"
        let old = Task { await model.generate() }
        try? await Task.sleep(nanoseconds: 3_000_000)
        old.cancel()
        model.idea = "request-7"
        await model.generate()
        await old.value
        XCTAssertEqual(model.analysis?.input, "request-7")
        XCTAssertNil(model.errorMessage)
    }

    func testNewerSlowGenerationRetainsAuthorityAfterOlderFastResult() async {
        let model = CreateViewModel(coordinator: IntelligenceCoordinator(foundation: RCOrderedProvider()))
        model.idea = "request-7"
        let oldFast = Task { await model.generate() }
        try? await Task.sleep(nanoseconds: 3_000_000)
        model.idea = "request-0"
        let currentSlow = Task { await model.generate() }
        await oldFast.value
        await currentSlow.value
        XCTAssertEqual(model.analysis?.input, "request-0")
        XCTAssertEqual(model.analysis?.prompt, "result-request-0")
    }

    func testReanalysisInvalidatesAnEarlierGeneration() async {
        let model = CreateViewModel(coordinator: IntelligenceCoordinator(foundation: RCOrderedProvider()))
        model.idea = "request-0"
        let staleGeneration = Task { await model.generate() }
        try? await Task.sleep(nanoseconds: 3_000_000)
        model.idea = "request-7"
        await model.reanalyze()
        await staleGeneration.value
        XCTAssertEqual(model.analysis?.input, "request-7")
        XCTAssertEqual(model.analysis?.prompt, "result-request-7")
        XCTAssertNil(model.errorMessage)
    }
}

private actor RCOrderedProvider: IntelligenceProvider {
    nonisolated let name = "RC deterministic provider"
    func availability() async -> IntelligenceAvailability { .ready }
    func analyze(_ request: String) async throws -> PromptAnalysis {
        let index = Int(request.split(separator: "-").last ?? "0") ?? 0
        try? await Task.sleep(nanoseconds: UInt64(max(0, 8 - index)) * 8_000_000)
        return PromptAnalysis(analysisID: UUID(), title: request, input: request, task: "GENERAL", intent: "CREATE", domain: "unknown", secondaryDomains: [], target: "CHATGPT", outcome: request, elaboration: .light, discoveries: [], unknowns: [], prompt: "result-\(request)", qualityNotes: [], intelligenceMode: "TEST", analyzedAt: .now)
    }
}
