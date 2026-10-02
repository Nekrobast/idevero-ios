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
    var contextItems: [SemanticDomainItem] = []

    var anchors: [String] { actors + entities + relationships + workflows + decisions + constraints }
}

struct SemanticDomainItem: Sendable {
    let kind: String
    let text: String
    let epistemicStatus: String
    let decisionRelevance: String
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
    let domainSpecificity: String
    let professionalRelevance: String
    let caseDependency: String
    let domainMechanism: String

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
        scopeRisk: String = "LOW",
        domainSpecificity: String = "UNASSESSED",
        professionalRelevance: String = "HIGH",
        caseDependency: String = "GENERAL",
        domainMechanism: String = ""
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
        self.domainSpecificity = domainSpecificity
        self.professionalRelevance = professionalRelevance
        self.caseDependency = caseDependency
        self.domainMechanism = domainMechanism.isEmpty ? reason : domainMechanism
    }
}

struct SemanticUnknown: Sendable {
    let question: String
    let reason: String
    let architectureImpact: String
    let workflowImpact: String
    let scopeImpact: String
    let level: String
    let dependsOnPrimaryJob: Bool

    init(question: String, reason: String, architectureImpact: String, workflowImpact: String, scopeImpact: String, level: String = "DOMAIN_DETAIL", dependsOnPrimaryJob: Bool = false) {
        self.question = question
        self.reason = reason
        self.architectureImpact = architectureImpact
        self.workflowImpact = workflowImpact
        self.scopeImpact = scopeImpact
        self.level = level
        self.dependsOnPrimaryJob = dependsOnPrimaryJob
    }
}

enum DisplayLanguage: String, Codable, Sendable {
    case spanish = "es"
    case english = "en"

    static func detect(in request: String) -> DisplayLanguage {
        let value = request.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        let spanish = ["quiero", "para", "una", "un", "crear", "necesito", "aplicacion", "organizar", "mejora", "comprar"].filter { value.range(of: "\\b\($0)\\b", options: .regularExpression) != nil }.count
        let english = ["i", "want", "for", "an", "a", "create", "need", "organize", "improve", "buy"].filter { value.range(of: "\\b\($0)\\b", options: .regularExpression) != nil }.count
        return english > spanish ? .english : .spanish
    }
}

struct UserFacingTextPolicy: Sendable {
    let language: DisplayLanguage

    func isSafeDisplay(_ value: String, minimumLength: Int = 3) -> Bool {
        let clean = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard clean.count >= minimumLength, !containsMachineToken(clean), !containsSyntheticPlaceholder(clean) else { return false }
        return isLanguageConsistent(clean)
    }

    func isNaturalJob(_ value: String) -> Bool {
        guard isSafeDisplay(value, minimumLength: 8) else { return false }
        let words = value.split(whereSeparator: { $0.isWhitespace })
        guard words.count >= 3 else { return false }
        let normalized = value.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        let activitySignals = language == .spanish
            ? ["gest", "segu", "control", "plan", "organ", "registr", "revis", "coord", "administr", "supervis", "oper"]
            : ["manag", "track", "monitor", "plan", "organ", "record", "inspect", "coordin", "administ", "operat"]
        return activitySignals.contains { normalized.contains($0) }
    }

    func containsMachineToken(_ value: String) -> Bool {
        let expression = try? NSRegularExpression(pattern: "\\b[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)+\\b")
        let range = NSRange(value.startIndex..<value.endIndex, in: value)
        let matches = expression?.matches(in: value, range: range).compactMap { match -> String? in
            guard let swiftRange = Range(match.range, in: value) else { return nil }
            return String(value[swiftRange])
        } ?? []
        return matches.contains { token in
            let parts = token.split(separator: "_").map(String.init)
            let internalRoles = Set(SemanticRole.allCases.map(\.rawValue))
            if internalRoles.contains(token) { return true }
            let modelWords: Set<String> = ["PRIMARY", "SECONDARY", "OPTIONAL", "FEATURE", "JOB", "UNKNOWN", "PLACEHOLDER", "DECISION", "INPUT", "CANDIDATE"]
            let looksSynthetic = parts.contains(where: { modelWords.contains($0) }) &&
                (parts.last?.count == 1 || parts.contains("JOB") || parts.contains("FEATURE") || parts.contains("PLACEHOLDER"))
            if looksSynthetic { return true }
            // Standards, field identifiers and protocol names typically consist of
            // short acronym/number segments. They are content, not model metadata.
            return !parts.allSatisfy { part in
                part.range(of: "^[A-Z]{2,5}[0-9]*$", options: .regularExpression) != nil ||
                part.range(of: "^[0-9]{2,6}$", options: .regularExpression) != nil
            }
        }
    }

