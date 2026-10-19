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
        app.buttons["Error"].tap()
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
    func testCloseDismissesAndClearsTheBinding() {
        let app = Showcase.launch("toast")
        app.buttons["Until closed"].tap()
        let paused = app.toast(beginningWith: "Sync paused")
        XCTAssertTrue(paused.waitForExistence(timeout: 5))
        app.buttons["Close"].tap()
        XCTAssertFalse(paused.waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["toast-state"].label, "Showing: nothing")
    }

    @MainActor
    func testTheActionRunsOnceAndDismisses() {
        let app = Showcase.launch("toast")
        app.buttons["Archive with undo"].tap()
        let undo = app.buttons["Undo"]
        XCTAssertTrue(undo.waitForExistence(timeout: 5))
        undo.tap()
        XCTAssertFalse(undo.waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["toast-undos"].label, "Undone: 1")
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
