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
        let keyboardCreateButton = app.buttons["keyboardCreatePromptButton"]
        let visibleCreateButton = createButton.isHittable ? createButton : keyboardCreateButton
        XCTAssertTrue(visibleCreateButton.isHittable, "Create prompt must remain reachable while the keyboard is visible.")
        visibleCreateButton.tap()

        let resultHeader = app.staticTexts["Prompt generado"]
        XCTAssertTrue(resultHeader.waitForExistence(timeout: 20), "Generation must reveal the result header.")
        XCTAssertFalse(app.keyboards.element.exists, "The keyboard must close after generation to expose the result.")
        let providerBadge = app.descendants(matching: .any)["providerBadge"]
        let generatedPrompt = app.descendants(matching: .any)["generatedPrompt"]
        XCTAssertTrue(resultHeader.isHittable, "The result header must be on screen after automatic scrolling.")
        XCTAssertTrue(providerBadge.exists && providerBadge.isHittable, "The concrete intelligence provider badge must be visible on screen.")
        XCTAssertTrue(generatedPrompt.exists && generatedPrompt.isHittable, "The generated prompt must be visible and reachable in the root scroll view.")

        let disclosure = app.descendants(matching: .any)["discoveriesDisclosure"]
        XCTAssertTrue(disclosure.exists)
        for _ in 0..<8 where !disclosure.isHittable { app.swipeUp() }
        XCTAssertTrue(disclosure.isHittable)
        disclosure.tap()
        XCTAssertTrue(app.buttons["Excluir"].waitForExistence(timeout: 3))
        let excludeButtons = app.buttons.matching(identifier: "Excluir")
        XCTAssertGreaterThan(excludeButtons.count, 0)
        let lastAction = excludeButtons.element(boundBy: excludeButtons.count - 1)
        for _ in 0..<12 where !lastAction.isHittable { app.swipeUp() }
        XCTAssertTrue(lastAction.isHittable, "The final discovery actions must scroll fully above the bottom tab bar.")

        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "Idevero-responsive-result"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