    func displayLens(for role: SemanticRole) -> String {
        switch (language, role) {
        case (.spanish, .domainPrimitive): return "Estructura del dominio"
        case (.spanish, .coreWorkflow): return "Flujo del dominio"
        case (.spanish, .decisionInput): return "Decisión profesional"
        case (.spanish, .constraint): return "Restricción operativa"
        case (.spanish, .failureMode): return "Riesgo operativo"
        case (.spanish, .contextDependent): return "Contexto por confirmar"
        case (.spanish, .optionalFeature): return "Posibilidad opcional"
        case (.spanish, .businessOpportunity): return "Oportunidad fuera del alcance"
        case (.english, .domainPrimitive): return "Domain structure"
        case (.english, .coreWorkflow): return "Domain workflow"
        case (.english, .decisionInput): return "Professional decision"
        case (.english, .constraint): return "Operational constraint"
        case (.english, .failureMode): return "Operational risk"
        case (.english, .contextDependent): return "Context to confirm"
        case (.english, .optionalFeature): return "Optional possibility"
        case (.english, .businessOpportunity): return "Out-of-scope opportunity"
        }
    }

    private func containsSyntheticPlaceholder(_ value: String) -> Bool {
        value.range(of: "(?:PRIMARY|SECONDARY|OPTION|PLACEHOLDER|UNKNOWN)[-_ ]?[A-Z0-9]+", options: .regularExpression) != nil ||
        value.range(of: "[<{][A-Z0-9_ -]{3,}[>}]", options: .regularExpression) != nil
    }

    private func isLanguageConsistent(_ value: String) -> Bool {
        guard value.split(whereSeparator: { $0.isWhitespace }).count >= 2 else { return true }
        let normalized = value.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).lowercased()
        let spanishWords = ["que", "para", "del", "de", "la", "el", "los", "las", "una", "como", "cual", "debe", "permite", "necesita", "cambia", "estado", "operativo", "gestion", "registro", "limites", "capacidad", "estacional"]
        let englishWords = ["what", "which", "the", "for", "with", "from", "should", "must", "does", "allows", "needs", "changes", "state", "operational", "management", "record", "limits", "capacity", "seasonal"]
        func score(_ words: [String]) -> Int { words.filter { normalized.range(of: "\\b\($0)\\b", options: .regularExpression) != nil }.count }
        let es = score(spanishWords), en = score(englishWords)
        return language == .spanish ? !(en >= 2 && es == 0) : !(es >= 2 && en == 0)
    }
}

