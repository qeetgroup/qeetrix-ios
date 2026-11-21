import XCTest

final class SegmentedControlUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testAFullWidthControlSharesTheRowEqually() {
        let app = Showcase.launch("segmented-control")
        let everyone = app.buttons["Everyone"]
        let contacts = app.buttons["My contacts"]
        let nobody = app.buttons["Nobody"]
        contacts.scrollIntoView(in: app)
        XCTAssertTrue(contacts.isSelected)
        // Three equal shares, whatever the labels, edge to edge with a 1 pt rule between them.
        XCTAssertEqual(everyone.frame.width, contacts.frame.width, accuracy: 0.5)
        XCTAssertEqual(nobody.frame.width, contacts.frame.width, accuracy: 0.5)
        XCTAssertEqual(contacts.frame.minX - everyone.frame.maxX, 1, accuracy: 0.5)
        nobody.tap()
        XCTAssertTrue(nobody.isSelected)
        XCTAssertFalse(contacts.isSelected)
        XCTAssertEqual(app.staticTexts["segmented-audience"].label, "Who sees it: nobody")
    }
}
