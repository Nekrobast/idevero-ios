import Foundation

/// Priority alternatives need independent user evidence, not a model's sector
/// associations, confidence, anchors or self-declared epistemic status.
struct PrimaryJobEvidence {
    let request: String
    var authority: [Discovery] = []

    private static let actions: [String: String] = {
        let groups = [
            "manage": ["gestionar", "gestion", "administrar", "manage", "managing", "management"],
            "track": ["seguir", "seguimiento", "track", "tracking", "monitor", "monitoring"],
            "record": ["registrar", "registro", "record", "recording", "register", "registering"],
            "control": ["controlar", "control", "controlling"],
            "inspect": ["inspeccionar", "revisar", "inspect", "inspecting", "review", "reviewing"],
            "compare": ["comparar", "compare", "comparing"],
            "coordinate": ["coordinar", "coordinate", "coordinating"],
            "schedule": ["programar", "schedule", "scheduling"],
            "assign": ["asignar", "assign", "assigning"],
            "organize": ["organizar", "organize", "organizing", "organise", "organising"],
            "plan": ["planificar", "plan", "planning"]
        ]
        return Dictionary(uniqueKeysWithValues: groups.flatMap { key, words in words.map { ($0, key) } })
    }()

    private func tokens(_ text: String) -> [String] {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .replacingOccurrences(of: "[^a-z0-9]+", with: " ", options: .regularExpression)
            .split(separator: " ").map(String.init)
    }

    private func objective(_ text: String, inherited: String? = nil) -> (action: String, objects: Set<String>)? {
        let words = tokens(text)
        let index = words.firstIndex { Self.actions[$0] != nil }
        guard let action = index.flatMap({ Self.actions[words[$0]] }) ?? inherited else { return nil }
        let content = index.map { Array(words.dropFirst($0 + 1)) } ?? words
        let stop: Set<String> = ["de", "del", "la", "las", "el", "los", "un", "una", "unos", "unas", "para", "por", "con", "y", "the", "a", "an", "of", "for", "with", "and", "their", "each", "app", "application", "aplicacion"]
        let objects = Set(content.filter { $0.count > 2 && !stop.contains($0) }.map { word in
            word.count > 4 && word.hasSuffix("s") ? String(word.dropLast()) : word
        })
        return objects.isEmpty ? nil : (action, objects)
    }

    private var explicitObjectives: [(action: String, objects: Set<String>)] {
        let clauses = request.replacingOccurrences(of: "\\b(?:and|y|e)\\b|[;,]", with: "\n", options: [.regularExpression, .caseInsensitive]).components(separatedBy: "\n")
        var inherited: String?
        return clauses.compactMap { clause in
            guard let value = objective(clause, inherited: inherited) else { return nil }
            inherited = value.action
            return value
        }
    }

    func candidates(_ proposed: [String]) -> [String] {
        let trusted = authority.filter {
            DiscoverySemantics.isCompilerIncluded($0) &&
            [.userExplicit, .userAccepted, .userLocked].contains($0.provenance) &&
            $0.semanticRole == SemanticRole.coreWorkflow.rawValue
        }.map(\.concept)
        let evidence = explicitObjectives + trusted.compactMap { objective($0) }
        let policy = UserFacingTextPolicy(language: .detect(in: request))
        var seen = Set<String>()
        return Array((proposed + trusted).filter { text in
            guard policy.isNaturalJob(text), let value = objective(text) else { return false }
            // Every material object must be supported under the same action.
            // Sharing a sector noun or an unrelated verb is insufficient.
            let supported = evidence.filter { $0.action == value.action }.reduce(into: Set<String>()) { $0.formUnion($1.objects) }
            guard value.objects.isSubset(of: supported) else { return false }
            return seen.insert(value.action + "|" + value.objects.sorted().joined(separator: ".")).inserted
        }.prefix(3))
    }

    static func validate(_ analysis: PromptAnalysis) -> PromptAnalysis {
        guard let context = analysis.domainContext, context.primaryJobStatus == "UNDERSPECIFIED" else { return analysis }
        let values = PrimaryJobEvidence(request: analysis.input, authority: analysis.discoveries).candidates(context.primaryJobCandidates)
        let jobs = values.count >= 2 ? values : []
        let validated = DomainContext(language: context.language, primaryJobStatus: context.primaryJobStatus, primaryJobCandidates: jobs, actors: context.actors, entities: context.entities, relationships: context.relationships, workflows: context.workflows, decisions: context.decisions, constraints: context.constraints, calibratedItems: context.calibratedItems, lifecycle: context.lifecycle)
        let frame = SemanticDomainFrame(primaryJobStatus: "UNDERSPECIFIED", primaryJobCandidates: jobs, actors: [], entities: [], relationships: [], workflows: [], decisions: [], constraints: [])
        let question = AppleUnknownSelector().select([], frame: frame, findings: [], language: .detect(in: analysis.input))
        let remaining = analysis.unknowns.filter { text in
            text.range(of: "trabajo principal|problema principal|primary job|primary problem", options: [.regularExpression, .caseInsensitive]) == nil &&
            !context.primaryJobCandidates.contains { text.localizedCaseInsensitiveContains($0) }
        }
        return PromptAnalysis(analysisID: analysis.analysisID, title: analysis.title, input: analysis.input, task: analysis.task, intent: analysis.intent, domain: analysis.domain, secondaryDomains: analysis.secondaryDomains, target: analysis.target, outcome: analysis.outcome, elaboration: analysis.elaboration, discoveries: analysis.discoveries, unknowns: Array((question + remaining).prefix(3)), prompt: analysis.prompt, qualityNotes: analysis.qualityNotes, intelligenceMode: analysis.intelligenceMode, analyzedAt: analysis.analyzedAt, domainContext: validated)
    }
}
