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
            Eres el especialista de dominio bajo demanda de IDEVERO. No escribas ni reescribas el prompt final.
            Complementa Local Expert con lo que una persona competente en el dominio sabría y el marco genérico no contiene: workflows, entidades, relaciones, decisiones, contexto operativo, datos materiales, restricciones, fallos, riesgos, criterios de aceptación y desconocidos que cambian el alcance.
            Cada hallazgo debe ser concreto, operativo y útil para esta tarea. Si al quitar el nombre del sector serviría igual para cualquier industria, omítelo. No repitas ni parafrasees la petición o los hallazgos locales. No propongas tecnología, integraciones o funciones sin una necesidad material.
            No conviertas posibilidades en hechos. Si una normativa, integración, dispositivo o condición depende del usuario, trátala como dato por confirmar y explica su impacto. Prioriza entre tres y seis hallazgos excelentes; usa menos si la tarea es simple.
            """)
            let packet = """
            Petición: \(request)
            Tarea: \(local.task)
            Intención: \(local.intent)
            Dominio: \(local.domain)
            Complejidad: \(local.elaboration.rawValue)
            Resultado local: \(local.outcome)
            Descubrimientos locales: \(local.discoveries.map(\.concept).joined(separator: ", "))
            Desconocidos locales: \(local.unknowns.joined(separator: ", "))

            Descubre solo conocimiento adicional que cambie materialmente el prompt. Respeta la forma de la tarea: conocimiento visual para IMAGE, operativo y relacional para SPREADSHEET, decisiones y restricciones para TRAVEL/SHOPPING/RESEARCH, y workflows/datos/relaciones para APPLICATION/WEB. Una tarea LIGHT debe permanecer compacta.
            """
            let inferenceStarted = Date.timeIntervalSinceReferenceDate
            let response = try await session.respond(to: packet, generating: ModelFindings.self)
            #if DEBUG
            print("IDEVERO_METRIC foundation_inference_ms=\(Int((Date.timeIntervalSinceReferenceDate - inferenceStarted) * 1000))")
            #endif
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
        @Guide(description: "Finding type: WORKFLOW, ENTITY, RELATIONSHIP, DECISION, DOMAIN_DATA, CONSTRAINT, FAILURE_MODE, RISK, ACCEPTANCE_CRITERION, or OPERATIONAL_CONTEXT")
        var kind: String
        @Guide(description: "Material impact if omitted: HIGH, MEDIUM, or LOW")
        var materiality: String
        @Guide(description: "Fit with the user's stated intent: HIGH, MEDIUM, or LOW")
        var userIntentFit: String
        @Guide(description: "Risk of unjustified scope expansion: LOW, MEDIUM, or HIGH")
        var scopeRisk: String
    }

    @available(iOS 26.0, *)
    @Generable
    struct ModelUnknown {
        @Guide(description: "Specific fact to confirm, phrased as a semantic placeholder or concise question")
        var question: String
        @Guide(description: "Why the answer changes architecture, workflow, or scope")
        var reason: String
        @Guide(description: "Decision impact: HIGH, MEDIUM, or LOW")
        var impact: String
    }

    @available(iOS 26.0, *)
    @Generable
    struct ModelFindings {
        @Guide(description: "At most six material, domain-specific, non-duplicative findings", .maximumCount(6))
        var discoveries: [ModelFinding]
        @Guide(description: "At most three unknowns whose answers materially change the result", .maximumCount(3))
        var unknowns: [ModelUnknown]
    }

    @available(iOS 26.0, *)
    private func merge(local: PromptAnalysis, findings: ModelFindings) -> PromptAnalysis {
        guard let store = try? KnowledgeStore.load() else { return local }
        let structured = findings.discoveries.map {
            SemanticFinding(concept: $0.concept, reason: $0.reason, lens: $0.lens, kind: $0.kind, materiality: $0.materiality, userIntentFit: $0.userIntentFit, scopeRisk: $0.scopeRisk)
        }
        let mergeStarted = Date.timeIntervalSinceReferenceDate
        let combined = AppleDiscoveryMerger(store: store).merge(local: local.discoveries, findings: structured, request: local.input)
        let appleUnknowns = findings.unknowns.compactMap { item -> String? in
            let question = item.question.trimmingCharacters(in: .whitespacesAndNewlines)
            let reason = item.reason.trimmingCharacters(in: .whitespacesAndNewlines)
            guard item.impact.uppercased() == "HIGH", question.count >= 8, reason.count >= 24 else { return nil }
            return question
        }
        let uniqueUnknowns: [String] = Array(Set(local.unknowns + appleUnknowns))
        let unknowns: [String] = Array(uniqueUnknowns.prefix(5))
        var merged = PromptAnalysis(analysisID: local.analysisID, title: local.title, input: local.input, task: local.task, intent: local.intent, domain: local.domain, secondaryDomains: local.secondaryDomains, target: local.target, outcome: local.outcome, elaboration: local.elaboration, discoveries: combined, unknowns: unknowns, prompt: "", qualityNotes: local.qualityNotes, intelligenceMode: "APPLE AUGMENTED + LOCAL EXPERT", analyzedAt: .now)
        #if DEBUG
        print("IDEVERO_METRIC apple_merge_ms=\(Int((Date.timeIntervalSinceReferenceDate - mergeStarted) * 1000))")
        #endif
        let compileStarted = Date.timeIntervalSinceReferenceDate
        let prompt = SpecializedCompiler().compile(merged)
        merged = PromptAnalysis(analysisID: merged.analysisID, title: merged.title, input: merged.input, task: merged.task, intent: merged.intent, domain: merged.domain, secondaryDomains: merged.secondaryDomains, target: merged.target, outcome: merged.outcome, elaboration: merged.elaboration, discoveries: merged.discoveries, unknowns: merged.unknowns, prompt: prompt, qualityNotes: merged.qualityNotes, intelligenceMode: merged.intelligenceMode, analyzedAt: merged.analyzedAt)
        #if DEBUG
        print("IDEVERO_METRIC specialized_compile_ms=\(Int((Date.timeIntervalSinceReferenceDate - compileStarted) * 1000))")
        #endif
        return merged
    }
    #endif
}
