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
            Primero construye un Domain Frame y calibra cada elemento. Distingue: ESTABLISHED para conocimiento general estable del oficio; CASE_DEPENDENT para patrones plausibles que pueden no aplicar a este caso; USER_SPECIFIC_UNKNOWN para hechos de la situación concreta que requieren confirmación; UNSUPPORTED para especulación que debe omitirse. No presentes organizaciones, supervisión, regulación, escala, ubicación ni relaciones comerciales como hechos si la petición no las establece.
            No rellenes categorías para completar el schema. Un campo vacío es mejor que un dato plausible pero poco relevante. Prefiere terminología profesional natural realmente usada en el dominio; si no tienes confianza, usa lenguaje claro sin inventar jerga.
            Distingue conocimiento que define el dominio de una posible feature. Prioriza DOMAIN_PRIMITIVE, CORE_WORKFLOW, DECISION_INPUT, CONSTRAINT y FAILURE_MODE. Marca como CONTEXT_DEPENDENT u OPTIONAL_FEATURE lo que solo sirve para un objetivo concreto. Marca como BUSINESS_OPPORTUNITY cualquier expansión comercial que no esté pedida.
            Si la petición admite productos materialmente distintos, usa primaryJobStatus UNDERSPECIFIED, enumera dos o tres trabajos plausibles de alto nivel y no elijas uno silenciosamente. Un supuesto fuerte requiere confirmación y nunca es un hecho.
            Cada finding debe indicar un anchor literal presente en el Domain Frame. Sin workflow, entidad, decisión, restricción o dato que lo necesite, no propongas integraciones, dispositivos, automatización ni funciones periféricas.
            Complementa Local Expert: omite universales de producto y cualquier reformulación de la petición. Un hallazgo no es sectorial solo porque incluya un sustantivo del dominio: explica el mecanismo profesional que cambia materialmente el requisito. Si seguiría siendo igual al sustituir el dominio por otro negocio, no lo propongas como augmentation. Calidad antes que cantidad; cero a cuatro hallazgos centrales son suficientes.
            Ordena los unknowns por ganancia de información y dependencia: primero dirección del producto/trabajo principal, después workflow o arquitectura y solo entonces detalle sectorial. Si primaryJobStatus es UNDERSPECIFIED, no preguntes detalles que dependan de haber elegido ese trabajo; normalmente una sola pregunta de dirección es mejor que tres preguntas prematuras.
            Todos los textos destinados al usuario —candidatos de trabajo, actores, entidades, relaciones, workflows, decisiones, restricciones, conceptos, razones, perspectivas y preguntas— deben estar escritos en el idioma principal de la petición original, con lenguaje humano natural. No mezcles idiomas.
            Nunca uses identificadores, nombres de enum, snake_case, ALL_CAPS_WITH_UNDERSCORES, marcadores sintéticos ni opciones como PRIMARY_JOB_A. Los códigos internos de semanticRole, assumptionLevel, scopeDependency e impact sí conservan los valores cerrados indicados por el schema.
            Los candidatos de trabajo deben describir actividades reales, comprensibles y materialmente distintas; nunca features técnicas ni etiquetas abstractas.
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
    struct ModelDomainItem {
        @Guide(description: "ACTOR, ENTITY, RELATIONSHIP, WORKFLOW, DECISION, or CONSTRAINT")
        var kind: String
        @Guide(description: "Concise natural professional domain statement in the original request language")
        var text: String
        @Guide(description: "ESTABLISHED, CASE_DEPENDENT, USER_SPECIFIC_UNKNOWN, or UNSUPPORTED")
        var epistemicStatus: String
        @Guide(description: "Decision relevance: HIGH, MEDIUM, or LOW")
        var decisionRelevance: String
    }

    @available(iOS 26.0, *)
    @Generable
    struct ModelDomainFrame {
        @Guide(description: "Primary job status: DEFINED or UNDERSPECIFIED")
        var primaryJobStatus: String
        @Guide(description: "Two or three materially different real professional activities, in the original request language and natural user-facing wording; never identifiers or placeholders", .maximumCount(3))
        var primaryJobCandidates: [String]
        @Guide(description: "Natural user-facing domain actors in the original request language, at most four", .maximumCount(4))
        var actors: [String]
        @Guide(description: "Natural user-facing objects, records or units that exist in the domain, in the original request language, at most six", .maximumCount(6))
        var entities: [String]
        @Guide(description: "Material relationships between domain elements, at most five", .maximumCount(5))
        var relationships: [String]
        @Guide(description: "Common domain workflows, not product features, at most four", .maximumCount(4))
        var workflows: [String]
        @Guide(description: "Material practitioner decisions, at most four", .maximumCount(4))
        var decisions: [String]
        @Guide(description: "Operational constraints that shape the work, at most four", .maximumCount(4))
        var constraints: [String]
        @Guide(description: "Only high-signal calibrated domain context. Do not fill categories for completeness and omit unsupported speculation", .maximumCount(12))
        var contextItems: [ModelDomainItem]
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
        @Guide(description: "Whether the requirement materially changes because of this domain: HIGH, MEDIUM, or LOW")
        var domainSpecificity: String
        @Guide(description: "Professional relevance to real practitioners: HIGH, MEDIUM, or LOW")
        var professionalRelevance: String
        @Guide(description: "GENERAL, CASE_DEPENDENT, or USER_SPECIFIC")
        var caseDependency: String
        @Guide(description: "Natural concise explanation of the domain mechanism that makes this finding different from a generic software requirement")
        var domainMechanism: String
    }

    @available(iOS 26.0, *)
    @Generable
    struct ModelUnknown {
        @Guide(description: "Natural concise question in the original request language; never a placeholder, identifier or enum token")
        var question: String
        @Guide(description: "Why the answer materially changes the product")
        var reason: String
        @Guide(description: "Architecture impact: HIGH, MEDIUM, or LOW")
        var architectureImpact: String
        @Guide(description: "Primary-workflow impact: HIGH, MEDIUM, or LOW")
        var workflowImpact: String
        @Guide(description: "Scope impact: HIGH, MEDIUM, or LOW")
        var scopeImpact: String
        @Guide(description: "PRIMARY_JOB, PRODUCT_DIRECTION, CORE_WORKFLOW, ARCHITECTURE, SCOPE, or DOMAIN_DETAIL")
        var level: String
        @Guide(description: "True when the question is premature until the primary job is selected")
        var dependsOnPrimaryJob: Bool
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
            constraints: findings.domainFrame.constraints,
            contextItems: findings.domainFrame.contextItems.map {
                SemanticDomainItem(kind: $0.kind, text: $0.text, epistemicStatus: $0.epistemicStatus, decisionRelevance: $0.decisionRelevance)
            }
        )
        let language = DisplayLanguage.detect(in: local.input)
        let domainContext = DomainContextBuilder().build(frame: frame, language: language)
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
                scopeRisk: $0.scopeRisk,
                domainSpecificity: $0.domainSpecificity,
                professionalRelevance: $0.professionalRelevance,
                caseDependency: $0.caseDependency,
                domainMechanism: $0.domainMechanism
            )
        }
        let mergeStarted = Date.timeIntervalSinceReferenceDate
        let combined = AppleDiscoveryMerger(store: store).merge(local: local.discoveries, findings: structured, request: local.input, frame: frame)
        let semanticUnknowns = findings.unknowns.map {
            SemanticUnknown(question: $0.question, reason: $0.reason, architectureImpact: $0.architectureImpact, workflowImpact: $0.workflowImpact, scopeImpact: $0.scopeImpact, level: $0.level, dependsOnPrimaryJob: $0.dependsOnPrimaryJob)
        }
        let appleUnknowns = AppleUnknownSelector().select(semanticUnknowns, frame: frame, findings: structured, language: language)
        var seen = Set<String>()
        let unknowns = (appleUnknowns + local.unknowns).filter { seen.insert($0.lowercased()).inserted }.prefix(3).map { $0 }
        var merged = PromptAnalysis(analysisID: local.analysisID, title: local.title, input: local.input, task: local.task, intent: local.intent, domain: local.domain, secondaryDomains: local.secondaryDomains, target: local.target, outcome: local.outcome, elaboration: local.elaboration, discoveries: combined, unknowns: unknowns, prompt: "", qualityNotes: local.qualityNotes, intelligenceMode: "APPLE AUGMENTED + LOCAL EXPERT", analyzedAt: .now, domainContext: domainContext)
        #if DEBUG
        print("IDEVERO_METRIC apple_merge_ms=\(Int((Date.timeIntervalSinceReferenceDate - mergeStarted) * 1000))")
        #endif
        let compileStarted = Date.timeIntervalSinceReferenceDate
        let prompt = SpecializedCompiler().compile(merged)
        merged = PromptAnalysis(analysisID: merged.analysisID, title: merged.title, input: merged.input, task: merged.task, intent: merged.intent, domain: merged.domain, secondaryDomains: merged.secondaryDomains, target: merged.target, outcome: merged.outcome, elaboration: merged.elaboration, discoveries: merged.discoveries, unknowns: merged.unknowns, prompt: prompt, qualityNotes: merged.qualityNotes, intelligenceMode: merged.intelligenceMode, analyzedAt: merged.analyzedAt, domainContext: merged.domainContext)
        #if DEBUG
        print("IDEVERO_METRIC specialized_compile_ms=\(Int((Date.timeIntervalSinceReferenceDate - compileStarted) * 1000))")
        #endif
        return merged
    }
    #endif
}
