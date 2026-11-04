import XCTest

final class TabsUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testSelectingATabShowsItsPanelAndMarksItSelected() {
        let app = Showcase.launch("tabs")
        let overview = app.buttons["Overview"]
        let activity = app.buttons["Activity"]
        XCTAssertTrue(activity.waitForExistence(timeout: 5))
        XCTAssertTrue(overview.isSelected)
        XCTAssertFalse(activity.isSelected)
        activity.tap()
        XCTAssertTrue(activity.isSelected)
        XCTAssertFalse(overview.isSelected)
        XCTAssertEqual(app.staticTexts["section-panel"].label, "Panel: activity")
    }

    @MainActor
    func testADisabledTabCannotBeChosen() {
        let app = Showcase.launch("tabs")
        let archive = app.buttons["Archive"]
        XCTAssertTrue(archive.waitForExistence(timeout: 5))
        XCTAssertFalse(archive.isEnabled)
        archive.tap()
        XCTAssertEqual(app.staticTexts["section-panel"].label, "Panel: overview")
    }

    @MainActor
    func testAStripWiderThanTheScreenScrolls() {
        let app = Showcase.launch("tabs")
        let disputes = app.buttons["Disputes"]
        XCTAssertTrue(disputes.waitForExistence(timeout: 5))
        XCTAssertFalse(disputes.isHittable, "Off screen to start with")
        // Drag the strip, just above its panel, towards the leading edge.
        let panel = app.staticTexts["report-panel"]
        for _ in 0..<3 where !disputes.isHittable {
            let start = panel.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: 300, dy: -36))
            start.press(forDuration: 0.05, thenDragTo: start.withOffset(CGVector(dx: -280, dy: 0)))
        }
        XCTAssertTrue(disputes.isHittable)
        disputes.tap()
        XCTAssertEqual(app.staticTexts["report-panel"].label, "Panel: disputes")
    }
}
