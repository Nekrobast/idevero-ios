import XCTest
import Combine
@testable import Idevero

final class PhysicalV6TargetedTests: XCTestCase {
    private func frame(_ jobs: [String]) -> SemanticDomainFrame {
        SemanticDomainFrame(primaryJobStatus: "UNDERSPECIFIED", primaryJobCandidates: jobs, actors: [], entities: [], relationships: [], workflows: jobs, decisions: [], constraints: [], contextItems: jobs.map { SemanticDomainItem(kind: "WORKFLOW", text: $0, epistemicStatus: "ESTABLISHED", decisionRelevance: "HIGH") })
    }

    func testBroadDomainCannotUseModelCandidatesAsIndependentEvidence() throws {
        for (request, jobs) in [
            ("Quiero una app para encuadernadores", ["Gestionar encargos de encuadernación", "Planificar entregas de libros"]),
            ("I want an app for costume designers", ["Manage costume orders", "Track costume deliveries"])
        ] {
            let validated = frame(jobs).validated(for: request)
            let context = try XCTUnwrap(DomainContextBuilder().build(frame: validated, language: .detect(in: request), originalRequest: request, resolvedTask: "APPLICATION", resolvedDomain: "unknown"))
            XCTAssertTrue(context.primaryJobCandidates.isEmpty)
            let question = AppleUnknownSelector().select([], frame: validated, findings: [], language: .detect(in: request)).joined()
            for job in jobs { XCTAssertFalse(question.contains(job), question) }
        }
    }

    func testOneExplicitWorkflowDoesNotAuthorizeASecondInventedAlternative() throws {
        let request = "Quiero una app para registrar préstamos de instrumentos"
        let jobs = ["Registrar préstamos de instrumentos", "Planificar conciertos de instrumentos"]
        let validated = frame(jobs).validated(for: request)
        let question = AppleUnknownSelector().select([], frame: validated, findings: []).joined()
        XCTAssertFalse(question.contains(jobs[1]))
        XCTAssertFalse(question.contains(";"))
        let context = try XCTUnwrap(DomainContextBuilder().build(frame: validated, language: .spanish, originalRequest: request))
        XCTAssertTrue(context.primaryJobCandidates.isEmpty)
    }

    func testTwoExplicitObjectivesRemainAvailableInBothLanguages() throws {
        for (request, jobs) in [
            ("Quiero una app para gestionar préstamos y gestionar devoluciones", ["Gestionar los préstamos", "Gestionar las devoluciones"]),
            ("I want an app to manage loans and manage returns", ["Manage the loans", "Manage the returns"])
        ] {
            let validated = frame(jobs).validated(for: request)
            let context = try XCTUnwrap(DomainContextBuilder().build(frame: validated, language: .detect(in: request), originalRequest: request))
            XCTAssertEqual(context.primaryJobCandidates.count, 2)
            let question = AppleUnknownSelector().select([], frame: validated, findings: [], language: .detect(in: request)).joined()
            for job in jobs { XCTAssertTrue(question.contains(job)) }
        }
    }

    func testSharedSectorAndVerbCannotGroundAnInventedObjective() {
        let request = "I want an app to manage laboratory bookings"
        let invented = "Manage laboratory purchasing"
        let validated = frame(["Manage laboratory bookings", invented]).validated(for: request)
        XCTAssertFalse(validated.primaryJobCandidates.contains(invented))
    }

    func testEquivalentWordingDoesNotCreateTwoDistinctPriorityChoices() {
        let request = "Quiero una app para registrar préstamos y gestionar devoluciones"
        let jobs = ["Registrar préstamos", "Registrar los préstamos"]
        let validated = frame(jobs).validated(for: request)
        let question = AppleUnknownSelector().select([], frame: validated, findings: []).joined()
        XCTAssertFalse(question.contains(";"))
    }

    func testUntrustedPrimaryQuestionCannotBypassTheValidatedOptions() {
        let request = "I want an app for archivists"
        let raw = SemanticUnknown(question: "Which primary job matters: manage sales or track deliveries?", reason: "This decision changes the complete scope of the application.", architectureImpact: "HIGH", workflowImpact: "HIGH", scopeImpact: "HIGH", level: "PRIMARY_JOB")
        let question = AppleUnknownSelector().select([raw], frame: frame([]).validated(for: request), findings: [], language: .english).joined()
        XCTAssertFalse(question.contains("sales"))
        XCTAssertFalse(question.contains("deliveries"))
    }

