import SwiftUI

/// A number, typed or stepped, with its label, help text and error — `@qeetrix/react`'s NumberField in
/// a Field.
///
/// ```swift
/// QeetrixNumberField("Seats", value: $seats, in: 1...250)
/// QeetrixNumberField("Discount", value: $discount, in: 0...100, step: Decimal(string: "0.5")!, fractionDigits: 1, endAdornment: Text("%"))
/// QeetrixNumberField("Amount", value: $amount, startAdornment: Text("₹"), showsSteppers: false)
/// ```
///
/// The box is the Qeetrix field, the value in tabular figures, units as affixes in
/// `color.text.subtle`, and — unless `showsSteppers` is false, for amounts nobody steps through — the
/// − and + steppers at its end: square `size.control.sm` buttons behind a hairline.
///
/// The value is an `Int?` or a `Decimal?` — `Decimal` so a fractional value is exact, never rounded
/// through binary floating point. `nil` is an empty field.
///
/// - **Typing** keeps its own text, so in-between states — a lone minus sign, a trailing decimal
///   separator — are never rejected or rewritten while the person types. The value follows the text
///   whenever the text is a number inside the range.
/// - **Committing** (Return, or leaving the field) settles the text: a number outside the range is
///   brought to its nearest end, a decimal is rounded to `fractionDigits`, text that is not a number goes
///   back to the last value, and the value is shown formatted, with grouping. Range errors are therefore
///   corrected, not reported; report your own rules with `error`.
/// - **Locale**: the environment's locale decides the decimal separator, grouping and digits; digits from
///   any script are read. The keypad is the number pad, the decimal pad, or — when negative values are
///   allowed, since neither pad has a minus key — the numbers-and-punctuation keyboard.
/// - **Steppers** change the value by `step`, are disabled at the ends of the range, and are named
///   "Decrease" and "Increase" for VoiceOver.
public struct QeetrixNumberField: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let value: Binding<Decimal?>
    let range: ClosedRange<Decimal>?
    let step: Decimal
    let fractionDigits: Int
    let prompt: Text?
    let startAdornment: Text?
    let endAdornment: Text?
    let showsSteppers: Bool

    // MARK: Int

    /// A whole-number field with a localised label.
    public init(
        _ titleKey: LocalizedStringKey,
        value: Binding<Int?>,
        in range: ClosedRange<Int>? = nil,
        step: Int = 1,
        prompt: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        startAdornment: Text? = nil,
        endAdornment: Text? = nil,
        showsSteppers: Bool = true,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(titleKey), value: value, in: range, step: step, prompt: prompt, description: description, error: error,
            startAdornment: startAdornment, endAdornment: endAdornment, showsSteppers: showsSteppers,
            isRequired: isRequired, isOptional: isOptional)
    }

    /// A whole-number field with a label shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        value: Binding<Int?>,
        in range: ClosedRange<Int>? = nil,
        step: Int = 1,
        prompt: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        startAdornment: Text? = nil,
        endAdornment: Text? = nil,
        showsSteppers: Bool = true,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(title), value: value, in: range, step: step, prompt: prompt, description: description, error: error,
            startAdornment: startAdornment, endAdornment: endAdornment, showsSteppers: showsSteppers,
            isRequired: isRequired, isOptional: isOptional)
    }

    /// A whole-number field with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: The label above the field, which also names it for VoiceOver.
    ///   - value: The number, or `nil` for an empty field.
    ///   - range: The allowed values. A committed number outside it is brought to its nearest end.
    ///   - step: How much a stepper changes the value.
    ///   - prompt: Placeholder text, shown while the field is empty.
    ///   - description: Help shown under the field.
    ///   - error: What to fix, already localised. It replaces the description and frames the field in
    ///     the danger colour.
    ///   - startAdornment: A unit before the value, such as ₹.
    ///   - endAdornment: A unit after the value, such as % or "minutes".
    ///   - showsSteppers: Whether the − and + steppers show. Turn them off for amounts nobody steps through.
    ///   - isRequired: Tells VoiceOver the field is required. Nothing is drawn: Qeetrix marks optional
    ///     fields, never required ones.
    ///   - isOptional: Appends "(optional)" to the label.
    public init(
        label: Text,
        value: Binding<Int?>,
        in range: ClosedRange<Int>? = nil,
        step: Int = 1,
        prompt: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        startAdornment: Text? = nil,
        endAdornment: Text? = nil,
        showsSteppers: Bool = true,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            context: QeetrixFieldContext(label: label, description: description, error: error, isRequired: isRequired),
            isOptional: isOptional,
            value: Binding(
                get: { value.wrappedValue.map { Decimal($0) } },
                set: { value.wrappedValue = $0.map(QeetrixNumberParser.integer) }),
            range: range.map { Decimal($0.lowerBound)...Decimal($0.upperBound) }, step: Decimal(step), fractionDigits: 0, prompt: prompt,
            startAdornment: startAdornment, endAdornment: endAdornment, showsSteppers: showsSteppers)
    }

    // MARK: Decimal

    /// A decimal field with a localised label.
    public init(
        _ titleKey: LocalizedStringKey,
        value: Binding<Decimal?>,
        in range: ClosedRange<Decimal>? = nil,
        step: Decimal = 1,
        fractionDigits: Int = 2,
        prompt: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        startAdornment: Text? = nil,
        endAdornment: Text? = nil,
        showsSteppers: Bool = true,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(titleKey), value: value, in: range, step: step, fractionDigits: fractionDigits, prompt: prompt,
            description: description, error: error, startAdornment: startAdornment, endAdornment: endAdornment,
            showsSteppers: showsSteppers, isRequired: isRequired, isOptional: isOptional)
    }

    /// A decimal field with a label shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        value: Binding<Decimal?>,
        in range: ClosedRange<Decimal>? = nil,
        step: Decimal = 1,
        fractionDigits: Int = 2,
        prompt: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        startAdornment: Text? = nil,
        endAdornment: Text? = nil,
        showsSteppers: Bool = true,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(title), value: value, in: range, step: step, fractionDigits: fractionDigits, prompt: prompt,
            description: description, error: error, startAdornment: startAdornment, endAdornment: endAdornment,
            showsSteppers: showsSteppers, isRequired: isRequired, isOptional: isOptional)
    }

    /// A decimal field with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: The label above the field, which also names it for VoiceOver.
    ///   - value: The number, or `nil` for an empty field.
    ///   - range: The allowed values. A committed number outside it is brought to its nearest end.
    ///   - step: How much a stepper changes the value.
    ///   - fractionDigits: The most fraction digits a committed value keeps, and shows.
    ///   - prompt: Placeholder text, shown while the field is empty.
    ///   - description: Help shown under the field.
    ///   - error: What to fix, already localised. It replaces the description and frames the field in
    ///     the danger colour.
    ///   - startAdornment: A unit before the value, such as ₹.
    ///   - endAdornment: A unit after the value, such as % or "minutes".
    ///   - showsSteppers: Whether the − and + steppers show. Turn them off for amounts nobody steps through.
    ///   - isRequired: Tells VoiceOver the field is required. Nothing is drawn: Qeetrix marks optional
    ///     fields, never required ones.
    ///   - isOptional: Appends "(optional)" to the label.
    public init(
        label: Text,
        value: Binding<Decimal?>,
        in range: ClosedRange<Decimal>? = nil,
        step: Decimal = 1,
        fractionDigits: Int = 2,
        prompt: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        startAdornment: Text? = nil,
        endAdornment: Text? = nil,
        showsSteppers: Bool = true,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            context: QeetrixFieldContext(label: label, description: description, error: error, isRequired: isRequired),
            isOptional: isOptional, value: value, range: range, step: step, fractionDigits: fractionDigits, prompt: prompt,
            startAdornment: startAdornment, endAdornment: endAdornment, showsSteppers: showsSteppers)
    }

    private init(
        context: QeetrixFieldContext, isOptional: Bool, value: Binding<Decimal?>, range: ClosedRange<Decimal>?, step: Decimal,
        fractionDigits: Int, prompt: Text?, startAdornment: Text?, endAdornment: Text?, showsSteppers: Bool
    ) {
        self.startAdornment = startAdornment
        self.endAdornment = endAdornment
        self.showsSteppers = showsSteppers
        self.context = context
        self.isOptional = isOptional
        self.value = value
        self.range = range
        self.step = step
        self.fractionDigits = max(0, fractionDigits)
        self.prompt = prompt
    }

    public var body: some View {
        QeetrixFieldLayout(context: context, isOptional: isOptional) {
            QeetrixNumberInput(
                value: value, range: range, step: step, fractionDigits: fractionDigits, prompt: prompt, startAdornment: startAdornment,
                endAdornment: endAdornment, showsSteppers: showsSteppers)
        }
    }
}

