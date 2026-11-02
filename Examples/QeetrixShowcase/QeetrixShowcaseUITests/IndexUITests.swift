import XCTest

final class IndexUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testIndexOpensEveryComponentPage() {
        let app = Showcase.launch()
        let pages = [
            "Button", "Icon button", "Text field", "Switch", "Fieldset", "Avatar", "Badge", "Text", "Heading", "Progress", "Spinner",
            "Card", "Separator",
        ]
        for page in pages {
            let link = app.buttons[page]
            link.scrollIntoView(in: app)
            XCTAssertTrue(link.waitForExistence(timeout: 5), "The index has no link to \(page)")
            link.tap()
            XCTAssertTrue(app.navigationBars[page].waitForExistence(timeout: 5), "\(page) did not open")
            app.navigateBack()
        }
    }
}
