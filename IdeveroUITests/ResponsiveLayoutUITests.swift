import XCTest

@MainActor
final class ResponsiveLayoutUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testKeyboardDismissesAndGeneratedResultIsReachable() throws {
        let app = XCUIApplication()
        app.launch()

        let editor = app.textViews["ideaEditor"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5), "The adaptive idea editor must be visible at launch.")
        editor.tap()
        editor.typeText("app para apicultores")
        XCTAssertTrue(app.keyboards.element.waitForExistence(timeout: 3), "The software keyboard must be present during the layout check.")

        let createButton = app.buttons["createPromptButton"]
        if !createButton.isHittable { app.swipeUp() }
        XCTAssertTrue(createButton.isHittable, "Create prompt must remain reachable while the keyboard is visible.")
        createButton.tap()

        XCTAssertTrue(app.staticTexts["Prompt generado"].waitForExistence(timeout: 20), "Generation must reveal the result header.")
        XCTAssertFalse(app.keyboards.element.exists, "The keyboard must close after generation to expose the result.")
        XCTAssertTrue(app.descendants(matching: .any)["providerBadge"].exists, "The concrete intelligence provider badge must be visible.")
        XCTAssertTrue(app.descendants(matching: .any)["generatedPrompt"].exists, "The generated prompt must remain reachable in the root scroll view.")

        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "Idevero-responsive-result"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
