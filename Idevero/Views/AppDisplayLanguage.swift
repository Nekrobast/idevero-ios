import SwiftUI

// Session-only UI language follows the explicit request. No semantic or stored
// analysis field changes, and no new persistent preference is introduced.
private struct AppDisplayLanguageKey: EnvironmentKey {
    static let defaultValue: DisplayLanguage = .spanish
}
private struct AppDisplayLanguageChangedKey: EnvironmentKey {
    static let defaultValue: (DisplayLanguage) -> Void = { _ in }
}
extension EnvironmentValues {
    var appDisplayLanguage: DisplayLanguage {
        get { self[AppDisplayLanguageKey.self] }
        set { self[AppDisplayLanguageKey.self] = newValue }
    }
    var appDisplayLanguageChanged: (DisplayLanguage) -> Void {
        get { self[AppDisplayLanguageChangedKey.self] }
        set { self[AppDisplayLanguageChangedKey.self] = newValue }
    }
}
extension DisplayLanguage {
    func ui(_ es: String, _ en: String) -> String { self == .spanish ? es : en }
}
