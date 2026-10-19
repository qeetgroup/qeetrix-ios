import Accessibility
import SwiftUI

/// A form field: a label, the control, an optional description and an optional validation message —
/// the web's `Field`, for any control.
///
/// The Qeetrix inputs (``QeetrixTextField``, ``QeetrixPasswordInput``, ``QeetrixSelect`` and the rest)
/// already build themselves on a field: give them a label and they lay it out. Use `QeetrixField` for any
/// other control, such as a native `Picker`, `Stepper` or `DatePicker`:
///
/// ```swift
/// QeetrixField("Seats", description: Text("You can add more later.")) {
///     Stepper("\(seats)", value: $seats, in: 1...25)
/// }
/// ```
///
/// The field passes its label, its required state, its description and its message to the control inside
/// it. A Qeetrix control uses them for its boundary colour and for VoiceOver; any control is named by the
/// label. The message colours the control's boundary and appears under it with its icon — never by
/// repainting the label. Validation is the app's: the field only presents the message it is given.
///
/// For VoiceOver the control carries the field: its name is the label (with "Required"), the description
/// is its hint, and the message is attached to it as content VoiceOver reads with it, whatever the hints
/// setting. The description and message also follow as text in reading order, as on the web, and a new
/// message is announced.
public struct QeetrixField<Content: View>: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let content: Content

    /// A field with a localised label.
    public init(
        _ titleKey: LocalizedStringKey,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            label: Text(titleKey), description: description, message: message, isRequired: isRequired, isOptional: isOptional,
            content: content)
    }

    /// A field with a label shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            label: Text(title), description: description, message: message, isRequired: isRequired, isOptional: isOptional,
            content: content)
    }

    /// A field with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: Names the field, and the control inside it for VoiceOver.
    ///   - description: Help shown under the control, and read by VoiceOver as the control's hint.
    ///   - message: An error, warning or success message under the control; it colours a Qeetrix
    ///     control's boundary and is read by VoiceOver with the control.
    ///   - isRequired: Marks the label with an asterisk, and tells VoiceOver the field is required.
    ///   - isOptional: Marks the label "(optional)" instead — the better convention when most fields of a
    ///     form are required. Ignored when `isRequired` is true.
    ///   - content: The control.
    public init(
        label: Text,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        context = QeetrixFieldContext(label: label, description: description, message: message, isRequired: isRequired)
        self.isOptional = isOptional
        self.content = content()
    }

    public var body: some View {
        QeetrixFieldLayout(context: context, isOptional: isOptional) {
            content
        }
    }
}

/// What a field passes to the control inside it, through the environment. Internal: controls read it;
/// apps set it with ``QeetrixField``.
struct QeetrixFieldContext: Sendable {
    let label: Text
    let description: Text?
    let message: QeetrixFieldMessage?
    let isRequired: Bool

    /// The control's VoiceOver name: the label, then "Required" — the counterpart of the web control's
    /// `required`, in the label because a hint can be switched off.
    var accessibilityLabel: Text {
        isRequired ? label + Text(verbatim: ", ") + QeetrixStrings.required : label
    }
}

private struct QeetrixFieldContextKey: EnvironmentKey {
    static let defaultValue: QeetrixFieldContext? = nil
}

extension EnvironmentValues {
    /// The field the view sits in, if any.
    var qeetrixFieldContext: QeetrixFieldContext? {
        get { self[QeetrixFieldContextKey.self] }
        set { self[QeetrixFieldContextKey.self] = newValue }
    }
}

/// The field rhythm: label, control, description and message 6 pt apart (`gap-1.5`).
struct QeetrixFieldLayout<Content: View>: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let content: Content
    @Environment(\.isEnabled) private var isEnabled

    init(context: QeetrixFieldContext, isOptional: Bool, @ViewBuilder content: () -> Content) {
        self.context = context
        self.isOptional = isOptional
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: QeetrixFieldMetrics.gap) {
            QeetrixFieldLabel(label: context.label, isRequired: context.isRequired, isOptional: isOptional)
                .opacity(isEnabled ? 1 : QeetrixOpacity.disabled)
                .accessibilityHidden(true)  // the control carries the label
            content
                .environment(\.qeetrixFieldContext, context)
            if let description = context.description {
                description
                    .qeetrixType(QeetrixFieldMetrics.captionType)
                    .foregroundStyle(QeetrixColor.textTertiary)  // text-muted-foreground
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let message = context.message {
                QeetrixFieldMessageView(message: message)
            }
        }
        .onChange(of: context.message) { _, newMessage in
            if let newMessage {
                AccessibilityNotification.Announcement(newMessage.text).post()
            }
        }
    }
}

/// `Label`: the text, then the required asterisk (decorative — VoiceOver hears "Required" from the
/// control) or "(optional)".
struct QeetrixFieldLabel: View {
    let label: Text
    let isRequired: Bool
    let isOptional: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: QeetrixWebScale.spacing(isRequired ? 0.5 : 1)) {  // gap-2 with -ms-1.5 / -ms-1
            label
            if isRequired {
                Text(verbatim: "*").foregroundStyle(QeetrixColor.textDanger)
            } else if isOptional {
                QeetrixStrings.optional
                    .qeetrixType(QeetrixFieldMetrics.optionalType)
                    .foregroundStyle(QeetrixColor.textTertiary)  // font-normal text-muted-foreground
            }
        }
        .qeetrixType(QeetrixFieldMetrics.labelType)
        .foregroundStyle(QeetrixColor.textPrimary)
        .fixedSize(horizontal: false, vertical: true)
    }
}

/// Gives a control the field's VoiceOver name, hint and message. Applied by every Qeetrix control to its
/// accessibility element — the text field, the menu button, the toggle — not to the field around it.
struct QeetrixFieldControlAccessibility: ViewModifier {
    /// The name when the control is not in a field, such as "One-time code".
    var fallbackLabel: Text?
    @Environment(\.qeetrixFieldContext) private var context

    func body(content: Content) -> some View {
        if let context {
            content
                .accessibilityLabel(context.accessibilityLabel)
                .accessibilityHint(context.description ?? Text(verbatim: ""))
                // Read with the control, at high importance, whatever the hints setting; no message, no content.
                .accessibilityCustomContent(
                    AccessibilityCustomContentKey(
                        context.message?.tone.accessibilityName ?? QeetrixStrings.error, id: "qeetrix.field.message"),
                    context.message.map { Text(verbatim: $0.text) },
                    importance: .high)
        } else if let fallbackLabel {
            content.accessibilityLabel(fallbackLabel)
        } else {
            content
        }
    }
}

extension View {
    /// The field's name, hint and message on this control (see ``QeetrixFieldControlAccessibility``).
    func qeetrixFieldControlAccessibility(fallbackLabel: Text? = nil) -> some View {
        modifier(QeetrixFieldControlAccessibility(fallbackLabel: fallbackLabel))
    }
}
