import XCTest

final class CollectionPatternsUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testSearchAndArchivedFilterNarrowTheList() {
        let app = Showcase.launch("collection-patterns")
        XCTAssertTrue(app.staticTexts["Documents: 5"].waitForExistence(timeout: 5), "Archived documents are hidden at first")
        app.buttons["Show archived"].tap()
        XCTAssertTrue(app.staticTexts["Documents: 6"].waitForExistence(timeout: 5))
        let field = app.searchFields["Search documents"]
        field.tap()
        field.typeText("road")
        XCTAssertTrue(app.staticTexts["Documents: 1"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testDeletingConfirmsThenOffersUndo() {
        let app = Showcase.launch("collection-patterns")
        let row = app.buttons["Roadmap, Meera Iyer, Active"]
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertTrue(app.staticTexts["Delete Roadmap?"].waitForExistence(timeout: 5))
        app.buttons["Delete"].tap()
        XCTAssertTrue(app.staticTexts["Documents: 4"].waitForExistence(timeout: 5))
        app.buttons["Undo"].tap()
        XCTAssertTrue(app.staticTexts["Documents: 5"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testTheLoadStatesAreTheApps() {
        let app = Showcase.launch("collection-patterns")
        XCTAssertTrue(app.staticTexts["Documents: 5"].waitForExistence(timeout: 5))
        choose("Failed", in: app)
        XCTAssertTrue(app.staticTexts["Couldn't load documents. Check your connection."].waitForExistence(timeout: 5))
        app.buttons["Try again"].tap()
        XCTAssertTrue(app.staticTexts["Documents: 5"].waitForExistence(timeout: 5))
        choose("Empty", in: app)
        let create = app.buttons["Create a document"]
        XCTAssertTrue(create.waitForExistence(timeout: 5))
        create.tap()
        XCTAssertTrue(app.staticTexts["Documents: 5"].waitForExistence(timeout: 5))
    }

    /// Picks a load state from the toolbar's menu.
    @MainActor
    private func choose(_ state: String, in app: XCUIApplication) {
        app.buttons["Load state"].tap()
        let option = app.buttons[state]
        XCTAssertTrue(option.waitForExistence(timeout: 5))
        option.tap()
    }
}
