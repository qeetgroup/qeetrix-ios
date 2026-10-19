import XCTest

final class SheetUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testCloseDismissesASheetWithoutChanges() {
        let app = Showcase.launch("sheet")
        app.buttons["Edit profile"].tap()
        let sheet = app.staticTexts["Your team sees these details."]
        XCTAssertTrue(sheet.waitForExistence(timeout: 5))
        app.buttons["Close"].tap()
        XCTAssertFalse(sheet.waitForExistence(timeout: 2))
    }

    @MainActor
    func testUnsavedChangesStopASwipeAndCloseAsksFirst() {
        let app = Showcase.launch("sheet")
        app.buttons["Edit profile"].tap()
        let field = app.textFields["Display name"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(" K")
        let sheet = app.staticTexts["Your team sees these details."]
        sheet.dragToBottom(of: app)
        XCTAssertTrue(sheet.waitForExistence(timeout: 2), "A swipe does not discard changes")
        app.buttons["Close"].tap()
        let discard = app.buttons["Discard changes"]
        XCTAssertTrue(discard.waitForExistence(timeout: 5))
        // "Keep editing" is the cancel action: anchored, the dialog shows no button for it, and a tap outside
        // chooses it.
        let keep = app.buttons["Keep editing"]
        if keep.exists { keep.tap() } else { app.tapOutside() }
        XCTAssertFalse(discard.waitForExistence(timeout: 2))
        XCTAssertTrue(sheet.exists)
        app.buttons["Close"].tap()
        XCTAssertTrue(discard.waitForExistence(timeout: 5))
        discard.tap()
        XCTAssertFalse(sheet.waitForExistence(timeout: 3))
        XCTAssertEqual(app.staticTexts["profile-name"].label, "Display name: Asha Rao")
    }

    @MainActor
    func testSavingAppliesTheChangeAndDismisses() {
        let app = Showcase.launch("sheet")
        app.buttons["Edit profile"].tap()
        let field = app.textFields["Display name"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(" K")
        app.buttons["Save"].tap()
        XCTAssertFalse(app.staticTexts["Your team sees these details."].waitForExistence(timeout: 3))
        XCTAssertEqual(app.staticTexts["profile-name"].label, "Display name: Asha Rao K")
    }

    @MainActor
    func testASheetWithDetentsWorksAndSwipesAway() {
        let app = Showcase.launch("sheet")
        app.buttons["Show filters"].tap()
        let oldest = app.buttons["Oldest"]
        XCTAssertTrue(oldest.waitForExistence(timeout: 5))
        oldest.tap()
        app.buttons["Done"].tap()
        XCTAssertEqual(app.staticTexts["filters-sort"].label, "Sort: oldest")
        app.buttons["Show filters"].tap()
        let sheet = app.staticTexts["Medium or large; drag the handle."]
        XCTAssertTrue(sheet.waitForExistence(timeout: 5))
        sheet.dragToBottom(of: app)
        XCTAssertFalse(sheet.waitForExistence(timeout: 3), "Without changes to guard, a swipe dismisses")
    }
}
