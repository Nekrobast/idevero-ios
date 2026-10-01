import Foundation

struct SpecializedCompiler {
    func compile(_ analysis: PromptAnalysis) -> String {
        let selected = analysis.discoveries.filter { [.included, .locked].contains($0.state) && [.core, .highValue].contains($0.priority) }
        switch analysis.task {
        case "EMAIL": return "Redacta un email para: \(analysis.input). Ajusta el tono a la relación con el destinatario, aporta solo el contexto imprescindible y formula con claridad la acción o respuesta esperada. No inventes hechos. Entrega únicamente el email listo para enviar, con asunto breve y cuerpo conciso."
        case "IMAGE": return image(analysis, selected)
        case "IMAGE_EDITING": return imageEdit(analysis, selected)
        case "SPREADSHEET": return spreadsheet(analysis, selected)
        case "APPLICATION", "WEB": return product(analysis, selected)
        case "TRAVEL": return travel(analysis, selected)
        case "SHOPPING", "RESEARCH": return research(analysis, selected)
        default: return structured(analysis, selected)
        }
    }
    private func bullets(_ values: [Discovery]) -> String { values.map { "- \($0.concept): \($0.reason)" }.joined(separator: "\n") }
    private func section(_ title: String, _ values: [Discovery]) -> String {
        guard !values.isEmpty else { return "" }
        return "\n\n\(title)\n\(bullets(values))"
    }
    private func unknowns(_ a: PromptAnalysis) -> String { a.unknowns.isEmpty ? "" : "\n\nDatos por confirmar — conserva los marcadores y no inventes valores:\n" + a.unknowns.map { "- \($0)" }.joined(separator: "\n") }
    private func product(_ a: PromptAnalysis, _ ds: [Discovery]) -> String {
        let domain = ds.filter { ($0.sourceProvenance ?? [$0.provenance]).contains(.appleModel) }
        let primitives = domain.filter { $0.semanticRole == SemanticRole.domainPrimitive.rawValue }
        let workflows = domain.filter { $0.semanticRole == SemanticRole.coreWorkflow.rawValue }
        let decisions = domain.filter { [SemanticRole.decisionInput.rawValue, SemanticRole.constraint.rawValue, SemanticRole.failureMode.rawValue].contains($0.semanticRole ?? "") }
        let groupedIDs = Set((primitives + workflows + decisions).map(\.id))
        let remaining = domain.filter { !groupedIDs.contains($0.id) }
        let domainIDs = Set(domain.map(\.id))
        let explicit = ds.filter { [.userExplicit, .userAccepted, .userLocked].contains($0.provenance) && !domainIDs.contains($0.id) }
        let domainBlock = domain.isEmpty ? "" : """


        Marco del dominio
        \(sectionBody("Entidades y relaciones", primitives))\(sectionBody("Flujos centrales", workflows))\(sectionBody("Decisiones, restricciones y fallos", decisions))\(sectionBody("Otros hallazgos confirmados", remaining))
        """
        let explicitBlock = explicit.isEmpty ? "" : "\n\nRequisitos expresos o bloqueados\n" + bullets(explicit)
        return """
        Encargo original: «\(a.input)».

        Diseña y especifica \(a.task == "WEB" ? "un producto web" : "una aplicación") que consiga este resultado: \(a.outcome)

        Enfoque
        Si el trabajo principal no está definido, no elijas silenciosamente uno: presenta las alternativas de alto nivel y utiliza los datos por confirmar para fijar el alcance.\(domainBlock)\(explicitBlock)\(unknowns(a))

        Diseño del producto
        Una vez elegido el problema principal, define de forma proporcional el flujo, modelo de información, navegación, persistencia, estados, validaciones y criterios de aceptación que ese problema necesite. No conviertas entidades del dominio en dashboards, alertas, automatizaciones o integraciones salvo que un workflow confirmado lo justifique.

        Alcance y calidad
        Separa el MVP de ampliaciones opcionales. Explica las relaciones y dependencias entre datos o pasos cuando afecten al funcionamiento. Incluye fallos y recuperación propios del flujo, junto con criterios de aceptación observables. Aplica privacidad, accesibilidad, rendimiento y pruebas en proporción al riesgo. No añadas IA, gamificación, integraciones, cuentas ni funciones sociales sin una razón material.\(work(a))
        """
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
