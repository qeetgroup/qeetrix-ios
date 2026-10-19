import SwiftUI

/// A labelled single-line text field: the web's `Field` with an `Input` — a label, the field, an
/// optional description and an optional ``QeetrixFieldMessage``.
///
/// ```swift
/// QeetrixTextField(
///     "Work email", text: $email,
///     prompt: Text("name@company.com"),
///     description: Text("We send sign-in links here."),
///     message: emailError.map { QeetrixFieldMessage(.error, text: $0) },
///     isRequired: true
/// )
/// .keyboardType(.emailAddress)
/// .textContentType(.emailAddress)
/// ```
///
/// The field's height follows the density and grows with Dynamic Type; its text is 16 pt, the web's
/// mobile field size. Keyboard, content type, autocapitalisation and submit modifiers apply to it as
/// to any `TextField`. `disabled(_:)` dims it; `isReadOnly` shows the value with a dashed boundary,
/// selectable but not editable.
///
/// It is a ``QeetrixField`` around a native `TextField`. VoiceOver reads the field by its label — with
/// "Required" for a required field — and its value, then the message attached to it; the description is
/// its hint. The description and message also follow as text in reading order, and a new message is
/// announced, as the web's `role="alert"` and `role="status"` do.
public struct QeetrixTextField: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let text: Binding<String>
    let prompt: Text?
    let isReadOnly: Bool

    /// A field with a localised label.
    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        prompt: Text? = nil,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false
    ) {
        self.init(
            label: Text(titleKey), text: text, prompt: prompt, description: description, message: message, isRequired: isRequired,
            isOptional: isOptional, isReadOnly: isReadOnly)
    }

    /// A field with a label shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        prompt: Text? = nil,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false
    ) {
        self.init(
            label: Text(title), text: text, prompt: prompt, description: description, message: message, isRequired: isRequired,
            isOptional: isOptional, isReadOnly: isReadOnly)
    }

    /// A field with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: The label above the field, which also names it for VoiceOver.
    ///   - text: The field's value.
    ///   - prompt: Placeholder text, shown while the field is empty. Never the only label.
    ///   - description: Help shown under the field.
    ///   - message: An error, warning or success message under the field; it also colours the boundary.
    ///   - isRequired: Marks the label with an asterisk, and tells VoiceOver the field is required.
    ///   - isOptional: Marks the label "(optional)" instead. Ignored when `isRequired` is true.
    ///   - isReadOnly: Shows the value without letting it be edited.
    public init(
        label: Text,
        text: Binding<String>,
        prompt: Text? = nil,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false
    ) {
        context = QeetrixFieldContext(label: label, description: description, message: message, isRequired: isRequired)
        self.isOptional = isOptional
        self.text = text
        self.prompt = prompt
        self.isReadOnly = isReadOnly
    }

    public var body: some View {
        QeetrixFieldLayout(context: context, isOptional: isOptional) {
            QeetrixTextInput(text: text, prompt: prompt, isReadOnly: isReadOnly)
        }
    }
}

/// The single-line input inside a field: a native `TextField` on the field surface — or, read-only, the
/// value as selectable text. It takes its name, hint, message and boundary colour from the field around it.
struct QeetrixTextInput: View {
    let text: Binding<String>
    let prompt: Text?
    let isReadOnly: Bool

    @FocusState private var isFocused: Bool
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixFieldContext) private var context

    var body: some View {
        let state = QeetrixFieldState(
            isEnabled: isEnabled, isReadOnly: isReadOnly, isFocused: isFocused, isHovered: isHovered, tone: context?.message?.tone)
        Group {
            if isReadOnly {
                Text(verbatim: text.wrappedValue)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityElement(children: .ignore)
                    .qeetrixFieldControlAccessibility()
                    .accessibilityValue(Text(verbatim: text.wrappedValue))
            } else {
                TextField(text: text, prompt: (prompt ?? Text(verbatim: "")).foregroundStyle(QeetrixInputTokens.placeholder)) {
                    context?.label ?? Text(verbatim: "")
                }
                .focused($isFocused)
                .qeetrixFieldControlAccessibility()
            }
        }
        .qeetrixType(QeetrixTextFieldMetrics.textType)
        .foregroundStyle(QeetrixInputTokens.foreground)
        .padding(.horizontal, QeetrixWebScale.spacing(2.5))  // px-2.5
        .padding(.vertical, QeetrixWebScale.spacing(1))  // py-1
        .frame(minHeight: QeetrixInputTokens.height(density))
        .qeetrixFieldSurface(state)
        // A 44 pt target: a tap on the padding, or just outside a short field, focuses it.
        .qeetrixHitArea()
        .simultaneousGesture(
            TapGesture().onEnded {
                if isEnabled && !isReadOnly { isFocused = true }
            }
        )
        .onHover { isHovered = $0 }
    }
}

enum QeetrixTextFieldMetrics {
    /// `text-base` — the web's field text below its `md` breakpoint, sized so iOS does not zoom on focus.
    static let textType = QeetrixComponentType.sans(QeetrixWebScale.textBase, .regular, scalesLike: .body)
}
