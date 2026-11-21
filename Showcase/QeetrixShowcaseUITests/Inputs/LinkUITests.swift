import XCTest

final class LinkUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testAnActionLinkIsAButtonWithA44PointTarget() {
        let app = Showcase.launch("link")
        let change = app.buttons["Change number"]
        XCTAssertTrue(change.waitForExistence(timeout: 5))
        // The element's frame is the 44 pt target round the 16 pt line (whose layout the library's tests check).
        XCTAssertEqual(change.frame.height, 44, accuracy: 0.5)
        change.tap()
        XCTAssertEqual(app.staticTexts["link-taps"].label, "Changed 1 times")
        // 12 pt under the words is still inside its 44 pt target.
        change.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).withOffset(CGVector(dx: 0, dy: 20)).tap()
        XCTAssertEqual(app.staticTexts["link-taps"].label, "Changed 2 times")
    }

    @MainActor
    func testADestinationIsALinkOpenedThroughTheEnvironment() {
        let app = Showcase.launch("link")
        let privacy = app.links["privacy-link"]
        privacy.scrollIntoView(in: app)
        XCTAssertEqual(privacy.label, "Privacy Policy")
        privacy.tap()
        XCTAssertEqual(app.staticTexts["link-opened"].label, "Opened: privacy")
    }

    @MainActor
    func testLinksInsideASentenceAreLinksOpenedThroughTheEnvironment() {
        let app = Showcase.launch("link")
        // The sentence's Markdown links: each a link element, named by its words.
        let terms = app.links["https://qeet.in/terms"]
        terms.scrollIntoView(in: app)
        XCTAssertEqual(terms.label, "Terms of Service")
        terms.tap()
        XCTAssertEqual(app.staticTexts["link-opened"].label, "Opened: terms")
    }
}
