import XCTest

final class SwitchUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testASwitchIsANativeSwitchThatToggles() {
        let app = Showcase.launch("switch")
        let email = app.switches["Email notifications"]
        XCTAssertTrue(email.waitForExistence(timeout: 5))
        XCTAssertEqual(email.value as? String, "1")
        email.tap()
        XCTAssertEqual(email.value as? String, "0")
        let push = app.switches["Push notifications"]
        XCTAssertEqual(push.value as? String, "0")
        push.tap()
        XCTAssertEqual(push.value as? String, "1")
    }

    @MainActor
    func testADisabledSwitchDoesNotToggle() {
        let app = Showcase.launch("switch")
        let managed = app.switches["Managed by your organisation"]
        managed.scrollIntoView(in: app)
        XCTAssertFalse(managed.isEnabled)
        managed.tap()
        XCTAssertEqual(managed.value as? String, "1")
    }

    @MainActor
    func testTheStyleOnANativeToggle() {
        let app = Showcase.launch("switch")
        let wifi = app.switches["Wi-Fi"]
        wifi.scrollIntoView(in: app)
        XCTAssertEqual(wifi.value as? String, "0")
        wifi.tap()
        XCTAssertEqual(wifi.value as? String, "1")
    }
}
