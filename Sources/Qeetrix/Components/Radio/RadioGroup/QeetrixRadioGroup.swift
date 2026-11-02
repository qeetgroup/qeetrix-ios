import SwiftUI

/// How a choice group lays out its options, as `@qeetrix/react`'s `ChoiceOrientation`.
public enum QeetrixChoiceOrientation: String, CaseIterable, Sendable {
    /// One option per row, the default.
    case vertical
    /// Options side by side, wrapping, for short options.
    case horizontal
}

/// Pick one of a set, as `@qeetrix/react`'s RadioGroup: the question as the legend, in the field-label
/// style, then a radio per option (design rules §9).
///
/// ```swift
/// QeetrixRadioGroup("Billing cycle", selection: $cycle, options: [
///     QeetrixOption("Monthly", value: Cycle.monthly),
///     QeetrixOption("Yearly", value: Cycle.yearly, description: Text("Two months free")),
/// ])
/// ```
///
/// A 16 pt circle with a 1 pt `color.border.strong` edge on `color.bg.input`; selected, the edge
/// becomes a 5 pt Ember ring around the centre. Each row is a 44 pt target. With an error, every
/// radio takes the danger edge (the chosen one a danger ring) and the error replaces the description,
/// as for a field. Choosing another option plays ``QeetrixFeedback/selection`` feedback. VoiceOver reads
/// each option as a button that is selected or not, with its description as its hint.
public struct QeetrixRadioGroup<Value: Hashable>: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let orientation: QeetrixChoiceOrientation
    let selection: Binding<Value>
    let options: [QeetrixOption<Value>]
    /// The person's changes of option: each plays the selection feedback, and a change the app makes
    /// doesn't.
    @State private var changes = 0

    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Value>,
        options: [QeetrixOption<Value>],
        description: Text? = nil,
        error: String? = nil,
        orientation: QeetrixChoiceOrientation = .vertical,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(titleKey), selection: selection, options: options, description: description, error: error,
            orientation: orientation, isRequired: isRequired, isOptional: isOptional)
    }

    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Value>,
        options: [QeetrixOption<Value>],
        description: Text? = nil,
        error: String? = nil,
        orientation: QeetrixChoiceOrientation = .vertical,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(title), selection: selection, options: options, description: description, error: error,
            orientation: orientation, isRequired: isRequired, isOptional: isOptional)
    }

    public init(
        label: Text,
        selection: Binding<Value>,
        options: [QeetrixOption<Value>],
        description: Text? = nil,
        error: String? = nil,
        orientation: QeetrixChoiceOrientation = .vertical,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        context = QeetrixFieldContext(label: label, description: description, error: error, isRequired: isRequired)
        self.isOptional = isOptional
        self.orientation = orientation
        self.selection = selection
        self.options = options
    }

    public var body: some View {
        QeetrixChoiceGroupLayout(context: context, isOptional: isOptional) {
            switch orientation {
            case .vertical:
                radios
            case .horizontal:
                // field.css: options 16 pt apart (`space.gap.lg`), wrapping.
                QeetrixCardFooterLayout(spacing: QeetrixSpace.gapLg, alignment: .leading) { radios }
            }
        }
        .qeetrixFeedback(.selection, trigger: changes)
    }

    private var radios: some View {
        ForEach(options) { option in
            QeetrixRadio(option: option, isSelected: option.value == selection.wrappedValue) {
                // Choosing the option already chosen changes nothing, and plays nothing.
                if option.value != selection.wrappedValue { changes += 1 }
                selection.wrappedValue = option.value
            }
            .layoutValue(key: QeetrixSelectionRowKey.self, value: true)
        }
    }
}

struct QeetrixRadio<Value: Hashable>: View {
    let option: QeetrixOption<Value>
    let isSelected: Bool
    let select: @MainActor () -> Void
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovered = false

    var body: some View {
        let enabled = isEnabled && !option.isDisabled
        Button(action: select) {
            QeetrixChoiceRow(description: option.description, isEnabled: enabled) {
                QeetrixRadioDisc(isSelected: isSelected, isHovered: isHovered, isEnabled: enabled)
            } label: {
                option.title
            }
        }
        .buttonStyle(QeetrixRadioButtonStyle())
        .disabled(option.isDisabled)
        .onHover { isHovered = $0 }
        // The button stays the element, so its disabled state reaches VoiceOver; the label replaces the
        // title-and-description it would read from its content.
        .accessibilityLabel(option.title)
        .accessibilityHint(option.description ?? Text(verbatim: ""))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .modifier(QeetrixGroupErrorAccessibility())
    }
}

private struct QeetrixRadioButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

/// The 16 pt circle (radio.css): selected, its border is a 5 pt Ember ring around the input-coloured
/// centre.
struct QeetrixRadioDisc: View {
    let isSelected: Bool
    var isHovered = false
    var isEnabled = true
    @Environment(\.qeetrixGroupIsInvalid) private var isInvalid
    @Environment(\.isFocused) private var isFocused

    static let side: CGFloat = 16
    static let selectedRing: CGFloat = 5

    var body: some View {
        ZStack {
            Circle().fill(isEnabled ? QeetrixColor.bgInput : QeetrixColor.bgDisabled)
            Circle().strokeBorder(border, lineWidth: isSelected ? Self.selectedRing : QeetrixBorderWidth.default)
        }
        .frame(width: Self.side, height: Self.side)
        .overlay { if isFocused { QeetrixOuterFocusFrame(shape: Circle()) } }
        .qeetrixAnimation(.standard, .fast, value: isSelected)
        .qeetrixAnimation(.standard, .fast, value: isHovered)
    }

    var border: QeetrixColor {
        if !isEnabled { return isSelected ? .iconDisabled : .borderDisabled }
        // `.qx-radio[data-invalid]` follows the checked and hover rules: a chosen invalid radio's 5 pt
        // ring is the danger colour, hovered too (QTRX-161).
        if isInvalid { return .borderDanger }
        if isSelected { return isHovered ? .bgBrandBoldHover : .bgBrandBold }
        return isHovered ? .borderStrongHover : .borderStrong
    }
}
