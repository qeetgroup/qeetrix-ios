import XCTest

final class OverlayPatternsUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testMenuConfirmationAndToastUndoHandOver() {
        let app = Showcase.launch("overlay-patterns")
        let actions = app.buttons["Actions for Design review"]
        XCTAssertTrue(actions.waitForExistence(timeout: 5))
        actions.tap()
        app.buttons["Delete"].tap()
        XCTAssertTrue(app.staticTexts["Delete Design review?"].waitForExistence(timeout: 5))
        app.buttons["Delete"].tap()
        XCTAssertTrue(app.staticTexts["document-count"].waitForLabel("2 documents"))
        let undo = app.buttons["Undo"]
        XCTAssertTrue(undo.waitForExistence(timeout: 5))
        undo.tap()
        XCTAssertTrue(app.staticTexts["document-count"].waitForLabel("3 documents"))
        XCTAssertTrue(app.staticTexts["Design review"].exists)
    }

    @MainActor
    func testSheetSaveThenToast() {
        let app = Showcase.launch("overlay-patterns")
        app.buttons["Actions for Roadmap"].tap()
        app.buttons["Rename"].tap()
        let field = app.textFields["Title"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.clearAndType("Plan")
        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts["Plan"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.toast(beginningWith: "Renamed to Plan").waitForExistence(timeout: 5))
    }
}
