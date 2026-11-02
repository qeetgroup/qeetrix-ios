import SwiftUI
import Testing

@testable import Qeetrix

#if os(macOS)
    import AppKit
#endif

@MainActor
@Suite("Swipe actions")
struct SwipeActionsTests {
    @Test("Tones are qeetrix-android's, by its shared names: neutral, brand and danger")
    func tones() {
        #expect(QeetrixSwipeActionTone.allCases.map(\.rawValue) == ["neutral", "brand", "danger"])
        #expect(QeetrixSwipeAction("Archive", icon: .archive) {}.tone == .neutral, "Neutral by default")
    }

    @Test("Fills: Ember and the danger fill in both schemes; warm graphite in light, the darkest neutral fill in dark")
    func fills() {
        #expect(QeetrixSwipeActionTone.neutral.fill(.light) == .bgNeutralBold)
        #expect(QeetrixSwipeActionTone.neutral.fill(.dark) == .bgNeutralSubtlePressed)
        for scheme in [ColorScheme.light, .dark] {
            #expect(QeetrixSwipeActionTone.brand.fill(scheme) == .bgBrandBold)
            #expect(QeetrixSwipeActionTone.danger.fill(scheme) == .bgDangerBold)
        }
        #expect(QeetrixSwipeActionsMetrics.iconSize.points == 20, "qeetrix-android: size.icon.md")
    }

    @Test("iOS draws the icon and title white: every fill keeps 4.5:1 with it, in both schemes")
    func contrast() {
        for theme in [QeetrixTheme.light, .dark] {
            let white = theme.resolve(.textOnBold)
            for tone in QeetrixSwipeActionTone.allCases {
                let ratio = QeetrixAccessibility.contrastRatio(white, on: theme.resolve(tone.fill(theme.colorScheme)))
                #expect(ratio >= 4.5, "\(tone) \(theme.colorScheme): \(ratio)")
            }
        }
        // Why dark neutral isn't warm graphite: in dark it is light, and white on it is unreadable.
        let dark = QeetrixTheme.dark
        #expect(QeetrixAccessibility.contrastRatio(dark.resolve(.textOnBold), on: dark.resolve(.bgNeutralBold)) < 3)
    }

    @Test("A danger action always asks first; another tone only when it has a question")
    func asksFirst() {
        #expect(QeetrixSwipeAction("Remove", icon: .trash, tone: .danger) {}.asksFirst)
        #expect(QeetrixSwipeAction("Remove", icon: .trash, tone: .danger, confirmation: Text("Remove Acme?")) {}.asksFirst)
        #expect(!QeetrixSwipeAction("Archive", icon: .archive) {}.asksFirst)
        #expect(!QeetrixSwipeAction("Approve", icon: .check, tone: .brand) {}.asksFirst)
        #expect(QeetrixSwipeAction("Sign out", icon: .x, confirmation: Text("Sign out of Acme?")) {}.asksFirst)
    }

    @Test("A danger action's dialog: its question and line, its title as the destructive button, then Cancel")
    func dangerDialog() {
        let remove = QeetrixSwipeAction(
            "Remove", icon: .trash, tone: .danger, confirmation: Text("Remove Acme from this phone?"),
            confirmationMessage: Text("You'll need a new QR code to add it again.")
        ) {}
        let dialog = remove.confirmationDialog
        #expect(dialog.message != nil)
        #expect(dialog.actions.map(\.role) == [.destructive])
        // The dialog adds its own Cancel beside a destructive action (ADR 0014).
        #expect(QeetrixDialogAction.resolved(dialog.actions).map(\.role) == [.destructive, .cancel])
        // Without a question, the dialog asks with the action's title.
        let bare = QeetrixSwipeAction("Remove", icon: .trash, tone: .danger) {}.confirmationDialog
        #expect(bare.message == nil)
        #expect(bare.actions.map(\.role) == [.destructive])
    }

    @Test("Another tone's dialog: its title as a plain button, and a Cancel of its own")
    func plainDialog() {
        let signOut = QeetrixSwipeAction("Sign out", icon: .x, confirmation: Text("Sign out of Acme?")) {}.confirmationDialog
        #expect(signOut.actions.map(\.role) == [nil, .cancel])
        #expect(QeetrixDialogAction.resolved(signOut.actions).count == 2, "Nothing more is added")
    }

    @Test("The dialog runs the action once, after it has gone")
    func runsOnceAfterDismissal() throws {
        final class Box {
            var dialog: QeetrixConfirmationDialog?
            var runs = 0
            var clearedFirst = false
        }
        let box = Box()
        let remove = QeetrixSwipeAction("Remove", icon: .trash, tone: .danger) {
            box.runs += 1
            box.clearedFirst = box.dialog == nil
        }
        box.dialog = remove.confirmationDialog
        let button = try #require(box.dialog?.actions.first)
        button.trigger(dismissing: Binding(get: { box.dialog }, set: { box.dialog = $0 }))
        #expect(box.dialog == nil)
        #expect(box.runs == 1)
        #expect(box.clearedFirst, "The action sees the dialog gone, and may present another")
    }

    @Test("The menu lists the other actions in order, then the danger ones")
    func menuOrder() {
        let actions = [
            QeetrixSwipeAction("Deny", icon: .x, tone: .danger) {},
            QeetrixSwipeAction("Approve", icon: .check, tone: .brand) {},
            QeetrixSwipeAction("Later", icon: .clock) {},
        ]
        let groups = QeetrixSwipeActionsMetrics.menuGroups(actions)
        #expect(groups.actions.map(\.tone) == [.brand, .neutral])
        #expect(groups.destructive.map(\.tone) == [.danger])
    }

