import Foundation

struct SemanticFinding: Sendable {
    let concept: String
    let reason: String
    let lens: String
    let kind: String
    let materiality: String
    let userIntentFit: String
    let scopeRisk: String

    init(concept: String, reason: String, lens: String, kind: String = "DOMAIN_DATA", materiality: String = "HIGH", userIntentFit: String = "HIGH", scopeRisk: String = "LOW") {
        self.concept = concept; self.reason = reason; self.lens = lens; self.kind = kind
        self.materiality = materiality; self.userIntentFit = userIntentFit; self.scopeRisk = scopeRisk
    }
}

struct AppleDiscoveryMerger: Sendable {
    let store: KnowledgeStore
    func merge(local: [Discovery], findings: [SemanticFinding], request: String = "") -> [Discovery] {
        let deduplicator = LocalSemanticDeduplicator(store: store)
        var accepted = local
        for (index, item) in findings.enumerated() {
            guard passesQualityGate(item, request: request, deduplicator: deduplicator) else { continue }
            if let known = deduplicator.canonicalConcept(for: item.concept),
               let existingIndex = accepted.firstIndex(where: { $0.id == "K_\(known.id)" || deduplicator.canonicalConcept(for: $0.concept)?.id == known.id }) {
                let current = accepted[existingIndex]
                var sources = current.sourceProvenance ?? [current.provenance]
                if !sources.contains(.appleModel) { sources.append(.appleModel) }
                let appleAddsDepth = specificity(item.reason, deduplicator: deduplicator) > specificity(current.reason, deduplicator: deduplicator) + 1
                accepted[existingIndex] = Discovery(
                    id: current.id,
                    concept: current.concept,
                    reason: appleAddsDepth ? item.reason.trimmingCharacters(in: .whitespacesAndNewlines) : current.reason,
                    lens: appleAddsDepth ? item.lens.trimmingCharacters(in: .whitespacesAndNewlines) : current.lens,
                    priority: current.priority,
                    provenance: current.provenance,
                    state: current.state,
                    dependencies: current.dependencies,
                    confidence: current.confidence,
                    sourceProvenance: sources
                )
                continue
            }
            if let discovery = deduplicator.appleDiscovery(index: index, concept: item.concept, reason: item.reason, lens: item.lens, existing: accepted) { accepted.append(discovery) }
        }
        return accepted
    }

    private func passesQualityGate(_ item: SemanticFinding, request: String, deduplicator: LocalSemanticDeduplicator) -> Bool {
        let concept = deduplicator.normalized(item.concept)
        let reason = item.reason.trimmingCharacters(in: .whitespacesAndNewlines)
        let kind = item.kind.uppercased(), materiality = item.materiality.uppercased()
        guard concept.split(separator: " ").count >= 2, reason.count >= 28 else { return false }
        guard materiality != "LOW", item.userIntentFit.uppercased() != "LOW", item.scopeRisk.uppercased() != "HIGH" else { return false }
        let allowedKinds = Set(["WORKFLOW", "ENTITY", "RELATIONSHIP", "DECISION", "DOMAIN_DATA", "CONSTRAINT", "FAILURE_MODE", "RISK", "ACCEPTANCE_CRITERION", "OPERATIONAL_CONTEXT"])
        guard allowedKinds.contains(kind) else { return false }
        let requestValue = deduplicator.normalized(request)
        if !requestValue.isEmpty && (concept == requestValue || tokenSimilarity(concept, requestValue) > 0.88) { return false }
        return specificity(reason, deduplicator: deduplicator) >= 3
    }

    private func tokenSimilarity(_ left: String, _ right: String) -> Double {
        let a = Set(left.split(separator: " ")), b = Set(right.split(separator: " "))
        guard !a.isEmpty, !b.isEmpty else { return 0 }
        return Double(a.intersection(b).count) / Double(a.union(b).count)
    }

    private func specificity(_ value: String, deduplicator: LocalSemanticDeduplicator) -> Int {
        let normalized = deduplicator.normalized(value)
        let tokens = normalized.split(separator: " ")
        let distinct = Set(tokens)
        var score = min(distinct.count / 4, 4)
        if value.contains(",") || value.contains(";") { score += 1 }
        if tokens.count >= 12 { score += 1 }
        if value.range(of: "\\b(permite|vincula|relaciona|depende|evita|determina|registra|conserva|requires|links|depends|records|prevents|determines)\\b", options: [.regularExpression, .caseInsensitive]) != nil { score += 1 }
        return score
    }
}
