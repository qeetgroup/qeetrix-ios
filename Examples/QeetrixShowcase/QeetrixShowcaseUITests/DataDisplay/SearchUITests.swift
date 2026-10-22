import XCTest

final class SearchUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testTypingFiltersAndCancelRestores() {
        let app = Showcase.launch("search")
        let field = app.searchFields["Search documents"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Documents: 6"].exists)
        field.tap()
        field.typeText("asha")
        XCTAssertTrue(app.staticTexts["Documents: 2"].waitForExistence(timeout: 5), "The page filters by owner too")
        app.endSearch()
        XCTAssertTrue(app.staticTexts["Documents: 6"].waitForExistence(timeout: 5), "Ending the search clears the query")
    }

    @MainActor
    func testNoResultsOffersAWayBack() {
        let app = Showcase.launch("search")
        let field = app.searchFields["Search documents"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("zzz")
        XCTAssertTrue(app.staticTexts["No results"].waitForExistence(timeout: 5))
        app.buttons["Clear search and filter"].tap()
        XCTAssertTrue(app.staticTexts["Documents: 6"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSubmittingAndFilteringWithChips() {
        let app = Showcase.launch("search")
        let field = app.searchFields["Search documents"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("road\n")
        XCTAssertTrue(app.staticTexts["Submitted: road"].waitForExistence(timeout: 5))
        app.endSearch()
        let archived = app.buttons["Archived"]
        XCTAssertTrue(archived.waitForExistence(timeout: 5))
        archived.tap()
        XCTAssertTrue(archived.isSelected)
        XCTAssertTrue(app.staticTexts["Documents: 1"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["All"].isSelected, "One chip at a time")
    }
}
