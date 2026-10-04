import XCTest
@testable import Idevero

/// Deterministic holdout for semantic safety categories. The cases exercise
/// structural rules and do not encode expected sector answers.
final class Phase3SemanticHoldoutTests: XCTestCase {
    private struct Case {
        let request: String
        let domain: String
        let candidate: String
        let status: String
        let shouldSurvive: Bool
    }

    func testTwentyCrossDomainGroundingCases() throws {
        let cases: [Case] = [
            .init(request: "app para una clínica veterinaria", domain: "VETERINARY SERVICES", candidate: "paciente veterinario", status: "ESTABLISHED", shouldSurvive: true),
            .init(request: "app para mantenimiento de ascensores", domain: "MAINTENANCE", candidate: "campaña de venta minorista", status: "UNSUPPORTED", shouldSurvive: false),
            .init(request: "app para entrenadores personales", domain: "FITNESS", candidate: "seguimiento profesional", status: "ESTABLISHED", shouldSurvive: true),
            .init(request: "software para una pequeña bodega", domain: "FOOD BUSINESS", candidate: "red social pública", status: "UNSUPPORTED", shouldSurvive: false),
            .init(request: "app para fotógrafos de bodas", domain: "PHOTOGRAPHY", candidate: "flujo fotográfico", status: "ESTABLISHED", shouldSurvive: true),
            .init(request: "software para limpieza industrial", domain: "INDUSTRIAL SERVICES", candidate: "cotización bursátil", status: "UNSUPPORTED", shouldSurvive: false),
            .init(request: "app para una autoescuela", domain: "EDUCATION", candidate: "registro educativo", status: "ESTABLISHED", shouldSurvive: true),
            .init(request: "app para técnicos de climatización", domain: "FIELD SERVICE", candidate: "marketplace de ocio", status: "UNSUPPORTED", shouldSurvive: false),
            .init(request: "app para un vivero de plantas", domain: "PLANT BUSINESS", candidate: "inventario de plantas", status: "ESTABLISHED", shouldSurvive: true),
            .init(request: "app para consultores financieros", domain: "FINANCE", candidate: "historial financiero", status: "ESTABLISHED", shouldSurvive: true),
            .init(request: "I want an app for independent electricians", domain: "FIELD SERVICE", candidate: "electrical inspection history", status: "ESTABLISHED", shouldSurvive: true),
            .init(request: "I want software for a language school", domain: "EDUCATION", candidate: "hospital pharmacy workflow", status: "UNSUPPORTED", shouldSurvive: false),
            .init(request: "app de inventario con SKU_ID", domain: "INVENTORY", candidate: "SKU_ID", status: "ESTABLISHED", shouldSurvive: true),
            .init(request: "sistema fiscal con VAT_ID", domain: "FINANCE", candidate: "VAT_ID", status: "ESTABLISHED", shouldSurvive: true),
            .init(request: "integración clínica HL7_FHIR", domain: "HEALTH", candidate: "HL7_FHIR", status: "ESTABLISHED", shouldSurvive: true),
            .init(request: "auditoría ISO_27001", domain: "SECURITY", candidate: "ISO_27001", status: "ESTABLISHED", shouldSurvive: true),
            .init(request: "app para talleres", domain: "PROFESSIONAL SERVICES", candidate: "PRIMARY_JOB_A", status: "ESTABLISHED", shouldSurvive: false),
            .init(request: "app para talleres", domain: "PROFESSIONAL SERVICES", candidate: "OPTIONAL_FEATURE", status: "ESTABLISHED", shouldSurvive: false),
            .init(request: "Quiero una app profesional", domain: "PROFESSIONAL SERVICES", candidate: "Seasonal capacity limits", status: "ESTABLISHED", shouldSurvive: false),
            .init(request: "I want a professional app", domain: "PROFESSIONAL SERVICES", candidate: "Estado operativo", status: "ESTABLISHED", shouldSurvive: false)
        ]

        XCTAssertEqual(cases.count, 20)
        for item in cases {
            let frame = SemanticDomainFrame(
                primaryJobStatus: "UNDERSPECIFIED", primaryJobCandidates: [],
                actors: [], entities: [item.candidate], relationships: [], workflows: [], decisions: [], constraints: [],
                contextItems: [SemanticDomainItem(kind: "ENTITY", text: item.candidate, epistemicStatus: item.status, decisionRelevance: "HIGH")]
            )
            let context = try XCTUnwrap(DomainContextBuilder().build(
                frame: frame,
                language: .detect(in: item.request),
                originalRequest: item.request,
                resolvedTask: "APPLICATION",
                resolvedDomain: item.domain
            ))
            let survived = context.calibratedItems?.contains(where: { $0.text == item.candidate }) == true
            XCTAssertEqual(survived, item.shouldSurvive, "Unexpected holdout result for \(item.candidate)")
        }
    }

    func testEquivalentParaphrasesShareIdentityButDistinctConceptsDoNot() throws {
        let store = try KnowledgeStore.load()
        let subject = LocalSemanticDeduplicator(store: store)
        XCTAssertEqual(
            subject.semanticIdentity(concept: "Historial de revisiones por unidad"),
            subject.semanticIdentity(concept: "Registro histórico de inspecciones de cada unidad")
        )
        XCTAssertNotEqual(
            subject.semanticIdentity(concept: "Historial de revisiones por unidad"),
            subject.semanticIdentity(concept: "Calendario comercial")
        )
    }
}
