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
    @StateObject private var model: CreateViewModel

    init(record: PromptRecord) {
        self.record = record
        let restored = record.reconstructedAnalysis()
        let model = CreateViewModel()
        model.analysis = restored
        model.idea = restored.input
        _model = StateObject(wrappedValue: model)
    }

    var body: some View {
        ScrollView {
            if let analysis = model.analysis {
                ResultView(analysis: analysis, onState: setState, onRegenerate: regenerate, onReanalyze: reanalyze, isWorking: model.isGenerating, completionMessage: model.completionMessage, onSave: persist)
                .padding()
            }
            if let errorMessage = model.errorMessage { Text(errorMessage).foregroundStyle(.red).padding() }
        }
        .navigationTitle(DisplayLocalization(language: .detect(in: record.originalIdea)).text(record.title))
        .safeAreaInset(edge: .top, spacing: 0) { OperationFeedbackView(model: model) }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func setState(_ id: String, _ state: DiscoveryState) {
        Task { await model.setState(state, id: id); persist() }
    }

    private func regenerate() {
        Task { await model.regenerate(); persist() }
    }

    private func reanalyze() {
        Task { await model.reanalyze(); persist() }
    }

    private func persist() { guard let analysis = model.analysis else { return }; record.update(from: analysis); try? context.save() }
}
