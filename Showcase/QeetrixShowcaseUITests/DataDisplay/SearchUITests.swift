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
        // A section header is drawn, and read, in capitals.
        let count = app.staticTexts["search-count"]
        XCTAssertEqual(count.label, "DOCUMENTS: 6")
        field.tap()
        field.typeText("asha")
        XCTAssertTrue(count.waitForLabel("DOCUMENTS: 2"), "The page filters by owner too")
        app.endSearch()
        XCTAssertTrue(count.waitForLabel("DOCUMENTS: 6"), "Ending the search clears the query")
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
        XCTAssertTrue(app.staticTexts["search-count"].waitForLabel("DOCUMENTS: 6"))
    }

    @MainActor
    func testSubmittingAndFilteringWithChips() {
        let app = Showcase.launch("search")
        let field = app.searchFields["Search documents"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("road\n")
        XCTAssertTrue(app.staticTexts["search-submitted"].waitForLabel("Submitted: road"))
        app.endSearch()
        let archived = app.buttons["Archived"]
        XCTAssertTrue(archived.waitForExistence(timeout: 5))
        archived.tap()
        XCTAssertTrue(archived.isSelected)
        XCTAssertTrue(app.staticTexts["search-count"].waitForLabel("DOCUMENTS: 1"))
        XCTAssertFalse(app.buttons["All"].isSelected, "One chip at a time")
    }
}