    func testRecompileUsesAcceptedAndLockedWorkflowAuthorityButNotAppleSelfClaims() async throws {
        var analysis = try await LocalExpertProvider().analyze("Quiero una app para una biblioteca musical")
        let jobs = ["Registrar préstamos de instrumentos", "Gestionar devoluciones de instrumentos", "Planificar conciertos de instrumentos"]
        analysis.discoveries = jobs.enumerated().map { index, job in
            Discovery(id: "authority-\(index)", concept: job, reason: "Determina la operación que el usuario ha elegido para su aplicación.", lens: "Flujo", priority: .highValue, provenance: index == 0 ? .userAccepted : index == 1 ? .userLocked : .appleModel, state: index == 1 ? .locked : .included, dependencies: [], confidence: "HIGH", semanticRole: "CORE_WORKFLOW", anchor: job)
        }
        analysis.domainContext = DomainContext(language: "es", primaryJobStatus: "UNDERSPECIFIED", primaryJobCandidates: jobs, actors: [], entities: [], relationships: [], workflows: [], decisions: [], constraints: [])
        analysis.unknowns = ["¿Qué trabajo principal: \(jobs.joined(separator: "; "))?"]
        let rebuilt = try LocalExpertProvider().recompile(analysis)
        XCTAssertEqual(rebuilt.domainContext?.primaryJobCandidates, Array(jobs.prefix(2)))
        XCTAssertFalse(rebuilt.unknowns.joined().contains(jobs[2]))
        XCTAssertEqual(rebuilt.discoveries[0].provenance, .userAccepted)
        XCTAssertEqual(rebuilt.discoveries[1].state, .locked)
    }

    func testUnconfirmedWorkflowIsNotPriorityAuthorityAndExcludedChoiceStaysExcluded() async throws {
        var analysis = try await LocalExpertProvider().analyze("I want an app for archivists")
        let jobs = ["Manage manuscript deliveries", "Track manuscript purchases"]
        analysis.discoveries = jobs.enumerated().map { index, job in
            Discovery(id: "untrusted-\(index)", concept: job, reason: "This workflow could change the operation of the archive.", lens: "Domain", priority: .optional, provenance: index == 0 ? .appleModel : .userAccepted, state: index == 0 ? .included : .excluded, dependencies: [], confidence: "HIGH", semanticRole: "CORE_WORKFLOW", anchor: job)
        }
        analysis.domainContext = DomainContext(language: "en", primaryJobStatus: "UNDERSPECIFIED", primaryJobCandidates: jobs, actors: [], entities: [], relationships: [], workflows: [], decisions: [], constraints: [])
        let rebuilt = try LocalExpertProvider().recompile(analysis)
        XCTAssertTrue(rebuilt.domainContext?.primaryJobCandidates.isEmpty == true)
        XCTAssertEqual(rebuilt.discoveries[1].state, .excluded)
    }

    @MainActor
    func testActualRegenerationPublishesCompletionAndErrorWithoutStickingBusy() async throws {
        for fails in [false, true] {
            let model = CreateViewModel(coordinator: IntelligenceCoordinator(local: TargetedCompiler(fails: fails)))
            model.analysis = try await LocalExpertProvider().analyze("Quiero una app para registrar préstamos")
            var states: [Bool] = []
            let subscription = model.$isGenerating.sink { states.append($0) }
            await model.regenerate()
            XCTAssertTrue(states.contains(true))
            XCTAssertFalse(model.isGenerating)
            XCTAssertEqual(model.errorMessage != nil, fails)
            XCTAssertEqual(model.completionMessage != nil, !fails)
            withExtendedLifetime(subscription) {}
        }
    }

    @MainActor
    func testCancelledRegenerationReturnsToNormalWithoutAFalseCompletion() async throws {
        let model = CreateViewModel(coordinator: IntelligenceCoordinator(local: TargetedCompiler(fails: false)))
        model.analysis = try await LocalExpertProvider().analyze("I want an app to manage loans")
        let task = Task { await model.regenerate() }
        task.cancel()
        await task.value
        XCTAssertFalse(model.isGenerating)
        XCTAssertNil(model.completionMessage)
    }
}

private struct TargetedCompiler: LocalIntelligenceProvider {
    let name = "Deterministic execution/error control"
    let fails: Bool
    func availability() async -> IntelligenceAvailability { .ready }
    func analyze(_ request: String) async throws -> PromptAnalysis { try await LocalExpertProvider().analyze(request) }
    func analyze(_ request: String, decisions: DiscoveryDecisions) throws -> PromptAnalysis { try LocalExpertProvider().analyze(request, decisions: decisions) }
    func recompile(_ analysis: PromptAnalysis) throws -> PromptAnalysis {
        if fails { throw IntelligenceError.emptyRequest }
        return try LocalExpertProvider().recompile(analysis)
    }
}
