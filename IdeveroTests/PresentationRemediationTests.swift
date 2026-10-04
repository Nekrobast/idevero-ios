import XCTest
@testable import Idevero

final class PresentationRemediationTests: XCTestCase {
    func testResidualAuthoredTitlesArePlainInBothLanguages() throws {
        let store = try KnowledgeStore.load()
        let labels = ["disparador", "reintentos, errores y recuperación", "aprobación humana", "fuente, procedencia y frescura", "ubicación y contexto operativo", "personas y roles", "revisiones e inspecciones"]
        for label in labels {
            let concept = try XCTUnwrap(store.concepts.first { $0.labels.es == label })
            for language in [DisplayLanguage.spanish, .english] {
                let raw = language == .spanish ? concept.labels.es : concept.labels.en
                let item = Discovery(id: "K_" + concept.id, concept: raw, reason: "Check whether this helps your request.", lens: "Needs", priority: .highValue, provenance: .localKnowledge, state: .included, dependencies: [], confidence: "HIGH")
                let display = DiscoveryPresentation(item: item, language: language)
                XCTAssertNotEqual(display.title.lowercased(), raw.lowercased(), "Residual title: \(raw)")
                XCTAssertFalse(display.explanation.isEmpty)
                XCTAssertEqual(item.concept, raw)
            }
        }
    }

    func testPhysicalAndUnseenHoldoutsKeepCompilerIdentityAndReanalysis() throws {
        for request in ["Quiero crear una app para gestionar las tareas de mantenimiento de una comunidad de vecinos", "I want to automate archive digitization when a scan arrives", "Quiero organizar revisiones de equipos de astronomía"] {
            let provider = LocalExpertProvider()
            let analysis = try provider.analyze(request, decisions: .init())
            let compiled = SpecializedCompiler().compile(analysis)
            for item in analysis.discoveries {
                let identity = DiscoverySemantics.identity(item)
                _ = DiscoveryPresentation(item: item, language: .detect(in: request), originalRequest: request).title
                XCTAssertEqual(DiscoverySemantics.identity(item), identity)
            }
            XCTAssertEqual(SpecializedCompiler().compile(analysis), compiled)
            let first = try XCTUnwrap(analysis.discoveries.first)
            var decisions = DiscoveryDecisions()
            decisions.locked.insert(first.id)
            let again = try provider.analyze(request, decisions: decisions)
            XCTAssertEqual(again.discoveries.first { $0.id == first.id }?.state, .locked)
        }
    }

    func testTwentySevenFindingsArePartitionedLosslesslyIntoSixInitialCards() {
        let items = (0..<27).map { index in
            Discovery(id: "UNSEEN_\(index)", concept: "Finding \(index)", reason: "Check the information.", lens: "Needs", priority: index < 10 ? .core : .highValue, provenance: .localKnowledge, state: .included, dependencies: [], confidence: "HIGH")
        }
        let summary = DiscoveryPresentation.summary(items)
        XCTAssertEqual(summary.important.count, 4)
        XCTAssertEqual(summary.recommended.count, 2)
        XCTAssertEqual(summary.initial.count, 6)
        XCTAssertEqual(summary.more.count, 21)
        XCTAssertEqual(Set((summary.initial + summary.more).map(\.id)), Set(items.map(\.id)))
        XCTAssertEqual(summary.initial + summary.more, DiscoveryPresentation.summary(items).initial + DiscoveryPresentation.summary(items).more)
        XCTAssertEqual(items.map(\.state), Array(repeating: .included, count: 27))
    }

    func testUserDecisionsCannotBeHiddenByThePreviewCap() {
        var items = (0..<27).map { index in
            Discovery(id: "HOLDOUT_\(index)", concept: "Review \(index)", reason: "Check the result.", lens: "Needs", priority: .optional, provenance: .localKnowledge, state: .pending, dependencies: [], confidence: "HIGH")
        }
        items[23] = DiscoverySemantics.transition(items[23], to: .locked)
        items[24] = DiscoverySemantics.transition(items[24], to: .excluded)
        items[25] = DiscoverySemantics.transition(items[25], to: .included)
        items[26].provenance = .userExplicit
        let summary = DiscoveryPresentation.summary(items)
        XCTAssertEqual(summary.decisions.map(\.id), Array(items.suffix(4)).map(\.id))
        XCTAssertTrue(summary.more.allSatisfy { !Set(summary.decisions.map(\.id)).contains($0.id) })
        XCTAssertEqual(summary.initial.count + summary.more.count, items.count)
        XCTAssertEqual(summary.important.count, 4)
    }

    func testPhysicalFixturePreviewPreservesEveryDiscoveryAndCompiler() throws {
        let request = "Quiero crear una app para gestionar las tareas de mantenimiento de una comunidad de vecinos"
        let source = try LocalExpertProvider().analyze(request, decisions: .init())
        let before = SpecializedCompiler().compile(source)
        let summary = DiscoveryPresentation.summary(source.discoveries)
        XCTAssertLessThanOrEqual(summary.initial.count - summary.decisions.count, 6)
        XCTAssertFalse(summary.more.isEmpty)
        XCTAssertEqual(Set((summary.initial + summary.more).map(\.id)), Set(source.discoveries.map(\.id)))
        XCTAssertEqual(SpecializedCompiler().compile(source), before)
        print("PHYSICAL_FIXTURE_PREVIEW total=\(source.discoveries.count) initial=\(summary.initial.count) decisions=\(summary.decisions.count) important=\(summary.important.count) recommended=\(summary.recommended.count) more=\(summary.more.count)")
    }

    func testCurrentActionCopyAndAccessibilitySelectionInEveryStateAndLanguage() {
        for language in [DisplayLanguage.spanish, .english] {
            for current in DiscoveryState.allCases {
                let item = Discovery(id: "UNSEEN", concept: "Check the result", reason: "Review before continuing.", lens: "Needs", priority: .highValue, provenance: .localKnowledge, state: current, dependencies: [], confidence: "HIGH")
                let display = DiscoveryPresentation(item: item, language: language)
                for action in [DiscoveryState.included, .locked, .excluded] {
                    XCTAssertEqual(display.isSelectedAction(action), current == action || (current == .locked && action == .included))
                    XCTAssertFalse(display.controlHint(action).contains(action.rawValue))
                }
                XCTAssertEqual(display.controlTitle(.included), current == .included || current == .locked ? (language == .spanish ? "Añadido" : "Added") : (language == .spanish ? "Añadir" : "Add"))
                XCTAssertEqual(display.controlTitle(.excluded), current == .excluded ? (language == .spanish ? "Quitado" : "Removed") : (language == .spanish ? "Quitar" : "Remove"))
                XCTAssertEqual(item.state, current)
            }
        }
    }

    func testPriorityStateOrderingHasNoHiddenSideEffects() {
        let items = (0..<8).map { index in
            Discovery(id: "CASE_\(index)", concept: "Check \(index)", reason: "Check the result.", lens: "Needs", priority: .core, provenance: .localKnowledge, state: index == 7 ? .pending : .included, dependencies: [], confidence: "HIGH")
        }
        let before = items
        let summary = DiscoveryPresentation.summary(items)
        XCTAssertEqual(summary.important.first?.id, "CASE_7")
        XCTAssertEqual(summary.more.count, 2)
        XCTAssertEqual(items, before)
    }
}
