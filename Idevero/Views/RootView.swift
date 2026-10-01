import SwiftUI
import UIKit

private struct TabBarClearanceKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var ideveroTabBarClearance: CGFloat {
        get { self[TabBarClearanceKey.self] }
        set { self[TabBarClearanceKey.self] = newValue }
    }
}

struct RootView: View {
    @State private var tabBarClearance: CGFloat = 0

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
        .environment(\.ideveroTabBarClearance, tabBarClearance)
        .background {
            TabBarClearanceReader { measured in
                if abs(tabBarClearance - measured) > 0.5 { tabBarClearance = measured }
            }
            .frame(width: 0, height: 0)
            .accessibilityHidden(true)
        }
    }
}

private struct TabBarClearanceReader: UIViewControllerRepresentable {
    let onChange: @MainActor (CGFloat) -> Void

    func makeUIViewController(context: Context) -> MeasuringViewController {
        MeasuringViewController(onChange: onChange)
    }

    func updateUIViewController(_ controller: MeasuringViewController, context: Context) {
        controller.onChange = onChange
        controller.measure()
    }

    final class MeasuringViewController: UIViewController {
        var onChange: @MainActor (CGFloat) -> Void
        private var lastValue: CGFloat = -1

        init(onChange: @escaping @MainActor (CGFloat) -> Void) {
            self.onChange = onChange
            super.init(nibName: nil, bundle: nil)
            view.isHidden = true
            view.isUserInteractionEnabled = false
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            measure()
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            measure()
        }

        func measure() {
            guard let tabBar = tabBarController?.tabBar, !tabBar.isHidden else { return }
            let value = tabBar.bounds.height
            guard value > 0, abs(lastValue - value) > 0.5 else { return }
            lastValue = value
            Task { @MainActor in onChange(value) }
        }
    }
}
