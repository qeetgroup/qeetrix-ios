import XCTest

final class AlertDialogUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testADestructiveAlertOffersCancelAndRunsItsActionOnce() {
        let app = Showcase.launch("alert-dialog")
        let open = app.buttons["Delete workspace"]
        XCTAssertTrue(open.waitForExistence(timeout: 5))
        open.tap()
        let alert = app.alerts["Delete this workspace?"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertTrue(alert.buttons["Cancel"].exists, "Added beside a lone destructive action")
        alert.buttons["Cancel"].tap()
        XCTAssertTrue(alert.waitForNonExistence(timeout: 3))
        XCTAssertEqual(app.staticTexts["alert-result"].label, "Result: none")
        open.tap()
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons["Delete"].tap()
        XCTAssertTrue(app.staticTexts["alert-result"].waitForLabel("Result: deleted 1"))
    }

    @MainActor
    func testAnAlertWithoutActionsHasOK() {
        let app = Showcase.launch("alert-dialog")
        app.buttons["Show a notice"].tap()
        let alert = app.alerts["Storage almost full"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertEqual(alert.buttons.count, 1)
        alert.buttons.firstMatch.tap()
        XCTAssertTrue(alert.waitForNonExistence(timeout: 3))
    }

    @MainActor
    func testTheChosenActionRuns() {
        let app = Showcase.launch("alert-dialog")
        app.buttons["Leave the page"].tap()
        let alert = app.alerts["Leave without saving?"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertEqual(alert.buttons.count, 2, "A cancel action was given, so none is added")
        alert.buttons["Keep editing"].tap()
        XCTAssertTrue(app.staticTexts["alert-result"].waitForLabel("Result: kept editing"))
    }
}