struct QeetrixNumberInput: View {
    let value: Binding<Decimal?>
    let range: ClosedRange<Decimal>?
    let step: Decimal
    let fractionDigits: Int
    let prompt: Text?
    var startAdornment: Text?
    var endAdornment: Text?
    var showsSteppers = true

    @State private var text = ""
    @FocusState private var isFocused: Bool
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.locale) private var locale
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixFieldContext) private var context
    /// The steppers grow with their icons at larger text sizes.
    @ScaledMetric(relativeTo: .body) private var stepperScale: CGFloat = 100

    private var allowsFraction: Bool { fractionDigits > 0 }
    private var allowsNegative: Bool { (range?.lowerBound ?? -1) < 0 }

    var body: some View {
        let state = QeetrixInputState(
            isEnabled: isEnabled, isReadOnly: false, isFocused: isFocused, isHovered: isHovered, isInvalid: context?.invalid ?? false)
        HStack(spacing: QeetrixInputMetrics.gap) {
            if let startAdornment {
                startAdornment.foregroundStyle(isEnabled ? QeetrixColor.textSubtle : QeetrixColor.textDisabled).accessibilityHidden(true)
            }
            TextField(text: $text, prompt: (prompt ?? Text(verbatim: "")).foregroundStyle(QeetrixInputMetrics.placeholder)) {
                context?.label ?? Text(verbatim: "")
            }
            .monospacedDigit()
            .qeetrixTextInputTraits(.number(allowsFraction: allowsFraction, allowsNegative: allowsNegative))
            .tint(QeetrixColor.borderFocus)
            .focused($isFocused)
            .qeetrixFieldControlAccessibility()
            if let endAdornment {
                endAdornment.foregroundStyle(isEnabled ? QeetrixColor.textSubtle : QeetrixColor.textDisabled).accessibilityHidden(true)
            }
            if showsSteppers {
                steppers
            }
        }
        // A number reads in number order whatever the layout direction (the web's dir="auto").
        .environment(\.layoutDirection, .leftToRight)
        .qeetrixTypeEnvironment(QeetrixInputMetrics.textType)
        .padding(.leading, QeetrixInputMetrics.padding)
        .padding(.trailing, showsSteppers ? QeetrixSpace.gapXs : QeetrixInputMetrics.padding)
        .qeetrixControlBlockSize(QeetrixInputMetrics.height(density), type: QeetrixInputMetrics.textType)
        .qeetrixInputSurface(state)
        .onHover { isHovered = $0 }
        .onAppear { text = display(value.wrappedValue) }
        .onChange(of: text) { _, newText in edit(newText) }
        .onSubmit(of: .text) { commit() }
        .onChange(of: isFocused) { _, focused in
            if !focused { commit() }
        }
        .onChange(of: value.wrappedValue) { _, newValue in
            // The app changed the value: show it, unless the person is typing it.
            if !isFocused { text = display(newValue) }
        }
        .onChange(of: locale) { _, _ in
            if !isFocused { text = display(value.wrappedValue) }
        }
    }

    private enum Direction {
        case decrease
        case increase
    }

    /// The steppers (number-field.css): after a hairline in `color.border.default`, 4 pt in, two
    /// square `size.control.sm` buttons 2 pt apart.
    private var steppers: some View {
        HStack(spacing: 2) {
            stepper(.decrease)
            stepper(.increase)
        }
        .padding(.leading, QeetrixSpace.gapXs)
        .overlay(alignment: .leading) {
            Rectangle().fill(QeetrixColor.borderDefault).frame(width: QeetrixBorderWidth.default).accessibilityHidden(true)
        }
    }

    /// A stepper: a 16 pt sharp minus or plus in `color.icon.default`, the overlay tints when pressed or
    /// hovered, disabled at its end of the range.
    private func stepper(_ direction: Direction) -> some View {
        let current = value.wrappedValue
        let atEnd: Bool =
            switch direction {
            case .decrease: current.map { $0 <= (range?.lowerBound ?? $0 - 1) } ?? false
            case .increase: current.map { $0 >= (range?.upperBound ?? $0 + 1) } ?? false
            }
        let side = density.sizeControlSm * stepperScale / 100
        return Button {
            let next = QeetrixNumberParser.stepped(current, by: direction == .increase ? step : -step, range: range)
            value.wrappedValue = next
            text = display(next)
        } label: {
            QeetrixIcon(direction == .increase ? .plus : .minus, size: .sm, shape: .sharp)
                .frame(width: side, height: side)
                .contentShape(Rectangle())
        }
        .buttonStyle(QeetrixStepperStyle())
        .disabled(atEnd)
        .qeetrixHitArea()
        .accessibilityLabel(direction == .increase ? QeetrixStrings.increase : QeetrixStrings.decrease)
    }

    private func display(_ value: Decimal?) -> String {
        value.map { QeetrixNumberParser.format($0, locale: locale, fractionDigits: fractionDigits) } ?? ""
    }

    /// While typing: follow the text whenever it is — or, with a trailing decimal separator, stands for — a
    /// number inside the range; leave everything else for the commit to settle.
    private func edit(_ newText: String) {
        guard isFocused else { return }
        switch QeetrixNumberParser.read(newText, locale: locale, allowsFraction: allowsFraction, allowsNegative: allowsNegative) {
        case .empty:
            value.wrappedValue = nil
        case .number(let number):
            if range?.contains(number) ?? true { value.wrappedValue = number }
        case .partial:
            let number = QeetrixNumberParser.partialValue(
                newText, locale: locale, allowsFraction: allowsFraction, allowsNegative: allowsNegative)
            if let number, range?.contains(number) ?? true { value.wrappedValue = number }
        case .invalid:
            break
        }
    }

    /// Settle the text: clamp and round a number, empty an empty field, restore the last value otherwise.
    private func commit() {
        switch QeetrixNumberParser.read(text, locale: locale, allowsFraction: allowsFraction, allowsNegative: allowsNegative) {
        case .empty:
            value.wrappedValue = nil
        case .number(let number):
            value.wrappedValue = QeetrixNumberParser.clamped(QeetrixNumberParser.rounded(number, fractionDigits: fractionDigits), to: range)
        case .partial, .invalid:
            break
        }
        text = display(value.wrappedValue)
    }
}

/// A number field's stepper button: transparent, `color.overlay.hover` under a pointer and
/// `color.overlay.pressed` when pressed, 4 pt corners.
struct QeetrixStepperStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        QeetrixStepperBody(configuration: configuration)
    }
}

private struct QeetrixStepperBody: View {
    let configuration: ButtonStyleConfiguration
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let background: QeetrixColor? = !isEnabled ? nil : configuration.isPressed ? .overlayPressed : isHovered ? .overlayHover : nil
        configuration.label
            .foregroundStyle(isEnabled ? QeetrixColor.iconDefault : QeetrixColor.iconDisabled)
            .background { if let background { RoundedRectangle(cornerRadius: QeetrixRadius.control).fill(background) } }
            .onHover { isHovered = $0 }
            .qeetrixAnimation(.standard, .fast, value: configuration.isPressed)
    }
}
