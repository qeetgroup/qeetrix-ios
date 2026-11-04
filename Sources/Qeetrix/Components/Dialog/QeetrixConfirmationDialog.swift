import SwiftUI

/// A choice among actions that follow from what the person just did — "Delete", "Archive", "Cancel" —
/// presented as the system confirmation dialog, anchored to the view the modifier is on. Attach it to the
/// control that opens it.
///
/// ```swift
/// @State private var confirmation: QeetrixConfirmationDialog?
///
/// Button("Remove member") {
///     confirmation = QeetrixConfirmationDialog(
///         "Remove Asha from the team?",
///         actions: [QeetrixDialogAction("Remove", role: .destructive) { removeMember() }])
/// }
/// .qeetrixConfirmationDialog($confirmation)
/// ```
///
/// As with ``QeetrixAlertDialog``, one optional value is the state and each action runs once, after
/// dismissal. Cancelling is always possible: a tap outside cancels, and where the system shows a Cancel
/// button it is the cancel action — yours, or the one added beside a destructive action. Use an alert
/// instead when the person must stop and decide; this dialog is for choosing what to do next.
public struct QeetrixConfirmationDialog: Identifiable {
    public let id = UUID()
    public let title: Text
    public let message: Text?
    public let actions: [QeetrixDialogAction]

    /// A confirmation dialog with a localised title, shown above its actions.
    public init(_ titleKey: LocalizedStringKey, message: Text? = nil, actions: [QeetrixDialogAction]) {
        self.init(title: Text(titleKey), message: message, actions: actions)
    }

    /// A confirmation dialog with a title shown as given, without localisation.
    public init<S: StringProtocol>(_ title: S, message: Text? = nil, actions: [QeetrixDialogAction]) {
        self.init(title: Text(title), message: message, actions: actions)
    }

    /// A confirmation dialog with a `Text` title.
    public init(title: Text, message: Text? = nil, actions: [QeetrixDialogAction]) {
        self.title = title
        self.message = message
        self.actions = actions
    }
}

extension View {
    /// Presents `dialog` while it is not `nil`, anchored to this view, and sets it back to `nil` when it is
    /// dismissed.
    public func qeetrixConfirmationDialog(_ dialog: Binding<QeetrixConfirmationDialog?>) -> some View {
        confirmationDialog(
            dialog.wrappedValue?.title ?? Text(verbatim: ""),
            isPresented: Binding(get: { dialog.wrappedValue != nil }, set: { if !$0 { dialog.wrappedValue = nil } }),
            titleVisibility: .visible,
            presenting: dialog.wrappedValue
        ) { presented in
            QeetrixDialogButtons(actions: presented.actions, presentation: dialog)
        } message: { presented in
            if let message = presented.message { message }
        }
    }
}
