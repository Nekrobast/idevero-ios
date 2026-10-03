import XCTest

@MainActor
final class PhysicalV6FeedbackUITests: XCTestCase {
    func testRegenerationCompletesWithAccessibleVisibleFeedback() throws {
        let app = XCUIApplication()
        app.launch()
        let editor = app.textViews["ideaEditor"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap()
        editor.typeText("Quiero una app para gestionar reparaciones")
        let keyboardButton = app.buttons["keyboardCreatePromptButton"]
        let create = keyboardButton.waitForExistence(timeout: 2) && keyboardButton.isHittable ? keyboardButton : app.buttons["createPromptButton"]
        create.tap()
        XCTAssertTrue(app.staticTexts["Prompt generado"].waitForExistence(timeout: 20))
        let update = app.buttons["Actualizar"]
        for _ in 0..<12 where !update.isHittable { app.swipeUp() }
        XCTAssertTrue(update.isHittable)
        update.tap()
        app.buttons["Regenerar prompt"].tap()
        let status = app.staticTexts["generationStatus"]
        XCTAssertTrue(status.waitForExistence(timeout: 10), "The actual ResultView must show persistent completion feedback after recompilation.")
        XCTAssertEqual(status.label, "Prompt actualizado")
        XCTAssertTrue(update.isEnabled)
        XCTAssertTrue(status.isHittable)
    }
}

