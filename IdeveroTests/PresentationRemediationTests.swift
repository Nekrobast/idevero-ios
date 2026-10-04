import XCTest
@testable import Idevero

final class PresentationRemediationTests: XCTestCase {
    private let residuals = ["TRIGGER", "RETRY_RECOVERY", "HUMAN_APPROVAL", "SOURCE_PROVENANCE", "LOCATION_CONTEXT", "PEOPLE_ROLES", "INSPECTIONS"]

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
}
