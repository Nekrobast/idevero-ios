import XCTest
import SwiftData
@testable import Idevero

/// Frozen 0.2.7 reproductions for the pre-0.2.8 audit.
///
/// A failing assertion is intentional when it captures a confirmed defect.
/// Skipped cases identify missing test seams; they are not simulated failures.
final class Pre028RedReproductionTests: XCTestCase {
    private let provider = LocalExpertProvider()

    private func appleDiscovery(
        id: String = "APPLE_FIXTURE",
        concept: String = "Historial operativo por unidad",
        state: DiscoveryState,
        priority: RequirementPriority
    ) -> Discovery {
        Discovery(
            id: id,
            concept: concept,
            reason: "Relaciona cada revisión con el estado observado para apoyar la siguiente decisión profesional.",
            lens: "Flujo del dominio",
            priority: priority,
            provenance: .appleModel,
            state: state,
            dependencies: [],
            confidence: "HIGH",
            sourceProvenance: [.appleModel],
            semanticRole: SemanticRole.coreWorkflow.rawValue,
            anchor: "revisión periódica"
        )
    }

    private func applicationAnalysis(
        input: String = "Quiero una app para profesionales",
        discoveries: [Discovery]
    ) async throws -> PromptAnalysis {
        let base = try await provider.analyze(input)
        return PromptAnalysis(
            analysisID: base.analysisID,
            title: base.title,
            input: base.input,
            task: "APPLICATION",
            intent: base.intent,
            domain: base.domain,
            secondaryDomains: base.secondaryDomains,
            target: base.target,
            outcome: base.outcome,
            elaboration: base.elaboration,
            discoveries: discoveries,
            unknowns: base.unknowns,
            prompt: SpecializedCompiler().compile(base),
            qualityNotes: base.qualityNotes,
            intelligenceMode: base.intelligenceMode,
            analyzedAt: base.analyzedAt,
            domainContext: base.domainContext
        )
    }

    private func domainFrame(
        candidates: [String] = [],
        entities: [String] = ["unidad gestionada"],
        items: [SemanticDomainItem] = []
    ) -> SemanticDomainFrame {
        SemanticDomainFrame(
            primaryJobStatus: "UNDERSPECIFIED",
            primaryJobCandidates: candidates,
            actors: ["profesional responsable"],
            entities: entities,
            relationships: ["cada unidad conserva su historial"],
            workflows: ["revisión periódica de cada unidad"],
            decisions: ["decidir la siguiente intervención"],
            constraints: [],
            contextItems: items
        )
    }

    // 01 — RED CONFIRMED: UI state changes but the optional priority still excludes compilation.
    @MainActor
    func test01OptionalToIncludedMustAppearInCompiledPrompt() async throws {
        let finding = appleDiscovery(state: .optional, priority: .optional)
        let model = CreateViewModel()
        model.analysis = try await applicationAnalysis(discoveries: [finding])
        await model.setState(.included, id: finding.id)
        XCTAssertTrue(try XCTUnwrap(model.analysis).prompt.contains(finding.concept))
    }

    // 02 — RED CONFIRMED: OUT OF SCOPE priority survives EXCLUDED → INCLUDED.
    @MainActor
    func test02ExcludedToIncludedMustReturnToCompiledPrompt() async throws {
        let finding = appleDiscovery(state: .excluded, priority: .outOfScope)
        let model = CreateViewModel()
        model.analysis = try await applicationAnalysis(discoveries: [finding])
        await model.setState(.included, id: finding.id)
        XCTAssertTrue(try XCTUnwrap(model.analysis).prompt.contains(finding.concept))
    }

    // 03 — ALREADY PASSING.
    @MainActor
    func test03IncludedToExcludedMustDisappearFromCompiledPrompt() async throws {
        let finding = appleDiscovery(state: .included, priority: .highValue)
        let model = CreateViewModel()
        model.analysis = try await applicationAnalysis(discoveries: [finding])
        await model.setState(.excluded, id: finding.id)
        XCTAssertFalse(try XCTUnwrap(model.analysis).prompt.contains(finding.concept))
    }

