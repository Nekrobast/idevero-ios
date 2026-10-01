import Foundation

enum SemanticRole: String, Sendable, CaseIterable {
    case domainPrimitive = "DOMAIN_PRIMITIVE"
    case coreWorkflow = "CORE_WORKFLOW"
    case decisionInput = "DECISION_INPUT"
    case constraint = "CONSTRAINT"
    case failureMode = "FAILURE_MODE"
    case contextDependent = "CONTEXT_DEPENDENT"
    case optionalFeature = "OPTIONAL_FEATURE"
    case businessOpportunity = "BUSINESS_OPPORTUNITY"
}

struct SemanticDomainFrame: Sendable {
    let primaryJobStatus: String
    let primaryJobCandidates: [String]
    let actors: [String]
    let entities: [String]
    let relationships: [String]
    let workflows: [String]
    let decisions: [String]
    let constraints: [String]

    var anchors: [String] { actors + entities + relationships + workflows + decisions + constraints }
}

struct SemanticFinding: Sendable {
    let concept: String
    let reason: String
    let lens: String
    let semanticRole: String
    let anchor: String
    let assumptionLevel: String
    let requiresConfirmation: Bool
    let scopeDependency: String
    let decisionImpact: String
    let materiality: String
    let userIntentFit: String
    let scopeRisk: String

    init(
        concept: String,
        reason: String,
        lens: String,
        semanticRole: String = "DOMAIN_PRIMITIVE",
        anchor: String = "",
        assumptionLevel: String = "LOW",
        requiresConfirmation: Bool = false,
        scopeDependency: String = "CORE",
        decisionImpact: String = "HIGH",
        materiality: String = "HIGH",
        userIntentFit: String = "HIGH",
        scopeRisk: String = "LOW"
    ) {
        self.concept = concept
        self.reason = reason
        self.lens = lens
        self.semanticRole = semanticRole
        self.anchor = anchor
        self.assumptionLevel = assumptionLevel
        self.requiresConfirmation = requiresConfirmation
        self.scopeDependency = scopeDependency
        self.decisionImpact = decisionImpact
        self.materiality = materiality
        self.userIntentFit = userIntentFit
        self.scopeRisk = scopeRisk
    }
}

struct SemanticUnknown: Sendable {
    let question: String
    let reason: String
    let architectureImpact: String
    let workflowImpact: String
    let scopeImpact: String
}

struct AppleUnknownSelector: Sendable {
    func select(_ unknowns: [SemanticUnknown], frame: SemanticDomainFrame, findings: [SemanticFinding]) -> [String] {
        var candidates = unknowns.filter { impactScore($0) >= 2 && informative($0) }

        if frame.primaryJobStatus.uppercased() == "UNDERSPECIFIED", !frame.primaryJobCandidates.isEmpty {
            let options = frame.primaryJobCandidates.prefix(3).joined(separator: ", ")
            candidates.insert(
                SemanticUnknown(
                    question: "¿Qué trabajo principal debe resolver primero el producto entre estas posibilidades: \(options)?",
                    reason: "La elección cambia el flujo principal, el modelo de información y el alcance del producto.",
                    architectureImpact: "HIGH",
                    workflowImpact: "HIGH",
                    scopeImpact: "HIGH"
                ),
                at: 0
            )
        }

        for finding in findings where finding.requiresConfirmation || finding.assumptionLevel.uppercased() == "HIGH" {
            guard finding.decisionImpact.uppercased() == "HIGH" else { continue }
            candidates.append(
                SemanticUnknown(
                    question: "¿Debe formar parte del alcance: \(finding.concept)?",
                    reason: finding.reason,
                    architectureImpact: "MEDIUM",
                    workflowImpact: finding.semanticRole == SemanticRole.coreWorkflow.rawValue ? "HIGH" : "MEDIUM",
                    scopeImpact: "HIGH"
                )
            )
        }

        var seen = Set<String>()
        return candidates
            .sorted { impactScore($0) > impactScore($1) }
            .compactMap { item in
                let key = normalized(item.question)
                guard !key.isEmpty, seen.insert(key).inserted else { return nil }
                return item.question.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .prefix(3)
            .map { $0 }
    }

    private func impactScore(_ item: SemanticUnknown) -> Int {
        [item.architectureImpact, item.workflowImpact, item.scopeImpact].reduce(0) { total, value in
            total + (value.uppercased() == "HIGH" ? 2 : value.uppercased() == "MEDIUM" ? 1 : 0)
        }
    }

    private func informative(_ item: SemanticUnknown) -> Bool {
        item.question.trimmingCharacters(in: .whitespacesAndNewlines).count >= 12 &&
        item.reason.trimmingCharacters(in: .whitespacesAndNewlines).count >= 20
    }

    private func normalized(_ value: String) -> String {
        value.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "[^a-z0-9]+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct AppleDiscoveryMerger: Sendable {
    let store: KnowledgeStore

    func merge(local: [Discovery], findings: [SemanticFinding], request: String = "", frame: SemanticDomainFrame? = nil) -> [Discovery] {
        let deduplicator = LocalSemanticDeduplicator(store: store)
        var accepted = local
        for (index, item) in findings.enumerated() {
            guard let disposition = disposition(for: item, request: request, frame: frame, deduplicator: deduplicator) else { continue }

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
                    sourceProvenance: sources,
                    semanticRole: item.semanticRole,
                    anchor: item.anchor
                )
                continue
            }

            guard var discovery = deduplicator.appleDiscovery(index: index, concept: item.concept, reason: item.reason, lens: item.lens, existing: accepted) else { continue }
            discovery.priority = disposition.priority
            discovery.state = disposition.state
            discovery.semanticRole = item.semanticRole
            discovery.anchor = item.anchor
            accepted.append(discovery)
        }
        return accepted
    }

