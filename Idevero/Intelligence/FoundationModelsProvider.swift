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
            Eres el especialista de dominio bajo demanda de IDEVERO. No escribas el prompt final ni diseñes la solución.
            Primero construye un Domain Frame: qué actores y entidades existen, qué relaciones los conectan, qué workflows son habituales, qué decisiones materiales toman y qué restricciones condicionan el trabajo. Después devuelve solo requisitos anclados explícitamente a ese frame.
            Distingue conocimiento que define el dominio de una posible feature. Prioriza DOMAIN_PRIMITIVE, CORE_WORKFLOW, DECISION_INPUT, CONSTRAINT y FAILURE_MODE. Marca como CONTEXT_DEPENDENT u OPTIONAL_FEATURE lo que solo sirve para un objetivo concreto. Marca como BUSINESS_OPPORTUNITY cualquier expansión comercial que no esté pedida.
            Si la petición admite productos materialmente distintos, usa primaryJobStatus UNDERSPECIFIED, enumera dos o tres trabajos plausibles de alto nivel y no elijas uno silenciosamente. Un supuesto fuerte requiere confirmación y nunca es un hecho.
            Cada finding debe indicar un anchor literal presente en el Domain Frame. Sin workflow, entidad, decisión, restricción o dato que lo necesite, no propongas integraciones, dispositivos, automatización ni funciones periféricas.
            Complementa Local Expert: omite universales de producto y cualquier reformulación de la petición. Calidad antes que cantidad; dos a cuatro hallazgos centrales son suficientes.
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

            Descubre solo conocimiento adicional que cambie materialmente el prompt. Respeta la tarea: lenguaje visual para IMAGE; operación y relaciones para SPREADSHEET; decisiones y restricciones para TRAVEL/SHOPPING/RESEARCH; estructura de dominio, workflows y decisiones para APPLICATION/WEB. Una tarea LIGHT debe permanecer compacta.
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
    struct ModelDomainFrame {
        @Guide(description: "Primary job status: DEFINED or UNDERSPECIFIED")
        var primaryJobStatus: String
        @Guide(description: "Two or three materially different plausible jobs only when underspecified", .maximumCount(3))
        var primaryJobCandidates: [String]
        @Guide(description: "Domain actors, at most four", .maximumCount(4))
        var actors: [String]
        @Guide(description: "Objects, records or units that exist in the domain, at most six", .maximumCount(6))
        var entities: [String]
        @Guide(description: "Material relationships between domain elements, at most five", .maximumCount(5))
        var relationships: [String]
        @Guide(description: "Common domain workflows, not product features, at most four", .maximumCount(4))
        var workflows: [String]
        @Guide(description: "Material practitioner decisions, at most four", .maximumCount(4))
        var decisions: [String]
        @Guide(description: "Operational constraints that shape the work, at most four", .maximumCount(4))
        var constraints: [String]
    }

    @available(iOS 26.0, *)
    @Generable
    struct ModelFinding {
        @Guide(description: "Short domain concept absent from local discoveries")
        var concept: String
        @Guide(description: "Concise causal reason explaining why this changes the task")
        var reason: String
        @Guide(description: "Expert perspective that produced the finding")
        var lens: String
        @Guide(description: "DOMAIN_PRIMITIVE, CORE_WORKFLOW, DECISION_INPUT, CONSTRAINT, FAILURE_MODE, CONTEXT_DEPENDENT, OPTIONAL_FEATURE, or BUSINESS_OPPORTUNITY")
        var semanticRole: String
        @Guide(description: "Exact actor, entity, relationship, workflow, decision or constraint from the Domain Frame that justifies this finding")
        var anchor: String
        @Guide(description: "Assumption level: LOW, MEDIUM, or HIGH")
        var assumptionLevel: String
        @Guide(description: "True when the finding cannot be treated as fact without the user's choice")
        var requiresConfirmation: Bool
        @Guide(description: "Scope dependency: CORE, CONTEXT_DEPENDENT, or OPTIONAL")
        var scopeDependency: String
        @Guide(description: "Impact on a material decision: HIGH, MEDIUM, or LOW")
        var decisionImpact: String
        @Guide(description: "Model claim about material impact: HIGH, MEDIUM, or LOW")
        var materiality: String
        @Guide(description: "Model claim about user-intent fit: HIGH, MEDIUM, or LOW")
        var userIntentFit: String
        @Guide(description: "Model claim about unjustified scope expansion: LOW, MEDIUM, or HIGH")
        var scopeRisk: String
    }

    @available(iOS 26.0, *)
    @Generable
    struct ModelUnknown {
        @Guide(description: "Specific fact to confirm, phrased as a semantic placeholder or concise question")
        var question: String
        @Guide(description: "Why the answer materially changes the product")
        var reason: String
        @Guide(description: "Architecture impact: HIGH, MEDIUM, or LOW")
        var architectureImpact: String
        @Guide(description: "Primary-workflow impact: HIGH, MEDIUM, or LOW")
        var workflowImpact: String
        @Guide(description: "Scope impact: HIGH, MEDIUM, or LOW")
        var scopeImpact: String
    }

    @available(iOS 26.0, *)
    @Generable
    struct ModelFindings {
        @Guide(description: "Domain understanding built before proposing findings")
        var domainFrame: ModelDomainFrame
        @Guide(description: "At most four anchored, material and non-duplicative findings", .maximumCount(4))
        var discoveries: [ModelFinding]
        @Guide(description: "At most three unknowns whose answers change architecture, primary workflow or scope", .maximumCount(3))
        var unknowns: [ModelUnknown]
    }

    @available(iOS 26.0, *)
    private func merge(local: PromptAnalysis, findings: ModelFindings) -> PromptAnalysis {
        guard let store = try? KnowledgeStore.load() else { return local }
        let frame = SemanticDomainFrame(
            primaryJobStatus: findings.domainFrame.primaryJobStatus,
            primaryJobCandidates: findings.domainFrame.primaryJobCandidates,
            actors: findings.domainFrame.actors,
            entities: findings.domainFrame.entities,
            relationships: findings.domainFrame.relationships,
            workflows: findings.domainFrame.workflows,
            decisions: findings.domainFrame.decisions,
            constraints: findings.domainFrame.constraints
        )
        let structured = findings.discoveries.map {
            SemanticFinding(
                concept: $0.concept,
                reason: $0.reason,
                lens: $0.lens,
                semanticRole: $0.semanticRole,
                anchor: $0.anchor,
                assumptionLevel: $0.assumptionLevel,
                requiresConfirmation: $0.requiresConfirmation,
                scopeDependency: $0.scopeDependency,
                decisionImpact: $0.decisionImpact,
                materiality: $0.materiality,
                userIntentFit: $0.userIntentFit,
                scopeRisk: $0.scopeRisk
            )
        }
        let mergeStarted = Date.timeIntervalSinceReferenceDate
        let combined = AppleDiscoveryMerger(store: store).merge(local: local.discoveries, findings: structured, request: local.input, frame: frame)
        let semanticUnknowns = findings.unknowns.map {
            SemanticUnknown(question: $0.question, reason: $0.reason, architectureImpact: $0.architectureImpact, workflowImpact: $0.workflowImpact, scopeImpact: $0.scopeImpact)
        }
        let appleUnknowns = AppleUnknownSelector().select(semanticUnknowns, frame: frame, findings: structured)
        var seen = Set<String>()
        let unknowns = (appleUnknowns + local.unknowns).filter { seen.insert($0.lowercased()).inserted }.prefix(3).map { $0 }
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
