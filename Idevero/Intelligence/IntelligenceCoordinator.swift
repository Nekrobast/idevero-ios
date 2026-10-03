import Foundation

actor IntelligenceCoordinator {
    private let local: any LocalIntelligenceProvider
    private let foundation: any IntelligenceProvider

    init(
        local: any LocalIntelligenceProvider = LocalExpertProvider(),
        foundation: any IntelligenceProvider = FoundationModelsProvider()
    ) {
        self.local = local
        self.foundation = foundation
    }

    func analyze(_ request: String) async throws -> (PromptAnalysis, String) {
        if case .ready = await foundation.availability() {
            do { return (try await foundation.analyze(request), foundation.name) }
            catch is CancellationError { throw CancellationError() }
            catch { return (try await local.analyze(request), local.name) }
        }
        return (try await local.analyze(request), local.name)
    }

    func reanalyze(_ request: String, decisions: DiscoveryDecisions) async throws -> (PromptAnalysis, String) {
        // Reanalysis reruns semantic discovery while carrying user authority forward.
        let decisions = decisions.scoped(to: request)
        let localResult = try protect(local.analyze(request, decisions: decisions), with: decisions)
        if case .ready = await foundation.availability() {
            do {
                let augmented = try await foundation.analyze(request)
                let protected = try protect(augmented, with: decisions)
                return (protected, foundation.name)
            } catch is CancellationError { throw CancellationError() }
            catch { return (localResult, local.name) }
        }
        return (localResult, local.name)
    }

    func regenerate(_ analysis: PromptAnalysis) throws -> PromptAnalysis {
        // Regeneration recompiles the same understanding and never invokes Apple intelligence.
        try local.recompile(analysis)
    }

    private func protect(_ analysis: PromptAnalysis, with decisions: DiscoveryDecisions) throws -> PromptAnalysis {
        var copy = analysis
        copy.discoveries = copy.discoveries.map { value in
            var item = value
            let key = item.concept.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            let semantic = DiscoverySemantics.identity(item)
            let savedID = decisions.authoritativeDiscoveries?.first { $0.id == item.id }
            let idIsEquivalent = savedID.map { DiscoverySemantics.identity($0) == semantic } ?? true
            if (idIsEquivalent && decisions.accepted.contains(item.id)) || decisions.accepted.contains(key) || decisions.acceptedSemantic?.contains(semantic) == true { item = DiscoverySemantics.transition(item, to: .included) }
            if (idIsEquivalent && decisions.excluded.contains(item.id)) || decisions.excluded.contains(key) || decisions.excludedSemantic?.contains(semantic) == true { item = DiscoverySemantics.transition(item, to: .excluded) }
            if (idIsEquivalent && decisions.locked.contains(item.id)) || decisions.locked.contains(key) || decisions.lockedSemantic?.contains(semantic) == true { item = DiscoverySemantics.transition(item, to: .locked) }
            return item
        }
        // The model can omit a previous finding. Omission cannot revoke a user
        // decision. Retain its snapshot; match replacements only with the same
        // conservative semantic identity (never a fuzzy or weakened match).
        for saved in decisions.authoritativeDiscoveries ?? [] {
            let identity = DiscoverySemantics.identity(saved)
            if let index = copy.discoveries.firstIndex(where: { DiscoverySemantics.identity($0) == identity }) {
                copy.discoveries[index] = DiscoverySemantics.transition(copy.discoveries[index], to: saved.state)
            } else {
                // A machine ID with changed semantics is not the same finding.
                copy.discoveries.removeAll { $0.id == saved.id }
                copy.discoveries.append(saved)
            }
        }
        if let id = decisions.analysisID {
            copy = PromptAnalysis(analysisID: id, title: copy.title, input: copy.input, task: copy.task, intent: copy.intent, domain: copy.domain, secondaryDomains: copy.secondaryDomains, target: copy.target, outcome: copy.outcome, elaboration: copy.elaboration, discoveries: copy.discoveries, unknowns: copy.unknowns, prompt: copy.prompt, qualityNotes: copy.qualityNotes, intelligenceMode: copy.intelligenceMode, analyzedAt: copy.analyzedAt, domainContext: copy.domainContext)
        }
        return try local.recompile(copy)
    }
}
