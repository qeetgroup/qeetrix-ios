import SwiftUI

/// A set of mutually exclusive choices — the web's `RadioGroup` in a field.
///
/// ```swift
/// QeetrixRadioGroup("Plan", selection: $plan, options: [
///     QeetrixOption("Starter", value: Plan.starter),
///     QeetrixOption("Team", value: Plan.team, description: Text("Up to 25 members")),
/// ])
/// ```
///
/// Exactly one option is selected once the person chooses: choosing another moves the selection, and
/// choosing the selected one again changes nothing. A selection no option has — `nil`, with an optional
/// value type — shows nothing selected. Disabled options are shown but cannot be chosen.
///
/// Each option is a native button, a 44 pt row; VoiceOver reads its title, "Selected" on the chosen
/// one, and its description as the hint. The group is a VoiceOver container named by its label, and the
/// group's message is read with each option. On iOS a choice is a tap, not an arrow-key move between
/// radios as on the web; with a hardware keyboard each option is its own Full Keyboard Access stop.
public struct QeetrixRadioGroup<Value: Hashable>: View {
    let label: Text
    let description: Text?
    let message: QeetrixFieldMessage?
    let isRequired: Bool
    let isOptional: Bool
    let selection: Binding<Value>
    let options: [QeetrixOption<Value>]

    /// A radio group with a localised label.
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Value>,
        options: [QeetrixOption<Value>],
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(titleKey), selection: selection, options: options, description: description, message: message,
            isRequired: isRequired, isOptional: isOptional)
    }

    /// A radio group with a label shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Value>,
        options: [QeetrixOption<Value>],
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(title), selection: selection, options: options, description: description, message: message,
            isRequired: isRequired, isOptional: isOptional)
    }

    /// A radio group with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: Names the group, above its options.
    ///   - selection: The selected value.
    ///   - options: The choices, in order.
    ///   - description: Help shown under the options.
    ///   - message: An error, warning or success message about the choice.
    ///   - isRequired: Marks the label with an asterisk, and tells VoiceOver a choice is required.
    ///   - isOptional: Marks the label "(optional)" instead. Ignored when `isRequired` is true.
    public init(
        label: Text,
        selection: Binding<Value>,
        options: [QeetrixOption<Value>],
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.label = label
        self.description = description
        self.message = message
        self.isRequired = isRequired
        self.isOptional = isOptional
        self.selection = selection
        self.options = options
    }

    public var body: some View {
        QeetrixGroupLayout(
            legend: label, legendStyle: .label, description: description, message: message, isRequired: isRequired,
            isOptional: isOptional
        ) {
            ForEach(options) { option in
                QeetrixRadio(option: option, isSelected: option.value == selection.wrappedValue) {
                    selection.wrappedValue = option.value
                }
                .layoutValue(key: QeetrixSelectionRowKey.self, value: true)
            }
        }
    }
}

struct QeetrixRadio<Value: Hashable>: View {
    let option: QeetrixOption<Value>
    let isSelected: Bool
    let select: @MainActor () -> Void
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let enabled = isEnabled && !option.isDisabled
        Button(action: select) {
            QeetrixSelectionRow(description: option.description, isEnabled: enabled) {
                QeetrixRadioDisc(isSelected: isSelected)
            } label: {
                option.title
            }
        }
        .buttonStyle(QeetrixRadioButtonStyle())
        .disabled(option.isDisabled)
        // The button stays the element, so its disabled state reaches VoiceOver; the label replaces the
        // title-and-description it would read from its content.
        .accessibilityLabel(option.title)
        .accessibilityHint(option.description ?? Text(verbatim: ""))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .modifier(QeetrixGroupMessageAccessibility())
    }
}

/// The row is the button: no highlight of its own, the disc says what is chosen.
private struct QeetrixRadioButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

/// The 16 pt disc: the field fill and control boundary at rest; the brand fill with the `border-brand`
/// edge and a 6 pt white dot when selected.
struct QeetrixRadioDisc: View {
    let isSelected: Bool
    @Environment(\.qeetrixGroupMessage) private var groupMessage

    var body: some View {
        ZStack {
            Circle().fill(isSelected ? QeetrixComponentColor(.actionPrimary) : QeetrixInputTokens.background)  // bg-primary
            Circle().strokeBorder(border, lineWidth: QeetrixStroke.hairline)
            if isSelected {
                Circle()
                    .fill(QeetrixColor.textOnBrand)  // bg-primary-foreground
                    .frame(width: QeetrixWebScale.spacing(1.5), height: QeetrixWebScale.spacing(1.5))  // size-1.5
            }
        }
        .frame(width: QeetrixWebScale.spacing(4), height: QeetrixWebScale.spacing(4))  // size-4
        .qeetrixAnimation(.standard, .fast, value: isSelected)
    }

    var border: QeetrixComponentColor {
        if groupMessage?.tone == .error { return QeetrixInputTokens.borderInvalid }
        return isSelected ? QeetrixComponentColor(.borderBrand) : QeetrixInputTokens.border
    }
}
