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

    func testProjectionNeverMutatesIdentityCompilerOrProvenance() throws {
        let source = try LocalExpertProvider().analyze("Quiero una app para gestionar reservas de telescopios", decisions: .init())
        let before = SpecializedCompiler().compile(source)
        for item in source.discoveries {
            let copy = item
            _ = DiscoveryPresentation(item: item, language: .spanish)
            _ = DiscoveryPresentation(item: item, language: .english)
            XCTAssertEqual(item, copy)
            XCTAssertEqual(DiscoverySemantics.identity(item), DiscoverySemantics.identity(copy))
            XCTAssertEqual(item.sourceProvenance, copy.sourceProvenance)
        }
        XCTAssertEqual(SpecializedCompiler().compile(source), before)
    }

    func testPlainLanguageCatalogAndBilingualActions() {
        let es = DiscoveryPresentation(item: finding(), language: .spanish)
        let en = DiscoveryPresentation(item: finding(), language: .english)
        XCTAssertEqual(es.title, "Evitar duplicados y acciones repetidas")
        XCTAssertEqual(en.title, "Avoid duplicates and repeated actions")
        XCTAssertEqual(es.actionTitle(.included), "Añadir")
        XCTAssertEqual(es.actionTitle(.locked), "Mantener siempre")
        XCTAssertEqual(es.actionTitle(.excluded), "Quitar")
        XCTAssertEqual(en.actionTitle(.included), "Add")
        XCTAssertEqual(en.actionTitle(.locked), "Always keep")
        XCTAssertEqual(en.actionTitle(.excluded), "Remove")
        XCTAssertFalse(es.explanation.contains("idempotencia"))
        XCTAssertFalse(en.explanation.contains("deduplicación"))
    }

    func testMachineMetadataCannotLeakButExplicitLiteralsRemain() {
        let item = Discovery(id: "APPLE_PRIVATE", concept: "SAMPLE_KEY and ISO 17025", reason: "Keep SAMPLE_KEY and ISO 17025 in each record.", lens: "operations_registry", priority: .highValue, provenance: .appleModel, state: .included, dependencies: [], confidence: "HIGH", semanticRole: "DOMAIN_PRIMITIVE")
        let display = DiscoveryPresentation(item: item, language: .english)
        XCTAssertTrue(display.title.contains("SAMPLE_KEY"))
        XCTAssertTrue(display.technicalTitle.contains("ISO 17025"))
        XCTAssertFalse(display.perspective.contains("operations_registry"))
        XCTAssertFalse(display.sourceDescriptions.joined().contains("APPLE_PRIVATE"))
    }

    func testUnknownNaturalHoldoutRetainsPrecisionAndDoesNotInventDomainObjects() {
        let item = Discovery(id: "UNSEEN", concept: "Calibrate the spectrometer", reason: "Check calibration before collecting measurements.", lens: "Measurement", priority: .optional, provenance: .appleModel, state: .pending, dependencies: [], confidence: "MEDIUM")
        let display = DiscoveryPresentation(item: item, language: .english)
        XCTAssertEqual(display.title, item.concept)
        XCTAssertEqual(display.explanation, item.reason)
        XCTAssertEqual(display.priority, "Optional")
        XCTAssertTrue(display.sourceDescriptions.joined().contains("confirm"))
    }

    func testDisplayActionsDoNotChangeAnyInternalStateOrPriority() {
        for state in DiscoveryState.allCases {
            var item = finding()
            item.state = state
            let before = item
            let display = DiscoveryPresentation(item: item, language: .spanish)
            XCTAssertFalse(display.state.isEmpty)
            XCTAssertEqual(item, before)
        }
        for priority in RequirementPriority.allCases {
            var item = finding()
            item.priority = priority
            XCTAssertFalse(DiscoveryPresentation(item: item, language: .english).priority.isEmpty)
            XCTAssertEqual(item.priority, priority)
        }
    }

    func testAllProvenanceCasesHaveHumanDescriptionsInBothLanguages() {
        for provenance in DiscoveryProvenance.allCases {
            var item = finding()
            item.provenance = provenance
            item.sourceProvenance = [provenance]
            for language in [DisplayLanguage.spanish, .english] {
                let display = DiscoveryPresentation(item: item, language: language)
                XCTAssertEqual(display.sourceDescriptions.count, 1)
                XCTAssertFalse(display.sourceDescriptions[0].contains(provenance.rawValue))
            }
        }
    }

    func testAuthoredMetadataAlsoAppliesToMergedFindingWithoutReidentifyingIt() {
        let source = finding()
        let merged = Discovery(id: "APPLE_NEW", concept: source.concept, reason: source.reason, lens: source.lens, priority: source.priority, provenance: .appleModel, state: source.state, dependencies: [], confidence: "MEDIUM")
        let display = DiscoveryPresentation(item: merged, language: .spanish)
        XCTAssertEqual(display.title, DiscoveryPresentation(item: source, language: .spanish).title)
        XCTAssertEqual(merged.id, "APPLE_NEW")
        XCTAssertTrue(display.sourceDescriptions.joined().contains("confirmar"))
    }

    @MainActor
    func testHumanActionContractsRetainAllThreeDecisionsThroughActualReanalysis() async throws {
        for state in [DiscoveryState.included, .locked, .excluded] {
            let model = CreateViewModel(coordinator: IntelligenceCoordinator(local: LocalExpertProvider()))
            model.idea = "Quiero una app para gestionar reservas de telescopios"
            await model.generate()
            let first = try XCTUnwrap(model.analysis?.discoveries.first)
            XCTAssertFalse(DiscoveryPresentation(item: first, language: .spanish).actionTitle(state).isEmpty)
            await model.setState(state, id: first.id)
            let identity = DiscoverySemantics.identity(try XCTUnwrap(model.analysis?.discoveries.first { $0.id == first.id }))
            await model.reanalyze()
            let restored = try XCTUnwrap(model.analysis?.discoveries.first { DiscoverySemantics.identity($0) == identity })
            XCTAssertEqual(restored.state, state)
            XCTAssertEqual(restored.provenance, state == .locked ? .userLocked : state == .included ? .userAccepted : first.provenance)
        }
    }

    func testUnjustifiedMixedLanguageAndLowercaseMetadataHaveSafeFallbacks() {
        let item = Discovery(id: "UNSEEN", concept: "la gestión del registro", reason: "Controla operations_pipeline para la gestión del registro.", lens: "operations_pipeline", priority: .optional, provenance: .appleModel, state: .pending, dependencies: [], confidence: "LOW")
        let en = DiscoveryPresentation(item: item, language: .english)
        XCTAssertEqual(en.title, "A detail of your request")
        XCTAssertFalse(en.fullReason.contains("operations_pipeline"))
        XCTAssertFalse(en.perspective.contains("operations_pipeline"))
        var literal = DiscoveryPresentation(item: Discovery(id: "USER", concept: "Use sample_key for records", reason: "Keep sample_key in each record.", lens: "Data", priority: .core, provenance: .userExplicit, state: .included, dependencies: [], confidence: "HIGH"), language: .english)
        literal.originalRequest = "Use sample_key for records"
        XCTAssertTrue(literal.title.contains("sample_key"))
    }

    func testTaskTitleAndAccessibleActionEffectsUseHumanCopy() {
        XCTAssertEqual(DisplayLocalization(language: .english).task("IMAGE_EDITING"), "Image Editing")
        for language in [DisplayLanguage.spanish, .english] {
            let display = DiscoveryPresentation(item: finding(), language: language)
            for state in [DiscoveryState.included, .locked, .excluded] {
                XCTAssertFalse(display.actionHint(state).isEmpty)
                XCTAssertFalse(display.actionHint(state).contains(state.rawValue))
            }
        }
    }
}
