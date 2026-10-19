import SwiftUI

/// A choice from a list, in the system's menu — the web's `Select` (and `NativeSelect`) in a field.
///
/// ```swift
/// QeetrixSelect("Country", selection: $country, options: countries, placeholder: Text("Choose a country"))
/// ```
///
/// The field shows the selected option's title, or the placeholder while the selection matches no
/// option; tapping it opens the native menu, which marks the current choice with a checkmark and scrolls
/// as long lists do. Disabled options are listed but cannot be chosen, and option descriptions appear as
/// subtitles. It takes the field states: a message colours its boundary and `disabled(_:)` dims it.
///
/// VoiceOver reads a button named by the label, with the selected title (or the placeholder) as its
/// value; the menu items are the system's. For a handful of options that should all stay visible, use
/// ``QeetrixRadioGroup``. Search, multiple selection and loading options remotely are out of its scope.
public struct QeetrixSelect<Value: Hashable>: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let selection: Binding<Value>
    let options: [QeetrixOption<Value>]
    let placeholder: Text?

    /// A select with a localised label.
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Value>,
        options: [QeetrixOption<Value>],
        placeholder: Text? = nil,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(titleKey), selection: selection, options: options, placeholder: placeholder, description: description,
            message: message, isRequired: isRequired, isOptional: isOptional)
    }

    /// A select with a label shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Value>,
        options: [QeetrixOption<Value>],
        placeholder: Text? = nil,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(title), selection: selection, options: options, placeholder: placeholder, description: description,
            message: message, isRequired: isRequired, isOptional: isOptional)
    }

    /// A select with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: The label above the field, which also names it for VoiceOver.
    ///   - selection: The selected value.
    ///   - options: The choices, in order.
    ///   - placeholder: Shown while the selection matches no option.
    ///   - description: Help shown under the field.
    ///   - message: An error, warning or success message under the field; it also colours the boundary.
    ///   - isRequired: Marks the label with an asterisk, and tells VoiceOver the field is required.
    ///   - isOptional: Marks the label "(optional)" instead. Ignored when `isRequired` is true.
    public init(
        label: Text,
        selection: Binding<Value>,
        options: [QeetrixOption<Value>],
        placeholder: Text? = nil,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        context = QeetrixFieldContext(label: label, description: description, message: message, isRequired: isRequired)
        self.isOptional = isOptional
        self.selection = selection
        self.options = options
        self.placeholder = placeholder
    }

    public var body: some View {
        QeetrixFieldLayout(context: context, isOptional: isOptional) {
            QeetrixSelectTrigger(selection: selection, options: options, placeholder: placeholder)
        }
    }
}

struct QeetrixSelectTrigger<Value: Hashable>: View {
    let selection: Binding<Value>
    let options: [QeetrixOption<Value>]
    let placeholder: Text?

    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixFieldContext) private var context

    var body: some View {
        let selected = options.first { $0.value == selection.wrappedValue }
        let state = QeetrixFieldState(
            isEnabled: isEnabled, isReadOnly: false, isFocused: false, isHovered: isHovered, tone: context?.message?.tone)
        Menu {
            // Each option is a toggle, which the system menu draws with a checkmark when on and honours
            // `disabled` for — a menu ignores `disabled` on the rows of a Picker.
            ForEach(options) { option in
                Toggle(
                    isOn: Binding(
                        get: { option.value == selection.wrappedValue },
                        set: { isOn in if isOn { selection.wrappedValue = option.value } })
                ) {
                    option.title
                    if let description = option.description {
                        description
                    }
                }
                .disabled(option.isDisabled)
            }
        } label: {
            HStack(spacing: QeetrixWebScale.spacing(1.5)) {  // gap-1.5
                (selected?.title ?? placeholder ?? Text(verbatim: ""))
                    .foregroundStyle(selected == nil ? QeetrixInputTokens.placeholder : QeetrixInputTokens.foreground)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                QeetrixIcon(.chevronDown, size: QeetrixIconSize(QeetrixWebScale.spacing(4)))  // size-4
                    .foregroundStyle(QeetrixColor.textTertiary)  // text-muted-foreground
            }
            .qeetrixType(QeetrixTextFieldMetrics.textType)
            .padding(.leading, QeetrixWebScale.spacing(2.5))  // ps-2.5
            .padding(.trailing, QeetrixWebScale.spacing(2))  // pe-2
            .padding(.vertical, QeetrixWebScale.spacing(1))  // py-1
            .frame(minHeight: QeetrixInputTokens.height(density))
            .qeetrixFieldSurface(state)
            .contentShape(Rectangle())
        }
        .buttonStyle(QeetrixPlainControlStyle())
        .qeetrixHitArea()
        .onHover { isHovered = $0 }
        .qeetrixFieldControlAccessibility()
        .accessibilityValue(selected?.title ?? placeholder ?? Text(verbatim: ""))
    }
}

/// No highlight of its own, as the web trigger has none: the field surface is the control's whole
/// appearance, and the menu opening is the response to a tap.
struct QeetrixPlainControlStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
