import XCTest

final class ChipUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// A selectable chip draws as a button but reads as the system toggle it stands for.
    @MainActor
    func testASelectableChipIsASwitch() {
        let app = Showcase.launch("chip")
        let unread = app.switches["Unread"]
        XCTAssertTrue(unread.waitForExistence(timeout: 5))
        XCTAssertEqual(unread.value as? String, "0")
        unread.tap()
        XCTAssertEqual(unread.value as? String, "1")
        XCTAssertEqual(app.staticTexts["chip-state"].label, "Unread on, mentions on")
        XCTAssertFalse(app.switches["Archived"].isEnabled)
    }

    @MainActor
    func testGroupsChooseOneOrSeveral() {
        let app = Showcase.launch("chip")
        let open = app.buttons["Open"]
        XCTAssertTrue(open.waitForExistence(timeout: 5))
        open.tap()
        XCTAssertTrue(open.isSelected)
        XCTAssertFalse(app.buttons["All"].isSelected)
        XCTAssertEqual(app.staticTexts["chip-status"].label, "Status: open")
        XCTAssertFalse(app.buttons["Closed"].isEnabled, "A disabled option can't be chosen")
        let design = app.switches["Design"].firstMatch
        design.scrollIntoView(in: app)
        XCTAssertEqual(design.value as? String, "0")
        design.tap()
        XCTAssertEqual(design.value as? String, "1")
        XCTAssertEqual(app.switches["Engineering"].firstMatch.value as? String, "1", "Several can be on")
    }

    @MainActor
    func testARemovableChipNamesWhatItRemoves() {
        let app = Showcase.launch("chip")
        let remove = app.buttons["Remove Team: Finance"]
        remove.scrollIntoView(in: app)
        XCTAssertTrue(remove.exists)
        remove.tap()
        XCTAssertTrue(remove.waitForNonExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Remove Status: Active"].exists, "Only that chip is removed")
        XCTAssertFalse(app.buttons["Remove Region: South"].isEnabled)
    }
}
