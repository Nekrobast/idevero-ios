import XCTest

@MainActor
final class PhysicalV6TargetedUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    private func generatedApp() throws -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        let editor = app.textViews["ideaEditor"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap()
        editor.typeText("Quiero una app para gestionar prestamos de instrumentos")
        let keyboard = app.buttons["keyboardCreatePromptButton"]
        let create = keyboard.waitForExistence(timeout: 2) && keyboard.isHittable ? keyboard : app.buttons["createPromptButton"]
        create.tap()
        XCTAssertTrue(app.staticTexts["Prompt generado"].waitForExistence(timeout: 20))
        return app
    }

    private func revealUpdate(_ app: XCUIApplication) {
        for _ in 0..<16 where !app.buttons["Actualizar"].isHittable { app.swipeUp() }
        XCTAssertTrue(app.buttons["Actualizar"].isHittable)
    }

    private func assertPersistentCompletion(_ app: XCUIApplication) {
        let status = app.staticTexts["generationStatus"]
        XCTAssertTrue(status.waitForExistence(timeout: 15))
        for _ in 0..<16 where !app.staticTexts["Prompt generado"].isHittable { app.swipeDown() }
        XCTAssertTrue(app.staticTexts["Prompt generado"].isHittable)
        XCTAssertTrue(status.isHittable, "Feedback must remain visible at the current viewport, not only beside the offscreen action buttons.")
        XCTAssertEqual(status.label, "Prompt actualizado")
        let image = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        image.lifetime = .keepAlways
        add(image)
    }

    func testUpdateEntryPointVisiblyExplainsTheActionChoice() throws {
        let app = try generatedApp()
        revealUpdate(app)
        app.buttons["Actualizar"].tap()
        XCTAssertTrue(app.staticTexts["Elige cómo actualizar el prompt"].waitForExistence(timeout: 3), "Actualizar opens a choice, not a generation; it must make that transition visible and accessible.")
        XCTAssertTrue(app.buttons["Regenerar prompt"].exists)
        XCTAssertTrue(app.buttons["Reanalizar necesidades"].exists)
    }

    func testCreateRegenerationFeedbackRemainsVisibleAwayFromTheActionRow() throws {
        let app = try generatedApp()
        revealUpdate(app)
        app.buttons["Actualizar"].tap()
        app.buttons["Regenerar prompt"].tap()
        assertPersistentCompletion(app)
    }

    func testHistoryRegenerateAndReanalyzeBothHaveViewportFeedback() throws {
        let app = try generatedApp()
        revealUpdate(app)
        app.buttons["Guardar"].tap()
        app.tabBars.buttons["Historial"].tap()
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 5))
        app.cells.firstMatch.tap()
        revealUpdate(app)
        app.buttons["Actualizar"].tap()
        app.buttons["Regenerar prompt"].tap()
        assertPersistentCompletion(app)
        revealUpdate(app)
        app.buttons["Actualizar"].tap()
        app.buttons["Reanalizar necesidades"].tap()
        assertPersistentCompletion(app)
    }
}
