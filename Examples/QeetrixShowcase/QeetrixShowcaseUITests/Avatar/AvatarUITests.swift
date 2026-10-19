import XCTest

final class AvatarUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testAnAvatarIsAnImageNamedByThePersonThenTheStatus() {
        let app = Showcase.launch("avatar")
        XCTAssertTrue(app.images["Asha Rao"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.images["Asha Rao, Online"].exists, "The badge's status is read after the name")
        XCTAssertTrue(app.images["Qeet Group"].exists)
    }
}
