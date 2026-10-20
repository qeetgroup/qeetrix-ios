import XCTest

final class PopoverUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// Back to portrait for the next test. XCTest calls teardown off the main actor, and the device is the
    /// main actor's, so the reset hops to it (a Swift 6 data-race warning otherwise).
    override func tearDown() async throws {
        await MainActor.run { XCUIDevice.shared.orientation = .portrait }
        try await super.tearDown()
    }

    private let roles = "Admins can invite members and manage billing. Members can view and edit projects."

    @MainActor
    func testInPortraitIPhoneTheContentComesUpAsASheet() {
        let app = Showcase.launch("popover")
        app.buttons["About roles"].tap()
        let content = app.staticTexts[roles]
        XCTAssertTrue(content.waitForExistence(timeout: 5))
        content.dragToBottom(of: app)
        XCTAssertFalse(content.waitForExistence(timeout: 3))
    }

    @MainActor
    func testInLandscapeItIsShownAndDismissedByATapOutside() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let app = Showcase.launch("popover")
        let trigger = app.buttons["About roles"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.tap()
        let content = app.staticTexts[roles]
        XCTAssertTrue(content.waitForExistence(timeout: 5))
        app.tapOutside()
        XCTAssertFalse(content.waitForExistence(timeout: 3))
    }

    @MainActor
    func testACompactPopoverStaysAPopoverOnIPhone() {
        let app = Showcase.launch("popover")
        app.buttons["Show details"].tap()
        let content = app.staticTexts["Last synced 2 minutes ago."]
        XCTAssertTrue(content.waitForExistence(timeout: 5))
        app.tapOutside()
        XCTAssertFalse(content.waitForExistence(timeout: 3))
    }
}
