import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \PromptRecord.createdAt, order: .reverse) private var records: [PromptRecord]
    @Environment(\.modelContext) private var context

    var body: some View {
        Group {
            if records.isEmpty {
                ContentUnavailableView("Sin prompts guardados", systemImage: "clock", description: Text("Los prompts que guardes aparecerán aquí."))
            } else {
                List {
                    ForEach(records) { record in
                        NavigationLink { HistoryDetailView(record: record) } label: {
                            VStack(alignment: .leading) {
                                Text(DisplayLocalization(language: .detect(in: record.originalIdea)).text(record.title)).font(.headline).lineLimit(1)
                                Text(record.originalIdea).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                            }
                        }
                    }
                    .onDelete { offsets in offsets.map { records[$0] }.forEach(context.delete) }
                }
            }
        }
        .navigationTitle("Historial")
    }
}

struct HistoryDetailView: View {
    let record: PromptRecord
    @Environment(\.modelContext) private var context
    @State private var analysis: PromptAnalysis
    @State private var providerName: String
    @State private var isWorking = false
    @State private var errorMessage: String?
    private let coordinator = IntelligenceCoordinator()

    init(record: PromptRecord) {
        self.record = record
        let restored = record.reconstructedAnalysis()
        _analysis = State(initialValue: restored)
        _providerName = State(initialValue: restored.intelligenceMode)
    }

    var body: some View {
        ScrollView {
            ResultView(analysis: analysis, onState: setState, onRegenerate: regenerate, onReanalyze: reanalyze, onSave: persist)
                .padding()
            if isWorking { ProgressView("Actualizando…") }
            if let errorMessage { Text(errorMessage).foregroundStyle(.red).padding() }
        }
        .navigationTitle(DisplayLocalization(language: .detect(in: record.originalIdea)).text(record.title))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var decisions: DiscoveryDecisions {
        DiscoveryDecisions(
            locked: Set(analysis.discoveries.filter { $0.state == .locked }.map(\.id)),
            excluded: Set(analysis.discoveries.filter { $0.state == .excluded }.map(\.id)),
            accepted: Set(analysis.discoveries.filter { $0.provenance == .userAccepted }.map(\.id))
        )
    }

    private func setState(_ id: String, _ state: DiscoveryState) {
        guard let index = analysis.discoveries.firstIndex(where: { $0.id == id }) else { return }
        analysis.discoveries[index].state = state
        if state == .locked { analysis.discoveries[index].priority = .core; analysis.discoveries[index].provenance = .userLocked }
        if state == .excluded { analysis.discoveries[index].priority = .outOfScope }
        if state == .included && analysis.discoveries[index].provenance == .localKnowledge { analysis.discoveries[index].provenance = .userAccepted }
        Task { if let rebuilt = try? await coordinator.regenerate(analysis) { analysis = rebuilt; persist() } }
    }

    private func regenerate() {
        Task {
            isWorking = true; defer { isWorking = false }
            do { analysis = try await coordinator.regenerate(analysis); persist() }
            catch { errorMessage = error.localizedDescription }
        }
    }

    private func reanalyze() {
        Task {
            isWorking = true; defer { isWorking = false }
            do { let result = try await coordinator.reanalyze(record.originalIdea, decisions: decisions); analysis = result.0; providerName = result.1; persist() }
            catch { errorMessage = error.localizedDescription }
        }
    }

    private func persist() { record.update(from: analysis); try? context.save() }
}
