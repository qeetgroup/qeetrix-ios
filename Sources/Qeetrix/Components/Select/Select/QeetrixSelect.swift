import SwiftUI

/// Pick one option from a short list (up to about 15), with its label, help text and error —
/// `@qeetrix/react`'s Select in a Field.
///
/// ```swift
/// QeetrixSelect("Country", selection: $country, options: countries, placeholder: Text("Choose a country"))
/// ```
///
/// The trigger looks like a field (design rules §8): the filled box with its bottom line, the value in
/// `body.md` or the placeholder in `color.text.subtlest`, and a trailing 16 pt sharp chevron in
/// `color.icon.default`. `size` gives it a toolbar's height beside buttons of the same size (`lg`, the
/// field height, by default; `sm` also takes `body.sm`). The list is the system menu (ADR 0012): the
/// chosen option carries the system checkmark, disabled options are dimmed, and it opens from a tap, a
/// keyboard or VoiceOver like any menu. VoiceOver reads the trigger as a pop-up button named by the
/// label, with the chosen option as its value.
public struct QeetrixSelect<Value: Hashable>: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let selection: Binding<Value>
    let options: [QeetrixOption<Value>]
    let placeholder: Text?
    let size: QeetrixControlSize
    let isReadOnly: Bool

    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Value>,
        options: [QeetrixOption<Value>],
        placeholder: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        size: QeetrixControlSize = .lg,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false
    ) {
        self.init(
            label: Text(titleKey), selection: selection, options: options, placeholder: placeholder, description: description,
            error: error, size: size, isRequired: isRequired, isOptional: isOptional, isReadOnly: isReadOnly)
    }

    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Value>,
        options: [QeetrixOption<Value>],
        placeholder: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        size: QeetrixControlSize = .lg,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false
    ) {
        self.init(
            label: Text(title), selection: selection, options: options, placeholder: placeholder, description: description,
            error: error, size: size, isRequired: isRequired, isOptional: isOptional, isReadOnly: isReadOnly)
    }

    public init(
        label: Text,
        selection: Binding<Value>,
        options: [QeetrixOption<Value>],
        placeholder: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        size: QeetrixControlSize = .lg,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false
    ) {
        context = QeetrixFieldContext(label: label, description: description, error: error, isRequired: isRequired)
        self.isOptional = isOptional
        self.selection = selection
        self.options = options
        self.placeholder = placeholder
        self.size = size
        self.isReadOnly = isReadOnly
    }

    public var body: some View {
        QeetrixFieldLayout(context: context, isOptional: isOptional) {
            QeetrixSelectTrigger(selection: selection, options: options, placeholder: placeholder, size: size, isReadOnly: isReadOnly)
        }
    }
}

struct QeetrixSelectTrigger<Value: Hashable>: View {
    let selection: Binding<Value>
    let options: [QeetrixOption<Value>]
    let placeholder: Text?
    let size: QeetrixControlSize
    let isReadOnly: Bool
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixFieldContext) private var context
    // Read here, not inside the menu's label (see `qeetrixControlBlockSize(_:lineHeight:scale:)`).
    @ScaledMetric(relativeTo: .body) private var bodyScale: CGFloat = 100
    @ScaledMetric(relativeTo: .footnote) private var footnoteScale: CGFloat = 100

    var body: some View {
        let selected = options.first { $0.value == selection.wrappedValue }
        let state = QeetrixInputState(
            isEnabled: isEnabled, isReadOnly: isReadOnly, isFocused: isFocused, isHovered: isHovered && !isReadOnly,
            isInvalid: context?.invalid ?? false)
        let type = QeetrixTypeSpec(size == .sm ? .bodySm : .bodyMd)
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
            HStack(spacing: QeetrixInputMetrics.gap) {
                ZStack(alignment: .leading) {
                    // A hidden line keeps an empty select one line tall at every text size.
                    Text(verbatim: "X").hidden()
                    (selected?.title ?? placeholder ?? Text(verbatim: ""))
                        .foregroundStyle(selected == nil ? QeetrixInputMetrics.placeholder : state.foreground)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                QeetrixIcon(.chevronDown, size: .sm, shape: .sharp)
                    .foregroundStyle(isEnabled ? QeetrixColor.iconDefault : QeetrixColor.iconDisabled)
            }
            .qeetrixTypeEnvironment(type)
            .padding(.horizontal, size == .sm ? QeetrixSpace.insetSm : QeetrixSpace.insetMd)
            .qeetrixControlBlockSize(
                density.controlHeight(size), lineHeight: type.tokens.size * CGFloat(type.tokens.lineHeight),
                scale: (type.textStyle == .footnote ? footnoteScale : bodyScale) / 100
            )
            .qeetrixInputSurface(state)
            .contentShape(Rectangle())
        }
        .buttonStyle(QeetrixPlainControlStyle())
        .disabled(isReadOnly)
        .qeetrixHitArea()
        .onHover { isHovered = $0 }
        .qeetrixFieldControlAccessibility()
        .accessibilityValue(selected?.title ?? placeholder ?? Text(verbatim: ""))
    }
}

struct QeetrixPlainControlStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
