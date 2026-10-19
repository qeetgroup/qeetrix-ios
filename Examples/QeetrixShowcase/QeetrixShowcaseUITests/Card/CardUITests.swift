import XCTest

final class CardUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testACardButtonRunsItsActionAndReportsSelection() {
        let app = Showcase.launch("card")
        let starter = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Starter")).firstMatch
        starter.scrollIntoView(in: app)
        XCTAssertFalse(starter.isSelected)
        starter.tap()
        XCTAssertTrue(starter.isSelected, "A selected card button is selected for VoiceOver")
        XCTAssertEqual(app.staticTexts["card-taps"].label, "Chosen 1 times")
    }
}
