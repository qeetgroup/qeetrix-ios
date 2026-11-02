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

        let toggle = app.buttons.matching(identifier: "Show password").firstMatch
        XCTAssertFalse(toggle.isSelected)
        toggle.tap()
        let revealed = app.textFields["Password, Required"]
        XCTAssertTrue(revealed.waitForExistence(timeout: 2), "Revealed, it is a plain text field")
        XCTAssertTrue(app.keyboards.firstMatch.exists, "Revealing keeps the keyboard")
        XCTAssertTrue(toggle.isSelected, "The toggle keeps its name and is selected while the password shows")
        revealed.typeText("x")
        XCTAssertEqual(app.staticTexts["password-length"].label, "9 characters", "Typing continues where it was")

        toggle.tap()
        XCTAssertTrue(app.secureTextFields["Password, Required"].waitForExistence(timeout: 2))
        XCTAssertFalse(toggle.isSelected)
        XCTAssertEqual(app.staticTexts["password-length"].label, "9 characters")
    }

    @MainActor
    func testAppOwnedVisibilityAndDisabled() {
        let app = Showcase.launch("password-input")
        let managed = app.secureTextFields["Managed password"]
        managed.scrollIntoView(in: app)
        XCTAssertFalse(managed.isEnabled)
        let toggles = app.buttons.matching(identifier: "Show password")
        XCTAssertEqual(toggles.count, 4, "Every password field has the toggle")
        XCTAssertFalse(toggles.element(boundBy: 3).isEnabled, "A disabled field's toggle is disabled with it")
        XCTAssertEqual(app.staticTexts["secret-visibility"].label, "Hidden")
        toggles.element(boundBy: 2).tap()
        XCTAssertTrue(app.staticTexts["secret-visibility"].waitForLabel("Shown"), "The app owns the visibility through its binding")
        XCTAssertTrue(app.textFields["API secret"].exists)
    }
}
