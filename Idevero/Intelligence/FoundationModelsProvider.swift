import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

struct FoundationModelsProvider: IntelligenceProvider {
    let name = "Apple Foundation Models"
    private let fallback = LocalExpertProvider()

    func availability() async -> IntelligenceAvailability {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available: return .ready
            case .unavailable(let reason): return .unavailable(String(describing: reason))
            @unknown default: return .unavailable("Estado de disponibilidad no reconocido por esta versión.")
            }
        }
        #endif
        return .unavailable("Foundation Models no está disponible en este dispositivo o sistema.")
    }

    func analyze(_ request: String) async throws -> PromptAnalysis {
        try Task.checkCancellation()
        let local = try await fallback.analyze(request)
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *), case .ready = await availability() {
            let session = LanguageModelSession(instructions: """
            Actúa como motor de descubrimiento de requisitos. No escribas el prompt final. Complementa el análisis local con conocimiento de dominio material, relaciones, riesgos y desconocidos. No reformules lo ya indicado, no inventes datos y evita scope creep. Devuelve hallazgos breves y estructurados.
            """)
            let packet = """
            Petición: \(request)
            Tarea: \(local.task)
            Intención: \(local.intent)
            Dominio: \(local.domain)
            Descubrimientos locales: \(local.discoveries.map(\.concept).joined(separator: ", "))
            """
            let response = try await session.respond(to: packet, generating: ModelFindings.self)
            try Task.checkCancellation()
            return merge(local: local, findings: response.content)
        }
        #endif
        return local
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    @Generable
    struct ModelFinding {
        @Guide(description: "Short domain concept absent from the local discoveries")
        var concept: String
        @Guide(description: "One concise reason explaining material value")
        var reason: String
        @Guide(description: "Expert perspective that produced the finding")
        var lens: String
    }

    @available(iOS 26.0, *)
    @Generable
    struct ModelFindings {
        @Guide(description: "At most eight domain-specific, non-duplicative findings", .maximumCount(8))
        var discoveries: [ModelFinding]
        @Guide(description: "At most three material unknowns", .maximumCount(3))
        var unknowns: [String]
    }

    @available(iOS 26.0, *)
    private func merge(local: PromptAnalysis, findings: ModelFindings) -> PromptAnalysis {
        guard let store = try? KnowledgeStore.load() else { return local }
        let structured = findings.discoveries.map { SemanticFinding(concept: $0.concept, reason: $0.reason, lens: $0.lens) }
        let combined = AppleDiscoveryMerger(store: store).merge(local: local.discoveries, findings: structured)
        let uniqueUnknowns: [String] = Array(Set(local.unknowns + findings.unknowns))
        let unknowns: [String] = Array(uniqueUnknowns.prefix(5))
        var merged = PromptAnalysis(analysisID: local.analysisID, title: local.title, input: local.input, task: local.task, intent: local.intent, domain: local.domain, secondaryDomains: local.secondaryDomains, target: local.target, outcome: local.outcome, elaboration: local.elaboration, discoveries: combined, unknowns: unknowns, prompt: "", qualityNotes: local.qualityNotes, intelligenceMode: "APPLE AUGMENTED + LOCAL EXPERT", analyzedAt: .now)
        merged = PromptAnalysis(analysisID: merged.analysisID, title: merged.title, input: merged.input, task: merged.task, intent: merged.intent, domain: merged.domain, secondaryDomains: merged.secondaryDomains, target: merged.target, outcome: merged.outcome, elaboration: merged.elaboration, discoveries: merged.discoveries, unknowns: merged.unknowns, prompt: SpecializedCompiler().compile(merged), qualityNotes: merged.qualityNotes, intelligenceMode: merged.intelligenceMode, analyzedAt: merged.analyzedAt)
        return merged
    }
    #endif
}
