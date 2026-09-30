import SwiftUI

struct SettingsView: View {
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
            Section("Versión") { LabeledContent("Idevero", value: "0.2.1") }
        }
        .navigationTitle("Ajustes")
    }
}
