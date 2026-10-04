import Foundation

enum PrivacySupportConfiguration {
    // Publication and final destinations require the owner's approval.
    static let privacyPolicyURL: URL? = nil
    static let supportURL: URL? = nil

    static func validatedURL(_ value: String?) -> URL? {
        guard let value, let url = URL(string: value), url.scheme == "https",
              let host = url.host, !host.isEmpty, url.user == nil, url.password == nil,
              !value.contains("PLACEHOLDER"), !value.contains("[") else { return nil }
        return url
    }
}
