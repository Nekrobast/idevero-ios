import XCTest
@testable import Idevero

final class HumanFriendlyUXTests: XCTestCase {
    private func finding() -> Discovery {
        Discovery(id: "K_IDEMPOTENCY", concept: "deduplicación e idempotencia", reason: "Evita repetir acciones al reintentar.", lens: "Fiabilidad", priority: .highValue, provenance: .localKnowledge, state: .included, dependencies: [], confidence: "HIGH", sourceProvenance: [.localKnowledge])
    }

    func testDisplayTitleMustNotBecomeSemanticIdentity() {
        let source = finding()
        let identity = DiscoverySemantics.identity(source)
        let humanTitle = "Evitar duplicados y acciones repetidas"
        XCTAssertNotEqual(identity, DiscoverySemantics.identity(concept: humanTitle))
        XCTAssertEqual(DiscoverySemantics.identity(source), identity)
    }

    func testAddKeepRemovePreserveExistingTransitionsAndSources() {
        let source = finding()
        for state in [DiscoveryState.included, .locked, .excluded] {
            let changed = DiscoverySemantics.transition(source, to: state)
            XCTAssertEqual(changed.state, state)
            XCTAssertEqual(changed.id, source.id)
            XCTAssertEqual(changed.sourceProvenance, source.sourceProvenance)
            XCTAssertEqual(DiscoverySemantics.identity(changed), DiscoverySemantics.identity(source))
        }
        XCTAssertEqual(DiscoverySemantics.transition(source, to: .locked).provenance, .userLocked)
    }

    func testHoldoutUserDecisionsSurviveReanalysis() throws {
        let provider = LocalExpertProvider()
        let before = try provider.analyze("Quiero una app para gestionar reservas de telescopios", decisions: .init())
        let item = try XCTUnwrap(before.discoveries.first)
        var decisions = DiscoveryDecisions()
        decisions.locked.insert(item.id)
        let after = try provider.analyze(before.input, decisions: decisions)
        XCTAssertEqual(after.discoveries.first { $0.id == item.id }?.state, .locked)
        XCTAssertEqual(after.discoveries.first { $0.id == item.id }?.provenance, .userLocked)
    }

    func testTechnicalLiteralHoldoutRemainsInCompiledRequest() throws {
        let source = try LocalExpertProvider().analyze("I want an app to manage spectrometer records with SAMPLE_KEY and ISO 17025", decisions: .init())
        XCTAssertTrue(source.prompt.contains("SAMPLE_KEY"))
        XCTAssertTrue(source.prompt.contains("ISO 17025"))
        XCTAssertEqual(SpecializedCompiler().compile(source), source.prompt)
    }
}
