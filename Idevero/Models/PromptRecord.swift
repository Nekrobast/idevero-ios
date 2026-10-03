import Foundation
import SwiftData

@Model
final class PromptRecord {
    @Attribute(.unique) var id: UUID
    var title: String
    var originalIdea: String
    var generatedPrompt: String
    // Kept for compatibility with 0.1.0 stores. New code uses `task`.
    var strategy: String = "GENERAL"
    var task: String = "GENERAL"
    var intent: String = "TRANSFORM"
    var domain: String = "unknown"
    var target: String = "CHATGPT"
    var discoveriesData: Data = Data()
    var analysisData: Data = Data()
    var intelligenceMode: String = "LOCAL EXPERT"
    var createdAt: Date
    var updatedAt: Date = Date.now
    var isFavorite: Bool

    init(analysis: PromptAnalysis) {
        self.id = analysis.analysisID
        self.title = analysis.title
        self.originalIdea = analysis.input
        self.generatedPrompt = analysis.prompt
        self.task = analysis.task
        self.strategy = analysis.task
        self.intent = analysis.intent
        self.domain = analysis.domain
        self.target = analysis.target
        self.discoveriesData = (try? JSONEncoder().encode(analysis.discoveries)) ?? Data()
        self.analysisData = (try? JSONEncoder().encode(analysis)) ?? Data()
        self.intelligenceMode = analysis.intelligenceMode
        self.createdAt = .now
        self.updatedAt = .now
        self.isFavorite = false
    }

    var discoveries: [Discovery] { (try? JSONDecoder().decode([Discovery].self, from: discoveriesData)) ?? [] }

    func reconstructedAnalysis() -> PromptAnalysis {
        if let saved = try? JSONDecoder().decode(PromptAnalysis.self, from: analysisData) { return saved }
        let safeTask = task == "GENERAL" && strategy != "GENERAL" ? strategy : task
        return PromptAnalysis(
            analysisID: id,
            title: title,
            input: originalIdea,
            task: safeTask,
            intent: intent,
            domain: domain,
            secondaryDomains: [],
            target: target,
            outcome: "",
            elaboration: .light,
            discoveries: discoveries,
            unknowns: [],
            prompt: generatedPrompt,
            qualityNotes: ["Registro anterior: solo se conserva la información realmente almacenada."],
            intelligenceMode: intelligenceMode,
            analyzedAt: createdAt
        )
    }

    func update(from analysis: PromptAnalysis) {
        title = analysis.title; originalIdea = analysis.input; generatedPrompt = analysis.prompt
        task = analysis.task; strategy = analysis.task; intent = analysis.intent; domain = analysis.domain; target = analysis.target
        discoveriesData = (try? JSONEncoder().encode(analysis.discoveries)) ?? discoveriesData
        analysisData = (try? JSONEncoder().encode(analysis)) ?? analysisData
        intelligenceMode = analysis.intelligenceMode; updatedAt = .now
    }

    @discardableResult
    static func upsert(_ analysis: PromptAnalysis, in context: ModelContext) throws -> PromptRecord {
        if let existing = try context.fetch(FetchDescriptor<PromptRecord>())
            .first(where: { $0.id == analysis.analysisID }) {
            existing.update(from: analysis)
            try context.save()
            return existing
        }
        let record = PromptRecord(analysis: analysis)
        context.insert(record)
        try context.save()
        return record
    }
}
