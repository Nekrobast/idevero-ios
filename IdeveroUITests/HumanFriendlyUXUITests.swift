import XCTest

@MainActor
final class HumanFriendlyUXUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    private func openDiscoveries(_ request: String, heading: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        let editor = app.textViews["ideaEditor"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap()
        editor.typeText(request)
        let keyboard = app.buttons["keyboardCreatePromptButton"]
        let create = keyboard.waitForExistence(timeout: 2) && keyboard.isHittable ? keyboard : app.buttons["createPromptButton"]
        create.tap()
        XCTAssertTrue(app.staticTexts[heading].waitForExistence(timeout: 20))
        let disclosure = app.buttons["discoveriesDisclosure"]
        for _ in 0..<20 where !disclosure.isHittable { app.swipeUp() }
        XCTAssertTrue(disclosure.isHittable)
        disclosure.tap()
        return app
    }

    func testSpanishCardsExplainActionsAndHideAdvancedMetadata() {
        let app = openDiscoveries("Quiero una app para gestionar prestamos de instrumentos", heading: "Prompt generado")
        let add = app.buttons["Añadir"].firstMatch
        for _ in 0..<12 where !add.isHittable { app.swipeUp() }
        XCTAssertTrue(add.isHittable)
        XCTAssertTrue(app.buttons["Mantener siempre"].firstMatch.isHittable)
        XCTAssertTrue(app.buttons["Quitar"].firstMatch.isHittable)
        XCTAssertFalse(app.buttons["Bloquear"].exists)
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Perspectiva:'")).firstMatch.exists)
        XCTAssertTrue(app.buttons["¿Por qué me recomienda esto?"].firstMatch.exists)
    }

    func testEnglishCardsExposeUnderstandableAccessibleActions() {
        let app = openDiscoveries("I want an app to manage telescope bookings", heading: "Generated prompt")
        let add = app.buttons["Add"].firstMatch
        for _ in 0..<12 where !add.isHittable { app.swipeUp() }
        XCTAssertTrue(add.isHittable)
        XCTAssertTrue(app.buttons["Always keep"].firstMatch.isHittable)
        XCTAssertTrue(app.buttons["Remove"].firstMatch.isHittable)
        XCTAssertFalse(app.buttons["Bloquear"].exists)
        XCTAssertFalse(app.buttons["Añadir"].exists)
        XCTAssertGreaterThanOrEqual(add.frame.height, 44)
    }
}
