import Foundation

@MainActor
final class CreateViewModel: ObservableObject {
    @Published var idea = ""
    @Published var analysis: PromptAnalysis?
    @Published var providerName = "Local Expert"
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var completionMessage: String?
    private let coordinator: IntelligenceCoordinator
    private var generationSequence: UInt64 = 0

    init(coordinator: IntelligenceCoordinator = IntelligenceCoordinator()) {
        self.coordinator = coordinator
    }

    var decisions: DiscoveryDecisions {
        analysis.map(DiscoveryDecisions.capture) ?? .init()
    }

    func generate() async {
        generationSequence &+= 1
        let generation = generationSequence
        isGenerating = true
        errorMessage = nil
        completionMessage = nil
        defer {
            if generation == generationSequence { isGenerating = false }
        }
        do {
            let captured = decisions.scoped(to: idea)
            let (result, provider) = captured.analysisID == nil ? try await coordinator.analyze(idea) : try await coordinator.reanalyze(idea, decisions: captured)
            guard generation == generationSequence, !Task.isCancelled else { return }
            analysis = result
            providerName = provider
        } catch {
            guard generation == generationSequence, !Task.isCancelled else { return }
            errorMessage = error.localizedDescription
        }
    }

    func setState(_ state: DiscoveryState, id: String) async {
        guard !isGenerating else { return }
        guard var current = analysis, let index = current.discoveries.firstIndex(where: { $0.id == id }) else { return }
        current.discoveries[index] = DiscoverySemantics.transition(current.discoveries[index], to: state)
        await recompile(current)
    }

    func regenerate() async {
        guard !isGenerating, let current = analysis else { return }
        await recompile(current)
    }

    private func recompile(_ current: PromptAnalysis) async {
        generationSequence &+= 1
        let generation = generationSequence
        isGenerating = true
        errorMessage = nil
        completionMessage = nil
        defer { if generation == generationSequence { isGenerating = false } }
        do {
            let rebuilt = try await coordinator.regenerate(current)
            guard generation == generationSequence, !Task.isCancelled else { return }
            analysis = rebuilt
            completionMessage = DisplayLanguage.detect(in: rebuilt.input) == .spanish ? "Prompt actualizado" : "Prompt updated"
        } catch {
            guard generation == generationSequence, !Task.isCancelled else { return }
            errorMessage = error.localizedDescription
        }
    }
    func reanalyze() async {
        generationSequence &+= 1
        let generation = generationSequence
        isGenerating = true
        errorMessage = nil
        completionMessage = nil
        defer {
            if generation == generationSequence { isGenerating = false }
        }
        do {
            let result = try await coordinator.reanalyze(idea, decisions: decisions)
            guard generation == generationSequence, !Task.isCancelled else { return }
            analysis = result.0
            providerName = result.1
            completionMessage = DisplayLanguage.detect(in: result.0.input) == .spanish ? "Prompt actualizado" : "Prompt updated"
        } catch {
            guard generation == generationSequence, !Task.isCancelled else { return }
            errorMessage = error.localizedDescription
        }
    }
}

