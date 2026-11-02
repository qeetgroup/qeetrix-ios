import XCTest

final class PopoverUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    private let roles = "Admins can invite members and manage billing. Members can view and edit projects."

    @MainActor
    func testInPortraitIPhoneTheContentComesUpAsASheet() {
        let app = Showcase.launch("popover")
        app.buttons["About roles"].tap()
        let content = app.staticTexts[roles]
        XCTAssertTrue(content.waitForExistence(timeout: 5))
        let grabber = app.buttons["Sheet Grabber"]
        XCTAssertTrue(grabber.waitForExistence(timeout: 3), "A sheet, with the system's grabber")
        // From the grabber, the full height of the half-screen sheet.
        grabber.dragToBottom(of: app)
        XCTAssertTrue(content.waitForNonExistence(timeout: 5))
    }

    @MainActor
    func testInLandscapeItIsShownAndDismissedByATapOutside() {
        // Put back as found: a simulator can start at .unknown, and forcing .portrait there can leave the
        // tests after this one a different window.
        let original = XCUIDevice.shared.orientation
        addTeardownBlock { @MainActor in XCUIDevice.shared.orientation = original }
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = Showcase.launch("popover")
        let trigger = app.buttons["About roles"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.tap()
        let content = app.staticTexts[roles]
        XCTAssertTrue(content.waitForExistence(timeout: 5))
        // Compact height keeps the popover a popover, on every iPhone: before, a compact-width one (iPhone
        // SE) covered the screen with nothing to tap or swipe.
        XCTAssertFalse(app.buttons["Sheet Grabber"].exists, "A popover, not a sheet")
        app.tapOutside()
        XCTAssertTrue(content.waitForNonExistence(timeout: 5))
    }

    @MainActor
    func testACompactPopoverStaysAPopoverOnIPhone() {
        let app = Showcase.launch("popover")
        app.buttons["Show details"].tap()
        let content = app.staticTexts["Last synced 2 minutes ago."]
        XCTAssertTrue(content.waitForExistence(timeout: 5))
        app.tapOutside()
        XCTAssertTrue(content.waitForNonExistence(timeout: 5))
    }
}
