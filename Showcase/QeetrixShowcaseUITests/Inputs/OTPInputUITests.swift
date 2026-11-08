import XCTest

/// Synthetic codes only.
final class OTPInputUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testOneFieldTakesTheWholeCodeKeepsLeadingZerosAndCompletesOnce() {
        let app = Showcase.launch("otp-input")
        let field = app.textFields["Verification code"]
        XCTAssertTrue(field.waitForExistence(timeout: 5), "VoiceOver gets one field, not six cells")
        field.tap()
        field.typeText("0123")
        XCTAssertEqual(app.staticTexts["otp-status"].label, "4 of 6 entered, completed 0 times")
        field.typeText("45")
        XCTAssertEqual(app.staticTexts["otp-status"].label, "6 of 6 entered, completed 1 times")
        XCTAssertEqual(field.value as? String, "012345", "Leading zeros are kept")
        field.typeText("9")
        XCTAssertEqual(field.value as? String, "012345", "Nothing past the length is accepted")
        XCTAssertEqual(app.staticTexts["otp-status"].label, "6 of 6 entered, completed 1 times", "Completion fires once")
    }

    @MainActor
    func testClearAndIncompleteError() {
        let app = Showcase.launch("otp-input")
        let field = app.textFields["Verification code"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("12")
        app.buttons["Check"].tap()
        XCTAssertTrue(app.staticTexts["Enter all 6 digits."].waitForExistence(timeout: 2))
        app.buttons["Clear"].tap()
        XCTAssertEqual(app.staticTexts["otp-status"].label, "0 of 6 entered, completed 0 times")
    }

    @MainActor
    func testAStandaloneCodeIsNamedOneTimeCodeAndCanBeDisabled() {
        let app = Showcase.launch("otp-input")
        let standalone = app.textFields["One-time code"]
        standalone.scrollIntoView(in: app)
        XCTAssertTrue(standalone.exists)
        XCTAssertFalse(standalone.isEnabled)
    }

    /// A number match opens focused on the number pad, two slots that take digits and no more.
    @MainActor
    func testANumberMatchOpensFocusedAndTakesTwoDigits() {
        let app = Showcase.launch("otp-number-match")
        let field = app.textFields["Number on your other device"]
        XCTAssertTrue(field.waitForExistence(timeout: 5), "Named by its accessibility label")
        XCTAssertTrue(field.waitForKeyboardFocus(), "Focused on appear, without a tap")
        field.typeText("47")
        XCTAssertEqual(field.value as? String, "47")
        field.typeText("9")
        XCTAssertEqual(field.value as? String, "47", "Two slots, two digits")
        XCTAssertEqual(app.staticTexts["number-status"].label, "Entered 47")
    }
}
