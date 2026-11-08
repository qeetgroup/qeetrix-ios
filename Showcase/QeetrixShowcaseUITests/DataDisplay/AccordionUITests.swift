import XCTest

final class AccordionUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testOneAtATimeIsTheAppsBinding() {
        let app = Showcase.launch("accordion")
        let tax = app.buttons["Tax settings"].firstMatch
        let numbering = app.buttons["Invoice numbering"].firstMatch
        XCTAssertTrue(tax.waitForExistence(timeout: 5))
        XCTAssertEqual(tax.value as? String, "Expanded")
        XCTAssertEqual(numbering.value as? String, "Collapsed")
        numbering.tap()
        XCTAssertEqual(numbering.value as? String, "Expanded")
        XCTAssertEqual(tax.value as? String, "Collapsed", "Opening one closes the other")
        XCTAssertEqual(app.staticTexts["accordion-open"].label, "Open: numbering")
        XCTAssertFalse(app.buttons["Payment reminders"].isEnabled)
    }

    /// The trigger reads its title, then the summary, then its state.
    @MainActor
    func testASummaryIsReadAfterTheTitleBeforeTheState() {
        let app = Showcase.launch("accordion")
        let settings = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Code settings")).firstMatch
        settings.scrollIntoView(in: app)
        XCTAssertEqual(settings.label, "Code settings, 6 digits · every 30 seconds · SHA-1")
        XCTAssertEqual(settings.value as? String, "Collapsed")
        settings.tap()
        XCTAssertEqual(settings.value as? String, "Expanded")
        XCTAssertTrue(app.staticTexts["Change these only if the service's setup page asks you to."].waitForExistence(timeout: 2))
    }

    @MainActor
    func testSeveralCanBeOpenAtOnce() {
        let app = Showcase.launch("accordion")
        let unpaid = app.buttons["What happens to unpaid invoices at the end of the financial year?"]
        XCTAssertTrue(unpaid.waitForExistence(timeout: 5))
        unpaid.scrollIntoView(in: app)
        XCTAssertEqual(unpaid.value as? String, "Collapsed")
        unpaid.tap()
        XCTAssertEqual(unpaid.value as? String, "Expanded")
        let answer = app.staticTexts["They carry over to the next year, with their original dates."]
        XCTAssertTrue(answer.waitForExistence(timeout: 2))
        let otherTax = app.buttons.matching(identifier: "Tax settings").element(boundBy: 1)
        XCTAssertEqual(otherTax.value as? String, "Expanded", "The others stay open")
        unpaid.tap()
        XCTAssertFalse(answer.waitForExistence(timeout: 2))
    }

    @MainActor
    func testASingleSectionOpensItsContent() {
        let app = Showcase.launch("accordion")
        let advanced = app.buttons["Advanced options"]
        XCTAssertTrue(advanced.waitForExistence(timeout: 5))
        advanced.scrollIntoView(in: app)
        advanced.tap()
        XCTAssertTrue(app.switches["Retry failed webhooks"].waitForExistence(timeout: 2))
    }
}
