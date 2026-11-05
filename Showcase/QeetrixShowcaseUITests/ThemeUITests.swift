import XCTest

/// The theme picker, switched while the app runs: each choice redraws the whole window in that theme, and
/// System gives the window back to the device's appearance.
final class ThemeUITests: XCTestCase {
    /// Launched without `-theme`: a launch argument outranks the stored preference, so the picker could
    /// not change it. The simulator is in its default light appearance.
    @MainActor
    func testSwitchingTheThemeRedrawsTheWindow() {
        let app = XCUIApplication()
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryL"]
        app.launch()
        // The menu picker's label is its name and the current choice: "Theme, System".
        let picker = app.navigationBars.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Theme'")).firstMatch
        XCTAssertTrue(picker.waitForExistence(timeout: 10))

        func choose(_ mode: String) -> Bool {
            picker.tap()
            let item = app.buttons[mode]
            XCTAssertTrue(item.waitForExistence(timeout: 5), "The theme menu offers \(mode)")
            item.tap()
            XCTAssertTrue(item.waitForNonExistence(timeout: 5))
            XCTAssertEqual(picker.label, "Theme, \(mode)", "The picker shows the choice")
            Thread.sleep(forTimeInterval: 1)  // the cross-fade between themes
            return isDark(app)
        }
        XCTAssertFalse(choose("Light"), "Light draws the light theme")
        XCTAssertTrue(choose("Dark"), "Dark draws the dark theme")
        XCTAssertFalse(choose("System"), "System follows the device again, which is light")
        XCTAssertTrue(choose("Dark"), "Dark again, after System")
        XCTAssertFalse(choose("Light"), "Light again, straight from Dark")
        XCTAssertFalse(choose("System"), "System, from Light")
    }

    /// Whether the window's background, below the list, is drawn dark.
    @MainActor
    private func isDark(_ app: XCUIApplication) -> Bool {
        let image = app.screenshot().image
        guard let cgImage = image.cgImage,
            let pixel = cgImage.cropping(to: CGRect(x: cgImage.width / 2, y: cgImage.height * 19 / 20, width: 1, height: 1))
        else {
            XCTFail("No screenshot")
            return false
        }
        var rgba = [UInt8](repeating: 0, count: 4)
        let drawn = rgba.withUnsafeMutableBytes { bytes -> Bool in
            guard
                let context = CGContext(
                    data: bytes.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                    space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else { return false }
            context.draw(pixel, in: CGRect(x: 0, y: 0, width: 1, height: 1))
            return true
        }
        XCTAssertTrue(drawn)
        let brightness = (Int(rgba[0]) + Int(rgba[1]) + Int(rgba[2])) / 3
        return brightness < 128
    }
}