    #if os(macOS)
        @Test("Without swiping: VoiceOver offers every action of both edges on the row")
        func voiceOverActions() {
            let row = QeetrixListItem("Qeet Pay console", description: Text("Bengaluru"))
                .qeetrixSwipeActions(
                    leading: [QeetrixSwipeAction("Approve", icon: .check, tone: .brand) {}],
                    trailing: [QeetrixSwipeAction("Deny", icon: .x, tone: .danger) {}, QeetrixSwipeAction("Later", icon: .clock) {}])
            let elements = ListsAccessibilityTree.elements(of: row)
            #expect(elements.count == 1, "\(elements)")
            #expect(Set(elements.first?.actions ?? []) == ["Approve", "Deny", "Later"], "\(elements)")
            let button = ListsAccessibilityTree.elements(
                of: QeetrixListItem("Acme", action: {}).qeetrixSwipeActions(actions: [QeetrixSwipeAction("Remove", icon: .trash) {}]))
            #expect(button.map(\.role) == ["AXButton"])
            #expect(button.first?.actions == ["Remove"])
        }

        @Test("A disabled row offers no actions")
        func disabledRow() {
            let elements = ListsAccessibilityTree.elements(
                of: QeetrixListItem("Acme").qeetrixSwipeActions(actions: [QeetrixSwipeAction("Remove", icon: .trash) {}]).disabled(true))
            #expect(elements.first?.actions == [], "\(elements)")
        }

        @Test("A VoiceOver action runs a plain action at once, and only asks for a danger one")
        func voiceOverRuns() throws {
            final class Counter {
                var archived = 0
                var removed = 0
            }
            let counter = Counter()
            let row = QeetrixListItem("Acme")
                .qeetrixSwipeActions(actions: [
                    QeetrixSwipeAction("Archive", icon: .archive) { counter.archived += 1 },
                    QeetrixSwipeAction("Remove", icon: .trash, tone: .danger) { counter.removed += 1 },
                ])
            let actions = SwipeActionsAccessibility.customActions(of: row)
            try #require(actions.map(\.name).sorted() == ["Archive", "Remove"])
            _ = actions.first { $0.name == "Archive" }?.handler?()
            #expect(counter.archived == 1)
            _ = actions.first { $0.name == "Remove" }?.handler?()
            #expect(counter.removed == 0, "Remove asks first: it runs from the dialog")
        }
    #endif

    @Test("Rows with actions render as before, in both schemes and in a List")
    func renders() {
        let remove = QeetrixSwipeAction("Remove", icon: .trash, tone: .danger, confirmation: Text("Remove Acme?")) {}
        for scheme in [ColorScheme.light, .dark] {
            let row = QeetrixListItem("Acme", description: Text(verbatim: "priya@acme.in")).qeetrixSwipeActions(actions: [remove])
            #expect(ImageRenderer(content: row.frame(width: 390).environment(\.colorScheme, scheme)).cgImage != nil)
            let list = List {
                QeetrixListItem("Acme").qeetrixSwipeActions(
                    leading: [QeetrixSwipeAction("Pin", icon: .pin, tone: .brand) {}], trailing: [remove])
            }
            .qeetrixListStyle()
            #expect(ImageRenderer(content: list.frame(width: 390, height: 100).environment(\.colorScheme, scheme)).cgImage != nil)
        }
        // The modifier draws nothing of its own: the row looks the same with it.
        let plain = Rendered(QeetrixListItem("Acme").frame(width: 200).environment(\.colorScheme, .light))
        let swiped = Rendered(
            QeetrixListItem("Acme").qeetrixSwipeActions(actions: [remove]).frame(width: 200).environment(\.colorScheme, .light))
        #expect(plain?.height == swiped?.height)
    }
}

#if os(macOS)
    /// The custom actions SwiftUI gives the one accessibility element of `view`, read from AppKit's
    /// tree on the Mac host, with their handlers, so a test can run them as VoiceOver would.
    @MainActor
    enum SwipeActionsAccessibility {
        static func customActions(of view: some View, width: CGFloat = 390) -> [NSAccessibilityCustomAction] {
            _ = NSApplication.shared.perform(
                NSSelectorFromString("accessibilitySetValue:forAttribute:"), with: NSNumber(value: true), with: "AXEnhancedUserInterface")
            let host = NSHostingView(rootView: view.frame(width: width))
            host.frame = NSRect(x: 0, y: 0, width: width, height: max(host.fittingSize.height, 1))
            let window = NSWindow(contentRect: host.frame, styleMask: [.titled], backing: .buffered, defer: false)
            window.contentView = host
            host.layout()
            defer { window.contentView = nil }
            return collect(host)
        }

        private static func collect(_ node: Any) -> [NSAccessibilityCustomAction] {
            guard let object = node as? NSObject else { return [] }
            func value(_ key: String) -> Any? {
                object.responds(to: NSSelectorFromString(key)) ? object.value(forKey: key) : nil
            }
            let own = value("accessibilityCustomActions") as? [NSAccessibilityCustomAction] ?? []
            let children = value("accessibilityChildren") as? [Any] ?? []
            return own + children.flatMap(collect)
        }
    }
#endif
