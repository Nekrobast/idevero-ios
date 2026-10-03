import Foundation

struct DiscoveryDecisions: Codable, Sendable {
    var locked: Set<String> = []; var excluded: Set<String> = []; var accepted: Set<String> = []
    var lockedSemantic: Set<String>? = nil
    var excludedSemantic: Set<String>? = nil
    var acceptedSemantic: Set<String>? = nil
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
        let prompt = SpecializedCompiler().compile(analysis)
        return PromptAnalysis(analysisID: analysis.analysisID, title: analysis.title, input: analysis.input, task: analysis.task, intent: analysis.intent, domain: analysis.domain, secondaryDomains: analysis.secondaryDomains, target: analysis.target, outcome: analysis.outcome, elaboration: analysis.elaboration, discoveries: analysis.discoveries, unknowns: analysis.unknowns, prompt: prompt, qualityNotes: analysis.qualityNotes, intelligenceMode: analysis.intelligenceMode, analyzedAt: analysis.analyzedAt, domainContext: analysis.domainContext)
    }
}
