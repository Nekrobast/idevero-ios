import SwiftUI

struct RuntimeAppMetadata {
    let version: String
    let build: String

    init(bundle: Bundle = .main) {
        version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
    }
}

struct SettingsView: View {
    private let metadata = RuntimeAppMetadata()

    var body: some View {
        List {
            Section("Inteligencia") {
                LabeledContent("Modo", value: "Automático")
                Text("Apple Foundation Models cuando está disponible; Local Expert en cualquier otro caso.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("Privacidad") {
                Label("Historial guardado en el dispositivo", systemImage: "iphone")
                Label("Sin cuenta ni backend", systemImage: "lock")
            }
            Section("Versión") {
                LabeledContent("Versión", value: metadata.version)
                LabeledContent("Build", value: metadata.build)
            }
        }
        .navigationTitle("Ajustes")
    }
}
