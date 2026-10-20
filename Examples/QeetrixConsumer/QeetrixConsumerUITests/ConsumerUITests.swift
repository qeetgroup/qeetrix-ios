import XCTest

/// The consumer app, driven as a person would: resources load from the package, a form validates and
/// submits, an alert and a sheet present and dismiss, a list searches, and the app follows the theme,
/// the text size and right-to-left layout it is launched with.
final class ConsumerUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func launch(_ arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-theme", "light", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryL"] + arguments
        app.launch()
        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 10))
        return app
    }

    @MainActor
    func testThePackagesFontsAndTokensLoad() {
        let app = launch()
        func element(_ identifier: String, containing text: String) -> XCUIElement {
            app.descendants(matching: .any).matching(NSPredicate(format: "identifier == %@ AND label CONTAINS %@", identifier, text))
                .firstMatch
        }
        for font in ["sans", "mono"] {
            XCTAssertTrue(
                element("font-\(font)", containing: "Available").waitForExistence(timeout: 5),
                "\(font) registered from the package's bundle")
        }
        XCTAssertFalse(app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS 'Missing'")).firstMatch.exists)
        XCTAssertTrue(element("tokens", containing: "2.1.6").exists, "The provenance read from the package's bundle")
    }

    @MainActor
    func testTheFormReportsErrorsThenSubmits() {
        let app = launch()
        app.buttons["Sign up"].tap()
        let create = app.buttons["Create account"]
        create.scrollIntoViewIfNeeded(in: app)
        create.tap()
        XCTAssertTrue(app.staticTexts["There is a problem"].waitForExistence(timeout: 3), "The error summary appears")

        app.swipeDown()
        app.textFields["Full name, Required"].tap()
        app.textFields["Full name, Required"].typeText("Asha Rao")
        app.textFields["Work email, Required"].tap()
        app.textFields["Work email, Required"].typeText("asha@example.com")
        app.secureTextFields["Password, Required"].tap()
        app.secureTextFields["Password, Required"].typeText("correct-horse-battery")
        app.buttons["Country, Required"].tap()
        app.buttons["India"].tap()
        let terms = app.switches["I accept the terms"]
        terms.scrollIntoViewIfNeeded(in: app)
        terms.tap()
        create.scrollIntoViewIfNeeded(in: app)
        create.tap()
        XCTAssertTrue(app.staticTexts["Account created"].waitForExistence(timeout: 3), "The success toast appears")
    }

    @MainActor
    func testAnAlertAndASheetPresentAndDismiss() {
        let app = launch()
        app.buttons["Decisions"].tap()
        app.buttons["Delete document"].tap()
        let alert = app.alerts["Delete this document?"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3))
        alert.buttons["Cancel"].tap()
        XCTAssertTrue(app.staticTexts["outcome"].waitForLabel("Outcome: None"), "Cancel changes nothing")

        app.buttons["Rename document"].tap()
        let name = app.textFields["Name"]
        XCTAssertTrue(name.waitForExistence(timeout: 3))
        name.tap()
        name.typeText(" 2027")
        app.buttons["Save"].tap()
        XCTAssertTrue(app.staticTexts["outcome"].waitForLabel("Outcome: Renamed to Roadmap 2027"))
    }

    @MainActor
    func testSearchFiltersTheListAndShowsNoResults() {
        let app = launch()
        app.buttons["Documents"].tap()
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 3))
        search.tap()
        search.typeText("road")
        XCTAssertTrue(app.staticTexts["documents-count"].waitForLabel("Documents: 1"))
        search.typeText("zzz")
        XCTAssertTrue(app.staticTexts["No documents found"].waitForExistence(timeout: 3))
    }

    /// The theme from `@AppStorage("theme")`: the canvas is near-white in light and near-black in dark.
    @MainActor
    func testTheAppFollowsTheStoredTheme() {
        XCTAssertGreaterThan(canvasBrightness(launch(["-theme", "light"])), 0.9)
        XCTAssertLessThan(canvasBrightness(launch(["-theme", "dark"])), 0.2)
    }

    @MainActor
    func testLargeTextGrowsTheContent() {
        let regular = launch().staticTexts["Appearance"].frame.height
        let large = launch(["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityL"]).staticTexts["Appearance"].frame
            .height
        XCTAssertGreaterThan(large, regular * 1.25, "The section heading is \(regular) pt, then \(large) pt")
    }

    /// The heading's ink sits at the start of its row: the left half left to right, the right half right to
    /// left. (Its accessibility frame spans the row, so the frame alone can't show the alignment.)
    @MainActor
    func testRightToLeftMirrorsTheLayout() {
        let rightToLeft = [
            "-AppleLanguages", "(ar)", "-AppleLocale", "ar_SA", "-AppleTextDirection", "YES", "-NSForceRightToLeftWritingDirection", "YES",
        ]
        XCTAssertLessThan(headingInk(launch()), 0.5, "Left to right, the heading is at the left")
        XCTAssertGreaterThan(headingInk(launch(rightToLeft)), 0.5, "Right to left, the heading is at the right")
    }

    /// Where the dark pixels of the "Appearance" heading fall across its row: 0 is the row's left edge, 1 its
    /// right edge.
    @MainActor
    private func headingInk(_ app: XCUIApplication) -> CGFloat {
        let row = app.staticTexts["Appearance"].frame
        guard let image = app.screenshot().image.cgImage else { return -1 }
        let scale = CGFloat(image.width) / app.windows.firstMatch.frame.width
        let crop = CGRect(x: row.minX * scale, y: row.minY * scale, width: row.width * scale, height: row.height * scale).integral
        guard let pixels = image.cropping(to: crop) else { return -1 }
        let width = pixels.width
        let height = pixels.height
        var rgba = [UInt8](repeating: 0, count: width * height * 4)
        let drawn = rgba.withUnsafeMutableBytes { buffer -> Bool in
            guard
                let context = CGContext(
                    data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
                    space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else { return false }
            context.draw(pixels, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard drawn else { return -1 }
        var sum = 0
        var count = 0
        for y in 0..<height {
            for x in 0..<width {
                let index = (y * width + x) * 4
                if Int(rgba[index]) + Int(rgba[index + 1]) + Int(rgba[index + 2]) < 3 * 100 {  // dark text on the light canvas
                    sum += x
                    count += 1
                }
            }
        }
        return count == 0 ? -1 : CGFloat(sum) / CGFloat(count) / CGFloat(width)
    }

    /// Apple's audit on each screen of the app. The showcase's gate covers each component on its own; this
    /// covers them composed by an app.
    @MainActor
    func testAppleAccessibilityAuditOnEveryScreen() throws {
        let app = launch()
        let types: XCUIAccessibilityAuditType = [.contrast, .hitRegion, .sufficientElementDescription, .trait, .elementDetection]
        for screen in ["Brand", "Sign up", "Decisions", "Documents"] {
            app.buttons[screen].tap()
            XCTAssertTrue(app.navigationBars[screen].waitForExistence(timeout: 5))
            try app.performAccessibilityAudit(for: types) { issue in
                // The system's search field and navigation bar draw themselves; Qeetrix doesn't style them.
                issue.element?.elementType == .searchField || issue.element?.elementType == .navigationBar
            }
            app.navigateBack()
        }
    }

    @MainActor
    private func canvasBrightness(_ app: XCUIApplication) -> CGFloat {
        app.buttons["Brand"].tap()
        XCTAssertTrue(app.navigationBars["Brand"].waitForExistence(timeout: 5))
        guard let image = app.screenshot().image.cgImage else { return -1 }
        // A point near the bottom-left corner, below the content: the canvas. Drawn into a known RGBA
        // format first, whatever the screenshot's own pixel format.
        let point = CGRect(x: Int(CGFloat(image.width) * 0.05), y: Int(CGFloat(image.height) * 0.95), width: 1, height: 1)
        guard let pixel = image.cropping(to: point) else { return -1 }
        var rgba = [UInt8](repeating: 0, count: 4)
        let drawn = rgba.withUnsafeMutableBytes { buffer -> Bool in
            guard
                let context = CGContext(
                    data: buffer.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                    space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else { return false }
            context.draw(pixel, in: CGRect(x: 0, y: 0, width: 1, height: 1))
            return true
        }
        guard drawn else { return -1 }
        return (CGFloat(rgba[0]) + CGFloat(rgba[1]) + CGFloat(rgba[2])) / (3 * 255)
    }
}

extension XCUIElement {
    func waitForLabel(_ label: String, timeout: TimeInterval = 5) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "label == %@", label), object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    /// Back one page with the edge swipe: XCUITest on iOS 27 doesn't expose the bar's back button.
    func navigateBack() {
        let edge = coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))
        edge.press(forDuration: 0.05, thenDragTo: coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)))
    }

    func scrollIntoViewIfNeeded(in app: XCUIApplication, attempts: Int = 6) {
        var remaining = attempts
        while !isHittable && remaining > 0 {
            app.swipeUp()
            remaining -= 1
        }
    }
}
