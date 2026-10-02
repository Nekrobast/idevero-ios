import Foundation

/// Single source of truth for user-controlled discovery state.
enum DiscoverySemantics {
    static func transition(_ discovery: Discovery, to state: DiscoveryState) -> Discovery {
        var result = discovery
        result.state = state

        switch state {
        case .included:
            result.priority = result.priority == .core ? .core : .highValue
            if result.provenance != .userExplicit && result.provenance != .userLocked {
                result.provenance = .userAccepted
            }
        case .locked:
            result.priority = .core
            result.provenance = .userLocked
        case .excluded:
            result.priority = .outOfScope
        case .optional, .pending:
            result.priority = .optional
        }
        return result
    }

    static func isCompilerIncluded(_ discovery: Discovery) -> Bool {
        discovery.state == .included || discovery.state == .locked
    }
}
