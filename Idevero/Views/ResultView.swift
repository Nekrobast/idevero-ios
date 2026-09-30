import SwiftUI
import UIKit

struct ResultView: View {
    let analysis: PromptAnalysis
    let providerName: String
    let onState: (String, DiscoveryState) -> Void
    let onRegenerate: () -> Void
    let onReanalyze: () -> Void
    let onSave: () -> Void
    @State private var showDiscoveries = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Prompt generado").font(.title2.bold())
                Spacer()
                Text(providerName).font(.caption).foregroundStyle(.secondary)
            }
            Text(analysis.prompt)
                .textSelection(.enabled)
                .padding()
                .background(.background, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.quaternary))
            HStack {
                Button("Copiar") { UIPasteboard.general.string = analysis.prompt }
                ShareLink(item: analysis.prompt) { Text("Compartir") }
                Button("Guardar", action: onSave)
                Menu("Actualizar") {
                    Button("Regenerar prompt", action: onRegenerate)
                    Button("Reanalizar necesidades", action: onReanalyze)
                }
            }
            .buttonStyle(.bordered)
            DisclosureGroup("Lo que Idevero añadió", isExpanded: $showDiscoveries) {
                ForEach(analysis.discoveries) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack { Text(item.concept).bold(); Spacer(); Text(item.priority.rawValue).font(.caption) }
                        Text(item.reason).font(.subheadline).foregroundStyle(.secondary)
                        Text("\(item.lens) · \(item.provenance.rawValue) · \(item.state.rawValue)").font(.caption2).foregroundStyle(.tertiary)
                        HStack {
                            Button("Incluir") { onState(item.id, .included) }
                            Button("Bloquear") { onState(item.id, .locked) }
                            Button("Excluir", role: .destructive) { onState(item.id, .excluded) }
                        }.buttonStyle(.borderless).font(.caption)
                    }.padding(.vertical, 6)
                }
            }
        }
        .padding(.top, 8)
    }
}
