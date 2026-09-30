import XCTest
@testable import Idevero

final class FoundationModelsDeviceTests: XCTestCase {
    func testRealFoundationModelOnCompatibleDeviceOnly() async throws {
        #if targetEnvironment(simulator)
        throw XCTSkip("DEVICE TEST: Foundation Models requiere un dispositivo físico compatible con Apple Intelligence.")
        #else
        let provider = FoundationModelsProvider()
        guard case .ready = await provider.availability() else { throw XCTSkip("DEVICE / SDK TEST: Foundation Models no disponible en este destino.") }
        let result = try await provider.analyze("app para apicultores")
        XCTAssertEqual(result.intelligenceMode, "APPLE AUGMENTED + LOCAL EXPERT")
        XCTAssertTrue(result.discoveries.contains { $0.provenance == .appleModel || $0.sourceProvenance?.contains(.appleModel) == true })
        #endif
    }
}
