import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.appDisplayLanguage) private var language
    @Query(sort: \PromptRecord.createdAt, order: .reverse) private var records: [PromptRecord]
    @Environment(\.modelContext) private var context

    var body: some View {
        Group {
            if records.isEmpty {
                ContentUnavailableView(language.ui("Sin prompts guardados", "No saved prompts"), systemImage: "clock", description: Text(language.ui("Los prompts que guardes aparecerán aquí.", "Prompts you save will appear here.")))
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
        .navigationTitle(language.ui("Historial", "History"))
    }
}

struct HistoryDetailView: View {
    let record: PromptRecord
    @Environment(\.appDisplayLanguageChanged) private var languageChanged
    @Environment(\.modelContext) private var context
    @StateObject private var model: CreateViewModel
    @StateObject private var persistenceFeedback = PersistenceFeedback(scope: .history)

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
        .safeAreaInset(edge: .top, spacing: 0) { PersistenceFeedbackView(feedback: persistenceFeedback, language: .detect(in: model.idea)) }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { languageChanged(.detect(in: record.originalIdea)) }
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

    private func persist() {
        guard let analysis = model.analysis else { return }
        persistenceFeedback.save(language: .detect(in: analysis.input)) {
            try PersistenceFeedback.update(record, from: analysis) { try context.save() }
        }
    }
}
