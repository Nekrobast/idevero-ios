import Foundation

/// Centralized display-only localization. Internal task, lens and provenance IDs
/// remain stable and are never rewritten.
struct DisplayLocalization: Sendable {
    let language: DisplayLanguage

    func text(_ value: String) -> String {
        guard language == .spanish else { return value }
        var result = value
        let phrases: [(String, String)] = [
            ("happy path", "flujo principal"),
            ("responsive", "adaptabilidad entre dispositivos"),
            ("Application:", "Aplicación:"),
            ("Web:", "Web:"),
            ("General:", "General:")
        ]
        for (source, target) in phrases {
            result = result.replacingOccurrences(of: source, with: target, options: .caseInsensitive)
        }
        return result
    }

    func lens(_ value: String) -> String {
        // Only human labels cross this display boundary. Unknown machine IDs
        // have a localized abstraction rather than leaking their spelling.
        var result = value.components(separatedBy: " · ").map { component in
            component.range(of: "^[A-Za-z0-9]+(?:_[A-Za-z0-9]+)+$", options: .regularExpression) != nil ? (language == .spanish ? "Contexto del dominio" : "Domain context") : component
        }.joined(separator: " · ")
        guard language == .spanish else { return result }
        let terms: [(String, String)] = [
            ("Visual consistency", "Coherencia visual"), ("Art direction", "Dirección artística"),
            ("Edit intent", "Objetivo de edición"), ("Domain", "Dominio"),
            ("Product", "Producto"), ("Engineering", "Ingeniería"), ("Quality", "Calidad"),
            ("Workflow", "Flujo"), ("Operations", "Operaciones"), ("Data", "Datos"),
            ("Reliability", "Fiabilidad"), ("Security", "Seguridad"), ("Privacy", "Privacidad"),
            ("Planning", "Planificación"), ("Strategy", "Estrategia"), ("Research", "Investigación"),
            ("Evidence", "Evidencia"), ("Risk", "Riesgo"), ("Learning", "Aprendizaje"),
            ("Training", "Entrenamiento"), ("Debugging", "Diagnóstico"), ("Safety", "Seguridad"),
            ("Measurement", "Medición"), ("Presentation", "Presentación"), ("Composition", "Composición"),
            ("Environment", "Entorno"), ("Camera", "Cámara"), ("Lighting", "Iluminación"),
            ("Materials", "Materiales"), ("Preservation", "Conservación"), ("Integration", "Integración"),
            ("Context", "Contexto"), ("Accessibility", "Accesibilidad"), ("Conversion", "Conversión"),
            ("Positioning", "Posicionamiento"), ("Acquisition", "Adquisición"), ("Channel", "Canal"),
            ("Creative", "Creatividad"), ("Story", "Narrativa"), ("Method", "Método"),
            ("Agent", "Agente"), ("Governance", "Gobernanza"), ("Commerce", "Comercio"),
            ("Action", "Acción"), ("Assessment", "Evaluación"), ("Audience", "Audiencia"),
            ("Automation", "Automatización"), ("Bias", "Sesgo"), ("Budget", "Presupuesto"),
            ("Calculation", "Cálculo"), ("Communication", "Comunicación"), ("Comparison", "Comparación"),
            ("Constraints", "Restricciones"), ("Content", "Contenido"), ("Contingency", "Contingencia"),
            ("Contract", "Contrato"), ("Control", "Control"), ("Currentness", "Actualidad"),
            ("Curriculum", "Programa educativo"), ("Customer", "Cliente"), ("Data modeling", "Modelo de datos"),
            ("Decision", "Decisión"), ("Delivery", "Entrega"), ("Diagnosis", "Diagnóstico"),
            ("Economics", "Economía"), ("Editing", "Edición"), ("Error prevention", "Prevención de errores"),
            ("Exercise selection", "Selección de ejercicios"), ("Experience", "Experiencia"), ("Feasibility", "Viabilidad"),
            ("Feedback", "Retroalimentación"), ("Fit", "Adecuación"), ("Format", "Formato"),
            ("General", "General"), ("Genre", "Género"), ("Geography", "Geografía"),
            ("Go to market", "Salida al mercado"), ("Inference", "Inferencia"), ("Input validation", "Validación de entradas"),
            ("Instruction", "Instrucción"), ("Interface", "Interfaz"), ("Legal information", "Información jurídica"),
            ("Load management", "Gestión de carga"), ("Logic", "Lógica"), ("Logistics", "Logística"),
            ("Market", "Mercado"), ("Memory", "Memoria"), ("Mission", "Misión"),
            ("Needs", "Necesidades"), ("Observability", "Observabilidad"), ("Offer", "Oferta"),
            ("Orchestration", "Orquestación"), ("Outcome", "Resultado"), ("Ownership", "Responsabilidad"),
            ("Persuasion", "Persuasión"), ("Platform", "Plataforma"), ("Practice", "Práctica"),
            ("Programming", "Programación"), ("Progression", "Progresión"), ("Purpose", "Propósito"),
            ("Recovery", "Recuperación"), ("Relationship", "Relación"), ("Repair", "Reparación"),
            ("Reporting", "Informes"), ("Research design", "Diseño de investigación"), ("Reservations", "Reservas"),
            ("Retention", "Retención"), ("Rules", "Reglas"), ("Schedule", "Calendario"),
            ("Scope", "Alcance"), ("Sources", "Fuentes"), ("State", "Estado"),
            ("Structure", "Estructura"), ("Synthesis", "Síntesis"), ("Time", "Tiempo"),
            ("Tone", "Tono"), ("Tracking", "Seguimiento"), ("Transfer", "Transferencia"),
            ("Trust", "Confianza"), ("Usability", "Usabilidad"), ("Validation", "Validación"),
            ("Visual communication", "Comunicación visual"), ("Visual design", "Diseño visual"), ("Visual", "Visual")
        ]
        for (source, target) in terms.sorted(by: { $0.0.count > $1.0.count }) {
            result = result.replacingOccurrences(of: "\\b\(NSRegularExpression.escapedPattern(for: source))\\b", with: target, options: [.regularExpression, .caseInsensitive])
        }
        return result
    }

    func task(_ value: String) -> String {
        guard language == .spanish else { return value.replacingOccurrences(of: "_", with: " ").capitalized }
        let values = [
            "APPLICATION": "Aplicación", "WEB": "Web", "EMAIL": "Email", "IMAGE": "Imagen",
            "IMAGE_EDITING": "Edición de imagen", "SPREADSHEET": "Hoja de cálculo", "TRAVEL": "Viaje",
            "SHOPPING": "Compra", "RESEARCH": "Investigación", "PROGRAMMING": "Programación",
            "DEBUGGING": "Diagnóstico", "AUTOMATION": "Automatización", "PRESENTATION": "Presentación",
            "PLANNING": "Planificación", "DOCUMENT": "Documento", "GENERAL": "General"
        ]
        return values[value] ?? value.capitalized
    }
}
