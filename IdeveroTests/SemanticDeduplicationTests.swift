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
        let result = AppleDiscoveryMerger(store: store).merge(local: [local], findings: [.init(concept: "budget", reason: "Determina qué alternativas reales pueden compararse sin superar el límite económico indicado por el usuario.", lens: "Decision", semanticRole: "DECISION_INPUT", anchor: "budget")])
        XCTAssertEqual(result.count, 1); XCTAssertTrue(result[0].sourceProvenance?.contains(.appleModel) == true)
    }

    func testGenericAppleFindingIsRejected() throws {
        let finding = SemanticFinding(concept: "Buena experiencia de usuario", reason: "Es importante crear una experiencia genérica que resulte agradable para cualquier usuario.", lens: "General", semanticRole: "GENERAL", anchor: "usuario", materiality: "LOW", userIntentFit: "MEDIUM", scopeRisk: "MEDIUM")
        let result = AppleDiscoveryMerger(store: try KnowledgeStore.load()).merge(local: [], findings: [finding], request: "app para un sector")
        XCTAssertTrue(result.isEmpty)
    }

    func testMaterialDomainFindingIsAccepted() throws {
        let finding = SemanticFinding(concept: "Historial de inspecciones por activo", reason: "Vincula cada revisión con el activo, su estado anterior y las incidencias detectadas para poder decidir el siguiente trabajo.", lens: "Workflow operativo", semanticRole: "CORE_WORKFLOW", anchor: "inspecciones por activo", materiality: "HIGH", userIntentFit: "HIGH", scopeRisk: "LOW")
        let result = AppleDiscoveryMerger(store: try KnowledgeStore.load()).merge(local: [], findings: [finding], request: "app para gestionar trabajo de campo")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].provenance, .appleModel)
    }

    func testSpecificAppleReasonCanReplaceShallowLocalReasonWithoutDuplication() throws {
        let store = try KnowledgeStore.load(), known = try XCTUnwrap(store.concepts.first { $0.id == "DATA_MODEL" })
        let local = Discovery(id: "K_DATA_MODEL", concept: known.labels.es, reason: "Define los datos necesarios.", lens: "Producto", priority: .highValue, provenance: .localKnowledge, state: .included, dependencies: [], confidence: "HIGH")
        let reason = "Relaciona cada unidad gestionada con sus revisiones, cambios de estado e incidencias para conservar trazabilidad y apoyar decisiones operativas posteriores."
        let result = AppleDiscoveryMerger(store: store).merge(local: [local], findings: [.init(concept: known.labels.es, reason: reason, lens: "Modelo del dominio", semanticRole: "DOMAIN_PRIMITIVE", anchor: known.labels.es)])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].reason, reason)
        XCTAssertTrue(result[0].sourceProvenance?.contains(.appleModel) == true)
    }

    func testUnknownAppleConceptRemainsExternalAndStable() throws {
        let store = try KnowledgeStore.load(), merger = AppleDiscoveryMerger(store: store)
        let finding = SemanticFinding(concept: "Estado sanitario de la colonia", reason: "Registra cambios sectoriales a lo largo del tiempo y los vincula con revisiones e incidencias para apoyar decisiones posteriores.", lens: "Domain", semanticRole: "DOMAIN_PRIMITIVE", anchor: "colonia")
        let first = merger.merge(local: [], findings: [finding]), second = merger.merge(local: [], findings: [finding])
        XCTAssertEqual(first.first?.id, second.first?.id); XCTAssertTrue(first.first?.id.hasPrefix("APPLE_EXTERNAL_") == true)
    }

    func testUnknownAppleConceptIDDoesNotDependOnResponseOrder() throws {
        let store = try KnowledgeStore.load(), dedupe = LocalSemanticDeduplicator(store: store)
        let first = dedupe.appleDiscovery(index: 0, concept: "Estado sanitario de la colonia", reason: "Registra el histórico útil de cada unidad y lo vincula con revisiones e incidencias operativas.", lens: "Domain", existing: [])
        let reordered = dedupe.appleDiscovery(index: 7, concept: "Estado sanitario de la colonia", reason: "Registra el histórico útil de cada unidad y lo vincula con revisiones e incidencias operativas.", lens: "Domain", existing: [])
        XCTAssertEqual(first?.id, reordered?.id)
    }

    func testSimilarWordsDoNotCauseOverMerge() throws {
        let d = LocalSemanticDeduplicator(store: try KnowledgeStore.load())
        XCTAssertFalse(d.isDuplicate("presupuesto visual de producción", of: [Discovery(id: "K_BUDGET_LIMIT", concept: "presupuesto máximo", reason: "", lens: "", priority: .core, provenance: .localKnowledge, state: .included, dependencies: [], confidence: "HIGH")]))
    }
}
