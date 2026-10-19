import XCTest

final class MenuUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testTheMenuOffersItsItemsAndRunsTheChosenOne() {
        let app = Showcase.launch("menu")
        let trigger = app.buttons["More actions"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.tap()
        let delete = app.buttons["Delete"]
        XCTAssertTrue(delete.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Rename"].isEnabled)
        XCTAssertFalse(app.buttons["Duplicate"].isEnabled, "A disabled item is shown dimmed and cannot be chosen")
        XCTAssertTrue(app.buttons["Share"].exists)
        delete.tap()
        XCTAssertFalse(delete.waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["menu-result"].waitForLabel("Last action: delete"))
    }

    @MainActor
    func testANativePickerInsideTheMenuChooses() {
        let app = Showcase.launch("menu")
        app.buttons["Sort: Newest"].tap()
        let oldest = app.buttons["Oldest"]
        XCTAssertTrue(oldest.waitForExistence(timeout: 5))
        oldest.tap()
        XCTAssertTrue(app.buttons["Sort: Oldest"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testTheSameItemsWorkInAContextMenu() {
        let app = Showcase.launch("menu")
        let card = app.staticTexts["Q3 summary"]
        card.scrollIntoView(in: app)
        card.press(forDuration: 1.2)
        let share = app.buttons["Share"]
        XCTAssertTrue(share.waitForExistence(timeout: 5))
        share.tap()
        XCTAssertTrue(app.staticTexts["menu-result"].waitForLabel("Last action: share"))
    }
}
