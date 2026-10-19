import SwiftUI

/// A labelled multi-line text field — the web's `Field` with a `Textarea`.
///
/// ```swift
/// QeetrixTextarea(
///     "Feedback", text: $feedback,
///     prompt: Text("What could be better?"),
///     description: Text("Up to 500 characters.")
/// )
/// ```
///
/// It is a native multi-line text field: Return starts a new line, and selection, the edit menu and
/// dictation behave as in any iOS text field. It starts two control heights tall, grows
/// with its text to 15 lines (the web's 24 rem cap), then scrolls. The prompt is drawn while the field is
/// empty and is never part of its value. It takes the same states as ``QeetrixTextField``: a message
/// colours its boundary, `disabled(_:)` dims it and `isReadOnly` shows the text selectable but not
/// editable. Plain text only.
public struct QeetrixTextarea: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let text: Binding<String>
    let prompt: Text?
    let isReadOnly: Bool

    /// A multi-line field with a localised label.
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

    /// A multi-line field with a label shown as given, without localisation.
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

    /// A multi-line field with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: The label above the field, which also names it for VoiceOver.
    ///   - text: The field's value.
    ///   - prompt: Placeholder text, shown while the field is empty. Never the only label.
    ///   - description: Help shown under the field.
    ///   - message: An error, warning or success message under the field; it also colours the boundary.
    ///   - isRequired: Marks the label with an asterisk, and tells VoiceOver the field is required.
    ///   - isOptional: Marks the label "(optional)" instead. Ignored when `isRequired` is true.
    ///   - isReadOnly: Shows the text without letting it be edited.
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
            QeetrixTextareaInput(text: text, prompt: prompt, isReadOnly: isReadOnly)
        }
    }
}

struct QeetrixTextareaInput: View {
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
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .accessibilityElement(children: .ignore)
                    .qeetrixFieldControlAccessibility()
                    .accessibilityValue(Text(verbatim: text.wrappedValue))
            } else {
                TextField(
                    text: text, prompt: (prompt ?? Text(verbatim: "")).foregroundStyle(QeetrixInputTokens.placeholder), axis: .vertical
                ) {
                    context?.label ?? Text(verbatim: "")
                }
                .lineLimit(...QeetrixTextareaMetrics.maximumLines)
                .focused($isFocused)
                .qeetrixFieldControlAccessibility()
            }
        }
        .qeetrixType(QeetrixTextareaMetrics.textType)
        .foregroundStyle(QeetrixInputTokens.foreground)
        .padding(.horizontal, QeetrixWebScale.spacing(2.5))  // px-2.5
        .padding(.vertical, QeetrixWebScale.spacing(2))  // py-2
        .frame(maxWidth: .infinity, minHeight: QeetrixTextareaMetrics.minimumHeight(density), alignment: .topLeading)
        .qeetrixFieldSurface(state)
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                if isEnabled && !isReadOnly { isFocused = true }
            }
        )
        .onHover { isHovered = $0 }
    }
}

enum QeetrixTextareaMetrics {
    /// `text-base leading-normal`.
    static let textType = QeetrixComponentType.sans(QeetrixWebScale.textBase, .regular, lineHeight: 1.5, scalesLike: .body)

    /// `min-h-[calc(var(--qx-component-input-height)*2)]`: two control heights.
    static func minimumHeight(_ density: QeetrixDensity) -> CGFloat {
        2 * QeetrixInputTokens.height(density)
    }

    /// `max-h-96` — 24 rem, 384 pt — in lines of the field's text at the default size: (384 − 16) ÷ 24.
    /// A line count rather than a height, so the cap scales with Dynamic Type.
    static let maximumLines = 15
}
