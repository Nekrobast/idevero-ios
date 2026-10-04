import Foundation

/// Immutable UI projection. Never persisted or passed to the compiler.
struct DiscoveryPresentation: Sendable {
    let item: Discovery
    let language: DisplayLanguage
    var originalRequest: String = ""

    private struct Entry: Decodable, Sendable {
        let ids: [String]
        let title: LocalizedLabel
        let explanation: LocalizedLabel
    }
    private struct Catalog: Decodable { let schema: Int; let entries: [Entry] }
    private static let metadata: [String: Entry] = {
        guard let url = Bundle.main.url(forResource: "DiscoveryDisplayMetadata", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let catalog = try? JSONDecoder().decode(Catalog.self, from: data), catalog.schema == 1 else { return [:] }
        return Dictionary(uniqueKeysWithValues: catalog.entries.flatMap { entry in entry.ids.map { ($0, entry) } })
    }()
    // Merged Apple findings may retain their own ID but use an authored knowledge
    // label. Exact resource-label lookup shares presentation without changing ID.
    private static let metadataByConcept: [String: Entry] = {
        guard let store = try? KnowledgeStore.load() else { return [:] }
        var result: [String: Entry] = [:]
        for key in metadata.keys.sorted() {
            guard let entry = metadata[key] else { continue }
            var labels: [String] = []
            if key.hasPrefix("K_"), let concept = store.concepts.first(where: { "K_" + $0.id == key }) {
                labels = [concept.labels.es, concept.labels.en]
            } else if key.hasPrefix("S_") {
                let parts = key.dropFirst(2).split(separator: "_")
                if let last = parts.last, let index = Int(last) {
                    let strategyID = parts.dropLast().joined(separator: "_")
                    if let strategy = store.strategies.first(where: { $0.id == strategyID }), strategy.candidates.indices.contains(index) {
                        labels = [strategy.candidates[index].label]
                        if let english = LocalKnowledgeLocalization.candidate(strategy: strategyID, index: index) { labels.append(english.label) }
                    }
                }
            }
            for label in labels { result[label.lowercased()] = entry }
        }
        return result
    }()
    private var entry: Entry? { Self.metadata[item.id] ?? Self.metadataByConcept[item.concept.lowercased()] }
    private func localized(_ value: LocalizedLabel) -> String { language == .spanish ? value.es : value.en }
    private func ui(_ es: String, _ en: String) -> String { language == .spanish ? es : en }
    private func safe(_ value: String, fallback: String) -> String {
        let text = DisplayLocalization(language: language).text(value)
        guard UserFacingTextPolicy(language: language).isSafeDisplay(text, minimumLength: 1),
              text.range(of: "^[a-z0-9]+(?:_[a-z0-9]+)+$", options: .regularExpression) == nil else { return fallback }
        let pattern = "\\b[a-z][a-z0-9]*(?:_[a-z0-9]+)+\\b"
        if let expression = try? NSRegularExpression(pattern: pattern) {
            let matches = expression.matches(in: text, range: NSRange(text.startIndex..., in: text))
            for match in matches {
                if let range = Range(match.range, in: text), !originalRequest.contains(String(text[range])) { return fallback }
            }
        }
        return text
    }

    var title: String { entry.map { localized($0.title) } ?? technicalTitle }
    var explanation: String { entry.map { localized($0.explanation) } ?? fullReason }
    var technicalTitle: String { safe(item.concept, fallback: ui("Detalle de tu petición", "A detail of your request")) }
    var fullReason: String { safe(item.reason, fallback: ui("Comprueba si este detalle te ayuda a conseguir lo que buscas.", "Check whether this detail helps you achieve your goal.")) }
    var perspective: String {
        if (item.sourceProvenance ?? [item.provenance]).contains(.appleModel),
           let raw = item.semanticRole, let role = SemanticRole(rawValue: raw) {
            return UserFacingTextPolicy(language: language).displayLens(for: role)
        }
        return DisplayLocalization(language: language).lens(item.lens)
    }
    var priority: String {
        switch item.priority {
        case .core: return ui("Importante", "Important")
        case .highValue: return ui("Recomendado", "Recommended")
        case .optional: return ui("Opcional", "Optional")
        case .outOfScope: return ui("Fuera de esta petición", "Outside this request")
        }
    }
    var state: String {
        switch item.state {
        case .included: return ui("Añadido", "Added")
        case .locked: return ui("Se mantendrá siempre", "Always kept")
        case .excluded: return ui("No se utilizará", "Not used")
        case .optional: return ui("Puedes añadirlo", "You can add it")
        case .pending: return ui("Por confirmar", "To confirm")
        }
    }
    var sourceDescriptions: [String] {
        var sources = item.sourceProvenance ?? []
        if !sources.contains(item.provenance) { sources.insert(item.provenance, at: 0) }
        var seen = Set<DiscoveryProvenance>()
        return sources.filter { seen.insert($0).inserted }.map {
            switch $0 {
            case .userExplicit: return ui("Lo indicaste en tu petición.", "You stated it in your request.")
            case .localKnowledge: return ui("Una recomendación del conocimiento integrado de Idevero.", "A recommendation from Idevero’s built-in knowledge.")
            case .appleModel: return ui("Una sugerencia de Apple Intelligence que conviene confirmar.", "An Apple Intelligence suggestion to confirm.")
            case .userAccepted: return ui("Decidiste añadirlo a tu petición.", "You chose to add it to your request.")
            case .userLocked: return ui("Decidiste que se mantenga aunque vuelvas a analizar.", "You chose to keep it even when analyzing again.")
            case .placeholder: return ui("Falta información que puedes confirmar.", "Some information still needs your confirmation.")
            }
        }
    }
    func actionTitle(_ state: DiscoveryState) -> String {
        switch state {
        case .included: return ui("Añadir", "Add")
        case .locked: return ui("Mantener siempre", "Always keep")
        case .excluded: return ui("Quitar", "Remove")
        case .optional, .pending: return ui("Confirmar", "Confirm")
        }
    }
    func actionHint(_ state: DiscoveryState) -> String {
        switch state {
        case .included: return ui("Usar este detalle en el prompt.", "Use this detail in the prompt.")
        case .locked: return ui("Conservar este detalle al regenerar o reanalizar.", "Keep this detail when regenerating or analyzing again.")
        case .excluded: return ui("No usar este detalle en el prompt.", "Do not use this detail in the prompt.")
        case .optional, .pending: return ui("Decidir si quieres utilizar este detalle.", "Decide whether to use this detail.")
        }
    }
}
