import SwiftUI

/// The colour of a ``QeetrixSwipeAction``: the fill iOS draws the action in, behind its icon and title,
/// as qeetrix-android's `QeetrixSwipeActionTone`.
public enum QeetrixSwipeActionTone: String, CaseIterable, Sendable {
    /// Warm graphite: archive, mute, snooze. The default.
    case neutral
    /// Ember: the row's one constructive action, such as Approve.
    case brand
    /// The danger fill: remove, delete, deny. A danger action asks before it runs.
    case danger
}

/// One action on a list row — revealed by swiping the row, and always offered without swiping too:
/// as a VoiceOver action of the row and in the row's context menu.
///
/// ```swift
/// QeetrixListItem("Acme", description: Text(verbatim: "priya@acme.in")) {
///     QeetrixAvatar(name: "Acme", shape: .square, isDecorative: true)
/// }
/// .qeetrixSwipeActions(actions: [
///     QeetrixSwipeAction(
///         "Remove", icon: .trash, tone: .danger, confirmation: Text("Remove Acme from this phone?"),
///         confirmationMessage: Text("You'll need a new QR code to add it again.")
///     ) { remove(acme) }
/// ])
/// ```
///
/// Write the title as a verb: it is the action's label when the row is tall enough to show one, its
/// VoiceOver name, its menu item and the dialog's button. A `.danger` action always asks first, in a
/// ``QeetrixConfirmationDialog`` whose destructive button is the action's title beside Cancel, and runs
/// once the dialog has gone (ADR 0014); give it its question in `confirmation`. Another tone runs at
/// once, unless you give it a `confirmation` too.
public struct QeetrixSwipeAction {
    /// What the action does, as a verb: "Remove", "Approve".
    public let title: Text
    /// The icon iOS shows on the action; also the menu item's icon. Drawn sharp at 20 pt.
    public let icon: QeetrixIconName
    /// The action's fill.
    public let tone: QeetrixSwipeActionTone
    /// The question the action asks before it runs, as the confirmation dialog's title.
    public let confirmation: Text?
    /// A line under the question: what follows from the choice.
    public let confirmationMessage: Text?
    let perform: @MainActor () -> Void

    /// An action with a localised title.
    ///
    /// - Parameters:
    ///   - titleKey: What the action does, as a verb.
    ///   - icon: The action's icon, drawn sharp. Choose one without a direction: system chrome doesn't
    ///     mirror images in right-to-left layouts.
    ///   - tone: The fill; `.danger` asks before the action runs.
    ///   - confirmation: The question asked first. A `.danger` action asks with its title when it has
    ///     none; another tone asks only when given one.
    ///   - confirmationMessage: A line under the question.
    ///   - action: What the action does. It runs once: after the dialog has gone, when it asks first.
    public init(
        _ titleKey: LocalizedStringKey, icon: QeetrixIconName, tone: QeetrixSwipeActionTone = .neutral, confirmation: Text? = nil,
        confirmationMessage: Text? = nil, action: @escaping @MainActor () -> Void
    ) {
        self.init(
            title: Text(titleKey), icon: icon, tone: tone, confirmation: confirmation, confirmationMessage: confirmationMessage,
            action: action)
    }

