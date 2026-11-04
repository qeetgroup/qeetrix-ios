import SwiftUI

/// Multi-line text with its label, help text and error — `@qeetrix/react`'s Textarea in a Field.
///
/// ```swift
/// QeetrixTextarea("Notes", text: $notes, prompt: Text("e.g. Deliver after 5 pm"), rows: 4)
/// ```
///
/// The same box as ``QeetrixTextField`` (design rules §8), `rows` lines tall at least (3 by default),
/// with the padding that centres one line in an input's height. It grows with its content up to
/// `maxRows`, then scrolls; without `maxRows` it keeps growing. Read-only shows the text, selectable,
/// with no fill.
public struct QeetrixTextarea: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let text: Binding<String>
    let prompt: Text?
    let rows: Int
    let maxRows: Int?
    let isReadOnly: Bool

    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        prompt: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        rows: Int = 3,
        maxRows: Int? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false
    ) {
        self.init(
            label: Text(titleKey), text: text, prompt: prompt, description: description, error: error, rows: rows, maxRows: maxRows,
            isRequired: isRequired, isOptional: isOptional, isReadOnly: isReadOnly)
    }

    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        prompt: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        rows: Int = 3,
        maxRows: Int? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false
    ) {
        self.init(
            label: Text(title), text: text, prompt: prompt, description: description, error: error, rows: rows, maxRows: maxRows,
            isRequired: isRequired, isOptional: isOptional, isReadOnly: isReadOnly)
    }

    public init(
        label: Text,
        text: Binding<String>,
        prompt: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        rows: Int = 3,
        maxRows: Int? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false
    ) {
        context = QeetrixFieldContext(label: label, description: description, error: error, isRequired: isRequired)
        self.isOptional = isOptional
        self.text = text
        self.prompt = prompt
        self.rows = max(1, rows)
        self.maxRows = maxRows.map { max($0, max(1, rows)) }
        self.isReadOnly = isReadOnly
    }

    public var body: some View {
        QeetrixFieldLayout(context: context, isOptional: isOptional) {
            QeetrixTextareaInput(text: text, prompt: prompt, rows: rows, maxRows: maxRows, isReadOnly: isReadOnly)
        }
    }
}

struct QeetrixTextareaInput: View {
    let text: Binding<String>
    let prompt: Text?
    let rows: Int
    let maxRows: Int?
    let isReadOnly: Bool

    @FocusState private var isFocused: Bool
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixFieldContext) private var context
    @ScaledMetric(relativeTo: .body) private var lineHeight = QeetrixTextRole.bodyMd.tokens.size * QeetrixTextRole.bodyMd.tokens.lineHeight
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 100

    var body: some View {
        let state = QeetrixInputState(
            isEnabled: isEnabled, isReadOnly: isReadOnly, isFocused: isFocused, isHovered: isHovered, isInvalid: context?.invalid ?? false)
        // input.css: padding-block (control.lg − 1lh) / 2, so one line sits as in an input; the room
        // scales with the text, as in every single-line control.
        let type = QeetrixInputMetrics.textType.tokens
        let inset = QeetrixControlBlockSize.inset(
            height: QeetrixInputMetrics.height(density), lineHeight: type.size * CGFloat(type.lineHeight), scale: scale / 100)
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
                    text: text, prompt: (prompt ?? Text(verbatim: "")).foregroundStyle(QeetrixInputMetrics.placeholder), axis: .vertical
                ) {
                    context?.label ?? Text(verbatim: "")
                }
                .lineLimit(rows...(maxRows ?? Int.max))
                .tint(QeetrixColor.borderFocus)
                .focused($isFocused)
                .qeetrixFieldControlAccessibility()
            }
        }
        .qeetrixTypeEnvironment(QeetrixInputMetrics.textType)
        .padding(.horizontal, QeetrixInputMetrics.padding)
        .padding(.vertical, inset)
        .frame(maxWidth: .infinity, minHeight: CGFloat(rows) * lineHeight + 2 * inset, alignment: .topLeading)
        .qeetrixInputSurface(state)
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                if isEnabled && !isReadOnly { isFocused = true }
            }
        )
        .onHover { isHovered = $0 }
    }
}
