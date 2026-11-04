import XCTest

final class ListItemUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testARowReadsAsOneElementAndALinkRowOpensItsDetail() {
        let app = Showcase.launch("list-item")
        XCTAssertTrue(
            app.staticTexts["Design review, Edited by Ravi Kumar, 860 KB"].waitForExistence(timeout: 5), "Title, description, then metadata"
        )
        let budget = app.buttons["Budget, Neha Singh, 640 KB, Active"]
        budget.scrollIntoView(in: app)
        budget.tap()
        XCTAssertTrue(app.staticTexts["Owner, Neha Singh"].waitForExistence(timeout: 5))
        app.navigateBack()
        XCTAssertTrue(budget.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSelectionIsTheAppsAndReportedToVoiceOver() {
        let app = Showcase.launch("list-item")
        let first = app.buttons["Q3 summary, Asha Rao"]
        let second = app.buttons["Design review, Ravi Kumar"]
        second.scrollIntoView(in: app)
        XCTAssertTrue(first.isSelected)
        XCTAssertFalse(second.isSelected)
        second.tap()
        XCTAssertTrue(second.isSelected)
        XCTAssertFalse(first.isSelected)
    }

    @MainActor
    func testSwipeToDeleteOffersUndo() {
        let app = Showcase.launch("list-item")
        let roadmap = app.buttons["Roadmap, Meera Iyer, 1.1 MB, Active"]
        XCTAssertTrue(roadmap.waitForExistence(timeout: 5))
        roadmap.swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertFalse(roadmap.waitForExistence(timeout: 2))
        let undo = app.buttons["Undo"]
        XCTAssertTrue(undo.waitForExistence(timeout: 5))
        undo.tap()
        XCTAssertTrue(roadmap.waitForExistence(timeout: 5))
    }

    @MainActor
    func testTheContextMenuAndTheRowMenuAct() {
        let app = Showcase.launch("list-item")
        let row = app.buttons["Q3 summary, Asha Rao, 2.4 MB, Active"]
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.press(forDuration: 1.2)
        app.buttons["Rename"].tap()
        let last = app.staticTexts["list-last-action"]
        last.scrollIntoView(in: app)
        XCTAssertTrue(last.waitForLabel("Last action, rename Q3 summary"))
        let menu = app.buttons["Actions for Roadmap"]
        menu.scrollIntoView(in: app)
        menu.tap()
        app.buttons["Share"].tap()
        XCTAssertTrue(last.waitForLabel("Last action, share Roadmap"))
    }

    @MainActor
    func testASwitchRowToggles() {
        let app = Showcase.launch("list-item")
        let toggle = app.switches["Email notifications"]
        toggle.scrollIntoView(in: app)
        XCTAssertEqual(toggle.value as? String, "1")
        toggle.tap()
        XCTAssertEqual(toggle.value as? String, "0")
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
        let design = app.staticTexts["Design review, Edited by Ravi Kumar, 860 KB"]
        let asha = app.staticTexts["Asha Rao, asha@example.com"]
        let owner = app.staticTexts["Owner"]
        XCTAssertTrue(design.waitForExistence(timeout: 5))
        XCTAssertTrue(asha.exists)
        XCTAssertLessThanOrEqual(design.frame.maxY, asha.frame.minY, "Rows don't overlap")
        XCTAssertGreaterThanOrEqual(owner.frame.minY, asha.frame.maxY - 1, "The badge is below the text")
        XCTAssertGreaterThanOrEqual(owner.frame.minX, asha.frame.minX - 1, "…aligned with it")
    }
}
