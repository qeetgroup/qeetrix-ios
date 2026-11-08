import XCTest

/// Apple's accessibility audit (`performAccessibilityAudit`) as a gate over every showcase page: an issue
/// fails the test unless an exclusion below names it and says why.
///
/// Three runs, each where its checks mean most:
/// - **Light theme, the simulator's own text size** — every check but text clipping. The size is not
///   pinned with a launch argument, which would stop the Dynamic Type check from seeing text scale.
/// - **Dark theme** — contrast, the one check a theme changes. Contrast is checked at the default size,
///   where body text needs 4.5:1; at accessibility sizes text is large and needs only 3:1.
/// - **The largest accessibility size** — text clipping and hit regions, where layouts are most
///   stretched. The clipping check is a prediction ("may be clipped at larger sizes") even here; it found
///   the select cutting its value to one line (A11Y-5).
///
/// Every page of the showcase catalogue is audited except Foundations: it is a token specimen that pins
/// its own text sizes and labels swatches with token names. A new component's page joins `pages`. See
/// `docs/quality.md`.
final class AccessibilityAuditUITests: XCTestCase {
    static let pages = [
        "button", "icon-button", "text-field", "switch", "field", "textarea", "password-input", "otp-input", "checkbox",
        "radio-group", "select", "number-field", "form-patterns", "avatar", "badge", "text", "list-item", "search",
        "description-list", "chip", "timeline", "collection-patterns", "large-list", "progress", "spinner", "skeleton", "empty-state",
        "data-state", "toast", "alert-dialog", "confirmation-dialog", "sheet", "popover", "menu", "overlay-patterns", "tabs",
        "app-navigation", "card", "separator", "accordion",
    ]

    @MainActor
    func testLightTheme() {
        audit(theme: "light", size: nil, types: XCUIAccessibilityAuditType.all.subtracting(.textClipped), screens: 2)
    }

    @MainActor
    func testDarkTheme() {
        audit(theme: "dark", size: nil, types: .contrast, screens: 2)
    }

    @MainActor
    func testLargestAccessibilitySize() {
        audit(theme: "light", size: "UICTContentSizeCategoryAccessibilityXXXL", types: [.textClipped, .hitRegion], screens: 3)
    }

    /// The audit's Dynamic Type check reports text in `List` rows as not scaling — system text in a list
    /// footer included — so it is excluded there, and measured here instead: the same text,
    /// launched at the default size and at Accessibility Large, must be at least a quarter taller at the
    /// larger. Text that doesn't scale stays the same height; an element's frame can include fixed
    /// padding (a list footer's), which keeps the ratio below the text's own (measured 1.43 there).
    @MainActor
    func testTextInListsAndGridsScales() {
        let cases: [(page: String, text: String)] = [
            ("list-item", "admin@kaveri.in"),  // a List row's description; its title is also an avatar's name
            ("search", "search-submitted"),  // text in a list footer
        ]
        for (page, text) in cases {
            let regular = height(of: text, on: page, size: "UICTContentSizeCategoryL")
            let large = height(of: text, on: page, size: "UICTContentSizeCategoryAccessibilityL")
            XCTAssertGreaterThan(
                large, regular * 1.25, "\(page): “\(text)” is \(regular) pt tall at the default size and \(large) pt at Accessibility Large"
            )
        }
    }

