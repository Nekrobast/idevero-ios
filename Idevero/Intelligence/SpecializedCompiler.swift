import Foundation

struct SpecializedCompiler {
    func compile(_ analysis: PromptAnalysis) -> String {
        let selected = analysis.discoveries.filter { [.included, .locked].contains($0.state) && [.core, .highValue].contains($0.priority) }
        switch analysis.task {
        case "EMAIL":
            return DisplayLanguage.detect(in: analysis.input) == .english
                ? "Write an email for: \(analysis.input). Match the tone to the relationship with the recipient, include only essential context and state the expected action or reply clearly. Do not invent facts. Return only the ready-to-send email with a short subject and concise body."
                : "Redacta un email para: \(analysis.input). Ajusta el tono a la relación con el destinatario, aporta solo el contexto imprescindible y formula con claridad la acción o respuesta esperada. No inventes hechos. Entrega únicamente el email listo para enviar, con asunto breve y cuerpo conciso."
        case "IMAGE": return image(analysis, selected)
        case "IMAGE_EDITING": return imageEdit(analysis, selected)
        case "SPREADSHEET": return spreadsheet(analysis, selected)
        case "APPLICATION", "WEB": return product(analysis, selected)
        case "TRAVEL": return travel(analysis, selected)
        case "SHOPPING", "RESEARCH": return research(analysis, selected)
        default: return structured(analysis, selected)
        }
    }
    private func bullets(_ values: [Discovery], language: DisplayLanguage = .spanish) -> String {
        let display = DisplayLocalization(language: language)
        return values.map { "- \(display.text($0.concept)): \(display.text($0.reason))" }.joined(separator: "\n")
    }
    private func section(_ title: String, _ values: [Discovery]) -> String {
        guard !values.isEmpty else { return "" }
        return "\n\n\(title)\n\(bullets(values))"
    }
    private func unknowns(_ a: PromptAnalysis, language: DisplayLanguage? = nil) -> String {
        guard !a.unknowns.isEmpty else { return "" }
        let language = language ?? .detect(in: a.input)
        let placeholders = a.unknowns.filter { $0.contains("[") && $0.contains("]") }
        let questions = a.unknowns.filter { !placeholders.contains($0) }
        var blocks: [String] = []
        if !questions.isEmpty {
            let title = language == .spanish ? "Preguntas por confirmar" : "Questions to confirm"
            blocks.append(title + "\n" + questions.map { "- \($0)" }.joined(separator: "\n"))
        }
        if !placeholders.isEmpty {
            let title = language == .spanish ? "Datos que debe completar el usuario" : "Information for the user to complete"
            blocks.append(title + "\n" + placeholders.map { "- \($0)" }.joined(separator: "\n"))
        }
        return blocks.isEmpty ? "" : "\n\n" + blocks.joined(separator: "\n\n")
    }
    private func product(_ a: PromptAnalysis, _ ds: [Discovery]) -> String {
        let language = DisplayLanguage(rawValue: a.domainContext?.language ?? "") ?? .detect(in: a.input)
        if language == .english { return productEnglish(a, ds) }
        let domain = ds.filter { ($0.sourceProvenance ?? [$0.provenance]).contains(.appleModel) }
        let primitives = domain.filter { $0.semanticRole == SemanticRole.domainPrimitive.rawValue }
        let workflows = domain.filter { $0.semanticRole == SemanticRole.coreWorkflow.rawValue }
        let decisions = domain.filter { [SemanticRole.decisionInput.rawValue, SemanticRole.constraint.rawValue, SemanticRole.failureMode.rawValue].contains($0.semanticRole ?? "") }
        let groupedIDs = Set((primitives + workflows + decisions).map(\.id))
        let remaining = domain.filter { !groupedIDs.contains($0.id) }
        let domainIDs = Set(domain.map(\.id))
        let explicit = ds.filter { [.userExplicit, .userAccepted, .userLocked].contains($0.provenance) && !domainIDs.contains($0.id) }
        let domainBlock = domainContextBlock(a, language: .spanish)
        let explicitBlock = explicit.isEmpty ? "" : "\n\nRequisitos expresos o bloqueados\n" + bullets(explicit)
        let confirmedDomain = domain.isEmpty ? "" : "\n\nRequisitos sectoriales confirmados\n" + groupedRequirements(primitives: primitives, workflows: workflows, decisions: decisions, remaining: remaining)
        return """
        Encargo original: «\(a.input)».

        Diseña y especifica \(a.task == "WEB" ? "un producto web" : "una aplicación") que consiga este resultado: \(a.outcome)

        \(domainBlock)

        Trabajo principal
        \(primaryJobText(a, language: .spanish))\(explicitBlock)\(confirmedDomain)\(unknowns(a, language: .spanish))

        Diseño del producto
        Una vez elegido el problema principal, define de forma proporcional el flujo, modelo de información, navegación, persistencia, estados, validaciones y criterios de aceptación que ese problema necesite. No conviertas entidades del dominio en dashboards, alertas, automatizaciones o integraciones salvo que un workflow confirmado lo justifique.

        Alcance y calidad
        Separa el MVP de ampliaciones opcionales. Explica las relaciones y dependencias entre datos o pasos cuando afecten al funcionamiento. Incluye fallos y recuperación propios del flujo, junto con criterios de aceptación observables. Aplica privacidad, accesibilidad, rendimiento y pruebas en proporción al riesgo. No añadas IA, gamificación, integraciones, cuentas ni funciones sociales sin una razón material.\(work(a))
        """
    }
    private func productEnglish(_ a: PromptAnalysis, _ ds: [Discovery]) -> String {
        let domain = ds.filter { ($0.sourceProvenance ?? [$0.provenance]).contains(.appleModel) }
        let domainIDs = Set(domain.map(\.id))
        let explicit = ds.filter { [.userExplicit, .userAccepted, .userLocked].contains($0.provenance) && !domainIDs.contains($0.id) }
        let confirmed = domain.isEmpty ? "" : "\n\nConfirmed domain requirements\n" + bullets(domain, language: .english)
        let explicitBlock = explicit.isEmpty ? "" : "\n\nExplicit or locked requirements\n" + bullets(explicit, language: .english)
        return """
        Original request: “\(a.input)”.

        Design and specify \(a.task == "WEB" ? "a web product" : "an application") that achieves this outcome: \(a.outcome)

        \(domainContextBlock(a, language: .english))

        Primary job
        \(primaryJobText(a, language: .english))\(explicitBlock)\(confirmed)\(unknowns(a, language: .english))

        Product design
        Once the primary problem is chosen, define only the proportionate workflow, information model, navigation, persistence, states, validation and acceptance criteria it requires. Do not turn domain entities into dashboards, alerts, automation or integrations unless a confirmed workflow justifies them.

        Scope and quality
        Separate the MVP from optional extensions. Explain relationships and dependencies when they affect operation. Cover workflow-specific failures and recovery with observable acceptance criteria. Apply privacy, accessibility, performance and testing in proportion to risk. Do not add AI, gamification, integrations, accounts or social features without material justification.\(work(a))
        """
    }
    private func domainContextBlock(_ a: PromptAnalysis, language: DisplayLanguage) -> String {
        guard let context = a.domainContext, !context.isEmpty else {
            return language == .spanish
                ? "Contexto del dominio\nNo presupongas procesos sectoriales que no estén respaldados; utiliza las preguntas por confirmar para fijar el alcance."
                : "Domain context\nDo not assume unsupported sector workflows; use the questions to confirm the scope."
        }
        if let calibrated = context.calibratedItems, !calibrated.isEmpty {
            return calibratedDomainContextBlock(calibrated, language: language)
        }
        let elements = Array((context.actors + context.entities).prefix(5))
        let relationships = Array(context.relationships.prefix(4))
        let workflows = Array(context.workflows.prefix(3))
        let decisions = Array((context.decisions + context.constraints).prefix(4))
        let title = language == .spanish ? "Contexto del dominio" : "Domain context"
        let notice = language == .spanish
            ? "Utiliza este marco para comprender el trabajo, pero no conviertas automáticamente cada elemento en una función ni en alcance del MVP."
            : "Use this frame to understand the work, but do not automatically turn every element into a feature or MVP scope."
        var sections: [String] = []
        func append(_ headingES: String, _ headingEN: String, _ values: [String]) {
            guard !values.isEmpty else { return }
            sections.append((language == .spanish ? headingES : headingEN) + "\n" + values.map { "- \($0)" }.joined(separator: "\n"))
        }
        append("Elementos centrales", "Core elements", elements)
        append("Relaciones relevantes", "Relevant relationships", relationships)
        append("Flujos habituales", "Common workflows", workflows)
        append("Decisiones y restricciones", "Decisions and constraints", decisions)
        return title + "\n" + notice + (sections.isEmpty ? "" : "\n\n" + sections.joined(separator: "\n\n"))
    }
    private func calibratedDomainContextBlock(_ items: [DomainContextItem], language: DisplayLanguage) -> String {
        let title = language == .spanish ? "Contexto del dominio" : "Domain context"
        let notice = language == .spanish
            ? "Usa este contexto para razonar, sin convertirlo automáticamente en funciones ni asumir que todos los patrones aplican a este caso."
            : "Use this context for reasoning without automatically turning it into features or assuming every pattern applies to this case."
        let established = items.filter { $0.status == .established }.prefix(6)
        let conditional = items.filter { $0.status == .caseDependent }.prefix(3)
        var blocks: [String] = []
        if !established.isEmpty {
            let heading = language == .spanish ? "Conocimiento sectorial fiable" : "Reliable domain knowledge"
            blocks.append(heading + "\n" + established.map { "- \($0.text)" }.joined(separator: "\n"))
        }
        if !conditional.isEmpty {
            let heading = language == .spanish ? "Patrones que dependen del caso" : "Case-dependent patterns"
            let prefix = language == .spanish ? "Puede ser relevante, según el objetivo elegido: " : "Depending on the chosen objective, it may be relevant to consider: "
            blocks.append(heading + "\n" + conditional.map { "- \(prefix)\($0.text)" }.joined(separator: "\n"))
        }
        return title + "\n" + notice + (blocks.isEmpty ? "" : "\n\n" + blocks.joined(separator: "\n\n"))
    }
    private func primaryJobText(_ a: PromptAnalysis, language: DisplayLanguage) -> String {
        guard let context = a.domainContext, context.primaryJobStatus == "UNDERSPECIFIED" else {
            return language == .spanish ? "Respeta el objetivo principal expresado por el usuario." : "Follow the primary objective expressed by the user."
        }
        guard context.primaryJobCandidates.count >= 2 else {
            return language == .spanish
                ? "El objetivo prioritario todavía no está definido. No elijas uno silenciosamente; conserva un diseño útil y adaptable hasta confirmarlo."
                : "The priority objective is not yet defined. Do not choose one silently; keep the design useful and adaptable until it is confirmed."
        }
        let candidates = context.primaryJobCandidates.map { "- \($0)" }.joined(separator: "\n")
        return (language == .spanish
            ? "El objetivo prioritario está pendiente de confirmar. Alternativas plausibles:\n"
            : "The priority objective still needs confirmation. Plausible alternatives:\n") + candidates
    }
    private func groupedRequirements(primitives: [Discovery], workflows: [Discovery], decisions: [Discovery], remaining: [Discovery]) -> String {
        [primitives, workflows, decisions, remaining].flatMap { $0 }.map { "- \($0.concept): \($0.reason)" }.joined(separator: "\n")
    }
    private func sectionBody(_ title: String, _ values: [Discovery]) -> String {
        guard !values.isEmpty else { return "" }
        return "\n\n\(title)\n\(bullets(values))"
    }
    private func image(_ a: PromptAnalysis, _ ds: [Discovery]) -> String { "\(a.input). Elige una única dirección artística coherente y descríbela como lo que debe verse: sujeto y acción inequívocos, composición y encuadre intencionales, punto de vista, planos, atmósfera, luz motivada, paleta, materiales y movimiento físicamente compatibles. \(bullets(ds)) Evita mezclar épocas, estilos o condiciones de luz contradictorias. Indica relación de aspecto solo si sirve al uso final." }
    private func imageEdit(_ a: PromptAnalysis, _ ds: [Discovery]) -> String { "Edita la imagen según esta petición: \(a.input). Prioridad 1: conserva idénticos rostros, identidad, pose, ropa, proporciones, perspectiva, encuadre, estilo y resolución fuera del área indicada. Prioridad 2: realiza únicamente el cambio solicitado. Prioridad 3: reconstruye fondo, sombras, reflejos, grano y luz solo lo necesario para integrarlo. No reinterpretar ni embellecer otras zonas. \(bullets(ds))" }
    private func spreadsheet(_ a: PromptAnalysis, _ ds: [Discovery]) -> String { """
    Crea un libro de cálculo operativo para: \(a.input).

    Propón una estructura concreta de hojas separando datos maestros, movimientos/entradas y resumen. Define columnas, IDs, tipos, validaciones, relaciones, fórmulas y campos calculados; protege fórmulas y evita mantener manualmente valores que puedan derivarse.

    Requisitos priorizados
    \(bullets(ds))\(unknowns(a))

    Incluye filtros, formato condicional y dashboard solo cuando ayuden a decidir. Añade datos de ejemplo mínimos, prueba fórmulas con casos normales y límite, documenta el flujo de actualización y evita macros si no son necesarias.\(work(a))
    """ }
    private func travel(_ a: PromptAnalysis, _ ds: [Discovery]) -> String { """
    Planifica \(a.input) como un itinerario viable, no como una lista de lugares. Agrupa por zonas y calcula tiempo real para desplazamientos, comidas, colas, check-in, visitas y descanso. Respeta horarios, días de cierre y reservas; indica qué debe verificarse con información actual.

    Criterios
    \(bullets(ds))\(unknowns(a))

    Entrega un plan día a día con ritmo razonable, transporte entre zonas, decisiones de reserva y alternativas ante clima, cierre o cansancio. No inventes precios ni disponibilidad.
    """ }
    private func research(_ a: PromptAnalysis, _ ds: [Discovery]) -> String { """
    Investiga y resuelve: \(a.input). Define primero la decisión real, el alcance y los criterios de comparación. Usa información actual cuando precio, disponibilidad o especificaciones puedan haber cambiado; prioriza fuentes primarias/oficiales y contrasta afirmaciones relevantes.

    Criterios priorizados
    \(bullets(ds))\(unknowns(a))

    Separa hechos, inferencias y opinión. Compara alternativas con los mismos criterios, explica trade-offs y termina con una recomendación condicionada al uso y presupuesto. No inventes precios, fuentes ni certezas.
    """ }
    private func structured(_ a: PromptAnalysis, _ ds: [Discovery]) -> String { """
    Realiza este encargo: \(a.input)

    Resultado esperado
    \(a.outcome)

    Criterios y requisitos
    \(bullets(ds))\(unknowns(a))

    Mantén la intención original, resuelve dependencias, evita supuestos no respaldados y entrega un resultado específico, ejecutable y revisado. No infles el alcance con elementos opcionales sin valor material.\(work(a))
    """ }
    private func work(_ a: PromptAnalysis) -> String { guard a.target == "CHATGPT WORK" else { return "" }; return "\n\nEjecución en ChatGPT Work: inspecciona primero los archivos y el estado real; conserva arquitectura, datos e identidad; planifica internamente; modifica lo mínimo necesario; ejecuta build y pruebas pertinentes; inspecciona el resultado, corrige fallos y entrega el artefacto final con pruebas y limitaciones reales. No reconstruyas un proyecto existente ni te limites a explicar." }
}
