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
        for title in ["Mantener siempre", "Quitar"] {
            let action = app.buttons[title].firstMatch
            for _ in 0..<6 where !action.isHittable { app.swipeUp() }
            XCTAssertTrue(action.isHittable)
            XCTAssertGreaterThanOrEqual(action.frame.height, 44)
        }
        XCTAssertFalse(app.buttons["Bloquear"].exists)
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Perspectiva:'")).firstMatch.exists)
        XCTAssertTrue(app.buttons["¿Por qué me recomienda esto?"].firstMatch.exists)
    }

    func testEnglishCardsExposeUnderstandableAccessibleActions() {
        let app = openDiscoveries("I want an app to manage telescope bookings", heading: "Generated prompt")
        let add = app.buttons["Add"].firstMatch
        for _ in 0..<12 where !add.isHittable { app.swipeUp() }
        XCTAssertTrue(add.isHittable)
        for title in ["Always keep", "Remove"] {
            let action = app.buttons[title].firstMatch
            for _ in 0..<6 where !action.isHittable { app.swipeUp() }
            XCTAssertTrue(action.isHittable)
            XCTAssertGreaterThanOrEqual(action.frame.height, 44)
        }
        XCTAssertFalse(app.buttons["Bloquear"].exists)
        XCTAssertFalse(app.buttons["Añadir"].exists)
        XCTAssertGreaterThanOrEqual(add.frame.height, 44)
    }

    func testHumanActionsKeepTheirActualEffectsAndDetailsAreAccessible() {
        let app = openDiscoveries("Quiero una app para gestionar reservas de telescopios", heading: "Prompt generado")
        let keep = app.buttons["Mantener siempre"].firstMatch
        for _ in 0..<12 where !keep.isHittable { app.swipeUp() }
        XCTAssertTrue(keep.isHittable)
        keep.tap()
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Se mantendrá siempre'")).firstMatch.waitForExistence(timeout: 5))
        let remove = app.buttons["Quitar"].firstMatch
        for _ in 0..<6 where !remove.isHittable { app.swipeUp() }
        remove.tap()
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'No se utilizará'")).firstMatch.waitForExistence(timeout: 5))
        let add = app.buttons["Añadir"].firstMatch
        for _ in 0..<6 where !add.isHittable { app.swipeDown() }
        XCTAssertTrue(add.isHittable)
        add.tap()
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Añadido'")).firstMatch.waitForExistence(timeout: 5))
        let why = app.buttons["¿Por qué me recomienda esto?"].firstMatch
        for _ in 0..<6 where !why.isHittable { app.swipeUp() }
        XCTAssertTrue(why.isHittable)
        why.tap()
        XCTAssertTrue(app.staticTexts["De dónde sale esta recomendación"].firstMatch.waitForExistence(timeout: 3))
        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screenshot.lifetime = .keepAlways
        self.add(screenshot)
    }
}
