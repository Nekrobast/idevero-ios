import XCTest
@testable import Idevero

final class SemanticDeduplicationTests: XCTestCase {
    func testKnownAliasesMapToStableConcept() throws {
        let dedupe = LocalSemanticDeduplicator(store: try KnowledgeStore.load())
        XCTAssertEqual(dedupe.canonicalConcept(for: "budget")?.id, "BUDGET_LIMIT")
        XCTAssertEqual(dedupe.canonicalConcept(for: "presupuesto máximo")?.id, "BUDGET_LIMIT")
        XCTAssertNil(dedupe.canonicalConcept(for: "presupuesto creativo de iluminación"))
    }

    func testKnownAppleDiscoveryAddsSourceWithoutDuplicate() throws {
        let store = try KnowledgeStore.load(), known = try XCTUnwrap(store.concepts.first { $0.id == "BUDGET_LIMIT" })
        let local = Discovery(id: "K_BUDGET_LIMIT", concept: known.labels.es, reason: known.reason, lens: known.lens, priority: .core, provenance: .localKnowledge, state: .included, dependencies: [], confidence: "HIGH")
        let result = AppleDiscoveryMerger(store: store).merge(local: [local], findings: [.init(concept: "budget", reason: "Limita opciones", lens: "Decision")])
        XCTAssertEqual(result.count, 1); XCTAssertTrue(result[0].sourceProvenance?.contains(.appleModel) == true)
    }

    func testUnknownAppleConceptRemainsExternalAndStable() throws {
        let store = try KnowledgeStore.load(), merger = AppleDiscoveryMerger(store: store)
        let finding = SemanticFinding(concept: "Estado sanitario de la colonia", reason: "Permite seguir cambios sectoriales.", lens: "Domain")
        let first = merger.merge(local: [], findings: [finding]), second = merger.merge(local: [], findings: [finding])
        XCTAssertEqual(first.first?.id, second.first?.id); XCTAssertTrue(first.first?.id.hasPrefix("APPLE_EXTERNAL_") == true)
    }

    func testUnknownAppleConceptIDDoesNotDependOnResponseOrder() throws {
        let store = try KnowledgeStore.load(), dedupe = LocalSemanticDeduplicator(store: store)
        let first = dedupe.appleDiscovery(index: 0, concept: "Estado sanitario de la colonia", reason: "Histórico útil.", lens: "Domain", existing: [])
        let reordered = dedupe.appleDiscovery(index: 7, concept: "Estado sanitario de la colonia", reason: "Histórico útil.", lens: "Domain", existing: [])
        XCTAssertEqual(first?.id, reordered?.id)
    }

    func testSimilarWordsDoNotCauseOverMerge() throws {
        let d = LocalSemanticDeduplicator(store: try KnowledgeStore.load())
        XCTAssertFalse(d.isDuplicate("presupuesto visual de producción", of: [Discovery(id: "K_BUDGET_LIMIT", concept: "presupuesto máximo", reason: "", lens: "", priority: .core, provenance: .localKnowledge, state: .included, dependencies: [], confidence: "HIGH")]))
    }
}
