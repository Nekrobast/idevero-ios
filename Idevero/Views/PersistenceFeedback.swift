import SwiftUI
import SwiftData
import UIKit

@MainActor
final class PersistenceFeedback: ObservableObject {
    enum Scope: String { case create = "CREATE", history = "HISTORY" }
    @Published private(set) var succeeded = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var successMessage = ""
    private var retryAction: (() throws -> Void)?
    private var retryLanguage: DisplayLanguage = .spanish
    private var injectedFailures = 0
    private var successDismissal: Task<Void, Never>?

    init(scope: Scope) {
        #if DEBUG
        injectedFailures = max(0, Int(ProcessInfo.processInfo.environment["IDEVERO_UI_TEST_\(scope.rawValue)_SAVE_FAILURES"] ?? "0") ?? 0)
        #endif
    }

    func save(language: DisplayLanguage, action: @escaping () throws -> Void) {
        successDismissal?.cancel()
        succeeded = false
        errorMessage = nil
        do {
            if injectedFailures > 0 {
                injectedFailures -= 1
                throw CocoaError(.fileWriteUnknown)
            }
            try action()
            retryAction = nil
            successMessage = language.ui("Guardado", "Saved")
            succeeded = true
            UIAccessibility.post(notification: .announcement, argument: successMessage)
            successDismissal = Task { [weak self] in
                do { try await Task.sleep(for: .seconds(8)) } catch { return }
                self?.succeeded = false
            }
        } catch {
            retryAction = action
            retryLanguage = language
            errorMessage = language.ui("No se ha podido guardar. Tu prompt sigue disponible.", "Could not save. Your prompt is still available.")
            UIAccessibility.post(notification: .announcement, argument: errorMessage)
        }
    }

    func retry() {
        guard let retryAction else { return }
        save(language: retryLanguage, action: retryAction)
    }

    static func insertOrUpdate(_ analysis: PromptAnalysis, in context: ModelContext) throws {
        if let existing = try context.fetch(FetchDescriptor<PromptRecord>()).first(where: { $0.id == analysis.analysisID }) {
            try update(existing, from: analysis) { try context.save() }
        } else {
            let record = PromptRecord(analysis: analysis)
            context.insert(record)
            do { try context.save() } catch {
                context.delete(record)
                throw error
            }
        }
    }

    // Restore only the fields updated here, without rolling back unrelated records.
    static func update(_ record: PromptRecord, from analysis: PromptAnalysis, persist: () throws -> Void) throws {
        let strings = (record.title, record.originalIdea, record.generatedPrompt, record.task,
                       record.strategy, record.intent, record.domain, record.target, record.intelligenceMode)
        let data = (record.discoveriesData, record.analysisData, record.updatedAt)
        record.update(from: analysis)
        do { try persist() } catch {
            (record.title, record.originalIdea, record.generatedPrompt, record.task,
             record.strategy, record.intent, record.domain, record.target, record.intelligenceMode) = strings
            (record.discoveriesData, record.analysisData, record.updatedAt) = data
            throw error
        }
    }
}

struct PersistenceFeedbackView: View {
    @ObservedObject var feedback: PersistenceFeedback
    let language: DisplayLanguage

    var body: some View {
        if let error = feedback.errorMessage {
            VStack(alignment: .leading, spacing: 8) {
                Text(error).accessibilityIdentifier("persistenceError")
                Button(language.ui("Reintentar guardado", "Retry save")) { feedback.retry() }
                    .buttonStyle(.bordered).accessibilityIdentifier("retryPersistenceSave")
            }
            .padding().frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial)
        } else if feedback.succeeded {
            Text(feedback.successMessage).accessibilityIdentifier("persistenceSuccess")
                .padding().frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial)
        }
    }
}
