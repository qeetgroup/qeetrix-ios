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
/// - Up to two ``QeetrixAlertTextField``s ask for a short value — a rename, a new name — the iOS way. The
///   confirming action (the last that doesn't cancel) waits for the required fields, and Return in the
///   last field runs it.
///
/// It is the system alert: iOS draws it, places the buttons, takes the keyboard (Return and Escape) and
/// gives VoiceOver a modal it announces. Its fonts and surface are the system's, not Qeetrix's; only the
/// tint reaches it. For an outcome that needs no decision, use a ``QeetrixToast``; for a choice among
/// several actions, a ``QeetrixConfirmationDialog``.
public struct QeetrixAlertDialog: Identifiable {
    public let id = UUID()
    public let title: Text
    public let message: Text?
    /// Up to two text fields, above the buttons; a third and later are not shown.
    public let textFields: [QeetrixAlertTextField]
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
        self.init(title: title, message: message, textFields: [], actions: actions)
    }

    /// An alert that asks for one or two short values, with a localised title.
    ///
    /// ```swift
    /// alert = QeetrixAlertDialog(
    ///     "Rename account",
    ///     textFields: [
    ///         QeetrixAlertTextField("Issuer", text: $issuer),
    ///         QeetrixAlertTextField("Account name", text: $accountName, isRequired: true),
    ///     ],
    ///     actions: [QeetrixDialogAction("Cancel", role: .cancel), QeetrixDialogAction("Save") { save() }])
    /// ```
    ///
    /// - Parameters:
    ///   - titleKey: The title, looked up in the main bundle.
    ///   - message: Text under the title.
    ///   - textFields: One or two fields, in order. The confirming action — the last that doesn't cancel —
    ///     is unavailable while a required field is empty, and Return in the last field runs it; with one
    ///     still empty, the system alert's Return closes it as Cancel.
    ///   - actions: The buttons, in order: give a cancel and the confirming action.
    public init(
        _ titleKey: LocalizedStringKey, message: Text? = nil, textFields: [QeetrixAlertTextField], actions: [QeetrixDialogAction] = []
    ) {
        self.init(title: Text(titleKey), message: message, textFields: textFields, actions: actions)
    }

    /// An alert that asks for one or two short values, with a title shown as given.
    public init<S: StringProtocol>(
        _ title: S, message: Text? = nil, textFields: [QeetrixAlertTextField], actions: [QeetrixDialogAction] = []
    ) {
        self.init(title: Text(title), message: message, textFields: textFields, actions: actions)
    }

    /// An alert that asks for one or two short values, with a `Text` title.
    public init(title: Text, message: Text? = nil, textFields: [QeetrixAlertTextField], actions: [QeetrixDialogAction] = []) {
        self.title = title
        self.message = message
        self.textFields = Array(textFields.prefix(Self.maximumTextFields))
        self.actions = actions
    }

    /// The system alert holds two text fields comfortably; more belong in a sheet.
    static let maximumTextFields = 2

    /// The action Return runs and an empty required field holds back: the last that doesn't cancel.
    var confirmingAction: QeetrixDialogAction? {
        actions.last { $0.role != .cancel }
    }

    /// Whether every required field has more than spaces.
    var isComplete: Bool {
        Self.isComplete(textFields, texts: textFields.map(\.text.wrappedValue))
    }

    /// Whether every required field among `fields`, holding `texts`, has more than spaces.
    static func isComplete(_ fields: [QeetrixAlertTextField], texts: [String]) -> Bool {
        zip(fields, texts).allSatisfy { field, text in
            !field.isRequired || !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}

/// What a text field holds, for its keyboard and AutoFill: UIKit's text content types, by names that exist
/// on every platform Qeetrix builds for.
public enum QeetrixTextContentType: String, CaseIterable, Sendable {
    /// A person's full name: words capitalised, AutoFill offers the person's own.
    case name
    /// A company or organisation: words capitalised.
    case organizationName
    /// A username or account name: no capitals or corrections.
    case username
    /// An email address: the email keyboard, no capitals or corrections.
    case emailAddress
    /// A web address: the URL keyboard, no capitals or corrections.
    case url
    /// A phone number: the phone pad.
    case telephoneNumber
    /// The person's password: Password AutoFill, no capitals or corrections.
    case password
    /// A password being created: strong-password suggestions, no capitals or corrections.
    case newPassword
}

/// One text field of a ``QeetrixAlertDialog``: what it's called, the text it edits and what it holds.
///
/// The system alert draws it: the label is its placeholder, and what VoiceOver reads it by.
public struct QeetrixAlertTextField: Identifiable {
    public let id = UUID()
    /// Names the field: its placeholder, and what VoiceOver reads.
    public let label: Text
    /// The text the field edits.
    public let text: Binding<String>
    /// What the field holds, for its keyboard and AutoFill; `nil` for plain text.
    public let contentType: QeetrixTextContentType?
    /// Shows dots in place of the characters.
    public let isSecure: Bool
    /// Holds the confirming action back while the field is empty or only spaces.
    public let isRequired: Bool

    /// A field with a localised label.
    public init(
        _ labelKey: LocalizedStringKey, text: Binding<String>, contentType: QeetrixTextContentType? = nil, isSecure: Bool = false,
        isRequired: Bool = false
    ) {
        self.init(label: Text(labelKey), text: text, contentType: contentType, isSecure: isSecure, isRequired: isRequired)
    }

    /// A field with a label shown as given, without localisation.
    public init<S: StringProtocol>(
        _ label: S, text: Binding<String>, contentType: QeetrixTextContentType? = nil, isSecure: Bool = false, isRequired: Bool = false
    ) {
        self.init(label: Text(label), text: text, contentType: contentType, isSecure: isSecure, isRequired: isRequired)
    }

    /// A field with a `Text` label.
    public init(
        label: Text, text: Binding<String>, contentType: QeetrixTextContentType? = nil, isSecure: Bool = false, isRequired: Bool = false
    ) {
        self.label = label
        self.text = text
        self.contentType = contentType
        self.isSecure = isSecure
        self.isRequired = isRequired
    }
}

/// An alert's fields and buttons as one view. The fields' bindings are its own properties, so SwiftUI
/// redraws it — and the system alert's confirming button becomes available — as the person types.
struct QeetrixAlertFieldsAndButtons: View {
    let dialog: QeetrixAlertDialog
    let presentation: Binding<QeetrixAlertDialog?>
    let first: Binding<String>
    let second: Binding<String>

    init(dialog: QeetrixAlertDialog, presentation: Binding<QeetrixAlertDialog?>) {
        self.dialog = dialog
        self.presentation = presentation
        first = dialog.textFields.first?.text ?? .constant("")
        second = dialog.textFields.dropFirst().first?.text ?? .constant("")
    }

    var body: some View {
        let isComplete = QeetrixAlertDialog.isComplete(dialog.textFields, texts: [first.wrappedValue, second.wrappedValue])
        ForEach(Array(dialog.textFields.enumerated()), id: \.offset) { index, field in
            QeetrixAlertFieldInput(field: field, text: index == 0 ? first : second) {
                // Return in the last field confirms, once the required fields are filled.
                guard index == dialog.textFields.count - 1, isComplete else { return }
                dialog.confirmingAction?.trigger(dismissing: presentation)
            }
        }
        QeetrixDialogButtons(
            actions: dialog.actions, presentation: presentation, unavailable: isComplete ? nil : dialog.confirmingAction?.id)
    }
}

/// One field as the system alert takes it, with its content type; `submit` runs on Return.
struct QeetrixAlertFieldInput: View {
    let field: QeetrixAlertTextField
    let text: Binding<String>
    let submit: @MainActor () -> Void

    var body: some View {
        if field.isSecure {
            SecureField(text: text) { field.label }
                .qeetrixTextContentType(field.contentType)
                .accessibilityLabel(field.label)
                .onSubmit(submit)
        } else {
            TextField(text: text) { field.label }
                .qeetrixTextContentType(field.contentType)
                .accessibilityLabel(field.label)
                .onSubmit(submit)
        }
    }
}

extension View {
    /// The keyboard and AutoFill for `contentType`. iOS only: on the Mac development host, nothing.
    @ViewBuilder
    func qeetrixTextContentType(_ contentType: QeetrixTextContentType?) -> some View {
        #if os(iOS)
            if let contentType {
                textContentType(contentType.uiContentType)
                    .keyboardType(contentType.keyboardType)
                    .textInputAutocapitalization(contentType.capitalization)
                    .autocorrectionDisabled(!contentType.correctsSpelling)
            } else {
                self
            }
        #else
            self
        #endif
    }
}

#if os(iOS)
    extension QeetrixTextContentType {
        var uiContentType: UITextContentType {
            switch self {
            case .name: .name
            case .organizationName: .organizationName
            case .username: .username
            case .emailAddress: .emailAddress
            case .url: .URL
            case .telephoneNumber: .telephoneNumber
            case .password: .password
            case .newPassword: .newPassword
            }
        }

        var keyboardType: UIKeyboardType {
            switch self {
            case .emailAddress: .emailAddress
            case .url: .URL
            case .telephoneNumber: .phonePad
            case .name, .organizationName, .username, .password, .newPassword: .default
            }
        }

        /// Words for a name; nothing for anything typed exactly.
        var capitalization: TextInputAutocapitalization {
            correctsSpelling ? .words : .never
        }
    }

    extension QeetrixTextContentType {
        /// A name is corrected as words are; anything typed exactly — an address, a password — is not.
        var correctsSpelling: Bool {
            switch self {
            case .name, .organizationName: true
            case .username, .emailAddress, .url, .telephoneNumber, .password, .newPassword: false
            }
        }
    }
#endif

extension View {
    /// Presents `alert` while it is not `nil`, and sets it back to `nil` when it is dismissed.
    public func qeetrixAlertDialog(_ alert: Binding<QeetrixAlertDialog?>) -> some View {
        self.alert(
            alert.wrappedValue?.title ?? Text(verbatim: ""),
            isPresented: Binding(get: { alert.wrappedValue != nil }, set: { if !$0 { alert.wrappedValue = nil } }),
            presenting: alert.wrappedValue
        ) { presented in
            if presented.textFields.isEmpty {
                QeetrixDialogButtons(actions: presented.actions, presentation: alert)
            } else {
                QeetrixAlertFieldsAndButtons(dialog: presented, presentation: alert)
            }
        } message: { presented in
            if let message = presented.message { message }
        }
    }
}
