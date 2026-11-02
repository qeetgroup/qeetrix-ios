#if os(macOS)
    import AppKit
    import SwiftUI

    /// One accessibility element SwiftUI made of a view: what VoiceOver stops on. Read from AppKit's
    /// tree on the Mac host, where SwiftUI builds the same elements it builds for UIKit; the speech
    /// itself stays on the device checklist (ACCESSIBILITY.md).
    struct ListsAccessibilityElement: CustomStringConvertible {
        /// `AXButton`, `AXStaticText`, `AXCheckBox`, `AXHeading`, …
        let role: String
        /// The element's name: its label, or a static text's text.
        let text: String
        let value: String?
        let isSelected: Bool
        /// The names of the custom actions VoiceOver offers on it.
        let actions: [String]

        var description: String {
            "\(role) \"\(text)\"" + (value.map { " = \($0)" } ?? "") + (isSelected ? " selected" : "")
                + (actions.isEmpty ? "" : " actions \(actions)")
        }
    }

    @MainActor
    enum ListsAccessibilityTree {
        /// The elements of `view`, laid out at `width`, in tree order. Containers are walked, not listed.
        static func elements(of view: some View, width: CGFloat = 390) -> [ListsAccessibilityElement] {
            // Set as an assistive app connecting would (SwiftUI builds the tree only for one), through the
            // attribute setter AppKit still answers.
            _ = NSApplication.shared.perform(
                NSSelectorFromString("accessibilitySetValue:forAttribute:"), with: NSNumber(value: true), with: "AXEnhancedUserInterface")
            let host = NSHostingView(rootView: view.frame(width: width).environment(\.locale, Locale(identifier: "en")))
            host.frame = NSRect(x: 0, y: 0, width: width, height: max(host.fittingSize.height, 1))
            let window = NSWindow(contentRect: host.frame, styleMask: [.titled], backing: .buffered, defer: false)
            window.contentView = host
            host.layout()
            var elements: [ListsAccessibilityElement] = []
            walk(host, into: &elements)
            window.contentView = nil
            return elements
        }

        private static func walk(_ node: Any, into elements: inout [ListsAccessibilityElement]) {
            guard let object = node as? NSObject else { return }
            func string(_ key: String) -> String? {
                guard object.responds(to: NSSelectorFromString(key)) else { return nil }
                return (object.value(forKey: key) as? String).flatMap { $0.isEmpty ? nil : $0 }
            }
            func anyValue(_ key: String) -> Any? {
                guard object.responds(to: NSSelectorFromString(key)) else { return nil }
                return object.value(forKey: key)
            }
            let role = anyValue("accessibilityRole").map { "\($0)" } ?? ""
            let children = anyValue("accessibilityChildren") as? [Any] ?? []
            if role != "AXGroup" && !(object is NSView) {
                let label = string("accessibilityLabel")
                let value = anyValue("accessibilityValue").map { "\($0)" }
                let isStaticText = role == "AXStaticText"
                let actions = (anyValue("accessibilityCustomActions") as? [NSAccessibilityCustomAction] ?? []).map(\.name)
                elements.append(
                    ListsAccessibilityElement(
                        role: role,
                        text: (isStaticText ? value : label) ?? label ?? "",
                        value: isStaticText ? nil : value,
                        isSelected: object.responds(to: NSSelectorFromString("isAccessibilitySelected"))
                            && object.value(forKey: "accessibilitySelected") as? Bool == true,
                        actions: actions))
            }
            for child in children { walk(child, into: &elements) }
        }
    }
#endif
