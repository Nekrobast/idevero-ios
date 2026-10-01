import SwiftUI

struct SettingsView: View {
    private var version: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—" }
    private var build: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—" }

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
                LabeledContent("Versión", value: version)
                LabeledContent("Build", value: build)
            }
        }
        .navigationTitle("Ajustes")
    }
}
