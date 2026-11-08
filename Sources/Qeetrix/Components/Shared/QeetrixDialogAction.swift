import SwiftUI

/// One button of a ``QeetrixAlertDialog`` or a ``QeetrixConfirmationDialog``: its title, its role, and what
/// it does.
///
/// The role is the system's `ButtonRole`: `.destructive` draws the button in the destructive style and
/// VoiceOver says so; `.cancel` makes it the dismiss action. The action runs once, after the dialog is
/// dismissed.
public struct QeetrixDialogAction: Identifiable {
    public let id = UUID()
    public let title: Text
    public let role: ButtonRole?
    let perform: @MainActor () -> Void

    /// An action with a localised title.
    public init(_ titleKey: LocalizedStringKey, role: ButtonRole? = nil, action: @escaping @MainActor () -> Void = {}) {
        self.init(title: Text(titleKey), role: role, action: action)
    }

    /// An action with a title shown as given, without localisation.
    public init<S: StringProtocol>(_ title: S, role: ButtonRole? = nil, action: @escaping @MainActor () -> Void = {}) {
        self.init(title: Text(title), role: role, action: action)
    }

    /// An action with a `Text` title.
    public init(title: Text, role: ButtonRole? = nil, action: @escaping @MainActor () -> Void = {}) {
        self.title = title
        self.role = role
        perform = action
    }
}

extension QeetrixDialogAction {
    /// The dialog's actions as the system receives them: a dialog that offers a destructive action and no
    /// cancel gets a "Cancel", so the safe choice is always there.
    static func resolved(_ actions: [QeetrixDialogAction]) -> [QeetrixDialogAction] {
        let hasDestructive = actions.contains { $0.role == .destructive }
        let hasCancel = actions.contains { $0.role == .cancel }
        guard hasDestructive && !hasCancel else { return actions }
        return actions + [QeetrixDialogAction(title: QeetrixStrings.cancel, role: .cancel)]
    }

    /// What a tap does: clear the presentation, then run the action, once.
    @MainActor
    func trigger<Presentation>(dismissing presentation: Binding<Presentation?>) {
        presentation.wrappedValue = nil
        perform()
    }
}

/// The buttons of a presented dialog. Each clears the presentation first, then runs its action once.
struct QeetrixDialogButtons<Presentation>: View {
    let actions: [QeetrixDialogAction]
    let presentation: Binding<Presentation?>
    /// The action shown unavailable: an alert's confirming action while a required field is empty.
    var unavailable: QeetrixDialogAction.ID?

    var body: some View {
        // By position: the added Cancel is a new value on every update, so its id is not stable.
        ForEach(Array(QeetrixDialogAction.resolved(actions).enumerated()), id: \.offset) { _, action in
            Button(role: action.role) {
                action.trigger(dismissing: presentation)
            } label: {
                action.title
            }
            .disabled(unavailable != nil && action.id == unavailable)
        }
    }
}
