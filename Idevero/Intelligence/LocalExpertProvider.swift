import Foundation

struct DiscoveryDecisions: Codable, Sendable {
    var locked: Set<String> = []; var excluded: Set<String> = []; var accepted: Set<String> = []
    var lockedSemantic: Set<String>? = nil
    var excludedSemantic: Set<String>? = nil
    var acceptedSemantic: Set<String>? = nil
    var authoritativeDiscoveries: [Discovery]? = nil
    var originalRequest: String? = nil
    var analysisID: UUID? = nil

    static func capture(_ analysis: PromptAnalysis) -> DiscoveryDecisions {
        let locked = analysis.discoveries.filter { $0.state == .locked }
        let excluded = analysis.discoveries.filter { $0.state == .excluded }
        let accepted = analysis.discoveries.filter { [.userAccepted, .userExplicit, .userLocked].contains($0.provenance) && $0.state == .included }
        return DiscoveryDecisions(locked: Set(locked.map(\.id)), excluded: Set(excluded.map(\.id)), accepted: Set(accepted.map(\.id)), lockedSemantic: Set(locked.map(DiscoverySemantics.identity)), excludedSemantic: Set(excluded.map(DiscoverySemantics.identity)), acceptedSemantic: Set(accepted.map(DiscoverySemantics.identity)), authoritativeDiscoveries: locked + excluded + accepted, originalRequest: analysis.input, analysisID: analysis.analysisID)
    }

    func scoped(to request: String) -> DiscoveryDecisions {
        guard let originalRequest else { return self }
        func normalize(_ value: String) -> String { value.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ").lowercased() }
        return normalize(originalRequest) == normalize(request) ? self : .init()
    }
}

struct LocalExpertProvider: LocalIntelligenceProvider {
    let name = "Local Expert"
    private let suppliedStore: KnowledgeStore?
    init(store: KnowledgeStore? = nil) { suppliedStore = store }
    func availability() async -> IntelligenceAvailability { .ready }
    func analyze(_ request: String) async throws -> PromptAnalysis { try analyze(request, decisions: .init()) }
    func analyze(_ request: String, decisions: DiscoveryDecisions) throws -> PromptAnalysis {
        let input = request.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { throw IntelligenceError.emptyRequest }
        return try LocalDiscoveryEngine(store: suppliedStore ?? KnowledgeStore.load()).analyze(input, decisions: decisions)
    }
    func recompile(_ analysis: PromptAnalysis) throws -> PromptAnalysis {
        let analysis = PrimaryJobEvidence.validate(analysis)
        let prompt = SpecializedCompiler().compile(analysis)
        return PromptAnalysis(analysisID: analysis.analysisID, title: analysis.title, input: analysis.input, task: analysis.task, intent: analysis.intent, domain: analysis.domain, secondaryDomains: analysis.secondaryDomains, target: analysis.target, outcome: analysis.outcome, elaboration: analysis.elaboration, discoveries: analysis.discoveries, unknowns: analysis.unknowns, prompt: prompt, qualityNotes: analysis.qualityNotes, intelligenceMode: analysis.intelligenceMode, analyzedAt: analysis.analyzedAt, domainContext: analysis.domainContext)
    }
}
