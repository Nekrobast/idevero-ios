import SwiftUI
import SwiftData

struct CreateView: View {
    @StateObject private var model = CreateViewModel()
    @Environment(\.modelContext) private var context
    @FocusState private var isIdeaFocused: Bool

    private enum ScrollAnchor: Hashable {
        case editor
        case result
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("¿Qué quieres conseguir?")
                            .font(.title.bold())
                            .accessibilityAddTraits(.isHeader)
                        Text("Cuéntamelo aunque no sepas cómo pedirlo. Idevero descubre qué falta y construye el prompt.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    AdaptiveIdeaEditor(text: $model.idea, isFocused: $isIdeaFocused)
                        .id(ScrollAnchor.editor)

                    Button(action: submit) {
                        HStack(spacing: 8) {
                            if model.isGenerating { ProgressView().tint(.white) }
                            Text(model.isGenerating ? "Analizando" : "Crear prompt")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(model.isGenerating || model.idea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("createPromptButton")

                    if let error = model.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .accessibilityLabel("Error: \(error)")
                    }

                    if let analysis = model.analysis {
                        ResultView(analysis: analysis, onState: { id, state in
                            Task { await model.setState(state, id: id) }
                        }, onRegenerate: {
                            Task { await model.regenerate() }
                        }, onReanalyze: {
                            isIdeaFocused = false
                            Task {
                                await model.reanalyze()
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(ScrollAnchor.result, anchor: .top)
                                }
                            }
                        }) {
                            context.insert(PromptRecord(analysis: analysis))
                            try? context.save()
                        }
                        .id(ScrollAnchor.result)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.visible)
            .onChange(of: model.analysis?.analysisID) { _, analysisID in
                guard analysisID != nil else { return }
                isIdeaFocused = false
                Task { @MainActor in
                    await Task.yield()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(ScrollAnchor.result, anchor: .top)
                    }
                }
            }
        }
        .navigationTitle("Idevero")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Crear prompt", action: submit)
                    .fontWeight(.semibold)
                    .disabled(model.isGenerating || model.idea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("keyboardCreatePromptButton")
            }
        }
    }

    private func submit() {
        isIdeaFocused = false
        Task { await model.generate() }
    }
}

private struct AdaptiveIdeaEditor: View {
    @Binding var text: String
    let isFocused: FocusState<Bool>.Binding
    private let minimumHeight: CGFloat = 96
    private let maximumHeight: CGFloat = 184
    @State private var measuredTextHeight: CGFloat = 0

    private var editorHeight: CGFloat {
        min(max(measuredTextHeight + 34, minimumHeight), maximumHeight)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Text(text.isEmpty ? " " : text + "\n")
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 5)
                .background {
                    GeometryReader { geometry in
                        Color.clear.preference(key: EditorTextHeightKey.self, value: geometry.size.height)
                    }
                }
                .hidden()

            if text.isEmpty {
                Text("Describe la idea o tarea para la IA…")
                    .font(.body)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $text)
                .font(.body)
                .scrollContentBackground(.hidden)
                .focused(isFocused)
                .accessibilityLabel("Describe tu idea")
                .accessibilityIdentifier("ideaEditor")
        }
        .frame(height: editorHeight)
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isFocused.wrappedValue ? Color.indigo.opacity(0.8) : Color.clear, lineWidth: 1.5)
        }
        .animation(.easeOut(duration: 0.18), value: editorHeight)
        .onPreferenceChange(EditorTextHeightKey.self) { measuredTextHeight = $0 }
    }
}

private struct EditorTextHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
