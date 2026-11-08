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
        let add = app.buttons["Add account"]
        XCTAssertTrue(add.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["No accounts yet"].exists)
        add.tap()
        XCTAssertEqual(app.staticTexts["empty-state-added"].label, "Added: 1")
    }

    @MainActor
    func testTheDataStateShowsOneBranchAndRetries() {
        let app = Showcase.launch("data-state")
        let loading = app.otherElements["Loading"]
        XCTAssertTrue(loading.waitForExistence(timeout: 5), "One element for the whole loading branch")
        XCTAssertFalse(app.staticTexts["Priya Sharma · Qeet ID"].exists)
        app.buttons["Failed"].tap()
        XCTAssertTrue(app.staticTexts["Couldn't load this"].waitForExistence(timeout: 5))
        app.buttons["Try again"].tap()
        XCTAssertTrue(app.staticTexts["data-state-retries"].waitForLabel("Retries: 1"))
        app.buttons["Offline"].tap()
        XCTAssertTrue(app.staticTexts["You're offline"].waitForExistence(timeout: 5))
        app.buttons["Empty"].tap()
        XCTAssertTrue(app.staticTexts["No accounts yet"].waitForExistence(timeout: 5))
        app.buttons["Loaded"].tap()
        XCTAssertTrue(app.staticTexts["Priya Sharma · Qeet ID"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSkeletonsAreSilentAndTheirContainerSaysLoading() {
        let app = Showcase.launch("skeleton")
        let container = app.otherElements["Loading accounts"]
        XCTAssertTrue(container.waitForExistence(timeout: 5))
        XCTAssertEqual(app.images.count, 0, "No placeholder is exposed as an image")
    }

    /// VoiceOver reads an event as one element — title, description, time — and the marker not at all.
    @MainActor
    func testATimelineEventReadsAsOne() {
        let app = Showcase.launch("timeline")
        let failed = app.staticTexts["Directory sync failed, SAML certificate expired, Yesterday"]
        failed.scrollIntoView(in: app)
        XCTAssertTrue(failed.exists)
    }

    @MainActor
    func testADescriptionItemReadsTermAndValueTogether() {
        let app = Showcase.launch("description-list")
        XCTAssertTrue(app.staticTexts["App, Qeet Pay console"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Phone, Not set"].exists, "An empty value is read as Not set, not as a dash")
    }
}
