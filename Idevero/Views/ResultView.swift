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
    @State private var showMoreRecommendations = false
    @State private var showUpdateChoices = false
    private var language: DisplayLanguage { .detect(in: analysis.input) }
    private func ui(_ spanish: String, _ english: String) -> String { language == .spanish ? spanish : english }

    private var usedAppleAugmentation: Bool {
        analysis.intelligenceMode == "APPLE AUGMENTED + LOCAL EXPERT"
    }

    private var displayedProviderName: String {
        usedAppleAugmentation ? "Apple Intelligence" : ui("Conocimiento de Idevero", "Idevero’s built-in knowledge")
    }

    // Unsafe raw text receives the central display-safe fallback rather than
    // dropping the discovery from the UI. The original analysis is untouched.
    private var displayedDiscoveries: [Discovery] { analysis.discoveries }
    private var summary: DiscoveryPresentation.Summary { DiscoveryPresentation.summary(displayedDiscoveries) }

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
                    .fixedSize(horizontal: false, vertical: true)
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
                VStack(alignment: .leading, spacing: 12) {
                    discoverySection(ui("Tus decisiones", "Your decisions"), items: summary.decisions)
                    discoverySection(ui("Lo más importante", "Most important"), items: summary.important)
                    discoverySection(ui("También puede ayudar", "May also help"), items: summary.recommended)
                    if !summary.more.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Button { showMoreRecommendations.toggle() } label: {
                                HStack {
                                    Text(showMoreRecommendations
                                         ? ui("Mostrar menos recomendaciones", "Show fewer recommendations")
                                         : ui("Ver más recomendaciones (\(summary.more.count))", "See more recommendations (\(summary.more.count))"))
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer(minLength: 8)
                                    Image(systemName: showMoreRecommendations ? "chevron.down" : "chevron.right")
                                        .accessibilityHidden(true)
                                }
                                .frame(minHeight: 44)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.tint)
                            .accessibilityIdentifier("moreRecommendations")
                            .accessibilityValue(showMoreRecommendations ? ui("Expandido", "Expanded") : ui("Contraído", "Collapsed"))
                            .accessibilityHint(ui("Todas las recomendaciones siguen disponibles. Expande o contrae el resto.", "All recommendations remain available. Expand or collapse the rest."))
                            if showMoreRecommendations {
                                discoverySection(ui("Más recomendaciones", "More recommendations"), items: summary.more)
                            }
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("moreRecommendationsSection")
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
    private func discoverySection(_ title: String, items: [Discovery]) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.subheadline.bold())
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                ForEach(items) { item in
                    DiscoveryRow(item: item, language: language, originalRequest: analysis.input, onState: onState)
                        .disabled(isWorking)
                    if item.id != items.last?.id { Divider() }
                }
            }
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
                Text(ui("Por qué", "Why"))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: 44)
            }
            .accessibilityIdentifier(ui("¿Por qué me recomienda esto?", "Why is this recommended?"))
            .accessibilityHint(ui("Expande o contrae la razón, el origen y los detalles de esta recomendación.", "Expand or collapse the reason, source and details of this recommendation."))
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
            HStack(spacing: 4) {
                if display.isSelectedAction(state) { Image(systemName: "checkmark").accessibilityHidden(true) }
                Text(display.controlTitle(state))
            }
                .fixedSize(horizontal: false, vertical: true)
                .frame(minWidth: 44, minHeight: 44)
        }
        .accessibilityLabel(display.controlTitle(state))
        .accessibilityHint(display.controlHint(state))
        .accessibilityAddTraits(display.isSelectedAction(state) ? .isSelected : [])
        // Preserve the existing UI-test selector, not a user-visible label.
        .accessibilityIdentifier(state == .excluded ? "Excluir" : "discoveryAction-" + state.rawValue)
    }
}
