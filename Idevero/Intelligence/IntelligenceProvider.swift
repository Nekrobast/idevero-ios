import Foundation

protocol IntelligenceProvider: Sendable {
    var name: String { get }
    func availability() async -> IntelligenceAvailability
    func analyze(_ request: String) async throws -> PromptAnalysis
}

enum IntelligenceError: LocalizedError {
    case emptyRequest
    case unavailable(String)

    var errorDescription: String? {
        switch self {
        case .emptyRequest: "Escribe primero qué quieres conseguir."
        case .unavailable(let reason): reason
        }
    }
}

