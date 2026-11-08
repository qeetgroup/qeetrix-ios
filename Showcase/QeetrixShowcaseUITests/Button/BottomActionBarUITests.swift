import XCTest

final class BottomActionBarUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// A ghost action under the primary, across the bar and read after it; alone, a quiet Done.
    @MainActor
    func testAGhostActionSitsUnderThePrimaryOrAlone() {
        let app = Showcase.launch("bottom-action-bar")
        let ghost = app.switches["A ghost action instead"]
        XCTAssertTrue(ghost.waitForExistence(timeout: 5))
        ghost.tap()
        let pay = app.buttons["Pay ₹1,200"]
        let notNow = app.buttons["Not now"]
        XCTAssertTrue(notNow.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Later"].exists, "The ghost replaces the soft secondary")
        XCTAssertLessThan(pay.frame.maxY, notNow.frame.minY, "Under the primary")
        XCTAssertEqual(pay.frame.width, notNow.frame.width, accuracy: 1, "Both across the bar")
        // VoiceOver's order is the elements' order: the primary, then the ghost.
        let order = app.buttons.allElementsBoundByIndex.map(\.label).filter { $0 == "Pay ₹1,200" || $0 == "Not now" }
        XCTAssertEqual(order, ["Pay ₹1,200", "Not now"])
        notNow.tap()
        XCTAssertEqual(app.staticTexts["bottom-bar-last-action"].label, "Last action: Not now")

        let alone = app.switches["Only the ghost action"]
        alone.tap()
        let done = app.buttons["Done"]
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        XCTAssertFalse(pay.exists, "No primary")
        done.tap()
        XCTAssertEqual(app.staticTexts["bottom-bar-last-action"].label, "Last action: Done")
    }
}
