import XCTest

/// Scrolling 5,000 rows in a native List of QeetrixListItems. On the simulator these numbers describe the
/// simulator, not a device: they are recorded to catch large regressions, not to promise a frame rate.
final class LargeListPerformanceUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testScrollingFiveThousandRows() {
        let app = Showcase.launch("large-list")
        let list = app.collectionViews["large-list"]
        XCTAssertTrue(list.waitForExistence(timeout: 10))
        let options = XCTMeasureOptions()
        options.iterationCount = 5
        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric, XCTMemoryMetric(application: app)], options: options) {
            list.swipeUp(velocity: .fast)
            list.swipeUp(velocity: .fast)
            list.swipeDown(velocity: .fast)
        }
    }

    @MainActor
    func testFarRowsAreReachableAndSelectable() {
        let app = Showcase.launch("large-list")
        let list = app.collectionViews["large-list"]
        XCTAssertTrue(list.waitForExistence(timeout: 10))
        for _ in 0..<6 { list.swipeUp(velocity: .fast) }
        let row = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Document '")).element(boundBy: 2)
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        let label = row.label
        row.tap()
        XCTAssertTrue(app.buttons[label].isSelected, "Selection is a value the page keeps, found again by the row's id")
    }
}
