import XCTest

final class CollectionPatternsUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testSearchAndArchivedFilterNarrowTheList() {
        let app = Showcase.launch("collection-patterns")
        // A section header is drawn, and read, in capitals.
        let count = app.staticTexts["collection-count"]
        XCTAssertTrue(count.waitForExistence(timeout: 5))
        XCTAssertEqual(count.label, "DOCUMENTS: 5", "Archived documents are hidden at first")
        // The chip is the List row's one element, so its frame is the whole row; tap the chip, drawn at the start.
        app.switches["Show archived"].coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0.5)).withOffset(CGVector(dx: 60, dy: 0)).tap()
        XCTAssertTrue(count.waitForLabel("DOCUMENTS: 6"))
        let field = app.searchFields["Search documents"]
        field.tap()
        field.typeText("road")
        XCTAssertTrue(count.waitForLabel("DOCUMENTS: 1"))
    }

    @MainActor
    func testDeletingConfirmsThenOffersUndo() {
        let app = Showcase.launch("collection-patterns")
        let count = app.staticTexts["collection-count"]
        let row = app.buttons["Roadmap, Meera Iyer, Active"]
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertTrue(app.staticTexts["Delete Roadmap?"].waitForExistence(timeout: 5))
        app.buttons["Delete"].tap()
        XCTAssertTrue(count.waitForLabel("DOCUMENTS: 4"))
        app.buttons["Undo"].tap()
        XCTAssertTrue(count.waitForLabel("DOCUMENTS: 5"))
    }

    @MainActor
    func testTheLoadStatesAreTheApps() {
        let app = Showcase.launch("collection-patterns")
        XCTAssertTrue(app.staticTexts["collection-count"].waitForExistence(timeout: 5))
        choose("Failed", in: app)
        XCTAssertTrue(app.staticTexts["Couldn't load documents"].waitForExistence(timeout: 5))
        app.buttons["Try again"].tap()
        XCTAssertTrue(app.staticTexts["collection-count"].waitForExistence(timeout: 5))
        choose("Empty", in: app)
        let create = app.buttons["Create a document"]
        XCTAssertTrue(create.waitForExistence(timeout: 5))
        create.tap()
        XCTAssertTrue(app.staticTexts["collection-count"].waitForLabel("DOCUMENTS: 5"))
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
