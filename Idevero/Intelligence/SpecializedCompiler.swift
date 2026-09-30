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
    private func unknowns(_ a: PromptAnalysis) -> String { a.unknowns.isEmpty ? "" : "\n\nDatos por confirmar — conserva los marcadores y no inventes valores:\n" + a.unknowns.map { "- \($0)" }.joined(separator: "\n") }
    private func product(_ a: PromptAnalysis, _ ds: [Discovery]) -> String { """
    Diseña y especifica \(a.input) como un producto \(a.task == "WEB" ? "web" : "digital") centrado en este resultado: \(a.outcome)

    Empieza por la acción o decisión principal y construye alrededor de ella un flujo completo. Define únicamente pantallas, navegación, datos, estados, persistencia, validaciones y requisitos técnicos justificados por ese flujo.

    Requisitos priorizados
    \(bullets(ds))\(unknowns(a))

    Distingue el alcance inicial de ampliaciones opcionales. Incluye estados vacío, carga, error y recuperación cuando procedan; criterios de aceptación observables; privacidad, accesibilidad, rendimiento y pruebas en proporción al riesgo. No añadas IA, gamificación, integraciones, cuentas ni funciones sociales sin una razón material.\(work(a))
    """ }
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
