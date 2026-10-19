import XCTest

final class ButtonUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testTapRunsTheAction() {
        let app = Showcase.launch("button")
        let save = app.buttons["Save"]
        save.scrollIntoView(in: app)
        save.tap()
        XCTAssertEqual(app.staticTexts["save-count"].label, "Saved 1 times")
    }

    @MainActor
    func testTheHitAreaIs44PointsWithoutMovingLayout() {
        let app = Showcase.launch("button")
        let save = app.buttons["Save"]
        save.scrollIntoView(in: app)
        XCTAssertLessThan(save.frame.height, 44, "The button is drawn at its web height")
        // 32 pt drawn, 44 pt target: 6 pt of target on each side.
        save.tapBelow(by: 4)
        XCTAssertEqual(app.staticTexts["save-count"].label, "Saved 1 times")
    }

    @MainActor
    func testALoadingButtonIgnoresTapsAndReadsItsLoadingLabel() {
        let app = Showcase.launch("button")
        let simulate = app.buttons["Simulate work"]
        simulate.scrollIntoView(in: app)
        simulate.tap()
        let saving = app.buttons["Saving"]
        XCTAssertTrue(saving.waitForExistence(timeout: 2), "A loading button is named by its loading label")
        saving.tap()
        XCTAssertEqual(app.staticTexts["save-count"].label, "Saved 0 times")
        app.buttons["Stop"].tap()
        app.buttons["Save"].tap()
        XCTAssertEqual(app.staticTexts["save-count"].label, "Saved 1 times")
    }

    @MainActor
    func testADisabledButtonIsNotEnabled() {
        let app = Showcase.launch("button")
        let unavailable = app.buttons["Unavailable"].firstMatch
        unavailable.scrollIntoView(in: app)
        XCTAssertFalse(unavailable.isEnabled)
    }
}

final class IconButtonUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testTheLabelNamesTheButtonAndTheTapRunsTheAction() {
        let app = Showcase.launch("icon-button")
        let close = app.buttons["Close"]
        close.scrollIntoView(in: app)
        close.tap()
        XCTAssertEqual(app.staticTexts["close-count"].label, "Closed 1 times")
    }

    @MainActor
    func testLoadingAndDisabledStates() {
        let app = Showcase.launch("icon-button")
        let send = app.buttons["Send"]
        send.scrollIntoView(in: app)
        XCTAssertEqual(send.value as? String, "Loading", "A busy icon button reports that it is loading")
        XCTAssertFalse(app.buttons["Lock"].isEnabled)
    }
}
