import XCTest

final class FormPatternsUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testNextMovesFocusThroughTheFieldsTheAppOwns() {
        let app = Showcase.launch("form-patterns")
        let name = app.textFields["Full name, Required"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        name.typeText("Asha Rao\n")
        let email = app.textFields["Work email, Required"]
        XCTAssertTrue(email.hasKeyboardFocus, "Return on the name moves focus to the email: .focused reaches the field inside")
        email.typeText("asha@example.com\n")
        XCTAssertTrue(app.secureTextFields["Password, Required"].hasKeyboardFocus)
    }

    @MainActor
    func testAFailedSubmitShowsTheSummaryAndItsLinksFocusTheFields() {
        let app = Showcase.launch("form-patterns")
        let create = app.buttons["Create account"]
        create.scrollIntoView(in: app)
        create.tap()
        XCTAssertTrue(app.staticTexts["There is a problem"].waitForExistence(timeout: 2))
        let emailLink = app.buttons["Enter an email address with an @."]
        XCTAssertTrue(emailLink.exists)
        XCTAssertGreaterThanOrEqual(emailLink.frame.height, 44, "Each error is a full 44 pt row, so neighbouring targets never overlap")
        emailLink.tap()
        let focused = expectation(
            for: NSPredicate(format: "hasKeyboardFocus == true"), evaluatedWith: app.textFields["Work email, Required"])
        wait(for: [focused], timeout: 3)
    }
}
