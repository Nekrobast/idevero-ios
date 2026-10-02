import Foundation

@MainActor
final class CreateViewModel: ObservableObject {
    @Published var idea = ""
    @Published var analysis: PromptAnalysis?
    @Published var providerName = "Local Expert"
    @Published var isGenerating = false
    @Published var errorMessage: String?
    private let coordinator: IntelligenceCoordinator
    private var generationSequence: UInt64 = 0

    init(coordinator: IntelligenceCoordinator = IntelligenceCoordinator()) {
        self.coordinator = coordinator
    }

    var decisions: DiscoveryDecisions {
        let values = analysis?.discoveries ?? []
        return DiscoveryDecisions(locked: Set(values.filter { $0.state == .locked }.map(\.id)), excluded: Set(values.filter { $0.state == .excluded }.map(\.id)), accepted: Set(values.filter { $0.provenance == .userAccepted }.map(\.id)))
    }

    func generate() async {
        generationSequence &+= 1
        let generation = generationSequence
        isGenerating = true
        errorMessage = nil
        defer {
            if generation == generationSequence { isGenerating = false }
        }
        do {
            let (result, provider) = try await coordinator.analyze(idea)
            guard generation == generationSequence, !Task.isCancelled else { return }
            analysis = result
            providerName = provider
        } catch {
            guard generation == generationSequence, !Task.isCancelled else { return }
            errorMessage = error.localizedDescription
        }
    }

    func setState(_ state: DiscoveryState, id: String) async {
        guard var current = analysis, let index = current.discoveries.firstIndex(where: { $0.id == id }) else { return }
        current.discoveries[index] = DiscoverySemantics.transition(current.discoveries[index], to: state)
        analysis = try? await coordinator.regenerate(current)
    }

    func regenerate() async { guard let current = analysis else { return }; analysis = try? await coordinator.regenerate(current) }
    func reanalyze() async {
        isGenerating = true; defer { isGenerating = false }
        do { let result = try await coordinator.reanalyze(idea, decisions: decisions); analysis = result.0; providerName = result.1 }
        catch { errorMessage = error.localizedDescription }
    }
}