    @MainActor
    private func height(of text: String, on page: String, size: String) -> CGFloat {
        let app = XCUIApplication()
        app.launchArguments += ["-page", page, "-theme", "light", "-UIPreferredContentSizeCategoryName", size]
        app.launch()
        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 10))
        let element = app.staticTexts[text].firstMatch
        let window = app.windows.firstMatch.frame
        for _ in 0..<10 where !(element.exists && window.contains(element.frame)) {
            app.swipeUp()
        }
        XCTAssertTrue(element.exists, "\(page): “\(text)” is on screen")
        let height = element.frame.height
        app.terminate()
        return height
    }

    // MARK: - Running the audit

    @MainActor
    private func audit(theme: String, size: String?, types: XCUIAccessibilityAuditType, screens: Int) {
        var reported = Set<String>()
        for page in Self.pages {
            let app = XCUIApplication()
            app.launchArguments += ["-page", page, "-theme", theme]
            if let size { app.launchArguments += ["-UIPreferredContentSizeCategoryName", size] }
            app.launch()
            XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 10), "\(page) opens")
            for screen in 0..<screens {
                let content = Self.contentArea(of: app)
                var failures: [(key: String, line: String)] = []
                // The Dynamic Type check runs on its own, after the others. In the same call it re-lays out the
                // text as it tries sizes, and the contrast check then measures a scrolled screen at the old
                // positions: every heading failed contrast (Phase 7, TEST-2). Contrast alone was clean.
                let passes = [types.subtracting(.dynamicType), types.intersection(.dynamicType)].filter { !$0.isEmpty }
                for pass in passes {
                    var completed = false
                    // A busy simulator can end an audit with "Audit failed to complete in time": run it again.
                    for _ in 0..<2 where !completed {
                        var found: [(key: String, line: String)] = []
                        do {
                            try app.performAccessibilityAudit(for: pass) { issue in
                                // Judged now, where the audit measured it: an element's frame is read when it is
                                // asked for, and after the Dynamic Type pass text under the bar had moved below it.
                                if Self.exclusion(for: issue, on: page, content: content) == nil {
                                    found.append(Self.failure(issue, on: page))
                                }
                                return true
                            }
                            failures += found
                            completed = true
                        } catch {
                            continue
                        }
                    }
                    XCTAssertTrue(completed, "The audit of \(page), screen \(screen + 1), completes")
                }
                for failure in failures where reported.insert(failure.key).inserted {
                    XCTFail(failure.line)
                }
                if screen < screens - 1 {
                    app.swipeUp()
                    Self.waitUntilStill(app)
                }
            }
            app.terminate()
        }
    }

    /// An issue as a failure message, and the key that reports it once per page.
    @MainActor
    private static func failure(_ issue: XCUIAccessibilityAuditIssue, on page: String) -> (key: String, line: String) {
        let element = issue.element.map { "“\($0.label)” (\($0.elementType.rawValue)) at \($0.frame.integral)" } ?? "no element"
        return ("\(page)|\(issue.auditType.rawValue)|\(issue.element?.label ?? "")", "\(page): \(issue.compactDescription) — \(element)")
    }

    /// Waits until two screenshots a quarter-second apart are identical, at most `timeout` seconds. A
    /// flung list keeps decelerating after `swipeUp()` returns — the 5,000-row list for about 2.4 s — and an
    /// audit of moving content measured rows as they were recycled (Phase 7, TEST-2). Pages that animate
    /// for good (spinners, skeletons) reach the timeout and are audited as they are.
    @MainActor
    private static func waitUntilStill(_ app: XCUIApplication, timeout: TimeInterval = 5) {
        var previous = app.screenshot().pngRepresentation
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            Thread.sleep(forTimeInterval: 0.25)
            let current = app.screenshot().pngRepresentation
            if current == previous { return }
            previous = current
        }
    }

    /// The part of the window between the navigation bar and the bottom edge. The audit measures an
    /// element's colours from the screen, so it can't measure what a bar covers or what is off screen.
    @MainActor
    private static func contentArea(of app: XCUIApplication) -> CGRect {
        let window = app.windows.firstMatch.frame
        let bar = app.navigationBars.firstMatch
        let top = bar.exists ? bar.frame.maxY : window.minY
        return CGRect(x: window.minX, y: top, width: window.width, height: window.maxY - top)
    }

    // MARK: - Exclusions

    /// Why an issue is not a defect, or nil when it is one.
    @MainActor
    static func exclusion(for issue: XCUIAccessibilityAuditIssue, on page: String, content: CGRect) -> String? {
        let element = issue.element
        let label = element?.label ?? ""
        let type = issue.auditType

        if element?.elementType == .searchField {
            return "The search field is the system's (`searchable`): its drawing and type are UIKit's."
        }
        if type == .textClipped, [.switch, .toggle, .textField, .secureTextField].contains(element?.elementType) {
            return "A prediction (“may be clipped at larger sizes”): toggle labels wrap and their rows grow (103 and 111 pt "
                + "at the largest size), and a text field's line scrolls. Nothing is cut in the screenshots."
        }
        if type == .elementDetection, element == nil, ["number-field", "otp-input", "form-patterns"].contains(page) {
            return
                "Drawn glyphs the audit reads as text: the steppers' + and −, which are the Increase and Decrease buttons, and the one-time-code cells, whose code is the field's value."
        }
        if type == .dynamicType, ["list-item", "search", "collection-patterns", "large-list"].contains(page) {
            return
                "Text in a List, system text included: the audit can't follow the size it sets into lazy content. testTextInListsAndGridsScales measures it scaling."
        }
        if type == .contrast || type == .textClipped, let frame = element?.frame, !content.contains(frame) {
            return "Under the navigation bar or off screen when measured: the audit reads colours from the screen."
        }
        if type == .contrast || type == .textClipped, page == "description-list", element?.elementType == .staticText {
            return "A pair's VoiceOver element is an undrawn stand-in over the drawn term and value, which are hidden from "
                + "VoiceOver; the audit samples the screen where the stand-in's text would be. The drawn colours are "
                + "AccessibilityTests'."
        }
        if type == .contrast, page == "collection-patterns", label == "Show archived" {
            return "The chip is its List row's only element, so its frame is the whole row and the audit samples the row's "
                + "empty background. The chip's colours are measured on the chip page."
        }
        if type == .contrast, element == nil, page == "list-item" {
            return "The disabled row: in a diagnostic run the same issue resolved to its “Archived workspace” and “Read-only” text."
        }
        if type == .contrast, element?.isEnabled == false || disabledDemos.contains(where: { $0 == (page, label) }) {
            return "A disabled control: WCAG 1.4.3 exempts inactive components; disabled is drawn at 50% opacity, as on the web."
        }
        if type == .dynamicType, ["avatar", "list-item"].contains(page), (1...2).contains(label.count), label.allSatisfy(\.isUppercase) {
            return "Avatar initials: drawn to fit the avatar's fixed size, as on the web; the avatar's VoiceOver label is the name."
        }
        let isBusyIndicator = ["spinner", "data-state"].contains(page) && label.hasPrefix("Loading")
        if type == .hitRegion, [.staticText, .image].contains(element?.elementType) || isBusyIndicator {
            return "Not a control: text, an image or a busy indicator has nothing to tap."
        }
        if type == .hitRegion, page == "textarea", element?.elementType == .textField {
            return "The audit measures the one-line text view; a tap anywhere in the box focuses the field (TextareaUITests)."
        }
        if type == .sufficientElementDescription, page == "text-field", label == "Available." {
            return "A field's message, “Available.”, is a sentence; the audit's readability heuristic misreads it."
        }
        if type == .sufficientElementDescription, page == "text", label == "navigator.credentials.create()" {
            return "The inline-code specimen: code, which VoiceOver reads as written; the heuristic expects prose."
        }
        return nil
    }

    /// Text of controls the showcase shows disabled, which the audit measures without knowing the
    /// control is disabled.
    static let disabledDemos: [(String, String)] = [
        ("button", "Unavailable"),
        ("list-item", "Read-only"),
        ("list-item", "Archived workspace"),
        ("radio-group", "Talk to sales"),
        ("tabs", "Archive"),
        ("otp-input", "One-time code"),
        ("switch", "Managed by your organisation"),
        ("checkbox", "Managed by your organisation"),
        ("textarea", "Archived note"),
        ("text-field", "Archived note"),
    ]
}
