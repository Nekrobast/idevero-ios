import XCTest
import SwiftData
@testable import Idevero

@MainActor
final class MinimalComplianceSaveTests: XCTestCase {
    func testSuccessIsPublishedOnlyAfterPersistenceReturns() {
        let feedback = PersistenceFeedback(scope: .create)
        var persisted = false
        feedback.save(language: .spanish) {
            XCTAssertFalse(feedback.succeeded)
            persisted = true
        }
        XCTAssertTrue(persisted)
        XCTAssertTrue(feedback.succeeded)
        XCTAssertEqual(feedback.successMessage, "Guardado")
        XCTAssertNil(feedback.errorMessage)
    }

    func testFailureHasNoSuccessAndRetryRunsTheOriginalSave() {
        let feedback = PersistenceFeedback(scope: .create)
        var calls = 0
        feedback.save(language: .english) {
            calls += 1
            if calls == 1 { throw CocoaError(.fileWriteUnknown) }
        }
        XCTAssertFalse(feedback.succeeded)
        XCTAssertEqual(feedback.errorMessage, "Could not save. Your prompt is still available.")
        feedback.retry()
        XCTAssertEqual(calls, 2)
        XCTAssertTrue(feedback.succeeded)
        XCTAssertEqual(feedback.successMessage, "Saved")
        XCTAssertNil(feedback.errorMessage)
    }

    func testHistoryFailureRestoresExactRecordWithoutDiscardingCurrentAnalysis() throws {
        let local = LocalExpertProvider()
        let original = try local.analyze("organizar tareas", decisions: .init())
        let record = PromptRecord(analysis: original)
        let oldData = record.analysisData
        let oldDiscoveries = record.discoveriesData
        let oldDate = record.updatedAt
        let current = try local.analyze("escribe un email de agradecimiento", decisions: .init())
        let currentPrompt = current.prompt
        XCTAssertThrowsError(try PersistenceFeedback.update(record, from: current) {
            XCTAssertEqual(record.generatedPrompt, current.prompt)
            throw CocoaError(.fileWriteUnknown)
        })
        XCTAssertEqual(record.title, original.title)
        XCTAssertEqual(record.generatedPrompt, original.prompt)
        XCTAssertEqual(record.analysisData, oldData)
        XCTAssertEqual(record.discoveriesData, oldDiscoveries)
        XCTAssertEqual(record.updatedAt, oldDate)
        XCTAssertEqual(current.prompt, currentPrompt)
        try PersistenceFeedback.update(record, from: current) {}
        XCTAssertEqual(record.generatedPrompt, current.prompt)
    }

    func testRepeatedCreateSaveKeepsOnePersistedRecord() throws {
        let container = try ModelContainer(for: PromptRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let analysis = try LocalExpertProvider().analyze("organizar tareas", decisions: .init())
        try PersistenceFeedback.insertOrUpdate(analysis, in: context)
        try PersistenceFeedback.insertOrUpdate(analysis, in: context)
        XCTAssertEqual(try context.fetch(FetchDescriptor<PromptRecord>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<PromptRecord>()).first?.generatedPrompt, analysis.prompt)
    }

    func testUnpublishedPrivacyAndSupportHaveNoInventedDestination() {
        XCTAssertNil(PrivacySupportConfiguration.privacyPolicyURL)
        XCTAssertNil(PrivacySupportConfiguration.supportURL)
        XCTAssertNil(PrivacySupportConfiguration.validatedURL(nil))
        XCTAssertNil(PrivacySupportConfiguration.validatedURL("http://example.com/privacy"))
        XCTAssertNil(PrivacySupportConfiguration.validatedURL("https://user:secret@example.com/privacy"))
        XCTAssertNil(PrivacySupportConfiguration.validatedURL("PLACEHOLDER"))
        XCTAssertNotNil(PrivacySupportConfiguration.validatedURL("https://example.com/privacy"))
    }
}