    // 04 — Phase 2 target: a stale provider result never owns visible state.
    @MainActor
    func test04OlderSlowGenerationCannotOverwriteNewerGeneration() async throws {
        let provider = DeterministicDelayedProvider(delays: ["Generation A": 220_000_000, "Generation B": 20_000_000])
        let model = CreateViewModel(coordinator: IntelligenceCoordinator(foundation: provider))
        model.idea = "Generation A"
        let first = Task { await model.generate() }
        try await Task.sleep(nanoseconds: 20_000_000)
        model.idea = "Generation B"
        let second = Task { await model.generate() }
        await second.value
        await first.value
        XCTAssertEqual(model.analysis?.input, "Generation B")
        XCTAssertEqual(model.analysis?.prompt, "Result for Generation B")
    }

    // 05 — Phase 2 target: cancellation is enforced by generation authority even
    // when the provider deliberately ignores cooperative cancellation.
    @MainActor
    func test05CancelledGenerationCannotMutateLaterState() async throws {
        let provider = DeterministicDelayedProvider(delays: ["Cancelled A": 220_000_000, "Current B": 20_000_000])
        let model = CreateViewModel(coordinator: IntelligenceCoordinator(foundation: provider))
        model.idea = "Cancelled A"
        let first = Task { await model.generate() }
        try await Task.sleep(nanoseconds: 20_000_000)
        first.cancel()
        model.idea = "Current B"
        let second = Task { await model.generate() }
        await second.value
        await first.value
        XCTAssertEqual(model.analysis?.input, "Current B")
        XCTAssertEqual(model.analysis?.prompt, "Result for Current B")
        XCTAssertNil(model.errorMessage)
    }

    // 06 — RED CONFIRMED: rejected calibrated items become nil, so compiler resurrects raw frame arrays.
    func test06RejectedDomainFrameCannotResurrectWhenCalibratedItemsAreEmpty() async throws {
        let rejected = SemanticDomainItem(
            kind: "ENTITY",
            text: "expansión comercial periférica",
            epistemicStatus: "UNSUPPORTED",
            decisionRelevance: "HIGH"
        )
        let context = try XCTUnwrap(
            DomainContextBuilder().build(
                frame: domainFrame(entities: ["expansión comercial periférica"], items: [rejected]),
                language: .spanish
            )
        )
        var analysis = try await provider.analyze("Quiero una app para profesionales")
        analysis.domainContext = context
        let prompt = SpecializedCompiler().compile(analysis)
        XCTAssertFalse(prompt.localizedCaseInsensitiveContains("expansión comercial periférica"))
    }

