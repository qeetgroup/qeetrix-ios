import XCTest

final class ToastUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testANewToastReplacesTheOneShown() {
        let app = Showcase.launch("toast")
        app.buttons["Success"].tap()
        let saved = app.toast(beginningWith: "Settings saved")
        XCTAssertTrue(saved.waitForExistence(timeout: 5))
        app.buttons["Danger"].tap()
        XCTAssertTrue(app.toast(beginningWith: "Report not sent").waitForExistence(timeout: 5))
        XCTAssertFalse(saved.waitForExistence(timeout: 1), "One at a time: nothing queues")
    }

    @MainActor
    func testARepeatIsNotShownTwice() {
        let app = Showcase.launch("toast")
        app.buttons["Info"].tap()
        app.buttons["Info"].tap()
        XCTAssertTrue(app.toast(beginningWith: "Message archived").waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Message archived")).count, 1)
    }

    @MainActor
    func testDismissClosesAndClearsTheBinding() {
        let app = Showcase.launch("toast")
        app.buttons["Until dismissed"].tap()
        let paused = app.toast(beginningWith: "Sync paused")
        XCTAssertTrue(paused.waitForExistence(timeout: 5))
        let dismiss = app.buttons["Dismiss"]
        XCTAssertTrue(dismiss.exists, "The close button is named Dismiss, as on the web")
        dismiss.tap()
        XCTAssertTrue(paused.waitForNonExistence(timeout: 3))
        XCTAssertEqual(app.staticTexts["toast-state"].label, "Showing: nothing")
    }

    @MainActor
    func testTheActionRunsOnceAndDismisses() {
        let app = Showcase.launch("toast")
        app.buttons["Archive with undo"].tap()
        let undo = app.buttons["Undo"]
        XCTAssertTrue(undo.waitForExistence(timeout: 5))
        undo.tap()
        XCTAssertTrue(undo.waitForNonExistence(timeout: 3))
        XCTAssertEqual(app.staticTexts["toast-undos"].label, "Undone: 1")
    }

    @MainActor
    func testADangerToastStaysUntilDismissed() {
        let app = Showcase.launch("toast")
        app.buttons["Danger"].tap()
        let failed = app.toast(beginningWith: "Report not sent")
        XCTAssertTrue(failed.waitForExistence(timeout: 5))
        // Longer than the 5 s every other toast gets.
        let gone = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: failed)
        gone.isInverted = true
        wait(for: [gone], timeout: 7)
        app.buttons["Dismiss"].tap()
        XCTAssertTrue(failed.waitForNonExistence(timeout: 3))
    }

    @MainActor
    func testAToastLeavesByItself() {
        let app = Showcase.launch("toast")
        app.buttons["Brief, 2 s"].tap()
        let copied = app.toast(beginningWith: "Link copied")
        XCTAssertTrue(copied.waitForExistence(timeout: 5))
        let gone = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: copied)
        wait(for: [gone], timeout: 6)
        XCTAssertEqual(app.staticTexts["toast-state"].label, "Showing: nothing")
    }
}

extension XCUIApplication {
    /// A toast's message, which VoiceOver reads as one element: the title, then any description.
    func toast(beginningWith title: String) -> XCUIElement {
        staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@ AND NOT (identifier BEGINSWITH 'toast-')", title)).firstMatch
    }
}
