import Foundation

struct RegexResource: Codable, Sendable { let pattern: String; let flags: String }
struct LocalizedLabel: Codable, Sendable { let es: String; let en: String }
struct ConceptRelationResource: Codable, Sendable { let type: String; let to: String }
struct ConceptResource: Codable, Sendable {
    let id: String; let labels: LocalizedLabel; let reason: String; let lens: String; let aliases: [String]
    let intents: [String]?; let requires: [String]?; let relations: [ConceptRelationResource]?
    let usefulWhen: RegexResource?; let irrelevantWhen: RegexResource?; let cost: Int?
}
struct UnknownResource: Codable, Sendable { let field: String; let question: String; let level: String; let placeholder: String? }
struct DomainResource: Codable, Sendable {
    let id: String; let family: String; let labels: LocalizedLabel; let signals: [RegexResource]
    let concepts: [String]; let unknowns: [UnknownResource]?; let parents: [String]?
}
struct RelationshipResource: Codable, Sendable { let from: String; let type: String; let to: String }
struct CandidateResource: Codable, Sendable {
    let label: String; let reason: String; let lens: String; let when: RegexResource?; let unless: RegexResource?
    let core: Bool?; let cost: Int?; let dependencies: [String]?
}
struct StrategyResource: Codable, Sendable {
    let id: String; let label: String; let blueprint: String; let format: String
    let quality: [String]; let forbidden: [String]; let candidates: [CandidateResource]
}
struct StrategyAliasResource: Codable, Sendable { let id: String; let base: String }
struct ConceptsEnvelope: Codable { let schema: Int; let concepts: [ConceptResource] }
struct DomainsEnvelope: Codable { let schema: Int; let domains: [DomainResource] }
struct RelationshipsEnvelope: Codable { let schema: Int; let relationships: [RelationshipResource] }
struct StrategiesEnvelope: Codable { let schema: Int; let strategies: [StrategyResource]; let aliases: [StrategyAliasResource] }

struct KnowledgeStore: Sendable {
    let concepts: [ConceptResource]; let domains: [DomainResource]; let relationships: [RelationshipResource]
    let strategies: [StrategyResource]; let strategyAliases: [String: String]
    static func load(bundle: Bundle = .main) throws -> KnowledgeStore {
        func decode<T: Decodable>(_ type: T.Type, _ name: String) throws -> T {
            guard let url = bundle.url(forResource: name, withExtension: "json") else { throw IntelligenceError.unavailable("Falta \(name).json") }
            return try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
        }
        let c = try decode(ConceptsEnvelope.self, "Concepts"), d = try decode(DomainsEnvelope.self, "DomainPacks")
        let r = try decode(RelationshipsEnvelope.self, "Relationships"), s = try decode(StrategiesEnvelope.self, "StrategyPacks")
        return KnowledgeStore(concepts: c.concepts, domains: d.domains, relationships: r.relationships, strategies: s.strategies, strategyAliases: Dictionary(uniqueKeysWithValues: s.aliases.map { ($0.id, $0.base) }))
    }
    func matches(_ regex: RegexResource?, text: String) -> Bool {
        guard let regex, let expression = try? NSRegularExpression(pattern: regex.pattern, options: regex.flags.contains("i") ? [.caseInsensitive] : []) else { return false }
        return expression.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    }
}
