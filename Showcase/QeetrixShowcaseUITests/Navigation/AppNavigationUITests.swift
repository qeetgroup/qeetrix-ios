import XCTest

final class AppNavigationUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testADetailPageHasItsToolbarActionAndGoesBack() {
        let app = Showcase.launch("app-navigation")
        let open = app.buttons["Open a detail page"]
        XCTAssertTrue(open.waitForExistence(timeout: 5))
        open.tap()
        let add = app.buttons["Add item"]
        XCTAssertTrue(add.waitForExistence(timeout: 5), "The toolbar button is named by its label, not its icon")
        add.tap()
        XCTAssertEqual(app.staticTexts["detail-items"].label, "Items: 1")
        app.navigateBack()
        XCTAssertTrue(open.waitForExistence(timeout: 5))
    }

    @MainActor
    func testTheTabBarSwitchesTabsAndTheAppKeepsTheSelection() {
        let app = Showcase.launch("app-navigation")
        app.buttons["Open the tab bar"].tap()
        let inbox = app.buttons["Inbox"]
        XCTAssertTrue(inbox.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Home"].isSelected)
        inbox.tap()
        XCTAssertTrue(inbox.isSelected)
        XCTAssertEqual(app.staticTexts["tab-content"].label, "Inbox content")
        app.buttons["Close"].tap()
        XCTAssertEqual(app.staticTexts["selected-tab"].label, "Selected tab: inbox")
        app.buttons["Open the tab bar"].tap()
        XCTAssertTrue(app.buttons["Inbox"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Inbox"].isSelected, "The selection lives in the app's state")
    }
}
