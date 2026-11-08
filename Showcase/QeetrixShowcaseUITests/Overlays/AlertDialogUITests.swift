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

    /// Two fields read by their labels; Save waits for the required one; Return in the last saves,
    /// once. Return with the required field empty is the system alert's own: it closes as Cancel, saving nothing.
    @MainActor
    func testTextFieldsAreTypedIntoAndReturnSaves() {
        let app = Showcase.launch("alert-dialog")
        let open = app.buttons["Rename account"]
        open.scrollIntoView(in: app)
        open.tap()
        let alert = app.alerts["Rename account"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertEqual(alert.textFields.count, 2)
        let issuer = alert.textFields["Issuer"]
        let account = alert.textFields["Account name"]
        XCTAssertTrue(issuer.exists && account.exists, "Each field by its label")
        XCTAssertEqual(account.value as? String, "priya@acme.in")
        let save = alert.buttons["Save"]
        XCTAssertTrue(save.isEnabled)

        // Empty the required field: Save is unavailable, and Return doesn't save.
        account.coordinate(withNormalizedOffset: CGVector(dx: 0.97, dy: 0.5)).tap()
        account.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 20))
        wait(for: [expectation(for: NSPredicate(format: "isEnabled == false"), evaluatedWith: save)], timeout: 3)  // waits for a name
        account.typeText("\n")
        XCTAssertTrue(alert.waitForNonExistence(timeout: 3), "The system alert closes on Return")
        XCTAssertEqual(app.staticTexts["alert-result"].label, "Result: none", "As Cancel: nothing saved")

        // Open again: the field is still empty, Save unavailable until a name is typed; Return saves once.
        open.tap()
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertFalse(save.isEnabled)
        account.tap()
        account.typeText("priya.sharma")
        wait(for: [expectation(for: NSPredicate(format: "isEnabled == true"), evaluatedWith: save)], timeout: 3)
        account.typeText("\n")
        XCTAssertTrue(alert.waitForNonExistence(timeout: 3), "Return in the last field saves")
        XCTAssertTrue(app.staticTexts["alert-result"].waitForLabel("Result: renamed 1: Acme, priya.sharma"), "Once")
        sleep(1)
        XCTAssertEqual(app.staticTexts["alert-result"].label, "Result: renamed 1: Acme, priya.sharma", "Not twice")
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