    private func disposition(for item: SemanticFinding, request: String, frame: SemanticDomainFrame?, deduplicator: LocalSemanticDeduplicator) -> (priority: RequirementPriority, state: DiscoveryState)? {
        let concept = deduplicator.normalized(item.concept)
        let reason = item.reason.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let role = SemanticRole(rawValue: item.semanticRole.uppercased()) else { return nil }
        guard !concept.isEmpty, reason.count >= 18 else { return nil }

        let requestValue = deduplicator.normalized(request)
        if !requestValue.isEmpty && (concept == requestValue || tokenSimilarity(concept, requestValue) > 0.88) { return nil }

        guard hasValidAnchor(item, role: role, frame: frame, deduplicator: deduplicator) else { return nil }
        guard item.scopeRisk.uppercased() != "HIGH", item.userIntentFit.uppercased() != "LOW" else { return nil }
        guard specificity(reason, deduplicator: deduplicator) >= 1 else { return nil }

        if role == .businessOpportunity { return nil }
        if item.requiresConfirmation || item.assumptionLevel.uppercased() == "HIGH" { return nil }

        let scopeDependent = item.scopeDependency.uppercased() != "CORE"
        if role == .optionalFeature || role == .contextDependent || scopeDependent || item.assumptionLevel.uppercased() == "MEDIUM" {
            return (.optional, .optional)
        }

        let autoIncluded: Set<SemanticRole> = [.domainPrimitive, .coreWorkflow, .decisionInput, .constraint, .failureMode]
        guard autoIncluded.contains(role), item.decisionImpact.uppercased() != "LOW" else { return nil }
        return (item.materiality.uppercased() == "HIGH" ? .highValue : .optional,
                item.materiality.uppercased() == "HIGH" ? .included : .optional)
    }

    private func hasValidAnchor(_ item: SemanticFinding, role: SemanticRole, frame: SemanticDomainFrame?, deduplicator: LocalSemanticDeduplicator) -> Bool {
        let anchor = deduplicator.normalized(item.anchor)
        guard !anchor.isEmpty else { return false }
        guard let frame else { return true }
        let knownAnchors = frame.anchors.map(deduplicator.normalized)
        let concept = deduplicator.normalized(item.concept)
        return knownAnchors.contains { candidate in
            candidate == anchor || tokenSimilarity(candidate, anchor) >= 0.72 ||
            (role == .domainPrimitive && (candidate == concept || tokenSimilarity(candidate, concept) >= 0.72))
        }
    }

    private func tokenSimilarity(_ left: String, _ right: String) -> Double {
        let a = Set(left.split(separator: " ")), b = Set(right.split(separator: " "))
        guard !a.isEmpty, !b.isEmpty else { return 0 }
        return Double(a.intersection(b).count) / Double(a.union(b).count)
    }

    // Auxiliary text-quality signal only; never establishes relevance or scope.
    private func specificity(_ value: String, deduplicator: LocalSemanticDeduplicator) -> Int {
        let tokens = Set(deduplicator.normalized(value).split(separator: " "))
        var score = tokens.count >= 6 ? 1 : 0
        if tokens.count >= 12 { score += 1 }
        if value.range(of: "\\b(permite|vincula|relaciona|depende|evita|determina|registra|conserva|requires|links|depends|records|prevents|determines)\\b", options: [.regularExpression, .caseInsensitive]) != nil { score += 1 }
        return score
    }
}
