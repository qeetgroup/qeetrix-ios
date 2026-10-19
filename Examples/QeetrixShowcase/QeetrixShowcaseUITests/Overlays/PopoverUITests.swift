import XCTest

final class PopoverUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    override func tearDown() {
        XCUIDevice.shared.orientation = .portrait
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
