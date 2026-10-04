import SwiftUI
import UIKit

struct ResultView: View {
    let analysis: PromptAnalysis
    let onState: (String, DiscoveryState) -> Void
    let onRegenerate: () -> Void
    let onReanalyze: () -> Void
    var isWorking = false
    var completionMessage: String? = nil
    let onSave: () -> Void
    @State private var showDiscoveries = false
    @State private var showUpdateChoices = false
    private var language: DisplayLanguage { .detect(in: analysis.input) }
    private func ui(_ spanish: String, _ english: String) -> String { language == .spanish ? spanish : english }

    private var usedAppleAugmentation: Bool {
        analysis.intelligenceMode == "APPLE AUGMENTED + LOCAL EXPERT"
    }

    private var displayedProviderName: String {
        usedAppleAugmentation ? "Apple Intelligence" : ui("Conocimiento de Idevero", "Idevero’s built-in knowledge")
    }

    private var displayedDiscoveries: [Discovery] {
        let policy = UserFacingTextPolicy(language: .detect(in: analysis.input))
        return analysis.discoveries.filter { item in
            let isApple = (item.sourceProvenance ?? [item.provenance]).contains(.appleModel)
            return !isApple || (policy.isSafeDisplay(item.concept) && policy.isSafeDisplay(item.reason, minimumLength: 12))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text(ui("Prompt generado", "Generated prompt"))
                    .font(.title2.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .accessibilityAddTraits(.isHeader)

                Label(displayedProviderName, systemImage: usedAppleAugmentation ? "sparkles" : "cpu")
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .foregroundStyle(usedAppleAugmentation ? Color.indigo : Color.secondary)
                    .background((usedAppleAugmentation ? Color.indigo : Color.secondary).opacity(0.12), in: Capsule())
                    .accessibilityLabel(ui("Inteligencia utilizada: \(displayedProviderName)", "Intelligence used: \(displayedProviderName)"))
                    .accessibilityIdentifier("providerBadge")
            }

            Text(analysis.prompt)
                .textSelection(.enabled)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(.quaternary))
                .accessibilityIdentifier("generatedPrompt")

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) { resultActions }
                VStack(alignment: .leading, spacing: 8) { resultActions }
            }
            .disabled(isWorking)

            DisclosureGroup(isExpanded: $showDiscoveries) {
                Text(ui("Ideas y detalles que pueden mejorar tu petición. Puedes añadirlos, mantenerlos siempre o quitarlos.", "Ideas and details that can improve your request. You can add them, always keep them or remove them."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(displayedDiscoveries) { item in
                        DiscoveryRow(item: item, language: .detect(in: analysis.input), originalRequest: analysis.input, onState: onState)
                            .disabled(isWorking)
                        if item.id != displayedDiscoveries.last?.id { Divider() }
                    }
                }
                .padding(.top, 8)
            } label: {
                HStack(spacing: 8) {
                    Text(ui("Lo que Idevero añadió", "What Idevero added"))
                        .fontWeight(.semibold)
                    Text("\(displayedDiscoveries.count)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(.quaternary, in: Capsule())
                }
            }
            .accessibilityIdentifier("discoveriesDisclosure")
        }
        .padding(.top, 8)
        .confirmationDialog(ui("Elige cómo actualizar el prompt", "Choose how to update the prompt"), isPresented: $showUpdateChoices, titleVisibility: .visible) {
            Button(ui("Regenerar prompt", "Regenerate prompt"), action: onRegenerate)
            Button(ui("Reanalizar necesidades", "Reanalyze needs"), action: onReanalyze)
            Button(ui("Cancelar", "Cancel"), role: .cancel) {}
        }
    }

    @ViewBuilder
    private var resultActions: some View {
        Button(ui("Copiar", "Copy")) { UIPasteboard.general.string = analysis.prompt }
        ShareLink(item: analysis.prompt) { Text(ui("Compartir", "Share")) }
        Button(ui("Guardar", "Save"), action: onSave)
        Button(ui("Actualizar", "Update")) { showUpdateChoices = true }
            .accessibilityHint(ui("Elige regenerar el prompt o reanalizar las necesidades", "Choose to regenerate the prompt or reanalyze needs"))
    }
}

private struct DiscoveryRow: View {
    let item: Discovery
    let language: DisplayLanguage
    let originalRequest: String
    let onState: (String, DiscoveryState) -> Void
    @State private var showDetails = false
    private var display: DiscoveryPresentation { .init(item: item, language: language, originalRequest: originalRequest) }
    private func ui(_ es: String, _ en: String) -> String { language == .spanish ? es : en }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(display.title)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Text(display.explanation)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
            Text(display.priority + " · " + display.state)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(ui("Importancia y decisión: ", "Importance and decision: ") + display.priority + ". " + display.state)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) { actions }
                VStack(alignment: .leading, spacing: 8) { actions }
            }
            .buttonStyle(.bordered)
            DisclosureGroup(isExpanded: $showDetails) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(display.fullReason)
                    Text(ui("De dónde sale esta recomendación", "Where this recommendation comes from"))
                        .fontWeight(.semibold)
                    ForEach(display.sourceDescriptions, id: \.self) { Text($0) }
                    Text(ui("Perspectiva: ", "Perspective: ") + display.perspective)
                    if display.title != display.technicalTitle {
                        Text(ui("Término técnico: ", "Technical term: ") + display.technicalTitle)
                    }
                }
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 6)
            } label: {
                Text(ui("¿Por qué me recomienda esto?", "Why is this recommended?"))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: 44)
            }
        }
        .padding(.vertical, 12)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("discoveryRow")
    }

    @ViewBuilder
    private var actions: some View {
        action(.included)
        action(.locked)
        action(.excluded)
    }

    private func action(_ state: DiscoveryState) -> some View {
        Button(role: state == .excluded ? .destructive : nil) {
            onState(item.id, state)
        } label: {
            Text(display.actionTitle(state))
                .fixedSize(horizontal: false, vertical: true)
                .frame(minWidth: 44, minHeight: 44)
        }
        .accessibilityHint(display.actionHint(state))
        // Preserve the existing UI-test selector, not a user-visible label.
        .accessibilityIdentifier(state == .excluded ? "Excluir" : "discoveryAction-" + state.rawValue)
    }
}
