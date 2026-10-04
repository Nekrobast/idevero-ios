import XCTest
import SwiftData
@testable import Idevero

final class Phase2StructuralTests: XCTestCase {
    private let provider = LocalExpertProvider()

    @MainActor
    func testPromptRecordUpsertIsIdempotentAndReloadable() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PromptRecord.self, configurations: configuration)
        let context = ModelContext(container)
        let original = try await provider.analyze("Excel para controlar stock")

        try PromptRecord.upsert(original, in: context)
        var updated = original
        updated.discoveries[0] = DiscoverySemantics.transition(updated.discoveries[0], to: .locked)
        updated = try provider.recompile(updated)
        try PromptRecord.upsert(updated, in: context)

        let records = try context.fetch(FetchDescriptor<PromptRecord>())
        XCTAssertEqual(records.count, 1)
        let reloaded = try XCTUnwrap(records.first).reconstructedAnalysis()
        XCTAssertEqual(reloaded.analysisID, original.analysisID)
        XCTAssertEqual(reloaded.discoveries[0].state, .locked)
        XCTAssertEqual(reloaded.prompt, updated.prompt)
    }

    func testLegacyRecordStillReconstructsWithoutDestructiveMigration() async throws {
        let current = try await provider.analyze("app para controlar gastos")
        let record = PromptRecord(analysis: current)
        record.analysisData = Data()
        record.generatedPrompt = "Legacy prompt"
        let restored = record.reconstructedAnalysis()
        XCTAssertEqual(restored.prompt, "Legacy prompt")
        XCTAssertNil(restored.domainContext)
        XCTAssertFalse(restored.qualityNotes.isEmpty)
    }

    func testDiscoveryTransitionContractHasSingleEffectiveMeaning() {
        let base = Discovery(
            id: "D", concept: "Concepto", reason: "Razón", lens: "Lens",
            priority: .optional, provenance: .appleModel, state: .optional,
            dependencies: [], confidence: "MEDIUM"
        )
        let included = DiscoverySemantics.transition(base, to: .included)
        let excluded = DiscoverySemantics.transition(included, to: .excluded)
        let restored = DiscoverySemantics.transition(excluded, to: .included)
        let locked = DiscoverySemantics.transition(restored, to: .locked)

        XCTAssertTrue(DiscoverySemantics.isCompilerIncluded(included))
        XCTAssertEqual(included.priority, .highValue)
        XCTAssertFalse(DiscoverySemantics.isCompilerIncluded(excluded))
        XCTAssertEqual(excluded.priority, .outOfScope)
        XCTAssertTrue(DiscoverySemantics.isCompilerIncluded(restored))
        XCTAssertEqual(restored.priority, .highValue)
        XCTAssertEqual(locked.state, .locked)
        XCTAssertEqual(locked.priority, .core)
        XCTAssertEqual(locked.provenance, .userLocked)
    }
}