struct DomainContextBuilder: Sendable {
    func build(frame: SemanticDomainFrame, language: DisplayLanguage, originalRequest: String = "", resolvedTask: String = "", resolvedDomain: String = "") -> DomainContext? {
        let policy = UserFacingTextPolicy(language: language)
        let semantic = DomainGroundingValidator(request: originalRequest, task: resolvedTask, domain: resolvedDomain)
        func selected(_ values: [String], maximum: Int) -> [String] {
            var seen = Set<String>()
            return values.compactMap { value -> String? in
                let clean = value.trimmingCharacters(in: .whitespacesAndNewlines)
                let key = clean.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
                guard policy.isSafeDisplay(clean), seen.insert(key).inserted else { return nil }
                return clean
            }.prefix(maximum).map { $0 }
        }
        var jobs = selected(frame.primaryJobCandidates, maximum: 3).filter { policy.isNaturalJob($0) && semantic.supports($0, frame: frame) }
        if Set(jobs.map { $0.lowercased() }).count < 2 { jobs = [] }
        let calibrated = frame.contextItems.compactMap { item -> DomainContextItem? in
            let clean = item.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard policy.isSafeDisplay(clean) else { return nil }
            guard let status = DomainKnowledgeStatus(rawValue: item.epistemicStatus.uppercased()), status != .unsupported else { return nil }
            guard semantic.supports(item.text, frame: frame, declaredStatus: status) else { return nil }
            let relevance = item.decisionRelevance.uppercased()
            guard relevance != "LOW" else { return nil }
            return DomainContextItem(kind: item.kind.uppercased(), text: clean, status: status, decisionRelevance: relevance)
        }
        var calibratedSeen = Set<String>()
        let uniqueCalibrated = Array(calibrated.filter {
            calibratedSeen.insert($0.text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)).inserted
        }.prefix(12))
        let rawActors = selected(frame.actors, maximum: 3).filter { semantic.supports($0, frame: frame) }
        let rawEntities = selected(frame.entities, maximum: 5).filter { semantic.supports($0, frame: frame) }
        let rawRelationships = selected(frame.relationships, maximum: 4).filter { semantic.supports($0, frame: frame) }
        let rawWorkflows = selected(frame.workflows, maximum: 3).filter { semantic.supports($0, frame: frame) }
        let rawDecisions = selected(frame.decisions, maximum: 3).filter { semantic.supports($0, frame: frame) }
        let rawConstraints = selected(frame.constraints, maximum: 3).filter { semantic.supports($0, frame: frame) }
        let hasRawContext = !jobs.isEmpty || !rawActors.isEmpty || !rawEntities.isEmpty ||
            !rawRelationships.isEmpty || !rawWorkflows.isEmpty || !rawDecisions.isEmpty || !rawConstraints.isEmpty
        let lifecycle: DomainFrameLifecycle
        if !uniqueCalibrated.isEmpty {
            lifecycle = .valid
        } else if !frame.contextItems.isEmpty {
            lifecycle = .rejected
        } else {
            lifecycle = hasRawContext ? .valid : .empty
        }
        let context = DomainContext(
            language: language.rawValue,
            primaryJobStatus: frame.primaryJobStatus.uppercased() == "DEFINED" ? "DEFINED" : "UNDERSPECIFIED",
            primaryJobCandidates: jobs,
            actors: rawActors,
            entities: rawEntities,
            relationships: rawRelationships,
            workflows: rawWorkflows,
            decisions: rawDecisions,
            constraints: rawConstraints,
            calibratedItems: uniqueCalibrated.isEmpty ? nil : uniqueCalibrated,
            lifecycle: lifecycle
        )
        return context
    }
}

/// Deterministic grounding gate. Model declarations are claims, never proof.
/// Unknown-domain detail is admitted only when it is supported by an accepted
/// calibrated item or shares evidence with the request/resolved classification.
struct DomainGroundingValidator: Sendable {
    let request: String
    let task: String
    let domain: String

    func supports(_ value: String, frame: SemanticDomainFrame, declaredStatus: DomainKnowledgeStatus? = nil) -> Bool {
        let candidate = tokens(value)
        guard !candidate.isEmpty else { return false }
        let evidence = tokens([request, task, domain].joined(separator: " "))
        if evidence.isEmpty { return true } // Explicit legacy/no-grounding compatibility.
        if !candidate.intersection(evidence).isEmpty { return true }
        if let declaredStatus, declaredStatus == .caseDependent || declaredStatus == .userSpecificUnknown { return true }
        // A calibrated ESTABLISHED claim remains inferred, but may be carried as
        // context when the model supplied an explicit, decision-relevant item.
        if declaredStatus == .established { return true }
        let calibrated = frame.contextItems.filter { $0.epistemicStatus.uppercased() != "UNSUPPORTED" }.flatMap { tokens($0.text) }
        return !candidate.intersection(Set(calibrated)).isEmpty
    }

