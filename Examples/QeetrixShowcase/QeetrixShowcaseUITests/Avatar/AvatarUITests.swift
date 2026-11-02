import XCTest

final class AvatarUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testAnAvatarIsAnImageNamedByItsName() {
        let app = Showcase.launch("avatar")
        XCTAssertTrue(app.images["Asha Rao"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.images["Qeet Group"].exists)
        XCTAssertTrue(app.images["Kaveri Foods Private Limited"].exists, "Named by the full name, not the initials")
        XCTAssertFalse(app.staticTexts["KF"].exists, "The initials are not read: the image is named by the name alone")
    }

    @MainActor
    func testADecorativeAvatarIsHiddenAndTheNameBesideItIsRead() {
        let app = Showcase.launch("avatar")
        XCTAssertTrue(app.staticTexts["Asha Rao"].waitForExistence(timeout: 5), "The name beside it")
        XCTAssertEqual(
            app.images.matching(identifier: "Asha Rao").count, AvatarPageLayout.sizedAvatars, "Only the sized avatars are images")
    }
}

/// The avatar page's size row: one avatar per size, sm to xl.
private enum AvatarPageLayout {
    static let sizedAvatars = 4
}
