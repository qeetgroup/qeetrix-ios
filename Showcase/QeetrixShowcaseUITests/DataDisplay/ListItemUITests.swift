import XCTest

final class ListItemUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testARowReadsAsOneElementAndALinkRowOpensItsDetail() {
        let app = Showcase.launch("list-item")
        let priya = app.buttons["Priya Sharma, priya@acme.in"].firstMatch
        XCTAssertTrue(priya.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Storage, Used this month, 2.4 GB, Pro"].exists, "Title, description, value, then the trailing view")
        priya.tap()
        XCTAssertTrue(app.navigationBars["Account"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label == 'Email, priya@acme.in'")).firstMatch.exists)
        app.navigateBack()
        XCTAssertTrue(priya.waitForExistence(timeout: 5))
    }

    @MainActor
    func testActionRowsAreTheApps() {
        let app = Showcase.launch("list-item")
        let language = app.buttons["Language, English"].firstMatch
        XCTAssertTrue(language.waitForExistence(timeout: 5))
        language.tap()
        app.buttons["Sign out"].firstMatch.tap()
        XCTAssertEqual(app.staticTexts["list-item-taps"].label, "Language opened 1 times, signed out 1 times")
    }

    @MainActor
    func testASwitchRowToggles() {
        let app = Showcase.launch("list-item")
        let notifications = app.switches["Notifications"].firstMatch
        XCTAssertTrue(notifications.waitForExistence(timeout: 5))
        XCTAssertEqual(notifications.value as? String, "0")
        notifications.tap()
        XCTAssertEqual(notifications.value as? String, "1")
        let managed = app.switches["Managed by Acme, Your organisation sets this"]
        managed.scrollIntoView(in: app)
        XCTAssertFalse(managed.isEnabled)
    }

    @MainActor
    func testSelectionIsTheAppsAndReportedToVoiceOver() {
        let app = Showcase.launch("list-item")
        let ada = app.buttons["Ada Lovelace"]
        let grace = app.buttons["Grace Hopper"]
        grace.scrollIntoView(in: app)
        XCTAssertTrue(ada.isSelected)
        XCTAssertFalse(grace.isSelected)
        grace.tap()
        XCTAssertTrue(grace.isSelected)
        XCTAssertTrue(ada.isSelected, "Several can be selected")
        ada.tap()
        XCTAssertFalse(ada.isSelected)
    }
}

final class ListItemAccessibilitySizeUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// At an accessibility text size the trailing view moves below the text, and rows grow instead of
    /// overlapping — checked in the app, where the snapshot host can't show it.
    @MainActor
    func testRowsReflowAtAnAccessibilitySize() {
        let app = XCUIApplication()
        app.launchArguments += [
            "-page", "list-item", "-theme", "light", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityL",
        ]
        app.launch()
        let storage = app.staticTexts["Storage, Used this month, 2.4 GB, Pro"]
        let backup = app.staticTexts["Last backup, 10:42"]
        storage.scrollIntoView(in: app)
        XCTAssertTrue(storage.exists)
        XCTAssertLessThanOrEqual(storage.frame.maxY, backup.frame.minY, "Rows don't overlap")
        let description = app.staticTexts["Used this month"]
        let badge = app.staticTexts["Pro"]
        XCTAssertGreaterThanOrEqual(badge.frame.minY, description.frame.maxY - 1, "The badge is below the text")
        XCTAssertGreaterThanOrEqual(badge.frame.minX, description.frame.minX - 1, "…aligned with it")
    }
}
