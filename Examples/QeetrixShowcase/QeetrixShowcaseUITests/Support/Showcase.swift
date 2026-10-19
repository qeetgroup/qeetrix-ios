import XCTest

/// Launches the showcase at one page (`-page <name>`), so each test starts where it needs to.
@MainActor
enum Showcase {
    static func launch(_ page: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        if let page {
            app.launchArguments += ["-page", page]
        }
        // A fixed theme and text size, so element frames do not depend on the simulator's settings.
        app.launchArguments += ["-theme", "light", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryL"]
        app.launch()
        return app
    }
}

extension XCUIElement {
    /// Taps `points` outside this element's frame, below its bottom edge — inside a 44 pt hit area
    /// for a control drawn shorter than that, outside it otherwise.
    func tapBelow(by points: CGFloat) {
        coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 1)).withOffset(CGVector(dx: 0, dy: points)).tap()
    }

    /// Scrolls the app until this element is on screen.
    func scrollIntoView(in app: XCUIApplication, attempts: Int = 8) {
        var remaining = attempts
        while !isHittable && remaining > 0 {
            app.swipeUp()
            remaining -= 1
        }
    }
}

extension XCUIElement {
    /// Waits until this element's label is `label`. A system dialog runs its action after its dismissal
    /// animation, so what the action changes appears a moment after the tap.
    func waitForLabel(_ label: String, timeout: TimeInterval = 5) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "label == %@", label), object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    /// Drags from this element to the bottom of the screen — the gesture that dismisses a sheet, or pulls
    /// it down a detent. Longer than `swipeDown()`, which a sheet at a detent can absorb.
    func dragToBottom(of app: XCUIApplication) {
        coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.99)))
    }
}

extension XCUIApplication {
    /// Taps outside a popover or an anchored dialog: on the dismiss region where UIKit exposes one, else
    /// near the top of the screen, clear of the content the tests open.
    func tapOutside() {
        let region = otherElements["PopoverDismissRegion"].firstMatch
        if region.exists {
            region.tap()
        } else {
            coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.08)).tap()
        }
    }

    /// Goes back one page with the system's edge swipe, which every navigation stack supports — the back
    /// button is not always exposed as a button of the navigation bar.
    func navigateBack() {
        let edge = coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))
        edge.press(forDuration: 0.05, thenDragTo: coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)))
    }
}
