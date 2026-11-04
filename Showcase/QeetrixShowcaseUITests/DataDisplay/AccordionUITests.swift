import XCTest

final class AccordionUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testHeadersExpandAndReportTheirState() {
        let app = Showcase.launch("accordion")
        let billing = app.buttons["Billing, Invoices and payment method"]
        XCTAssertTrue(billing.waitForExistence(timeout: 5))
        XCTAssertEqual(billing.value as? String, "Collapsed")
        billing.tap()
        XCTAssertEqual(billing.value as? String, "Expanded")
        XCTAssertTrue(app.staticTexts["Invoices are sent on the first of each month."].waitForExistence(timeout: 2))
        app.buttons["Members"].tap()
        XCTAssertEqual(billing.value as? String, "Expanded", "Several can be open at once")
        billing.tap()
        XCTAssertFalse(app.staticTexts["Invoices are sent on the first of each month."].waitForExistence(timeout: 2))
    }

    @MainActor
    func testOneAtATimeIsTheAppsBinding() {
        let app = Showcase.launch("accordion")
        let plan = app.buttons["Plan"]
        let people = app.buttons["People"]
        people.scrollIntoView(in: app)
        XCTAssertEqual(plan.value as? String, "Expanded")
        people.tap()
        XCTAssertEqual(people.value as? String, "Expanded")
        XCTAssertEqual(plan.value as? String, "Collapsed")
        XCTAssertEqual(app.staticTexts["accordion-open"].label, "Open: people")
    }

    @MainActor
    func testANestedDisclosureOpensInside() {
        let app = Showcase.launch("accordion")
        let security = app.buttons["Security"]
        security.scrollIntoView(in: app)
        security.tap()
        let advanced = app.buttons["Advanced"]
        XCTAssertTrue(advanced.waitForExistence(timeout: 2))
        advanced.tap()
        XCTAssertTrue(app.staticTexts["Session length and sign-in rules."].waitForExistence(timeout: 2))
    }
}
