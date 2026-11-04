import XCTest

/// The system draws the swipe actions, the confirmation dialog, the context menu and the refresh
/// control, so they are checked here rather than in snapshots (ADR 0014).
final class SwipeActionsAndRefreshUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testSwipingTowardsTheEndRevealsApprove() {
        let app = Showcase.launch("swipe-actions-and-refresh")
        let row = app.row("Qeet Pay console")
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.swipeRight()
        let approve = app.buttons["Approve"]
        XCTAssertTrue(approve.waitForExistence(timeout: 5))
        approve.tap()
        XCTAssertTrue(app.lastAction.waitForLabel("Last action, Approved: Qeet Pay console"))
        XCTAssertTrue(row.waitForNonExistence(timeout: 3), "The app removed the decided request")
    }

    @MainActor
    func testAFullSwipeAsksBeforeDenying() {
        let app = Showcase.launch("swipe-actions-and-refresh")
        let row = app.row("Qeet Pay console")
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.fullSwipeTowardsTheStart(in: app)
        let question = app.staticTexts["Deny the sign-in to Qeet Pay console?"]
        XCTAssertTrue(question.waitForExistence(timeout: 5), "Deny asks first")
        XCTAssertTrue(row.exists, "Nothing is removed before the answer")
        // Anchored to the row, the dialog may show no Cancel button: a tap outside is the cancel.
        let cancel = app.buttons["Cancel"]
        if cancel.exists { cancel.tap() } else { app.tapOutside() }
        XCTAssertTrue(question.waitForNonExistence(timeout: 3))
        XCTAssertEqual(app.lastAction.label, "Last action, None yet")

        row.fullSwipeTowardsTheStart(in: app)
        XCTAssertTrue(question.waitForExistence(timeout: 5))
        app.buttons["Deny"].firstMatch.tap()
        XCTAssertTrue(app.lastAction.waitForLabel("Last action, Denied: Qeet Pay console"), "It ran once the dialog had gone")
    }

    @MainActor
    func testTheContextMenuOffersTheSameActions() {
        let app = Showcase.launch("swipe-actions-and-refresh")
        let row = app.row("Qeet People")
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.press(forDuration: 1.2)
        for title in ["Approve", "Later", "Deny"] {
            XCTAssertTrue(app.buttons[title].waitForExistence(timeout: 5), "\(title) is in the menu")
        }
        app.buttons["Later"].tap()
        XCTAssertTrue(app.lastAction.waitForLabel("Last action, Later: Qeet People"))
    }

    @MainActor
    func testRemovingAnAccountAsksFirst() {
        let app = Showcase.launch("swipe-actions-and-refresh")
        let row = app.row("Acme")
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.scrollIntoView(in: app)
        row.swipeLeft()
        let remove = app.buttons["Remove"]
        XCTAssertTrue(remove.waitForExistence(timeout: 5))
        remove.tap()
        XCTAssertTrue(app.staticTexts["Remove Acme from this phone?"].waitForExistence(timeout: 5))
        app.buttons["Remove"].firstMatch.tap()
        XCTAssertTrue(app.lastAction.waitForLabel("Last action, Removed: Acme"))
    }

    @MainActor
    func testPullingDownRefreshesTheList() {
        let app = Showcase.launch("swipe-actions-and-refresh")
        let row = app.row("Qeet Logs")
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.swipeRight()
        app.buttons["Approve"].tap()
        XCTAssertTrue(row.waitForNonExistence(timeout: 3))
        app.pullToRefresh()
        XCTAssertTrue(app.lastAction.waitForLabel("Last action, Refreshed", timeout: 10))
        XCTAssertTrue(row.waitForExistence(timeout: 3), "The refresh brought the request back")
    }

    @MainActor
    func testAFailedRefreshIsShownInAToast() {
        let app = Showcase.launch("swipe-actions-and-refresh")
        let fail = app.switches["Fail the next refresh"]
        XCTAssertTrue(fail.waitForExistence(timeout: 5))
        fail.scrollIntoView(in: app)
        fail.tap()
        app.pullToRefresh()
        XCTAssertTrue(app.toast(beginningWith: "Couldn't refresh your approvals").waitForExistence(timeout: 10))
        XCTAssertTrue(app.lastAction.waitForLabel("Last action, Refresh failed"))
    }
}

extension XCUIApplication {
    /// A list row, by its title: VoiceOver reads it as one element whose label starts with the title.
    fileprivate func row(_ title: String) -> XCUIElement {
        descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH %@", "\(title),")).firstMatch
    }

    /// The page's last-action row.
    fileprivate var lastAction: XCUIElement {
        descendants(matching: .any)["swipe-result"].firstMatch
    }

    /// Pulls the list down from near the top of the screen, past the point where the refresh starts.
    fileprivate func pullToRefresh() {
        coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.25))
            .press(forDuration: 0.05, thenDragTo: coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.85)))
    }
}

extension XCUIElement {
    /// Drags the row from near its end to past the start of the screen: a full swipe, which runs the
    /// end's first action.
    fileprivate func fullSwipeTowardsTheStart(in app: XCUIApplication) {
        let start = coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0)).withOffset(CGVector(dx: 0, dy: frame.midY))
        start.press(forDuration: 0.05, thenDragTo: end)
    }
}
