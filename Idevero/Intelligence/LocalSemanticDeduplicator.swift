import Foundation

struct LocalSemanticDeduplicator: Sendable {
    let store: KnowledgeStore

    func normalized(_ value: String) -> String {
        value.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .replacingOccurrences(of: "[^a-z0-9]+", with: " ", options: .regularExpression)
            .split(separator: " ").map(String.init).joined(separator: " ")
    }

    func canonicalConcept(for label: String) -> ConceptResource? {
        let needle = normalized(label)
        guard !needle.isEmpty else { return nil }
        let exact = store.concepts.first { concept in
            ([concept.id, concept.labels.es, concept.labels.en] + concept.aliases).contains { normalized($0) == needle }
        }
        if let exact { return exact }

        // Conservative semantic match: nearly identical token sets only.
        let needleTokens = Set(needle.split(separator: " ").map(String.init))
        guard needleTokens.count > 1 else { return nil }
        return store.concepts.compactMap { concept -> (ConceptResource, Double)? in
            let aliases = [concept.labels.es, concept.labels.en] + concept.aliases
            let score = aliases.map { candidate -> Double in
                let tokens = Set(normalized(candidate).split(separator: " ").map(String.init))
                guard !tokens.isEmpty else { return 0 }
                return Double(needleTokens.intersection(tokens).count) / Double(needleTokens.union(tokens).count)
            }.max() ?? 0
            return score >= 0.85 ? (concept, score) : nil
        }.sorted { $0.1 > $1.1 }.first?.0
    }

    func isDuplicate(_ candidate: String, of discoveries: [Discovery]) -> Bool {
        let value = normalized(candidate)
        if discoveries.contains(where: { normalized($0.concept) == value }) { return true }
        guard let canonical = canonicalConcept(for: candidate) else { return false }
        return discoveries.contains { item in
            item.id == "K_\(canonical.id)" || canonicalConcept(for: item.concept)?.id == canonical.id
        }
    }

    func appleDiscovery(index: Int, concept: String, reason: String, lens: String, existing: [Discovery]) -> Discovery? {
        let clean = concept.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty, !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !isDuplicate(clean, of: existing) else { return nil }
        if let known = canonicalConcept(for: clean) {
            return Discovery(id: "K_\(known.id)", concept: known.labels.es, reason: reason, lens: lens, priority: .highValue, provenance: .appleModel, state: .included, dependencies: known.requires ?? [], confidence: "HIGH", sourceProvenance: [.localKnowledge, .appleModel])
        }
        // The identifier must not depend on response ordering: locks and exclusions
        // need to survive a later semantic pass that returns the same concept in a
        // different position.
        return Discovery(id: "APPLE_EXTERNAL_\(stableSuffix(clean))", concept: clean, reason: reason, lens: lens, priority: .highValue, provenance: .appleModel, state: .included, dependencies: [], confidence: "MEDIUM", sourceProvenance: [.appleModel])
    }

    private func stableSuffix(_ value: String) -> String {
        var hash: UInt64 = 1469598103934665603
        for byte in normalized(value).utf8 { hash = (hash ^ UInt64(byte)) &* 1099511628211 }
        return String(hash, radix: 16)
    }
}
