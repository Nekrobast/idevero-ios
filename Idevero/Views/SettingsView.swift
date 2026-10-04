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
    @Environment(\.appDisplayLanguage) private var language

    var body: some View {
        List {
            Section(language.ui("Inteligencia", "Intelligence")) {
                LabeledContent(language.ui("Modo", "Mode"), value: language.ui("Automático", "Automatic"))
                Text(language.ui("Apple Intelligence cuando está disponible; conocimiento integrado de Idevero en cualquier otro caso.", "Apple Intelligence when available; Idevero’s built-in knowledge otherwise."))
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section(language.ui("Privacidad", "Privacy")) {
                Label(language.ui("Historial guardado en el dispositivo", "History saved on your device"), systemImage: "iphone")
                Label(language.ui("No necesitas una cuenta", "No account needed"), systemImage: "lock")
            }
            Section(language.ui("Versión", "Version")) {
                LabeledContent(language.ui("Versión", "Version"), value: metadata.version)
                LabeledContent(language.ui("Compilación", "Build"), value: metadata.build)
            }
        }
        .navigationTitle(language.ui("Ajustes", "Settings"))
    }
}
