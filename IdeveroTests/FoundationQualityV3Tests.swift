import XCTest
@testable import Idevero

final class FoundationQualityV3Tests: XCTestCase {
    private let provider = LocalExpertProvider()

    private var frame: SemanticDomainFrame {
        SemanticDomainFrame(
            primaryJobStatus: "UNDERSPECIFIED",
            primaryJobCandidates: ["operar el trabajo diario", "seguir la evolución", "administrar recursos"],
            actors: ["profesional"],
            entities: ["unidad gestionada", "registro histórico"],
            relationships: ["unidad con su historial"],
            workflows: ["revisión de la unidad"],
            decisions: ["siguiente intervención"],
            constraints: ["trabajo en campo"]
        )
    }

    private func merge(_ findings: [SemanticFinding]) throws -> [Discovery] {
        AppleDiscoveryMerger(store: try KnowledgeStore.load()).merge(
            local: [],
            findings: findings,
            request: "Quiero crear una app para un sector profesional",
            frame: frame
        )
    }

    func testDomainPrimitiveAndCoreWorkflowAreAcceptedWhenAnchored() throws {
        let primitive = SemanticFinding(concept: "Unidad gestionada", reason: "Es la unidad estable a la que pertenecen cambios de estado, revisiones e incidencias a lo largo del tiempo.", lens: "Modelo del dominio", semanticRole: "DOMAIN_PRIMITIVE", anchor: "unidad gestionada")
        let workflow = SemanticFinding(concept: "Revisión periódica de cada unidad", reason: "Actualiza su estado y conserva observaciones que determinan la siguiente intervención profesional.", lens: "Operación", semanticRole: "CORE_WORKFLOW", anchor: "revisión de la unidad")
        let result = try merge([primitive, workflow])
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.state == .included })
    }

    func testOptionalAndContextDependentFindingsAreNotAutoIncluded() throws {
        let optional = SemanticFinding(concept: "Informe visual agregado", reason: "Resume tendencias del registro histórico, pero solo aporta valor cuando el usuario necesita supervisión agregada.", lens: "Reporting", semanticRole: "OPTIONAL_FEATURE", anchor: "registro histórico", scopeDependency: "OPTIONAL", decisionImpact: "MEDIUM")
        let result = try merge([optional])
        XCTAssertEqual(result.first?.priority, .optional)
        XCTAssertEqual(result.first?.state, .optional)
    }

    func testBusinessExpansionIsRejectedEvenWhenSelfRatedHigh() throws {
        let expansion = SemanticFinding(concept: "Intercambio comercial con terceros", reason: "Podría ampliar la distribución y abrir nuevas oportunidades económicas fuera del trabajo operativo principal.", lens: "Negocio", semanticRole: "BUSINESS_OPPORTUNITY", anchor: "profesional", materiality: "HIGH", userIntentFit: "HIGH", scopeRisk: "LOW")
        XCTAssertTrue(try merge([expansion]).isEmpty)
    }

    func testHighAssumptionIsNotIncludedAndCanBecomeUnknown() throws {
        let assumed = SemanticFinding(concept: "Captura automática en campo", reason: "Cambiaría la forma de registrar el estado, pero presupone equipamiento y una operación todavía no confirmados.", lens: "Operación", semanticRole: "CONTEXT_DEPENDENT", anchor: "trabajo en campo", assumptionLevel: "HIGH", requiresConfirmation: true, scopeDependency: "CONTEXT_DEPENDENT", decisionImpact: "HIGH")
        XCTAssertTrue(try merge([assumed]).isEmpty)
        let selected = AppleUnknownSelector().select([], frame: frame, findings: [assumed])
        XCTAssertEqual(selected.count, 1)
        XCTAssertFalse(selected.contains { $0.localizedCaseInsensitiveContains("captura automática") })
        XCTAssertTrue(selected[0].localizedCaseInsensitiveContains("trabajo principal"))
    }

    func testUnanchoredFindingIsRejected() throws {
        let finding = SemanticFinding(concept: "Integración externa avanzada", reason: "Conecta información adicional y automatiza intercambios que podrían resultar útiles en algunos escenarios futuros.", lens: "Integración", semanticRole: "OPTIONAL_FEATURE", anchor: "mercado externo", scopeDependency: "OPTIONAL")
        XCTAssertTrue(try merge([finding]).isEmpty)
    }

    func testLowDecisionImpactUnknownIsRejected() {
        let unknown = SemanticUnknown(question: "¿Qué color debería utilizar?", reason: "Permite ajustar una preferencia estética menor sin cambiar el producto.", architectureImpact: "LOW", workflowImpact: "LOW", scopeImpact: "LOW")
        let selected = AppleUnknownSelector().select([unknown], frame: SemanticDomainFrame(primaryJobStatus: "DEFINED", primaryJobCandidates: [], actors: [], entities: [], relationships: [], workflows: [], decisions: [], constraints: []), findings: [])
        XCTAssertTrue(selected.isEmpty)
    }

    func testUnderspecifiedPrimaryJobProducesHighestImpactUnknown() {
        let selected = AppleUnknownSelector().select([], frame: frame, findings: [])
        XCTAssertEqual(selected.count, 1)
        XCTAssertTrue(selected[0].contains("trabajo principal"))
    }

    func testGenericProductScaffoldingIsCompressed() throws {
        let analysis = try provider.analyze("app gastos", decisions: .init())
        XCTAssertFalse(analysis.prompt.contains("Requisitos esenciales del producto"))
        XCTAssertTrue(analysis.prompt.contains("flujo, modelo de información, navegación, persistencia, estados, validaciones"))
        XCTAssertLessThan(analysis.prompt.count, 2_200)
    }

    func testDomainSectionIsProminentAndGrouped() throws {
        var analysis = try provider.analyze("app para un sector profesional", decisions: .init())
        analysis.discoveries.append(Discovery(id: "APPLE_PRIMITIVE", concept: "Unidad gestionada", reason: "Relaciona el trabajo con una unidad estable y su evolución.", lens: "Dominio", priority: .highValue, provenance: .appleModel, state: .included, dependencies: [], confidence: "HIGH", sourceProvenance: [.appleModel], semanticRole: "DOMAIN_PRIMITIVE", anchor: "unidad gestionada"))
        analysis.discoveries.append(Discovery(id: "APPLE_WORKFLOW", concept: "Revisión de la unidad", reason: "Actualiza su estado antes de decidir la siguiente intervención.", lens: "Operación", priority: .highValue, provenance: .appleModel, state: .included, dependencies: [], confidence: "HIGH", sourceProvenance: [.appleModel], semanticRole: "CORE_WORKFLOW", anchor: "revisión"))
        let prompt = SpecializedCompiler().compile(analysis)
        XCTAssertTrue(prompt.contains("Contexto del dominio"))
        XCTAssertTrue(prompt.contains("Requisitos sectoriales confirmados"))
        XCTAssertLessThan(try XCTUnwrap(prompt.range(of: "Contexto del dominio")?.lowerBound), try XCTUnwrap(prompt.range(of: "Diseño del producto")?.lowerBound))
    }

    func testCrossDomainHoldoutV2KeepsApplicationTaskWithoutSectorRules() throws {
        let requests = [
            "app para apicultores",
            "app para una clínica veterinaria",
            "app para mantenimiento de ascensores",
            "app para entrenadores personales",
            "app para una pequeña bodega",
            "app para fotógrafos de bodas",
            "software para una empresa de limpieza industrial",
            "app para una escuela de conducción",
            "app para técnicos de climatización",
            "app para un vivero de plantas"
        ]
        for request in requests {
            XCTAssertEqual(try provider.analyze(request, decisions: .init()).task, "APPLICATION", request)
        }
    }
}
