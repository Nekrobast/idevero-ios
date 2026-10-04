import SwiftUI
import SwiftData

struct CreateView: View {
    @StateObject private var model = CreateViewModel()
    @Environment(\.modelContext) private var context
    @Environment(\.ideveroTabBarClearance) private var tabBarClearance
    @FocusState private var isIdeaFocused: Bool
    private var language: DisplayLanguage { .detect(in: model.idea) }
    private func ui(_ es: String, _ en: String) -> String { language == .spanish ? es : en }

    private enum ScrollAnchor: Hashable {
        case editor
        case result
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(ui("¿Qué quieres conseguir?", "What do you want to achieve?"))
                            .font(.title.bold())
                            .accessibilityAddTraits(.isHeader)
                        Text(ui("Cuéntamelo aunque no sepas cómo pedirlo. Idevero descubre qué falta y construye el prompt.", "Tell me even if you are not sure how to ask. Idevero finds what is missing and builds the prompt."))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    AdaptiveIdeaEditor(text: $model.idea, isFocused: $isIdeaFocused)
                        .id(ScrollAnchor.editor)

                    Button(action: submit) {
                        HStack(spacing: 8) {
                            if model.isGenerating { ProgressView().tint(.white) }
                            Text(model.isGenerating ? ui("Analizando", "Analyzing") : ui("Crear prompt", "Create prompt"))
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
                        }, isWorking: model.isGenerating, completionMessage: model.completionMessage) {
                            try? PromptRecord.upsert(analysis, in: context)
                        }
                        .id(ScrollAnchor.result)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear
                    .frame(height: max(tabBarClearance, 1) + 20)
                    .accessibilityHidden(true)
                    .accessibilityIdentifier("measuredTabBarClearance")
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .top, spacing: 0) { OperationFeedbackView(model: model) }
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
                Button(ui("Crear prompt", "Create prompt"), action: submit)
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
                .accessibilityLabel(DisplayLanguage.detect(in: text) == .spanish ? "Describe tu idea" : "Describe your idea")
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
