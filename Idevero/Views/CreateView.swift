import SwiftUI
import SwiftData

struct CreateView: View {
    @StateObject private var model = CreateViewModel()
    @Environment(\.modelContext) private var context

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("¿Qué quieres conseguir?")
                        .font(.largeTitle.bold())
                    Text("Cuéntamelo aunque no sepas cómo pedirlo. Idevero descubre qué falta y construye el prompt.")
                        .foregroundStyle(.secondary)
                }
                TextEditor(text: $model.idea)
                    .frame(minHeight: 170)
                    .padding(12)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 18))
                    .accessibilityLabel("Describe tu idea")
                Button {
                    Task { await model.generate() }
                } label: {
                    HStack {
                        if model.isGenerating { ProgressView().tint(.white) }
                        Text(model.isGenerating ? "Analizando" : "Crear prompt")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .disabled(model.isGenerating || model.idea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                if let error = model.errorMessage {
                    Text(error).foregroundStyle(.red).accessibilityLabel("Error: \(error)")
                }
                if let analysis = model.analysis {
                    ResultView(analysis: analysis, providerName: model.providerName, onState: { id, state in
                        Task { await model.setState(state, id: id) }
                    }, onRegenerate: { Task { await model.regenerate() } }, onReanalyze: { Task { await model.reanalyze() } }) {
                        context.insert(PromptRecord(analysis: analysis))
                        try? context.save()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Idevero")
    }
}