    private func tokens(_ value: String) -> Set<String> {
        let stop: Set<String> = ["de","del","la","las","el","los","para","por","una","un","the","of","for","a","an","app","application","aplicacion"]
        let normalized = value.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "[^a-z0-9]+", with: " ", options: .regularExpression)
        return Set(normalized.split(separator: " ").map(String.init).filter { $0.count > 2 && !stop.contains($0) })
    }
}

struct AppleUnknownSelector: Sendable {
    func select(_ unknowns: [SemanticUnknown], frame: SemanticDomainFrame, findings: [SemanticFinding], language: DisplayLanguage = .spanish) -> [String] {
        let policy = UserFacingTextPolicy(language: language)
        var candidates = unknowns.filter { impactScore($0) >= 3 && informative($0, policy: policy) }

        if frame.primaryJobStatus.uppercased() == "UNDERSPECIFIED" {
            let options = frame.primaryJobCandidates.filter(policy.isNaturalJob).prefix(3)
            let question: String
            if options.count >= 2 {
                let joined = options.joined(separator: "; ")
                question = language == .spanish
                    ? "¿Qué trabajo principal debe resolver primero la aplicación: \(joined)?"
                    : "Which primary job should the application solve first: \(joined)?"
            } else {
                question = language == .spanish
                    ? "¿Cuál es el problema principal que debe resolver primero la aplicación?"
                    : "What is the primary problem the application should solve first?"
            }
            candidates.insert(
                SemanticUnknown(
                    question: question,
                    reason: language == .spanish ? "La elección cambia el flujo principal, el modelo de información y el alcance del producto." : "The choice changes the primary workflow, information model and product scope.",
                    architectureImpact: "HIGH",
                    workflowImpact: "HIGH",
                    scopeImpact: "HIGH",
                    level: "PRIMARY_JOB",
                    dependsOnPrimaryJob: false
                ),
                at: 0
            )
        }

        for finding in findings where finding.requiresConfirmation || finding.assumptionLevel.uppercased() == "HIGH" {
            guard finding.decisionImpact.uppercased() == "HIGH" else { continue }
            guard policy.isSafeDisplay(finding.concept), policy.isSafeDisplay(finding.reason, minimumLength: 12) else { continue }
            candidates.append(
                SemanticUnknown(
                    question: language == .spanish ? "¿Debe incluir el alcance inicial \(finding.concept.lowercased())?" : "Should the initial scope include \(finding.concept.lowercased())?",
                    reason: finding.reason,
                    architectureImpact: "MEDIUM",
                    workflowImpact: finding.semanticRole == SemanticRole.coreWorkflow.rawValue ? "HIGH" : "MEDIUM",
                    scopeImpact: "HIGH",
                    level: "SCOPE",
                    dependsOnPrimaryJob: true
                )
            )
        }

        // When the product direction itself is unresolved, downstream operational
        // questions have poor information value and may encode a false premise.
        if frame.primaryJobStatus.uppercased() == "UNDERSPECIFIED" {
            candidates = candidates.filter { $0.level.uppercased() == "PRIMARY_JOB" || !$0.dependsOnPrimaryJob && $0.level.uppercased() == "PRODUCT_DIRECTION" }
        }

        var seen = Set<String>()
        return candidates
            .sorted {
                let left = levelRank($0.level), right = levelRank($1.level)
                return left == right ? impactScore($0) > impactScore($1) : left < right
            }
            .compactMap { item in
                guard policy.isSafeDisplay(item.question, minimumLength: 12) else { return nil }
                let key = normalized(item.question)
                guard !key.isEmpty, seen.insert(key).inserted else { return nil }
                return item.question.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .prefix(frame.primaryJobStatus.uppercased() == "UNDERSPECIFIED" ? 1 : 3)
            .map { $0 }
    }

    private func levelRank(_ value: String) -> Int {
        switch value.uppercased() {
        case "PRIMARY_JOB", "PRODUCT_DIRECTION": return 0
        case "CORE_WORKFLOW", "ARCHITECTURE": return 1
        case "SCOPE": return 2
        default: return 3
        }
    }

    private func impactScore(_ item: SemanticUnknown) -> Int {
        [item.architectureImpact, item.workflowImpact, item.scopeImpact].reduce(0) { total, value in
            total + (value.uppercased() == "HIGH" ? 2 : value.uppercased() == "MEDIUM" ? 1 : 0)
        }
    }

    private func informative(_ item: SemanticUnknown, policy: UserFacingTextPolicy) -> Bool {
        item.question.trimmingCharacters(in: .whitespacesAndNewlines).count >= 12 &&
        item.reason.trimmingCharacters(in: .whitespacesAndNewlines).count >= 20 &&
        policy.isSafeDisplay(item.question, minimumLength: 12) && policy.isSafeDisplay(item.reason, minimumLength: 12)
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
        let displayPolicy = UserFacingTextPolicy(language: .detect(in: request))
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
                    lens: appleAddsDepth ? displayPolicy.displayLens(for: SemanticRole(rawValue: item.semanticRole.uppercased()) ?? .domainPrimitive) : current.lens,
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

            guard var discovery = deduplicator.appleDiscovery(index: index, concept: item.concept, reason: item.reason, lens: displayPolicy.displayLens(for: SemanticRole(rawValue: item.semanticRole.uppercased()) ?? .domainPrimitive), existing: accepted, semanticRole: item.semanticRole, anchor: item.anchor) else { continue }
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
        let policy = UserFacingTextPolicy(language: .detect(in: request))
        guard policy.isSafeDisplay(item.concept), policy.isSafeDisplay(reason, minimumLength: 18), policy.isSafeDisplay(item.anchor) else { return nil }

        let requestValue = deduplicator.normalized(request)
        if !requestValue.isEmpty && (concept == requestValue || tokenSimilarity(concept, requestValue) > 0.88) { return nil }

        guard hasValidAnchor(item, role: role, frame: frame, deduplicator: deduplicator) else { return nil }
        guard item.scopeRisk.uppercased() != "HIGH", item.userIntentFit.uppercased() != "LOW" else { return nil }
        guard item.domainSpecificity.uppercased() != "LOW", item.professionalRelevance.uppercased() != "LOW" else { return nil }
        guard !isDomainWashed(item, frame: frame, deduplicator: deduplicator) else { return nil }
        guard specificity(reason, deduplicator: deduplicator) >= 1 else { return nil }

        if role == .businessOpportunity { return nil }
        if item.requiresConfirmation || item.assumptionLevel.uppercased() == "HIGH" || item.caseDependency.uppercased() == "USER_SPECIFIC" { return nil }

        let scopeDependent = item.scopeDependency.uppercased() != "CORE"
        if role == .optionalFeature || role == .contextDependent || scopeDependent || item.assumptionLevel.uppercased() == "MEDIUM" {
            return (.optional, .optional)
        }

        let autoIncluded: Set<SemanticRole> = [.domainPrimitive, .coreWorkflow, .decisionInput, .constraint, .failureMode]
        guard autoIncluded.contains(role), item.decisionImpact.uppercased() != "LOW" else { return nil }
        return (item.materiality.uppercased() == "HIGH" ? .highValue : .optional,
                item.materiality.uppercased() == "HIGH" ? .included : .optional)
    }

    private func isDomainWashed(_ item: SemanticFinding, frame: SemanticDomainFrame?, deduplicator: LocalSemanticDeduplicator) -> Bool {
        if item.domainSpecificity.uppercased() == "UNASSESSED" { return false }
        guard item.domainSpecificity.uppercased() != "HIGH" else {
            let mechanism = deduplicator.normalized(item.domainMechanism)
            guard mechanism.split(separator: " ").count >= 4 else { return true }
            guard let frame else { return false }
            let anchors = frame.anchors.map(deduplicator.normalized).filter { !$0.isEmpty }
            return !anchors.contains { mechanism.contains($0) || tokenSimilarity(mechanism, $0) >= 0.25 }
        }
        return true
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
