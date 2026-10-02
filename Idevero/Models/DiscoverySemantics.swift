import Foundation

/// Single source of truth for user-controlled discovery state.
enum DiscoverySemantics {
    static func identity(_ discovery: Discovery) -> String {
        identity(concept: discovery.concept, role: discovery.semanticRole ?? "", anchor: discovery.anchor ?? "")
    }

    static func identity(concept: String, role: String = "", anchor: String = "") -> String {
        let source = anchor.isEmpty ? concept : concept + " " + anchor
        let families: [String: String] = [
            "historial":"history", "historico":"history", "historica":"history", "historical":"history", "history":"history", "registro":"history", "record":"history",
            "revision":"inspection", "revisiones":"inspection", "inspeccion":"inspection", "inspecciones":"inspection", "inspection":"inspection", "inspections":"inspection",
            "unidad":"unit", "unidades":"unit", "unit":"unit", "units":"unit"
        ]
        let stop: Set<String> = ["de","del","la","las","el","los","por","para","cada","un","una","the","of","for","each","a","an"]
        let raw = source.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "[^a-z0-9]+", with: " ", options: .regularExpression)
            .split(separator: " ").map(String.init)
        let atoms = Set(raw.compactMap { token -> String? in
            guard token.count > 2, !stop.contains(token) else { return nil }
            return families[token] ?? token
        }).sorted().joined(separator: ".")
        return (role.isEmpty ? "finding" : role.lowercased()) + "|" + atoms
    }
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
