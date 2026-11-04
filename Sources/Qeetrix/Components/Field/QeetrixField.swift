import Accessibility
import SwiftUI

/// A form row, as `@qeetrix/react`'s Field: the label above the control, then help text — or the
/// error that replaces it — below, 4 pt apart (design rules §8).
///
/// The Qeetrix inputs (``QeetrixTextField``, ``QeetrixPasswordInput``, ``QeetrixSelect`` and the rest)
/// already build themselves on a field: give them a label and they lay it out. Use `QeetrixField` for any
/// other control, such as a native `Stepper` or `DatePicker`:
///
/// ```swift
/// QeetrixField("Seats", description: Text("You can add more later.")) {
///     Stepper("\(seats)", value: $seats, in: 1...25)
/// }
/// ```
///
/// The label is `label.sm` in `color.text.subtle`. An optional field says "(optional)"; fields never
/// carry asterisks — `isRequired` only tells VoiceOver. An `error` replaces the description, in
/// `color.text.danger` with a sharp alert icon, marks a Qeetrix control invalid (its danger frame), and
/// is announced when it appears; write it as what to do ("Enter a work email"). Validation is the app's:
/// the field only presents the error it is given.
///
/// For VoiceOver the control carries the field: its name is the label (with "Required"), the
/// description is its hint, and the error is attached to it as content VoiceOver reads with it,
/// whatever the hints setting.
public struct QeetrixField<Content: View>: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let isLabelHidden: Bool
    let content: Content

    /// A field with a localised label.
    public init(
        _ titleKey: LocalizedStringKey,
        description: Text? = nil,
        error: String? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isInvalid: Bool = false,
        isLabelHidden: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            label: Text(titleKey), description: description, error: error, isRequired: isRequired, isOptional: isOptional,
            isInvalid: isInvalid, isLabelHidden: isLabelHidden, content: content)
    }

    /// A field with a label shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        description: Text? = nil,
        error: String? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isInvalid: Bool = false,
        isLabelHidden: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            label: Text(title), description: description, error: error, isRequired: isRequired, isOptional: isOptional,
            isInvalid: isInvalid, isLabelHidden: isLabelHidden, content: content)
    }

    /// A field with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: Names the field, and the control inside it for VoiceOver.
    ///   - description: Help under the control, read by VoiceOver as the control's hint. An error
    ///     replaces it while it shows.
    ///   - error: What to fix, already localised (for example, from a server). It marks the control
    ///     invalid and is read by VoiceOver with the control.
    ///   - isRequired: Tells VoiceOver the field is required. Nothing is drawn: Qeetrix marks optional
    ///     fields, never required ones.
    ///   - isOptional: Appends "(optional)" to the label.
    ///   - isInvalid: Marks the control invalid without an error message.
    ///   - isLabelHidden: Hides the label visually and keeps it for VoiceOver — only for a toolbar
    ///     search with a visible icon.
    ///   - content: The control.
    public init(
        label: Text,
        description: Text? = nil,
        error: String? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isInvalid: Bool = false,
        isLabelHidden: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        context = QeetrixFieldContext(label: label, description: description, error: error, isRequired: isRequired, isInvalid: isInvalid)
        self.isOptional = isOptional
        self.isLabelHidden = isLabelHidden
        self.content = content()
    }

    public var body: some View {
        QeetrixFieldLayout(context: context, isOptional: isOptional, isLabelHidden: isLabelHidden) {
            content
        }
    }
}

/// What a field passes to the control inside it, through the environment. Internal: controls read it;
/// apps set it with ``QeetrixField``.
struct QeetrixFieldContext: Sendable {
    let label: Text
    let description: Text?
    let error: String?
    let isRequired: Bool
    let isInvalid: Bool

    init(label: Text, description: Text? = nil, error: String? = nil, isRequired: Bool = false, isInvalid: Bool = false) {
        self.label = label
        self.description = description
        self.error = error
        self.isRequired = isRequired
        self.isInvalid = isInvalid
    }