    // 07 — RED CONFIRMED: two Save actions create two unrelated records.
    @MainActor
    func test07RepeatedSaveOfSameAnalysisMustNotCreateDuplicates() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PromptRecord.self, configurations: configuration)
        let context = ModelContext(container)
        let analysis = try await provider.analyze("Excel para controlar stock")
        context.insert(PromptRecord(analysis: analysis))
        context.insert(PromptRecord(analysis: analysis))
        try context.save()
        XCTAssertEqual(try context.fetch(FetchDescriptor<PromptRecord>()).count, 1)
    }

    // 08 — ALREADY PASSING at model level: corrupt snapshots use an explicit recovery note.
    func test08CorruptSnapshotRecoveryIsNotSilentInTheRecoveredAnalysis() async throws {
        let analysis = try await provider.analyze("app para controlar gastos")
        let record = PromptRecord(analysis: analysis)
        record.analysisData = Data("{not-json".utf8)
        let recovered = record.reconstructedAnalysis()
        XCTAssertTrue(recovered.qualityNotes.contains { $0.localizedCaseInsensitiveContains("Registro anterior") })
    }

    // 09 — ALREADY PASSING for stable local IDs.
    func test09LocksSurviveRegenerateAndReanalyzeContract() async throws {
        var analysis = try await provider.analyze("app para controlar gastos")
        let id = try XCTUnwrap(analysis.discoveries.first?.id)
        analysis.discoveries[0].state = .locked
        analysis.discoveries[0].priority = .core
        analysis.discoveries[0].provenance = .userLocked
        let regenerated = try provider.recompile(analysis)
        let reanalyzed = try provider.analyze(analysis.input, decisions: .init(locked: [id]))
        XCTAssertEqual(regenerated.discoveries.first { $0.id == id }?.state, .locked)
        XCTAssertEqual(reanalyzed.discoveries.first { $0.id == id }?.state, .locked)
    }

    // 10 — ALREADY PASSING for exact Apple concepts because their ID is order-independent.
    func test10ExclusionIdentityIsStableAcrossAppleFindingOrder() throws {
        let store = try KnowledgeStore.load()
        let deduplicator = LocalSemanticDeduplicator(store: store)
        let first = try XCTUnwrap(deduplicator.appleDiscovery(index: 0, concept: "Historial operativo por unidad", reason: "Razón suficiente para crear un hallazgo estable.", lens: "Dominio", existing: []))
        let later = try XCTUnwrap(deduplicator.appleDiscovery(index: 9, concept: "Historial operativo por unidad", reason: "Otra razón suficiente para el mismo hallazgo.", lens: "Dominio", existing: []))
        XCTAssertEqual(first.id, later.id)
        let decisions = DiscoveryDecisions(excluded: [first.id])
        XCTAssertTrue(decisions.excluded.contains(later.id))
    }

    // 11 — RED CONFIRMED: equivalent Apple wording has no durable semantic identity.
    func test11AcceptanceSurvivesSemanticallyEquivalentAppleWording() throws {
        let deduplicator = LocalSemanticDeduplicator(store: try KnowledgeStore.load())
        let accepted = try XCTUnwrap(deduplicator.appleDiscovery(index: 0, concept: "Historial de revisiones por unidad", reason: "Conserva las revisiones realizadas para apoyar decisiones posteriores.", lens: "Dominio", existing: []))
        let equivalent = try XCTUnwrap(deduplicator.appleDiscovery(index: 1, concept: "Registro histórico de inspecciones de cada unidad", reason: "Mantiene las inspecciones previas para orientar la siguiente decisión.", lens: "Dominio", existing: []))
        let decisions = DiscoveryDecisions(accepted: [accepted.id])
        XCTAssertTrue(decisions.accepted.contains(equivalent.id))
    }

    // 12 — ALREADY PASSING.
    func test12MachineTokenDetectorBlocksInternalTokens() {
        let policy = UserFacingTextPolicy(language: .english)
        for token in ["PRIMARY_JOB_A", "DECISION_INPUT", "OPTIONAL_FEATURE"] {
            XCTAssertFalse(policy.isSafeDisplay(token), token)
        }
    }

    // 13 — RED CONFIRMED: the current detector rejects legitimate technical identifiers too.
    func test13MachineTokenDetectorAllowsLegitimateTechnicalIdentifiers() {
        let policy = UserFacingTextPolicy(language: .english)
        for identifier in ["SKU_ID", "VAT_ID", "HL7_FHIR", "ISO_27001"] {
            XCTAssertTrue(policy.isSafeDisplay(identifier), identifier)
        }
    }

    // 14 — ALREADY PASSING for exact/case-insensitive duplicates.
    func test14DuplicateEntitiesAreDetected() throws {
        let context = try XCTUnwrap(
            DomainContextBuilder().build(
                frame: domainFrame(entities: ["Colmena", "colmena", "Producto"]),
                language: .spanish
            )
        )
        XCTAssertEqual(context.entities.filter { $0.localizedCaseInsensitiveCompare("Colmena") == .orderedSame }.count, 1)
    }

    // 15 — Domain drift is rejected using request/task/domain grounding.
    func test15DomainDriftFixtureRequiresRequestGroundedValidation() throws {
        let context = try XCTUnwrap(DomainContextBuilder().build(
            frame: domainFrame(entities: ["unidad profesional", "producto", "material ajeno"]),
            language: .spanish,
            originalRequest: "Quiero una app para profesionales de inspección",
            resolvedTask: "APPLICATION",
            resolvedDomain: "INSPECTION SERVICES"
        ))
        XCTAssertFalse(context.entities.contains("material ajeno"))
    }

    // 16 — RED CONFIRMED: a syntactically natural but domain-drifted job is accepted.
    func test16PrimaryJobDriftIsRejected() throws {
        let drifted = "Gestionar la producción de abonos"
        let context = try XCTUnwrap(
            DomainContextBuilder().build(
                frame: domainFrame(
                    candidates: [drifted, "Planificar la distribución de productos"],
                    entities: ["Colmena", "Producto", "Abono"]
                ),
                language: .spanish,
                originalRequest: "Quiero crear una app para profesionales",
                resolvedTask: "APPLICATION",
                resolvedDomain: "PROFESSIONAL SERVICES"
            )
        )
        XCTAssertFalse(context.primaryJobCandidates.contains(drifted))
    }

    // 17 — RED CONFIRMED: model-calibrated ESTABLISHED is rendered as reliable knowledge.
    func test17ModelInferenceIsNotPresentedAsConfirmedReliableKnowledge() async throws {
        let context = DomainContext(
            language: "es",
            primaryJobStatus: "UNDERSPECIFIED",
            primaryJobCandidates: [],
            actors: [],
            entities: [],
            relationships: [],
            workflows: [],
            decisions: [],
            constraints: [],
            calibratedItems: [
                DomainContextItem(
                    kind: "ENTITY",
                    text: "unidad operativa",
                    status: .established,
                    decisionRelevance: "HIGH"
                )
            ]
        )
        var analysis = try await provider.analyze("Quiero una app para profesionales")
        analysis.domainContext = context
        XCTAssertFalse(SpecializedCompiler().compile(analysis).contains("Conocimiento sectorial fiable"))
    }

    // 18 — RED CONFIRMED: short English display text bypasses the language gate.
    func test18SpanishInputDoesNotExposeUnjustifiedEnglishDisplayText() async throws {
        let context = DomainContext(
            language: "es",
            primaryJobStatus: "UNDERSPECIFIED",
            primaryJobCandidates: [],
            actors: [],
            entities: [],
            relationships: [],
            workflows: [],
            decisions: [],
            constraints: [],
            calibratedItems: [
                DomainContextItem(kind: "CONSTRAINT", text: "Seasonal capacity limits", status: .established, decisionRelevance: "HIGH")
            ]
        )
        var analysis = try await provider.analyze("Quiero una app para profesionales")
        analysis.domainContext = context
        XCTAssertFalse(SpecializedCompiler().compile(analysis).contains("Seasonal capacity limits"))
    }

    // 19 — RED CONFIRMED: short Spanish display text bypasses the English language gate.
    func test19EnglishInputDoesNotExposeUnjustifiedSpanishDisplayText() async throws {
        let context = DomainContext(
            language: "en",
            primaryJobStatus: "UNDERSPECIFIED",
            primaryJobCandidates: [],
            actors: [],
            entities: [],
            relationships: [],
            workflows: [],
            decisions: [],
            constraints: [],
            calibratedItems: [
                DomainContextItem(kind: "ENTITY", text: "Estado operativo", status: .established, decisionRelevance: "HIGH")
            ]
        )
        var analysis = try await provider.analyze("I want an app for independent electricians")
        analysis.domainContext = context
        XCTAssertFalse(SpecializedCompiler().compile(analysis).contains("Estado operativo"))
    }

    // 20 — ALREADY PASSING.
    func test20LegacyHistoryWithoutDomainContextStillDecodes() async throws {
        let analysis = try await provider.analyze("app para controlar gastos")
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(analysis)) as? [String: Any])
        object.removeValue(forKey: "domainContext")
        let decoded = try JSONDecoder().decode(PromptAnalysis.self, from: JSONSerialization.data(withJSONObject: object))
        XCTAssertNil(decoded.domainContext)
        XCTAssertEqual(decoded.input, analysis.input)
    }

    // 21 — ALREADY PASSING: local provider remains a complete independent path.
    func test21LocalOnlyFallbackPathProducesAUsablePrompt() async throws {
        let result = try await provider.analyze("Quiero crear una app para profesionales")
        XCTAssertEqual(result.intelligenceMode, "LOCAL EXPERT")
        XCTAssertEqual(result.task, "APPLICATION")
        XCTAssertFalse(result.prompt.isEmpty)
    }

    // 22 — ALREADY PASSING.
    func test22AppleMergePreservesAppleProvenance() throws {
        let frame = domainFrame()
        let finding = SemanticFinding(
            concept: "Historial de revisiones por unidad",
            reason: "Relaciona cada revisión con el estado observado para decidir la siguiente intervención profesional.",
            lens: "Dominio",
            semanticRole: "CORE_WORKFLOW",
            anchor: "revisión periódica de cada unidad",
            domainSpecificity: "HIGH",
            professionalRelevance: "HIGH",
            domainMechanism: "la revisión periódica de cada unidad determina la siguiente intervención"
        )
        let merged = AppleDiscoveryMerger(store: try KnowledgeStore.load()).merge(
            local: [],
            findings: [finding],
            request: "Quiero una app para profesionales",
            frame: frame
        )
        let discovery = try XCTUnwrap(merged.first)
        XCTAssertEqual(discovery.provenance, .appleModel)
        XCTAssertTrue(discovery.sourceProvenance?.contains(.appleModel) == true)
    }

    // 23 — RED CONFIRMED: stable suffix is lexical, not semantic.
    func test23SemanticallyEquivalentAppleFindingsHaveStableIdentity() throws {
        let deduplicator = LocalSemanticDeduplicator(store: try KnowledgeStore.load())
        let first = try XCTUnwrap(deduplicator.appleDiscovery(index: 0, concept: "Historial de revisiones por unidad", reason: "Conserva cada revisión para apoyar decisiones posteriores.", lens: "Dominio", existing: []))
        let second = try XCTUnwrap(deduplicator.appleDiscovery(index: 0, concept: "Registro histórico de inspecciones de cada unidad", reason: "Mantiene inspecciones previas para orientar la siguiente decisión.", lens: "Dominio", existing: []))
        XCTAssertEqual(first.id, second.id)
    }

    // 24 — ALREADY PASSING structurally; test 06 captures the unsafe compiler semantics.
    func test24AbsentEmptyRejectedAndValidDomainFramesHaveDistinctFixtures() throws {
        let absent: DomainContext? = nil
        let empty = DomainContext(
            language: "es", primaryJobStatus: "DEFINED", primaryJobCandidates: [],
            actors: [], entities: [], relationships: [], workflows: [], decisions: [], constraints: [],
            calibratedItems: []
        )
        let rejected = try XCTUnwrap(
            DomainContextBuilder().build(
                frame: domainFrame(
                    entities: ["expansión periférica"],
                    items: [SemanticDomainItem(kind: "ENTITY", text: "expansión periférica", epistemicStatus: "UNSUPPORTED", decisionRelevance: "HIGH")]
                ),
                language: .spanish
            )
        )
        let valid = try XCTUnwrap(
            DomainContextBuilder().build(
                frame: domainFrame(
                    items: [SemanticDomainItem(kind: "ENTITY", text: "unidad operativa", epistemicStatus: "ESTABLISHED", decisionRelevance: "HIGH")]
                ),
                language: .spanish
            )
        )
        XCTAssertNil(absent)
        XCTAssertEqual(empty.calibratedItems, [])
        XCTAssertEqual(empty.resolvedLifecycle, .empty)
        XCTAssertNil(rejected.calibratedItems)
        XCTAssertEqual(rejected.resolvedLifecycle, .rejected)
        XCTAssertEqual(valid.calibratedItems?.count, 1)
        XCTAssertEqual(valid.resolvedLifecycle, .valid)
    }
}

private actor DeterministicDelayedProvider: IntelligenceProvider {
    nonisolated let name = "Deterministic delayed provider"
    private let delays: [String: UInt64]

    init(delays: [String: UInt64]) {
        self.delays = delays
    }

    func availability() async -> IntelligenceAvailability { .ready }

    func analyze(_ request: String) async throws -> PromptAnalysis {
        let delay = delays[request] ?? 0
        let slice: UInt64 = 10_000_000
        var elapsed: UInt64 = 0
        while elapsed < delay {
            try? await Task.sleep(nanoseconds: min(slice, delay - elapsed))
            elapsed += slice
        }
        return PromptAnalysis(
            analysisID: UUID(),
            title: request,
            input: request,
            task: "GENERAL",
            intent: "CREATE",
            domain: "unknown",
            secondaryDomains: [],
            target: "CHATGPT",
            outcome: request,
            elaboration: .light,
            discoveries: [],
            unknowns: [],
            prompt: "Result for \(request)",
            qualityNotes: [],
            intelligenceMode: "TEST",
            analyzedAt: .now
        )
    }
}
