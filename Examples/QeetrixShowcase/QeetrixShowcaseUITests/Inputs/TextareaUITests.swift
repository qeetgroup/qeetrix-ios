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

    @MainActor
    func testAnEmptyRequiredFieldShowsItsError() {
        let app = Showcase.launch("textarea")
        app.buttons["Send feedback"].tap()
        XCTAssertTrue(app.staticTexts["Tell us what to improve."].waitForExistence(timeout: 2))
    }
}
