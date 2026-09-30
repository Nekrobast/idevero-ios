import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack { CreateView() }
                .tabItem { Label("Crear", systemImage: "sparkles") }
            NavigationStack { HistoryView() }
                .tabItem { Label("Historial", systemImage: "clock") }
            NavigationStack { SettingsView() }
                .tabItem { Label("Ajustes", systemImage: "gearshape") }
        }
        .tint(.indigo)
    }
}

