import Foundation

enum RequirementPriority: String, Codable, Sendable, CaseIterable { case core = "CORE", highValue = "HIGH VALUE", optional = "OPTIONAL", outOfScope = "OUT OF SCOPE" }
enum DiscoveryState: String, Codable, Sendable, CaseIterable { case included = "INCLUDED", locked = "LOCKED", optional = "OPTIONAL", excluded = "EXCLUDED", pending = "PENDING" }
enum DiscoveryProvenance: String, Codable, Sendable, CaseIterable {
    case userExplicit = "USER EXPLICIT", localKnowledge = "LOCAL KNOWLEDGE", appleModel = "APPLE MODEL INFERENCE"
    case userAccepted = "USER ACCEPTED", userLocked = "USER LOCKED", placeholder = "PLACEHOLDER"
}
enum ElaborationLevel: String, Codable, Sendable { case light = "LIGHT", deep = "DEEP", project = "PROJECT", expert = "EXPERT" }

struct Discovery: Identifiable, Codable, Hashable, Sendable {
    let id: String; let concept: String; let reason: String; let lens: String
    var priority: RequirementPriority; var provenance: DiscoveryProvenance; var state: DiscoveryState
    let dependencies: [String]; var confidence: String
    var sourceProvenance: [DiscoveryProvenance]? = nil
    var semanticRole: String? = nil
    var anchor: String? = nil
}

struct DomainContext: Codable, Hashable, Sendable {
    let language: String
    let primaryJobStatus: String
    let primaryJobCandidates: [String]
    let actors: [String]
    let entities: [String]
    let relationships: [String]
    let workflows: [String]
    let decisions: [String]
    let constraints: [String]

    var isEmpty: Bool {
        primaryJobCandidates.isEmpty && actors.isEmpty && entities.isEmpty &&
        relationships.isEmpty && workflows.isEmpty && decisions.isEmpty && constraints.isEmpty
    }
}

struct PromptAnalysis: Codable, Sendable {
    let analysisID: UUID; let title: String; let input: String; let task: String; let intent: String
    let domain: String; let secondaryDomains: [String]; let target: String; let outcome: String
    let elaboration: ElaborationLevel; var discoveries: [Discovery]; let unknowns: [String]
    let prompt: String; let qualityNotes: [String]; let intelligenceMode: String; let analyzedAt: Date
    var domainContext: DomainContext? = nil
}

enum IntelligenceAvailability: Equatable, Sendable { case ready, unavailable(String) }
