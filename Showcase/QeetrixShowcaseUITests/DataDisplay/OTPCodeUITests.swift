import XCTest

/// Synthetic codes only.
final class OTPCodeUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// With the app's action, the first tap shows a hidden code, the next runs the action — and
    /// nothing is copied: no "Copied" toast.
    @MainActor
    func testACodeWithAnActionShowsThenRunsItInsteadOfCopying() {
        let app = Showcase.launch("otp-code")
        let code = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "GitHub, priya-sharma")).firstMatch
        code.scrollIntoView(in: app)
        XCTAssertTrue(code.exists)
        XCTAssertTrue(code.label.hasSuffix("Code hidden"), code.label)
        let status = app.staticTexts["otp-fill-status"]
        code.tap()
        XCTAssertEqual(status.label, "Nothing filled", "The first tap shows the code")
        XCTAssertFalse(code.label.hasSuffix("Code hidden"), code.label)
        code.tap()
        XCTAssertEqual(status.label, "Filled 1 times")
        XCTAssertFalse(app.toast(beginningWith: "Copied").waitForExistence(timeout: 2), "No copy, no toast")
        // The control: a code that copies, on the same page, does show the toast.
        let copies = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Bank, Savings")).firstMatch
        copies.scrollIntoView(in: app)
        copies.tap()
        copies.tap()
        XCTAssertTrue(app.toast(beginningWith: "Copied").waitForExistence(timeout: 5))
    }

    /// A menu's "Copy code" copies by Qeetrix's rules and confirms with the same toast and its
    /// expiry line.
    @MainActor
    func testAMenusCopyCodeShowsTheCopiedToast() {
        let app = Showcase.launch("otp-code")
        let code = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Qeet ID, priya.sharma")).firstMatch
        XCTAssertTrue(code.waitForExistence(timeout: 5))
        code.press(forDuration: 1.2)
        let copy = app.buttons["Copy code"]
        XCTAssertTrue(copy.waitForExistence(timeout: 5), "The row's menu")
        copy.tap()
        XCTAssertTrue(app.toast(beginningWith: "Copied").waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Clears from the clipboard after 1 minute"].exists, "A secret's expiry line")
    }
}