    /// An action with a title shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S, icon: QeetrixIconName, tone: QeetrixSwipeActionTone = .neutral, confirmation: Text? = nil,
        confirmationMessage: Text? = nil, action: @escaping @MainActor () -> Void
    ) {
        self.init(
            title: Text(title), icon: icon, tone: tone, confirmation: confirmation, confirmationMessage: confirmationMessage,
            action: action)
    }

    /// An action with a `Text` title.
    public init(
        title: Text, icon: QeetrixIconName, tone: QeetrixSwipeActionTone = .neutral, confirmation: Text? = nil,
        confirmationMessage: Text? = nil, action: @escaping @MainActor () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.tone = tone
        self.confirmation = confirmation
        self.confirmationMessage = confirmationMessage
        perform = action
    }

    /// Whether the action asks before it runs: a danger action always does; another when it has a
    /// question.
    var asksFirst: Bool {
        tone == .danger || confirmation != nil
    }

    /// The dialog the action asks in: its question (or its title), its line, and its title as the
    /// button — destructive for a danger action, which gets the dialog's own Cancel beside it.
    var confirmationDialog: QeetrixConfirmationDialog {
        let isDestructive = tone == .danger
        var actions = [QeetrixDialogAction(title: title, role: isDestructive ? .destructive : nil, action: perform)]
        if !isDestructive {
            actions.append(QeetrixDialogAction(title: QeetrixStrings.cancel, role: .cancel))
        }
        return QeetrixConfirmationDialog(title: confirmation ?? title, message: confirmationMessage, actions: actions)
    }
}

extension View {
    /// Gives a list row actions on one edge: revealed by swiping the row, the first run by a full swipe,
    /// and offered without swiping as VoiceOver actions of the row and in its context menu.
    ///
    /// ```swift
    /// List(accounts) { account in
    ///     QeetrixListItem(account.issuer, description: Text(account.email))
    ///         .qeetrixSwipeActions(actions: [
    ///             QeetrixSwipeAction("Remove", icon: .trash, tone: .danger, confirmation: Text("Remove \(account.issuer)?")) {
    ///                 remove(account)
    ///             }
    ///         ])
    /// }
    /// .qeetrixListStyle()
    /// ```
    ///
    /// The swipe is the system's `swipeActions(edge:allowsFullSwipe:content:)`, so it works on the rows
    /// of a `List`: iOS draws each action in its tone's fill with its icon (and, on a tall enough row,
    /// its title) in white, and taps as a full swipe reaches the first action; Qeetrix adds no haptic.
    /// Apply the modifier once per row; for actions on both edges, use
    /// `qeetrixSwipeActions(leading:trailing:allowsFullSwipe:)`.
    ///
    /// - Parameters:
    ///   - edge: The edge the actions come from: `.trailing`, the default, or `.leading`. It follows the
    ///     reading direction.
    ///   - allowsFullSwipe: Whether a full swipe runs the first action — after its question, for one that
    ///     asks first.
    ///   - actions: The actions, the first at the screen's edge: the one a full swipe runs.
    public func qeetrixSwipeActions(
        edge: HorizontalEdge = .trailing, allowsFullSwipe: Bool = true, actions: [QeetrixSwipeAction]
    ) -> some View {
        modifier(
            QeetrixSwipeActionsModifier(
                leading: edge == .leading ? actions : [], trailing: edge == .trailing ? actions : [], allowsFullSwipe: allowsFullSwipe))
    }

    /// Gives a list row actions on both edges — Approve at the start, Deny at the end — each edge's
    /// first run by a full swipe; the row's VoiceOver actions and context menu offer all of them.
    ///
    /// ```swift
    /// QeetrixListItem(request.app, description: Text(request.place))
    ///     .qeetrixSwipeActions(
    ///         leading: [QeetrixSwipeAction("Approve", icon: .check, tone: .brand) { approve(request) }],
    ///         trailing: [
    ///             QeetrixSwipeAction("Deny", icon: .x, tone: .danger, confirmation: Text("Deny this sign-in?")) { deny(request) }
    ///         ]
    ///     )
    /// ```
    public func qeetrixSwipeActions(
        leading: [QeetrixSwipeAction], trailing: [QeetrixSwipeAction], allowsFullSwipe: Bool = true
    ) -> some View {
        modifier(QeetrixSwipeActionsModifier(leading: leading, trailing: trailing, allowsFullSwipe: allowsFullSwipe))
    }
}

/// One list of actions feeding the swipe, the row's VoiceOver actions and its context menu, and the
/// confirmation dialog an action that asks first opens.
struct QeetrixSwipeActionsModifier: ViewModifier {
    let leading: [QeetrixSwipeAction]
    let trailing: [QeetrixSwipeAction]
    let allowsFullSwipe: Bool
    @State private var dialog: QeetrixConfirmationDialog?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled

