import XCTest
@testable import Idevero

final class FoundationQualityV2Tests: XCTestCase {
    private let provider = LocalExpertProvider()

    func testCrossDomainHoldoutPreservesTaskShape() throws {
        let cases: [(String, String)] = [
            ("Quiero crear una app para apicultores", "APPLICATION"),
            ("Quiero crear una app para gestionar una clínica veterinaria", "APPLICATION"),
            ("Quiero crear una app para una empresa de mantenimiento de ascensores", "APPLICATION"),
            ("Quiero crear una aplicación para entrenadores personales", "APPLICATION"),
            ("Quiero crear una app para gestionar una pequeña bodega", "APPLICATION"),
            ("Quiero una app para fotógrafos de bodas", "APPLICATION"),
            ("Quiero crear un marketplace de piezas de bicicleta usadas", "SHOPPING"),
            ("Necesito un Excel para gestionar un taller mecánico", "SPREADSHEET"),
            ("Quiero comparar móviles por 500 € con buenas fotos", "SHOPPING"),
            ("Organízame un viaje de siete días a Japón", "TRAVEL"),
            ("Escribe un email corto para agradecer una entrevista", "EMAIL"),
            ("Genera una imagen de un samurái bajo la lluvia", "IMAGE")
        ]
        for (input, expectedTask) in cases {
            let result = try provider.analyze(input, decisions: .init())
            XCTAssertEqual(result.task, expectedTask, input)
        }
    }

    func testSimpleEmailRemainsCompactAfterCompilerV2() throws {
        let result = try provider.analyze("Escribe un email corto de agradecimiento", decisions: .init())
        XCTAssertEqual(result.elaboration, .light)
        XCTAssertLessThan(result.prompt.count, 650)
        XCTAssertFalse(result.prompt.contains("Contexto y requisitos específicos del dominio"))
    }

    func testScopeRiskAndLowIntentFitAreRejected() throws {
        let merger = AppleDiscoveryMerger(store: try KnowledgeStore.load())
        let highRisk = SemanticFinding(concept: "Sensores conectados automáticamente", reason: "Añade dispositivos y una integración remota aunque el usuario no ha solicitado hardware ni captura automática.", lens: "Tecnología", kind: "OPERATIONAL_CONTEXT", materiality: "MEDIUM", userIntentFit: "MEDIUM", scopeRisk: "HIGH")
        let lowFit = SemanticFinding(concept: "Programa de fidelización comercial", reason: "Permite ofrecer recompensas y campañas comerciales aunque la petición se centra en una operación interna diferente.", lens: "Marketing", kind: "WORKFLOW", materiality: "MEDIUM", userIntentFit: "LOW", scopeRisk: "MEDIUM")
        XCTAssertTrue(merger.merge(local: [], findings: [highRisk, lowFit], request: "app operativa sencilla").isEmpty)
    }

    func testLockedAndExcludedDiscoveriesRemainAuthoritativeDuringAppleMerge() throws {
        let locked = Discovery(id: "LOCKED", concept: "Historial operativo", reason: "Conserva decisiones previas.", lens: "Usuario", priority: .core, provenance: .userLocked, state: .locked, dependencies: [], confidence: "HIGH")
        let excluded = Discovery(id: "EXCLUDED", concept: "Integración automática", reason: "Excluida por el usuario.", lens: "Usuario", priority: .outOfScope, provenance: .localKnowledge, state: .excluded, dependencies: [], confidence: "HIGH")
        let finding = SemanticFinding(concept: "Flujo de revisión por activo", reason: "Relaciona cada revisión con su activo y estado anterior para decidir la siguiente acción operativa.", lens: "Dominio", kind: "WORKFLOW")
        let result = AppleDiscoveryMerger(store: try KnowledgeStore.load()).merge(local: [locked, excluded], findings: [finding], request: "app de trabajo")
        XCTAssertEqual(result.first { $0.id == "LOCKED" }?.state, .locked)
        XCTAssertEqual(result.first { $0.id == "EXCLUDED" }?.state, .excluded)
    }
}
