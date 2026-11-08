import XCTest

final class EmptyStateUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// The image in place of the icon is decorative — VoiceOver skips it — while the same tile on
    /// its own is read; the actions under it are their own buttons.
    @MainActor
    func testAnImageInPlaceOfTheIconIsDecorative() {
        let app = Showcase.launch("empty-state")
        let unlock = app.buttons["Unlock"]
        unlock.scrollIntoView(in: app)
        XCTAssertTrue(unlock.exists)
        let alone = app.images["app-icon-alone"]
        alone.scrollIntoView(in: app)
        XCTAssertEqual(alone.label, "Qeet ID app icon", "The control: the tile is an image VoiceOver reads")
        XCTAssertEqual(app.images.matching(NSPredicate(format: "label == %@", "Qeet ID app icon")).count, 1, "Only the one alone")
        XCTAssertTrue(app.staticTexts["Qeet ID is locked"].exists)
    }
}
