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
    /// Taps `points` below this element's centre. Between half the drawn height and 22 pt, that is
    /// outside a control drawn shorter than 44 pt but inside its centred 44 pt hit area. Measured from
    /// the centre because the frame is the hit area on iOS 27 and the drawn control on earlier systems.
    func tapBelowCentre(by points: CGFloat) {
        coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).withOffset(CGVector(dx: 0, dy: points)).tap()
    }

    /// Taps `points` outside this element's frame, below its bottom edge: in a field's padding, under the
    /// line of text the element covers.
    func tapBelow(by points: CGFloat) {
        coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 1)).withOffset(CGVector(dx: 0, dy: points)).tap()
    }

    /// Scrolls the app until this element is on screen: slow drags of a third of the screen, without
    /// a swipe's momentum, which on a small screen (iPhone SE) carried the element past the top. Drags
    /// back down when the element is above the middle of the screen.
    func scrollIntoView(in app: XCUIApplication, attempts: Int = 16) {
        var remaining = attempts
        while !isHittable && remaining > 0 {
            let isAbove = exists && frame.maxY < app.frame.midY
            let from = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: isAbove ? 0.35 : 0.7))
            let to = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: isAbove ? 0.7 : 0.35))
            from.press(forDuration: 0.05, thenDragTo: to)
            remaining -= 1
        }
    }
}

extension XCUIElement {
    var hasKeyboardFocus: Bool {
        (value(forKey: "hasKeyboardFocus") as? Bool) ?? false
    }

    /// Waits until this element has the keyboard focus. Focus set from a tap gesture lands a moment
    /// after the tap, on a busy simulator up to a few seconds.
    func waitForKeyboardFocus(timeout: TimeInterval = 5) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "hasKeyboardFocus == true"), object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

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
            // Near a corner, not the centre: the region spans the screen, and in landscape the popover
            // can sit over its centre (iPhone 17), where a tap lands on the popover instead.
            region.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.88)).tap()
        } else {
            coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.08)).tap()
        }
    }

    /// Ends a search: the search bar's Cancel button, which iOS 27 shows as Close.
    func endSearch() {
        let cancel = buttons["Cancel"]
        if cancel.exists { cancel.tap() } else { buttons["Close"].tap() }
    }

    /// Goes back one page with the system's edge swipe, which every navigation stack supports — the back
    /// button is not always exposed as a button of the navigation bar.
    func navigateBack() {
        let edge = coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))
        edge.press(forDuration: 0.05, thenDragTo: coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)))
    }
}
