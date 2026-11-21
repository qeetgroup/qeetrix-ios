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
    func testABareSwitchIsTheTrackAloneNamedForVoiceOver() {
        let app = Showcase.launch("switch")
        let faceID = app.switches["Unlock with Face ID"]
        faceID.scrollIntoView(in: app)
        XCTAssertEqual(faceID.value as? String, "1")
        // The element's frame is its 44 pt target, centred on the 32 × 18 pt track (whose layout size the
        // library's tests check): VoiceOver's frame is where a tap lands.
        XCTAssertEqual(faceID.frame.size, CGSize(width: 44, height: 44))
        faceID.tap()
        XCTAssertEqual(faceID.value as? String, "0")
        // A tap 9 pt under the track's edge is still inside its 44 pt target.
        faceID.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).withOffset(CGVector(dx: 0, dy: 18)).tap()
        XCTAssertEqual(faceID.value as? String, "1")
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
