import XCTest

/// Empty state, data state, skeleton, timeline and description list: what VoiceOver finds, and the
/// actions the app wires to them.
final class ContentStateUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testAnEmptyStateActionIsTheApps() {
        let app = Showcase.launch("empty-state")
        let create = app.buttons["Create invoice"]
        XCTAssertTrue(create.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["No invoices yet"].exists)
        create.tap()
        XCTAssertEqual(app.staticTexts["empty-created"].label, "Created: 1")
    }

    @MainActor
    func testTheDataStateShowsOneBranchAndRetries() {
        let app = Showcase.launch("data-state")
        let loading = app.descendants(matching: .any).matching(NSPredicate(format: "label == 'Loading'")).firstMatch
        XCTAssertTrue(loading.waitForExistence(timeout: 5), "One element for the whole loading branch")
        XCTAssertFalse(app.staticTexts["Asha Rao"].exists)
        app.buttons["Failed"].tap()
        XCTAssertTrue(app.staticTexts["Couldn't load members."].waitForExistence(timeout: 5))
        app.buttons["Try again"].tap()
        XCTAssertTrue(app.staticTexts["data-retries"].waitForLabel("Retries: 1"))
        XCTAssertTrue(app.descendants(matching: .any)["data-content"].waitForExistence(timeout: 5), "The app moved to the content")
        app.buttons["Empty"].tap()
        XCTAssertTrue(app.staticTexts["No members yet"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSkeletonsAreSilentAndTheirContainerSaysLoading() {
        let app = Showcase.launch("skeleton")
        let container = app.descendants(matching: .any).matching(NSPredicate(format: "label == 'Loading members'")).firstMatch
        container.scrollIntoView(in: app)
        XCTAssertTrue(container.exists)
        XCTAssertEqual(app.images.count, 0, "No placeholder is exposed as an image")
    }

    @MainActor
    func testATimelineEventReadsAsOneWithItsMarkersMeaning() {
        let app = Showcase.launch("timeline")
        let failed = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Payment failed'")).firstMatch
        failed.scrollIntoView(in: app)
        XCTAssertTrue(failed.exists)
        XCTAssertEqual(failed.label, "Payment failed, 12 Oct, The card was declined.")
        XCTAssertEqual(failed.value as? String, "Failed")
    }

    @MainActor
    func testADescriptionItemReadsTermAndValueTogether() {
        let app = Showcase.launch("description-list")
        XCTAssertTrue(app.staticTexts["Plan, Team, billed monthly"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Workspace, Qeet Design"].exists)
    }
}
