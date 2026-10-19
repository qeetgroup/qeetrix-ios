import XCTest

final class ConfirmationDialogUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testAnActionIsChosenFromTheDialog() {
        let app = Showcase.launch("confirmation-dialog")
        let open = app.buttons["Share report"]
        XCTAssertTrue(open.waitForExistence(timeout: 5))
        open.tap()
        let copy = app.buttons["Copy link"]
        XCTAssertTrue(copy.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Share the Q3 summary"].exists, "The title is shown")
        copy.tap()
        XCTAssertFalse(copy.waitForExistence(timeout: 1))
        XCTAssertTrue(app.staticTexts["confirmation-result"].waitForLabel("Result: copied link"))
    }

    @MainActor
    func testADestructiveChoiceCanBeCancelled() {
        let app = Showcase.launch("confirmation-dialog")
        app.buttons["Remove member"].tap()
        let remove = app.buttons["Remove"]
        XCTAssertTrue(remove.waitForExistence(timeout: 5))
        // Anchored to its button, the dialog shows no Cancel button: a tap outside is the cancel.
        let cancel = app.buttons["Cancel"]
        if cancel.exists { cancel.tap() } else { app.tapOutside() }
        XCTAssertFalse(remove.waitForExistence(timeout: 1))
        XCTAssertEqual(app.staticTexts["confirmation-result"].label, "Result: none")
        app.buttons["Remove member"].tap()
        XCTAssertTrue(remove.waitForExistence(timeout: 5))
        remove.tap()
        XCTAssertTrue(app.staticTexts["confirmation-result"].waitForLabel("Result: removed"))
    }
}
