import Foundation

struct SemanticFinding: Sendable { let concept: String; let reason: String; let lens: String }

struct AppleDiscoveryMerger: Sendable {
    let store: KnowledgeStore
    func merge(local: [Discovery], findings: [SemanticFinding]) -> [Discovery] {
        let deduplicator = LocalSemanticDeduplicator(store: store)
        var accepted = local
        for (index, item) in findings.enumerated() {
            if let known = deduplicator.canonicalConcept(for: item.concept),
               let existingIndex = accepted.firstIndex(where: { $0.id == "K_\(known.id)" || deduplicator.canonicalConcept(for: $0.concept)?.id == known.id }) {
                var sources = accepted[existingIndex].sourceProvenance ?? [accepted[existingIndex].provenance]
                if !sources.contains(.appleModel) { sources.append(.appleModel) }
                accepted[existingIndex].sourceProvenance = sources
                continue
            }
            if let discovery = deduplicator.appleDiscovery(index: index, concept: item.concept, reason: item.reason, lens: item.lens, existing: accepted) { accepted.append(discovery) }
        }
        return accepted
    }
}