    /// Whether the control shows the invalid state: an error, or `isInvalid`.
    var invalid: Bool { error != nil || isInvalid }

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

/// The field rhythm (field.css `.qx-field`): label, control, then the description or error, 4 pt
/// apart (`space.gap.xs`).
struct QeetrixFieldLayout<Content: View>: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let isLabelHidden: Bool
    let content: Content

    init(context: QeetrixFieldContext, isOptional: Bool, isLabelHidden: Bool = false, @ViewBuilder content: () -> Content) {
        self.context = context
        self.isOptional = isOptional
        self.isLabelHidden = isLabelHidden
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
            if !isLabelHidden {
                QeetrixFieldLabel(label: context.label, isOptional: isOptional)
                    .accessibilityHidden(true)  // the control carries the label
            }
            content
                .environment(\.qeetrixFieldContext, context)
            QeetrixFieldMessages(description: context.description, error: context.error)
        }
        .qeetrixAnnouncesError(context.error)
    }
}

/// The label: `label.sm` in `color.text.subtle` (`color.text.disabled` when disabled), then
/// "(optional)" in `color.text.subtlest` at weight 400.
struct QeetrixFieldLabel: View {
    let label: Text
    let isOptional: Bool
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: QeetrixSpace.gapXs) {
            label
                .qeetrixTextStyle(.labelSm)
                .foregroundStyle(isEnabled ? QeetrixColor.textSubtle : QeetrixColor.textDisabled)
            if isOptional {
                QeetrixStrings.optional
                    .qeetrixType(Self.optionalType)
                    .foregroundStyle(QeetrixColor.textSubtlest)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    /// `label.sm` at `body.sm`'s weight (field.css `.qx-field-optional`).
    static let optionalType = QeetrixComponentType.role(.labelSm, QeetrixTextRole.bodySm.tokens.weight)
}

/// Under the control: the error, which replaces the description while it shows, or the description.
struct QeetrixFieldMessages: View {
    let description: Text?
    let error: String?
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        if let error {
            QeetrixFieldError(text: error)
        } else if let description {
            description
                .qeetrixTextStyle(.bodySm)
                // A disabled field's description dims to subtlest, not the disabled colour: it often says
                // why the field is disabled, and it isn't exempt from contrast.
                .foregroundStyle(isEnabled ? QeetrixColor.textSubtle : QeetrixColor.textSubtlest)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// The error row: a sharp 16 pt `circle-alert` in `color.icon.danger`, then the message in `body.sm`,
/// `color.text.danger`.
struct QeetrixFieldError: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: QeetrixSpace.gapXs) {
            QeetrixIcon(.circleAlert, size: .sm, shape: .sharp, relativeTo: .footnote)
                .foregroundStyle(QeetrixColor.iconDanger)
            Text(verbatim: text)
                .qeetrixTextStyle(.bodySm)
                .foregroundStyle(QeetrixColor.textDanger)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

extension View {
    /// Announces an error to VoiceOver when it appears or changes.
    func qeetrixAnnouncesError(_ error: String?) -> some View {
        onChange(of: error) { _, newError in
            if let newError {
                AccessibilityNotification.Announcement(newError).post()
            }
        }
    }
}

/// Gives a control the field's VoiceOver name, hint and error. Applied by every Qeetrix control to its
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
                // Read with the control, at high importance, whatever the hints setting; no error, no content.
                .accessibilityCustomContent(
                    AccessibilityCustomContentKey(QeetrixStrings.error, id: "qeetrix.field.error"),
                    context.error.map { Text(verbatim: $0) },
                    importance: .high)
        } else if let fallbackLabel {
            content.accessibilityLabel(fallbackLabel)
        } else {
            content
        }
    }
}

extension View {
    /// The field's name, hint and error on this control (see ``QeetrixFieldControlAccessibility``).
    func qeetrixFieldControlAccessibility(fallbackLabel: Text? = nil) -> some View {
        modifier(QeetrixFieldControlAccessibility(fallbackLabel: fallbackLabel))
    }
}
