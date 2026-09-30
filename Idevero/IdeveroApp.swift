import SwiftUI
import SwiftData

@main
struct IdeveroApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: PromptRecord.self)
    }
}

