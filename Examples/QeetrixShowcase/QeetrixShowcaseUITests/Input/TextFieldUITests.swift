import XCTest

final class TextFieldUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testTypingAndValidationMessages() {
        let app = Showcase.launch("text-field")
        let email = app.textFields["Work email, Required"]
        XCTAssertTrue(email.waitForExistence(timeout: 5), "A required field says so in its label")
        email.tap()
        email.typeText("asha")
        XCTAssertEqual(email.value as? String, "asha")
        app.buttons["Check"].tap()
        XCTAssertTrue(app.staticTexts["Enter a full email address."].waitForExistence(timeout: 2), "The error is readable text")
        email.tap()
        email.typeText("@qeet.in")
        XCTAssertTrue(app.staticTexts["Looks good."].waitForExistence(timeout: 2))
    }

    @MainActor
    func testTheDescriptionIsReadableText() {
        let app = Showcase.launch("text-field")
        XCTAssertTrue(app.staticTexts["We send sign-in links here."].waitForExistence(timeout: 5))
    }

    @MainActor
    func testATapJustOutsideAShortFieldFocusesIt() {
        let app = Showcase.launch("text-field")
        let email = app.textFields["Work email, Required"]
        XCTAssertTrue(email.waitForExistence(timeout: 5))
        XCTAssertLessThan(email.frame.height, 44)
        email.tapBelow(by: 3)
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 3), "The 44 pt target focuses the field")
    }

    @MainActor
    func testReadOnlyAndDisabledFields() {
        let app = Showcase.launch("text-field")
        let tenant = app.descendants(matching: .any)["Tenant ID"]
        XCTAssertTrue(tenant.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertEqual(tenant.value as? String, "qeet-7f3a")
        let organisation = app.textFields["Organisation"]
        XCTAssertFalse(organisation.isEnabled)
    }
}
