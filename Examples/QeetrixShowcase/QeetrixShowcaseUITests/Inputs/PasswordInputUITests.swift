import XCTest

/// Synthetic values only. The page shows how many characters were typed, never the text.
final class PasswordInputUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testSecureByDefaultAndRevealKeepsTheKeyboardAndTheText() {
        let app = Showcase.launch("password-input")
        let secure = app.secureTextFields["Password, Required"]
        XCTAssertTrue(secure.waitForExistence(timeout: 5), "A password field is a secure text field by default")
        secure.tap()
        secure.typeText("sample-1")
        XCTAssertEqual(app.staticTexts["password-length"].label, "8 characters")
        XCTAssertNotEqual(secure.value as? String, "sample-1", "A secure field never reports its text")

        app.buttons["Show password"].firstMatch.tap()
        let revealed = app.textFields["Password, Required"]
        XCTAssertTrue(revealed.waitForExistence(timeout: 2), "Revealed, it is a plain text field")
        XCTAssertTrue(app.keyboards.firstMatch.exists, "Revealing keeps the keyboard")
        revealed.typeText("x")
        XCTAssertEqual(app.staticTexts["password-length"].label, "9 characters", "Typing continues where it was")

        app.buttons["Hide password"].firstMatch.tap()
        XCTAssertTrue(app.secureTextFields["Password, Required"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["password-length"].label, "9 characters")
    }

    /// The whole field is the target, as for a text field: a tap on its padding, or just outside a field
    /// drawn shorter than 44 pt, focuses it — not only a tap on the line of text (Phase 6, finding A11Y-1).
    @MainActor
    func testATapOnTheFieldsPaddingFocusesIt() {
        let app = Showcase.launch("password-input")
        let secure = app.secureTextFields["Password, Required"]
        XCTAssertTrue(secure.waitForExistence(timeout: 5))
        XCTAssertFalse(secure.hasKeyboardFocus)
        secure.tapBelow(by: 8)
        XCTAssertTrue(secure.waitForKeyboardFocus(), "A tap on the field's padding focuses it")
        XCTAssertGreaterThanOrEqual(secure.frame.height, 36, "The field's element is the field, not its line of text")
    }

    @MainActor
    func testDisabledAndWithoutToggle() {
        let app = Showcase.launch("password-input")
        let managed = app.secureTextFields["Managed password"]
        managed.scrollIntoView(in: app)
        XCTAssertFalse(managed.isEnabled)
        XCTAssertTrue(app.secureTextFields["PIN"].exists)
        let toggles = app.buttons.matching(identifier: "Show password")
        XCTAssertEqual(toggles.count, 3, "Every field but the PIN has a toggle")
        XCTAssertFalse(toggles.element(boundBy: 2).isEnabled, "A disabled field's toggle is disabled with it")
    }
}
