import XCTest

final class FeedbackUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testAProgressBarIsANativeProgressIndicatorWithItsPercentage() {
        let app = Showcase.launch("progress")
        let uploading = app.progressIndicators["Uploading"]
        XCTAssertTrue(uploading.waitForExistence(timeout: 5))
        XCTAssertEqual(uploading.value as? String, "40%")
        app.buttons["Advance"].tap()
        XCTAssertEqual(uploading.value as? String, "60%")
    }

    @MainActor
    func testAnIndeterminateBarIsAnActivityIndicatorWithoutAPercentage() {
        let app = Showcase.launch("progress")
        let exporting = app.activityIndicators["Preparing export"]
        XCTAssertTrue(exporting.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertFalse((exporting.value as? String ?? "").contains("%"), "An unknown total has no percentage")
        // An offset segment once stretched the bar's frame to 140% of the track, off the screen.
        XCTAssertLessThanOrEqual(
            exporting.frame.maxX, app.navigationBars.firstMatch.frame.maxX, "The moving segment stays inside the track")
    }

    @MainActor
    func testASpinnerIsNamedLoadingByDefault() {
        let app = Showcase.launch("spinner")
        XCTAssertTrue(app.descendants(matching: .any)["Loading"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["Loading, xl"].exists)
    }
}
