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
        guard language == .spanish else { return value }
        var result = value
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
            ("Agent", "Agente"), ("Governance", "Gobernanza"), ("Commerce", "Comercio")
        ]
        for (source, target) in terms {
            result = result.replacingOccurrences(of: "\\b\(NSRegularExpression.escapedPattern(for: source))\\b", with: target, options: [.regularExpression, .caseInsensitive])
        }
        return result
    }

    func task(_ value: String) -> String {
        guard language == .spanish else { return value.capitalized }
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
