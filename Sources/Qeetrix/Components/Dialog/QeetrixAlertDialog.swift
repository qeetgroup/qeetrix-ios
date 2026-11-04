import SwiftUI

/// An alert that interrupts to ask for a decision or to report something that needs one —
/// `@qeetrix/react`'s Dialog with a `danger` or `warning` intent (an alert dialog), presented as the
/// system alert.
///
/// Describe the alert as a value and present it by setting it:
///
/// ```swift
/// @State private var alert: QeetrixAlertDialog?
///
/// Button("Delete workspace") {
///     alert = QeetrixAlertDialog(
///         "Delete this workspace?",
///         message: Text("Its projects and files are removed for everyone."),
///         actions: [QeetrixDialogAction("Delete", role: .destructive) { deleteWorkspace() }])
/// }
/// .qeetrixAlertDialog($alert)
/// ```
///
/// - One optional value is the whole state: `nil` is dismissed, a value is shown with its content, so the
///   presentation and its data never disagree.
/// - Each button clears the value, then runs its action once.
/// - An alert with a destructive action and no cancel gets "Cancel", so the safe choice is always there.
///
/// It is the system alert: iOS draws it, places the buttons, takes the keyboard (Return and Escape) and
/// gives VoiceOver a modal it announces. Its fonts and surface are the system's, not Qeetrix's; only the
/// tint reaches it. For an outcome that needs no decision, use a ``QeetrixToast``; for a choice among
/// several actions, a ``QeetrixConfirmationDialog``.
public struct QeetrixAlertDialog: Identifiable {
    public let id = UUID()
    public let title: Text
    public let message: Text?
    public let actions: [QeetrixDialogAction]

    /// An alert with a localised title.
    ///
    /// - Parameters:
    ///   - titleKey: The title, looked up in the main bundle.
    ///   - message: Text under the title.
    ///   - actions: The buttons, in order. With none, the system shows an OK button.
    public init(_ titleKey: LocalizedStringKey, message: Text? = nil, actions: [QeetrixDialogAction] = []) {
        self.init(title: Text(titleKey), message: message, actions: actions)
    }

    /// An alert with a title shown as given, without localisation.
    public init<S: StringProtocol>(_ title: S, message: Text? = nil, actions: [QeetrixDialogAction] = []) {
        self.init(title: Text(title), message: message, actions: actions)
    }

    /// An alert with a `Text` title.
    public init(title: Text, message: Text? = nil, actions: [QeetrixDialogAction] = []) {
        self.title = title
        self.message = message
        self.actions = actions
    }
}

extension View {
    /// Presents `alert` while it is not `nil`, and sets it back to `nil` when it is dismissed.
    public func qeetrixAlertDialog(_ alert: Binding<QeetrixAlertDialog?>) -> some View {
        self.alert(
            alert.wrappedValue?.title ?? Text(verbatim: ""),
            isPresented: Binding(get: { alert.wrappedValue != nil }, set: { if !$0 { alert.wrappedValue = nil } }),
            presenting: alert.wrappedValue
        ) { presented in
            QeetrixDialogButtons(actions: presented.actions, presentation: alert)
        } message: { presented in
            if let message = presented.message { message }
        }
    }
}
