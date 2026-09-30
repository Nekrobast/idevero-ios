import Foundation

@MainActor
final class CreateViewModel: ObservableObject {
    @Published var idea = ""
    @Published var analysis: PromptAnalysis?
    @Published var providerName = "Local Expert"
    @Published var isGenerating = false
    @Published var errorMessage: String?
    private let coordinator = IntelligenceCoordinator()

    var decisions: DiscoveryDecisions {
        let values = analysis?.discoveries ?? []
        return DiscoveryDecisions(locked: Set(values.filter { $0.state == .locked }.map(\.id)), excluded: Set(values.filter { $0.state == .excluded }.map(\.id)), accepted: Set(values.filter { $0.provenance == .userAccepted }.map(\.id)))
    }

    func generate() async {
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }
        do {
            let (result, provider) = try await coordinator.analyze(idea)
            analysis = result
            providerName = provider
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setState(_ state: DiscoveryState, id: String) async {
        guard var current = analysis, let index = current.discoveries.firstIndex(where: { $0.id == id }) else { return }
        current.discoveries[index].state = state
        if state == .locked { current.discoveries[index].priority = .core; current.discoveries[index].provenance = .userLocked }
        if state == .included && current.discoveries[index].provenance == .localKnowledge { current.discoveries[index].provenance = .userAccepted }
        if state == .excluded { current.discoveries[index].priority = .outOfScope }
        analysis = try? await coordinator.regenerate(current)
    }

    func regenerate() async { guard let current = analysis else { return }; analysis = try? await coordinator.regenerate(current) }
    func reanalyze() async {
        isGenerating = true; defer { isGenerating = false }
        do { let result = try await coordinator.reanalyze(idea, decisions: decisions); analysis = result.0; providerName = result.1 }
        catch { errorMessage = error.localizedDescription }
    }
}
