import XCTest

final class NumberFieldUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testSteppersChangeTheValueAndStopAtTheRange() {
        let app = Showcase.launch("number-field")
        let increase = app.buttons["Increase"].firstMatch
        XCTAssertTrue(increase.waitForExistence(timeout: 5))
        increase.tap()
        XCTAssertEqual(app.staticTexts["seats-value"].label, "Seats: 6")
        app.buttons["Decrease"].firstMatch.tap()
        app.buttons["Decrease"].firstMatch.tap()
        XCTAssertEqual(app.staticTexts["seats-value"].label, "Seats: 4")
    }

    @MainActor
    func testCommittingClampsToTheRangeAndInvalidTextReverts() {
        let app = Showcase.launch("number-field")
        let seats = app.textFields["Seats"]
        XCTAssertTrue(seats.waitForExistence(timeout: 5))
        seats.tap()
        seats.clearAndType("900")
        // Whether "9" and "90" were taken on the way depends on how the keystrokes reached the field; "900",
        // outside the range, never is.
        XCTAssertNotEqual(app.staticTexts["seats-value"].label, "Seats: 900", "An out-of-range number is not taken while typing")
        app.textFields["Adjustment"].tap()  // leaving the field commits it
        XCTAssertEqual(app.staticTexts["seats-value"].label, "Seats: 250", "Committed, it is brought to the end of the range")
        XCTAssertEqual(seats.value as? String, "250")
    }

    @MainActor
    func testInBetweenStatesAreKeptWhileTyping() {
        let app = Showcase.launch("number-field")
        let adjustment = app.textFields["Adjustment"]
        adjustment.scrollIntoView(in: app)
        adjustment.tap()
        adjustment.typeText("-")
        XCTAssertEqual(adjustment.value as? String, "-", "A lone minus sign is kept")
        adjustment.typeText("12.")
        XCTAssertEqual(adjustment.value as? String, "-12.", "So is a trailing decimal separator")
        XCTAssertEqual(app.staticTexts["adjustment-value"].label, "Adjustment: -12")
        adjustment.typeText("5")
        XCTAssertEqual(app.staticTexts["adjustment-value"].label, "Adjustment: -12.5")
    }
}

extension XCUIElement {
    /// Replaces the field's text: puts the caret after it, deletes it, types. The tap at the trailing end
    /// matters for centred text — a tap in the middle can land the caret before the text, where deleting
    /// removes nothing.
    func clearAndType(_ text: String) {
        coordinate(withNormalizedOffset: CGVector(dx: 0.97, dy: 0.5)).tap()
        let current = value as? String ?? ""
        typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count) + text)
    }
}
