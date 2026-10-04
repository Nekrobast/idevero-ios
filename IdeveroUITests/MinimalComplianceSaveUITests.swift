import XCTest

@MainActor
final class MinimalComplianceSaveUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    private func launch(createFailures: Int = 0, historyFailures: Int = 0) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["IDEVERO_UI_TEST_CREATE_SAVE_FAILURES"] = String(createFailures)
        app.launchEnvironment["IDEVERO_UI_TEST_HISTORY_SAVE_FAILURES"] = String(historyFailures)
        app.launch()
        return app
    }
    private func generate(_ app: XCUIApplication) {
        let editor = app.textViews["ideaEditor"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap()
        editor.typeText("Quiero una app sencilla para organizar notas")
        let keyboard = app.buttons["keyboardCreatePromptButton"]
        let button = keyboard.waitForExistence(timeout: 2) && keyboard.isHittable ? keyboard : app.buttons["createPromptButton"]
        button.tap()
        XCTAssertTrue(app.descendants(matching: .any)["generatedPrompt"].waitForExistence(timeout: 30))
    }
    private func reach(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<30 where !element.isHittable { app.swipeUp() }
        XCTAssertTrue(element.exists && element.isHittable)
    }
    private func save(_ app: XCUIApplication) {
        let button = app.buttons["Guardar"].firstMatch
        reach(button, in: app)
        button.tap()
    }
    func testSettingsPrivacyAndSupportHaveIdentifiableAccessibleAccess() {
        let app = launch()
        app.tabBars.buttons["Ajustes"].tap()
        let privacy = app.descendants(matching: .any)["privacyPolicyAccess"].firstMatch
        let support = app.descendants(matching: .any)["supportAccess"].firstMatch
        XCTAssertTrue(privacy.waitForExistence(timeout: 5), "Settings must expose Privacy Policy, not just privacy claims.")
        XCTAssertTrue(privacy.label.contains("Política de privacidad"))
        reach(privacy, in: app)
        XCTAssertGreaterThanOrEqual(privacy.frame.height, 44)
        XCTAssertTrue(support.waitForExistence(timeout: 5), "Settings must expose Support.")
        XCTAssertTrue(support.label.contains("Soporte"))
        reach(support, in: app)
        XCTAssertGreaterThanOrEqual(support.frame.height, 44)
    }
    func testSaveSuccessIsConfirmedAfterPersistence() {
        let app = launch()
        generate(app)
        XCTAssertFalse(app.staticTexts["persistenceSuccess"].exists, "No success before Save.")
        save(app)
        let success = app.staticTexts["persistenceSuccess"]
        XCTAssertTrue(success.waitForExistence(timeout: 5), "Successful save must be acknowledged.")
        XCTAssertEqual(success.label, "Guardado")
        XCTAssertFalse(app.staticTexts["persistenceError"].exists)
        app.tabBars.buttons["Historial"].tap()
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "organizar notas")).firstMatch.waitForExistence(timeout: 5))
    }
    func testFailedSaveKeepsResultAndOffersRetryCopyAndShare() {
        let app = launch(createFailures: 1)
        generate(app)
        save(app)
        let error = app.staticTexts["persistenceError"]
        XCTAssertTrue(error.waitForExistence(timeout: 5), "A persistence failure must be visibly and accessibly reported.")
        XCTAssertTrue(error.label.contains("No se ha podido guardar"))
        XCTAssertTrue(error.isHittable)
        XCTAssertFalse(app.staticTexts["persistenceSuccess"].exists, "A failed save must never acknowledge success.")
        XCTAssertTrue(app.descendants(matching: .any)["generatedPrompt"].exists, "Save failure must not remove the generated result.")
        XCTAssertTrue(app.buttons["Copiar"].firstMatch.exists)
        XCTAssertTrue(app.buttons["Compartir"].firstMatch.exists)
        let retry = app.buttons["retryPersistenceSave"]
        XCTAssertTrue(retry.exists && retry.isHittable, "The retained save must be retryable without generating again.")
        retry.tap()
        XCTAssertTrue(app.staticTexts["persistenceSuccess"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["persistenceError"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["generatedPrompt"].exists)
    }
    func testHistoryUpdateSaveFailureIsNotSilenced() {
        let app = launch(historyFailures: 1)
        generate(app)
        save(app)
        app.tabBars.buttons["Historial"].tap()
        let record = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "organizar notas")).firstMatch
        XCTAssertTrue(record.waitForExistence(timeout: 5))
        record.tap()
        let update = app.buttons["Actualizar"].firstMatch
        reach(update, in: app)
        update.tap()
        app.buttons["Regenerar prompt"].tap()
        let error = app.staticTexts["persistenceError"]
        XCTAssertTrue(error.waitForExistence(timeout: 10), "History save errors must not be swallowed by try?.")
        XCTAssertTrue(error.label.contains("Tu prompt sigue disponible"))
        XCTAssertFalse(app.staticTexts["persistenceSuccess"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["generatedPrompt"].exists)
        XCTAssertTrue(app.buttons["retryPersistenceSave"].exists)
        XCTAssertTrue(app.buttons["Copiar"].firstMatch.exists)
        XCTAssertTrue(app.buttons["Compartir"].firstMatch.exists)
        app.buttons["retryPersistenceSave"].tap()
        XCTAssertTrue(app.staticTexts["persistenceSuccess"].waitForExistence(timeout: 5))
    }
}

