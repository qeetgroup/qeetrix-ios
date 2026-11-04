import SwiftUI

/// A single-line text field with its label, help text and error: `@qeetrix/react`'s TextField (a
/// Field around an Input), the default way to build a form row.
///
/// ```swift
/// QeetrixTextField("Trade name", text: $tradeName, prompt: Text("e.g. Acme Pvt Ltd"), isOptional: true)
/// QeetrixTextField("Amount", text: $amount, startAdornment: Text("₹"))
/// QeetrixTextField("Search", text: $query, icon: .search, isLabelHidden: true)
/// ```
///
/// The box is the Qeetrix field (design rules §8): filled with `color.bg.neutral.subtle`, a 1 pt
/// `color.border.strong` bottom line and 4 pt top corners, `size.control.lg` tall; a 2 pt Ember frame
/// inside it replaces the line while it is focused, and a danger frame while it has an error. The
/// value is `body.md`; the prompt — an example, never an instruction — `color.text.subtlest`. An
/// optional leading icon (sharp, 16 pt, `color.icon.subtle`) and text affixes (`color.text.subtle`)
/// sit 8 pt from the text. Read-only shows the value, selectable, with no fill.
///
/// It wraps SwiftUI's `TextField`, so text input traits apply as usual: `.textContentType(_:)`,
/// `.keyboardType(_:)`, `.submitLabel(_:)`, `.onSubmit`.
public struct QeetrixTextField: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let isLabelHidden: Bool
    let text: Binding<String>
    let prompt: Text?
    let icon: QeetrixIconName?
    let startAdornment: Text?
    let endAdornment: Text?
    let isReadOnly: Bool

    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        prompt: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        icon: QeetrixIconName? = nil,
        startAdornment: Text? = nil,
        endAdornment: Text? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false,
        isLabelHidden: Bool = false
    ) {
        self.init(
            label: Text(titleKey), text: text, prompt: prompt, description: description, error: error, icon: icon,
            startAdornment: startAdornment, endAdornment: endAdornment, isRequired: isRequired, isOptional: isOptional,
            isReadOnly: isReadOnly, isLabelHidden: isLabelHidden)
    }

    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        prompt: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        icon: QeetrixIconName? = nil,
        startAdornment: Text? = nil,
        endAdornment: Text? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false,
        isLabelHidden: Bool = false
    ) {
        self.init(
            label: Text(title), text: text, prompt: prompt, description: description, error: error, icon: icon,
            startAdornment: startAdornment, endAdornment: endAdornment, isRequired: isRequired, isOptional: isOptional,
            isReadOnly: isReadOnly, isLabelHidden: isLabelHidden)
    }

    public init(
        label: Text,
        text: Binding<String>,
        prompt: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        icon: QeetrixIconName? = nil,
        startAdornment: Text? = nil,
        endAdornment: Text? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false,
        isLabelHidden: Bool = false
    ) {
        context = QeetrixFieldContext(label: label, description: description, error: error, isRequired: isRequired)
        self.isOptional = isOptional
        self.isLabelHidden = isLabelHidden
        self.text = text
        self.prompt = prompt
        self.icon = icon
        self.startAdornment = startAdornment
        self.endAdornment = endAdornment
        self.isReadOnly = isReadOnly
    }

    public var body: some View {
        QeetrixFieldLayout(context: context, isOptional: isOptional, isLabelHidden: isLabelHidden) {
            QeetrixTextInput(
                text: text, prompt: prompt, icon: icon, startAdornment: startAdornment, endAdornment: endAdornment, isReadOnly: isReadOnly)
        }
    }
}

/// The Input box around a SwiftUI `TextField`, with its leading icon and affixes.
struct QeetrixTextInput: View {
    let text: Binding<String>
    let prompt: Text?
    var icon: QeetrixIconName?
    var startAdornment: Text?
    var endAdornment: Text?
    let isReadOnly: Bool

    @FocusState private var isFocused: Bool
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixFieldContext) private var context

    var body: some View {
        let state = QeetrixInputState(
            isEnabled: isEnabled, isReadOnly: isReadOnly, isFocused: isFocused, isHovered: isHovered, isInvalid: context?.invalid ?? false)
        HStack(spacing: QeetrixInputMetrics.gap) {
            if let icon {
                QeetrixIcon(icon, size: .sm, shape: .sharp)
                    .foregroundStyle(isEnabled ? QeetrixColor.iconSubtle : QeetrixColor.iconDisabled)
            }
            if let startAdornment {
                startAdornment.foregroundStyle(isEnabled ? QeetrixColor.textSubtle : QeetrixColor.textDisabled).accessibilityHidden(true)
            }
            field(state)
            if let endAdornment {
                endAdornment.foregroundStyle(isEnabled ? QeetrixColor.textSubtle : QeetrixColor.textDisabled).accessibilityHidden(true)
            }
        }
        .qeetrixTypeEnvironment(QeetrixInputMetrics.textType)
        .padding(.horizontal, QeetrixInputMetrics.padding)
        .qeetrixControlBlockSize(QeetrixInputMetrics.height(density), type: QeetrixInputMetrics.textType)
        .qeetrixInputSurface(state)
        // A 44 pt target: a tap on the padding, or just outside a short field, focuses it.
        .qeetrixHitArea()
        .simultaneousGesture(
            TapGesture().onEnded {
                if isEnabled && !isReadOnly { isFocused = true }
            }
        )
        .onHover { isHovered = $0 }
    }

    @ViewBuilder
    private func field(_ state: QeetrixInputState) -> some View {
        if isReadOnly {
            Text(verbatim: text.wrappedValue)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .ignore)
                .qeetrixFieldControlAccessibility()
                .accessibilityValue(Text(verbatim: text.wrappedValue))
        } else {
            TextField(text: text, prompt: (prompt ?? Text(verbatim: "")).foregroundStyle(QeetrixInputMetrics.placeholder)) {
                context?.label ?? Text(verbatim: "")
            }
            .tint(QeetrixColor.borderFocus)
            .focused($isFocused)
            .qeetrixFieldControlAccessibility()
        }
    }
}
