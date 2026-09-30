import Foundation

actor IntelligenceCoordinator {
    private let local = LocalExpertProvider()
    private let foundation = FoundationModelsProvider()

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
        let localResult = try local.analyze(request, decisions: decisions)
        if case .ready = await foundation.availability() {
            do {
                let augmented = try await foundation.analyze(request)
                let protected = protect(augmented, with: decisions)
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

    private func protect(_ analysis: PromptAnalysis, with decisions: DiscoveryDecisions) -> PromptAnalysis {
        var copy = analysis
        copy.discoveries = copy.discoveries.map { value in
            var item = value
            let key = item.concept.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            if decisions.excluded.contains(item.id) || decisions.excluded.contains(key) { item.state = .excluded; item.priority = .outOfScope }
            if decisions.locked.contains(item.id) || decisions.locked.contains(key) { item.state = .locked; item.priority = .core; item.provenance = .userLocked }
            return item
        }
        return (try? local.recompile(copy)) ?? copy
    }
}
