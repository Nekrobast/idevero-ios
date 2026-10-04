import XCTest

@MainActor
final class PresentationRemediationUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    private func captureDiagnostics(_ app: XCUIApplication, name: String) {
        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screenshot.name = name
        screenshot.lifetime = .keepAlways
        add(screenshot)
        let hierarchy = XCTAttachment(string: app.debugDescription)
        hierarchy.name = name + " accessibility hierarchy"
        hierarchy.lifetime = .keepAlways
        add(hierarchy)
    }
    private func open(_ request: String, heading: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        let editor = app.textViews["ideaEditor"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap(); editor.typeText(request)
        let keyboard = app.buttons["keyboardCreatePromptButton"]
        let create = keyboard.waitForExistence(timeout: 2) && keyboard.isHittable ? keyboard : app.buttons["createPromptButton"]
        create.tap()
        XCTAssertTrue(app.staticTexts[heading].waitForExistence(timeout: 20))
        let section = app.buttons["discoveriesDisclosure"]
        for _ in 0..<25 where !section.isHittable { app.swipeUp() }
        XCTAssertTrue(section.isHittable); section.tap()
        return app
    }
    func testPhysicalFixtureStartsGroupedAndAllRecommendationsRemainAccessible() {
        let app = open("Quiero crear una app para gestionar las tareas de mantenimiento de una comunidad de vecinos", heading: "Prompt generado")
        XCTAssertTrue(app.staticTexts["Lo más importante"].exists)
        let more = app.buttons["moreRecommendations"]
        for _ in 0..<30 where !more.isHittable { app.swipeUp() }
        if !more.isHittable { captureDiagnostics(app, name: "Unreachable more recommendations") }
        XCTAssertTrue(more.isHittable)
        XCTAssertGreaterThanOrEqual(more.frame.height, 44)
        XCTAssertTrue(more.label.contains("Ver más recomendaciones"))
        more.tap()
        XCTAssertTrue(app.staticTexts["Más recomendaciones"].waitForExistence(timeout: 3))
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.lifetime = .keepAlways; add(shot)
    }
    func testSelectedActionsAndCompactWhyExposeStateWithoutAmbiguity() {
        let app = open("Quiero una app para gestionar reservas de telescopios", heading: "Prompt generado")
        let included = app.buttons["discoveryAction-INCLUDED"].firstMatch
        for _ in 0..<15 where !included.isHittable { app.swipeUp() }
        XCTAssertTrue(included.isHittable)
        XCTAssertEqual(included.label, "Añadido")
        let keep = app.buttons["discoveryAction-LOCKED"].firstMatch
        for _ in 0..<8 where !keep.isHittable { app.swipeUp() }
        keep.tap()
        XCTAssertEqual(keep.label, "Mantener siempre")
        XCTAssertTrue(keep.isSelected)
        let remove = app.buttons["Excluir"].firstMatch
        for _ in 0..<8 where !remove.isHittable { app.swipeUp() }
        remove.tap()
        XCTAssertEqual(remove.label, "Quitado")
        XCTAssertTrue(remove.isSelected)
        let why = app.buttons["¿Por qué me recomienda esto?"].firstMatch
        for _ in 0..<8 where !why.isHittable { app.swipeUp() }
        XCTAssertEqual(why.label, "Por qué")
        XCTAssertGreaterThanOrEqual(why.frame.height, 44)
        why.tap()
        let source = app.staticTexts["De dónde sale esta recomendación"].firstMatch
        let sourceAppeared = source.waitForExistence(timeout: 3)
        if !sourceAppeared {
            captureDiagnostics(app, name: "Missing recommendation source after Why")
        }
        XCTAssertTrue(sourceAppeared)
    }
    func testEnglishGroupingAndSelectedActionCopy() {
        let app = open("I want an app to manage telescope bookings", heading: "Generated prompt")
        XCTAssertTrue(app.staticTexts["Most important"].exists)
        let included = app.buttons["discoveryAction-INCLUDED"].firstMatch
        for _ in 0..<15 where !included.isHittable { app.swipeUp() }
        XCTAssertEqual(included.label, "Added")
        XCTAssertTrue(included.isSelected)
        XCTAssertFalse(app.staticTexts["Lo más importante"].exists)
    }
}
