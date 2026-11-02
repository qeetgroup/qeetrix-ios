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
        let count = app.staticTexts["save-count"]
        // Laid out 32 pt tall (size.control.md), the count starts 16 pt and the section's 12 pt gap below
        // the button's centre; a 44 pt layout would push it to 34 pt.
        XCTAssertLessThan(count.frame.minY - save.frame.midY, 22 + 12, "The button is laid out at its web height")
        // 16 pt below the centre is the drawn edge, 22 pt the target's: 19 pt is target only.
        save.tapBelowCentre(by: 19)
        XCTAssertEqual(count.label, "Saved 1 times")
    }

    @MainActor
    func testALoadingButtonKeepsItsNameReportsLoadingAndIgnoresTaps() {
        let app = Showcase.launch("button")
        let simulate = app.buttons["Simulate work"]
        simulate.scrollIntoView(in: app)
        let save = app.buttons["Save"]
        let width = save.frame.width
        simulate.tap()
        XCTAssertTrue(app.buttons["Stop"].waitForExistence(timeout: 2))
        XCTAssertEqual(save.value as? String, "Loading", "A busy button keeps its name and reports that it is loading")
        XCTAssertGreaterThan(save.frame.width, width, "Without an icon, a loading button gains the zone for its spinner")
        save.tap()
        XCTAssertEqual(app.staticTexts["save-count"].label, "Saved 0 times")
        app.buttons["Stop"].tap()
        save.tap()
        XCTAssertEqual(app.staticTexts["save-count"].label, "Saved 1 times")
    }

    @MainActor
    func testAFullWidthButtonSpansThePage() {
        let app = Showcase.launch("button")
        let passkey = app.buttons["Continue with passkey"]
        passkey.scrollIntoView(in: app)
        // The size picker is a segmented control, which fills the page's content width.
        let content = app.segmentedControls.firstMatch.frame
        XCTAssertEqual(passkey.frame.width, content.width, accuracy: 1, "As wide as the page's content")
        XCTAssertGreaterThanOrEqual(passkey.frame.height, 40, "lg is the field height at the default density")
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

    @MainActor
    func testAnIconButtonIsSquareWithA44PointTarget() {
        let app = Showcase.launch("icon-button")
        let close = app.buttons["Close"]
        close.scrollIntoView(in: app)
        XCTAssertEqual(close.frame.width, close.frame.height, accuracy: 0.5, "Square")
        let count = app.staticTexts["close-count"]
        XCTAssertLessThan(count.frame.minY - close.frame.midY, 22 + 12, "Laid out at its 32 pt web size")
        close.tapBelowCentre(by: 19)
        XCTAssertEqual(count.label, "Closed 1 times")
    }
}
