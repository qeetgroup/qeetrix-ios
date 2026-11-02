import XCTest

final class FieldsetUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testTheLegendIsAHeadingAndDisablingTheFieldsetDisablesItsFields() {
        let app = Showcase.launch("fieldset")
        let street = app.textFields["Street"]
        XCTAssertTrue(street.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Billing address"].exists)
        XCTAssertTrue(street.isEnabled)
        app.switches["Lock the address"].tap()
        XCTAssertFalse(street.isEnabled, "Every field in a disabled fieldset is disabled")
        XCTAssertFalse(app.textFields["City"].isEnabled)
    }

    @MainActor
    func testCompactDensityDrawsShorterFields() {
        let app = Showcase.launch("fieldset")
        let street = app.textFields["Street"]
        let city = app.textFields["City"]
        let name = app.textFields["Name"]
        let phone = app.textFields.matching(NSPredicate(format: "label BEGINSWITH 'Phone'")).firstMatch
        name.scrollIntoView(in: app)
        XCTAssertTrue(street.exists && city.exists && name.exists && phone.exists)
        // The boxes are size.control.lg tall, 40 pt by default and 32 pt compact, and the form gap shrinks
        // too. Measured centre to centre: a frame is the 44 pt hit area on iOS 27, the same at both densities.
        XCTAssertLessThan(phone.frame.midY - name.frame.midY, city.frame.midY - street.frame.midY, "Compact fields sit closer")
        XCTAssertTrue(app.textFields["PIN code"].exists)
    }
}
