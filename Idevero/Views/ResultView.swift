import SwiftUI
import UIKit

struct ResultView: View {
    let analysis: PromptAnalysis
    let onState: (String, DiscoveryState) -> Void
    let onRegenerate: () -> Void
    let onReanalyze: () -> Void
    let onSave: () -> Void
    @State private var showDiscoveries = false

    private var usedAppleAugmentation: Bool {
        analysis.intelligenceMode == "APPLE AUGMENTED + LOCAL EXPERT"
    }

    private var displayedProviderName: String {
        usedAppleAugmentation ? "Apple Foundation Models" : "Local Expert"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Prompt generado")
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
                    .accessibilityLabel("Inteligencia utilizada: \(displayedProviderName)")
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

            DisclosureGroup(isExpanded: $showDiscoveries) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(analysis.discoveries) { item in
                        DiscoveryRow(item: item, onState: onState)
                        if item.id != analysis.discoveries.last?.id { Divider() }
                    }
                }
                .padding(.top, 8)
            } label: {
                HStack(spacing: 8) {
                    Text("Lo que Idevero añadió")
                        .fontWeight(.semibold)
                    Text("\(analysis.discoveries.count)")
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
    }

    @ViewBuilder
    private var resultActions: some View {
        Button("Copiar") { UIPasteboard.general.string = analysis.prompt }
        ShareLink(item: analysis.prompt) { Text("Compartir") }
        Button("Guardar", action: onSave)
        Menu("Actualizar") {
            Button("Regenerar prompt", action: onRegenerate)
            Button("Reanalizar necesidades", action: onReanalyze)
        }
    }
}

private struct DiscoveryRow: View {
    let item: Discovery
    let onState: (String, DiscoveryState) -> Void

    private var provenances: [DiscoveryProvenance] {
        var values = item.sourceProvenance ?? [item.provenance]
        if !values.contains(item.provenance) { values.insert(item.provenance, at: 0) }
        return values
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(item.concept)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                    priorityBadge
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.concept)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                    priorityBadge
                }
            }

            Text(item.reason)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Perspectiva: \(item.lens)")
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(provenances, id: \.self) { provenance in
                        MetadataBadge(
                            text: provenance.rawValue,
                            emphasized: provenance == .appleModel,
                            accessibilityPrefix: "Procedencia"
                        )
                    }
                    MetadataBadge(text: item.state.rawValue, emphasized: false, accessibilityPrefix: "Estado")
                }
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) { discoveryActions }
                VStack(alignment: .leading, spacing: 6) { discoveryActions }
            }
            .font(.caption.weight(.semibold))
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("discoveryRow")
    }

    private var priorityBadge: some View {
        MetadataBadge(text: item.priority.rawValue, emphasized: item.priority == .core, accessibilityPrefix: "Prioridad")
    }

    @ViewBuilder
    private var discoveryActions: some View {
        Button("Incluir") { onState(item.id, .included) }
            .frame(minHeight: 44)
        Button("Bloquear") { onState(item.id, .locked) }
            .frame(minHeight: 44)
        Button("Excluir", role: .destructive) { onState(item.id, .excluded) }
            .frame(minHeight: 44)
    }
}

private struct MetadataBadge: View {
    let text: String
    let emphasized: Bool
    let accessibilityPrefix: String

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .lineLimit(1)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .foregroundStyle(emphasized ? Color.indigo : Color.secondary)
            .background((emphasized ? Color.indigo : Color.secondary).opacity(0.12), in: Capsule())
            .accessibilityLabel("\(accessibilityPrefix): \(text)")
    }
}