    func body(content: Content) -> some View {
        // A disabled row offers no actions, whichever way they are reached.
        let leading = isEnabled ? leading : []
        let trailing = isEnabled ? trailing : []
        let all = leading + trailing
        content
            .swipeActions(edge: .leading, allowsFullSwipe: allowsFullSwipe) { buttons(leading) }
            .swipeActions(edge: .trailing, allowsFullSwipe: allowsFullSwipe) { buttons(trailing) }
            .contextMenu {
                let groups = QeetrixSwipeActionsMetrics.menuGroups(all)
                items(groups.actions)
                if !groups.actions.isEmpty && !groups.destructive.isEmpty {
                    Divider()
                }
                items(groups.destructive)
            }
            // SwiftUI also offers a List row's swipe actions to VoiceOver; it lists an action of the
            // same name once.
            .accessibilityActions {
                ForEach(Array(all.enumerated()), id: \.offset) { _, action in
                    Button {
                        run(action)
                    } label: {
                        action.title
                    }
                }
            }
            .qeetrixConfirmationDialog($dialog)
    }

    /// The actions as the system's swipe buttons: each tinted its tone's fill, with its icon and title.
    /// No button takes the destructive role, which would have the list slide the row away before the
    /// person has answered the question.
    private func buttons(_ actions: [QeetrixSwipeAction]) -> some View {
        // By position: actions are values without an identity, rebuilt with the row.
        ForEach(Array(actions.enumerated()), id: \.offset) { _, action in
            Button {
                run(action)
            } label: {
                Label {
                    action.title
                } icon: {
                    Image(qeetrix: action.icon, size: QeetrixSwipeActionsMetrics.iconSize, shape: .sharp)
                }
            }
            // A Color, not the style: the system resolves the tint into its own drawing.
            .tint(action.tone.fill(colorScheme).color(for: colorScheme))
        }
    }

    /// The actions as context menu items, with their icons; a danger one in the menu's destructive
    /// colour.
    private func items(_ actions: [QeetrixSwipeAction]) -> some View {
        ForEach(Array(actions.enumerated()), id: \.offset) { _, action in
            QeetrixMenuItem(title: action.title, icon: action.icon, tone: action.tone == .danger ? .danger : .default) {
                run(action)
            }
        }
    }

    /// Runs the action, or asks its question first.
    private func run(_ action: QeetrixSwipeAction) {
        if action.asksFirst {
            dialog = action.confirmationDialog
        } else {
            action.perform()
        }
    }
}

extension QeetrixSwipeActionTone {
    /// The action's fill. iOS draws every swipe action's icon and title white (`color.text.on-bold`), so
    /// each tone's fill is one white reads on: the danger fill and Ember in both schemes, and warm
    /// graphite (`color.bg.neutral.bold`) in light. In dark, warm graphite turns light and takes only
    /// `color.text.inverse` (design rules §4), so neutral is the darkest neutral fill there,
    /// `color.bg.neutral.subtle-pressed`.
    func fill(_ colorScheme: ColorScheme) -> QeetrixColor {
        switch self {
        case .neutral: colorScheme == .dark ? .bgNeutralSubtlePressed : .bgNeutralBold
        case .brand: .bgBrandBold
        case .danger: .bgDangerBold
        }
    }
}

/// The swipe actions' metrics and order.
enum QeetrixSwipeActionsMetrics {
    /// qeetrix-android's action icon: `size.icon.md`.
    static let iconSize = QeetrixIconSize.md

    /// The context menu's items: the other actions in their order, then the danger ones after a divider,
    /// as a menu puts destructive items last.
    static func menuGroups(_ actions: [QeetrixSwipeAction]) -> (actions: [QeetrixSwipeAction], destructive: [QeetrixSwipeAction]) {
        (actions.filter { $0.tone != .danger }, actions.filter { $0.tone == .danger })
    }
}
