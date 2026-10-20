import XCTest

final class TextareaUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testReturnStartsANewLineAndThePromptIsNotTheValue() {
        let app = Showcase.launch("textarea")
        let feedback = app.textFields["Feedback, Required"]
        XCTAssertTrue(feedback.waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["feedback-count"].label, "0 characters, 1 lines", "The prompt is not part of the value")
        feedback.tap()
        feedback.typeText("First line\nSecond line")
        XCTAssertEqual(app.staticTexts["feedback-count"].label, "22 characters, 2 lines")
    }

    /// The box is the target, not the line of text: Apple's audit measures the text view, one line tall
    /// while the field is empty, but a tap anywhere in the two-control-height box focuses the field
    /// (Phase 6 accessibility report).
    @MainActor
    func testATapInTheBoxBelowTheTextFocusesIt() {
        let app = Showcase.launch("textarea")
        let feedback = app.textFields["Feedback, Required"]
        XCTAssertTrue(feedback.waitForExistence(timeout: 5))
        XCTAssertFalse(feedback.hasKeyboardFocus)
        feedback.tapBelow(by: 24)
        XCTAssertTrue(feedback.waitForKeyboardFocus(), "A tap in the box, below the line of text, focuses the field")
    }

    @MainActor
    func testAnEmptyRequiredFieldShowsItsError() {
        let app = Showcase.launch("textarea")
        app.buttons["Send feedback"].tap()
        XCTAssertTrue(app.staticTexts["Tell us what to improve."].waitForExistence(timeout: 2))
    }
}
