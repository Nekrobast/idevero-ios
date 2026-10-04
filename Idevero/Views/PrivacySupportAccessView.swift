import SwiftUI

struct PrivacySupportAccessView: View {
    let title: String
    let systemImage: String
    let destination: URL?
    let identifier: String
    @Environment(\.appDisplayLanguage) private var language
    @State private var showsPending = false

    var body: some View {
        Group {
            if let destination {
                Link(destination: destination) { row }
            } else {
                Button { showsPending = true } label: { row }
                    .alert(language.ui("Pendiente de publicación", "Publication pending"), isPresented: $showsPending) {
                        Button(language.ui("Aceptar", "OK"), role: .cancel) {}
                    } message: {
                        Text(language.ui("Este acceso estará disponible cuando se configure una dirección publicada y verificada.", "This access will be available once a published, verified address is configured."))
                    }
            }
        }
        .accessibilityIdentifier(identifier)
    }

    private var row: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: systemImage)
            if destination == nil {
                Text(language.ui("Pendiente de publicación", "Publication pending"))
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
