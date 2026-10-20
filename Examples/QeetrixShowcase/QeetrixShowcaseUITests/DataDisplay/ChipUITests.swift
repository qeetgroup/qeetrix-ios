import XCTest

final class ChipUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testAToggleChipReportsItsState() {
        let app = Showcase.launch("chip")
        let unread = app.buttons["Unread"]
        XCTAssertTrue(unread.waitForExistence(timeout: 5))
        XCTAssertFalse(unread.isSelected)
        unread.tap()
        XCTAssertTrue(unread.isSelected)
        XCTAssertEqual(app.staticTexts["chip-unread"].label, "Unread: on")
        XCTAssertFalse(app.buttons["Shared"].isEnabled)
    }

    @MainActor
    func testGroupsChooseOneOrSeveral() {
        let app = Showcase.launch("chip")
        let open = app.buttons["Open"]
        XCTAssertTrue(open.waitForExistence(timeout: 5))
        open.tap()
        XCTAssertTrue(open.isSelected)
        XCTAssertFalse(app.buttons["All"].isSelected)
        XCTAssertEqual(app.staticTexts["chip-status"].label, "Status: Open")
        let engineering = app.buttons["Engineering"]
        engineering.scrollIntoView(in: app)
        engineering.tap()
        XCTAssertEqual(app.staticTexts["chip-labels"].label, "Labels: Design, Engineering")
        app.buttons["Design"].tap()
        XCTAssertEqual(app.staticTexts["chip-labels"].label, "Labels: Engineering")
        XCTAssertFalse(app.buttons["Legal"].isEnabled, "A disabled option can't be chosen")
    }

    @MainActor
    func testARemovableChipNamesWhatItRemoves() {
        let app = Showcase.launch("chip")
        let remove = app.buttons.matching(NSPredicate(format: "label == 'Remove' AND value == 'Research'")).firstMatch
        remove.scrollIntoView(in: app)
        XCTAssertTrue(remove.exists)
        remove.tap()
        XCTAssertEqual(app.staticTexts["chip-tags"].label, "Tags: 2")
        XCTAssertFalse(remove.exists)
    }
}
