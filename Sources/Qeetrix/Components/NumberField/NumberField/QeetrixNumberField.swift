import SwiftUI

/// A labelled numeric field with stepper buttons — the web's `NumberField` in a field.
///
/// ```swift
/// QeetrixNumberField("Seats", value: $seats, in: 1...250)
/// QeetrixNumberField("Discount", value: $discount, in: 0...100, step: Decimal(string: "0.5")!, fractionDigits: 1)
/// ```
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
///   corrected, not reported; report your own rules with `message`.
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

    // MARK: Int

    /// A whole-number field with a localised label.
    public init(
        _ titleKey: LocalizedStringKey,
        value: Binding<Int?>,
        in range: ClosedRange<Int>? = nil,
        step: Int = 1,
        prompt: Text? = nil,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(titleKey), value: value, in: range, step: step, prompt: prompt, description: description, message: message,
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
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(title), value: value, in: range, step: step, prompt: prompt, description: description, message: message,
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
    ///   - message: An error, warning or success message under the field; it also colours the boundary.
    ///   - isRequired: Marks the label with an asterisk, and tells VoiceOver the field is required.
    ///   - isOptional: Marks the label "(optional)" instead. Ignored when `isRequired` is true.
    public init(
        label: Text,
        value: Binding<Int?>,
        in range: ClosedRange<Int>? = nil,
        step: Int = 1,
        prompt: Text? = nil,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            context: QeetrixFieldContext(label: label, description: description, message: message, isRequired: isRequired),
            isOptional: isOptional,
            value: Binding(
                get: { value.wrappedValue.map { Decimal($0) } },
                set: { value.wrappedValue = $0.map(QeetrixNumberParser.integer) }),
            range: range.map { Decimal($0.lowerBound)...Decimal($0.upperBound) }, step: Decimal(step), fractionDigits: 0, prompt: prompt)
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
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(titleKey), value: value, in: range, step: step, fractionDigits: fractionDigits, prompt: prompt,
            description: description, message: message, isRequired: isRequired, isOptional: isOptional)
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
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            label: Text(title), value: value, in: range, step: step, fractionDigits: fractionDigits, prompt: prompt,
            description: description, message: message, isRequired: isRequired, isOptional: isOptional)
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
    ///   - message: An error, warning or success message under the field; it also colours the boundary.
    ///   - isRequired: Marks the label with an asterisk, and tells VoiceOver the field is required.
    ///   - isOptional: Marks the label "(optional)" instead. Ignored when `isRequired` is true.
    public init(
        label: Text,
        value: Binding<Decimal?>,
        in range: ClosedRange<Decimal>? = nil,
        step: Decimal = 1,
        fractionDigits: Int = 2,
        prompt: Text? = nil,
        description: Text? = nil,
        message: QeetrixFieldMessage? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false
    ) {
        self.init(
            context: QeetrixFieldContext(label: label, description: description, message: message, isRequired: isRequired),
            isOptional: isOptional, value: value, range: range, step: step, fractionDigits: fractionDigits, prompt: prompt)
    }

    private init(
        context: QeetrixFieldContext, isOptional: Bool, value: Binding<Decimal?>, range: ClosedRange<Decimal>?, step: Decimal,
        fractionDigits: Int, prompt: Text?
    ) {
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
            QeetrixNumberInput(value: value, range: range, step: step, fractionDigits: fractionDigits, prompt: prompt)
        }
    }
}

struct QeetrixNumberInput: View {
    let value: Binding<Decimal?>
    let range: ClosedRange<Decimal>?
    let step: Decimal
    let fractionDigits: Int
    let prompt: Text?

    @State private var text = ""
    @FocusState private var isFocused: Bool
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.locale) private var locale
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixFieldContext) private var context

    private var allowsFraction: Bool { fractionDigits > 0 }
    private var allowsNegative: Bool { (range?.lowerBound ?? -1) < 0 }

    var body: some View {
        let state = QeetrixFieldState(
            isEnabled: isEnabled, isReadOnly: false, isFocused: isFocused, isHovered: isHovered, tone: context?.message?.tone)
        let height = QeetrixInputTokens.height(density)
        HStack(spacing: 0) {
            stepper(.decrease, height: height)
            TextField(text: $text, prompt: (prompt ?? Text(verbatim: "")).foregroundStyle(QeetrixInputTokens.placeholder)) {
                context?.label ?? Text(verbatim: "")
            }
            .multilineTextAlignment(.center)
            .monospacedDigit()  // tabular-nums
            .qeetrixTextInputTraits(.number(allowsFraction: allowsFraction, allowsNegative: allowsNegative))
            .focused($isFocused)
            .qeetrixFieldControlAccessibility()
            .padding(.horizontal, QeetrixWebScale.spacing(2))  // px-2
            .padding(.vertical, QeetrixWebScale.spacing(1))
            // A number reads in number order whatever the layout direction (the web's dir="auto").
            .environment(\.layoutDirection, .leftToRight)
            stepper(.increase, height: height)
        }
        .qeetrixType(QeetrixTextFieldMetrics.textType)
        .foregroundStyle(QeetrixInputTokens.foreground)
        .frame(minHeight: height)
        .qeetrixFieldSurface(state)
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

    /// A stepper: as wide as the field is tall, a 16 pt minus or plus, divided from the input by a
    /// hairline, disabled at its end of the range.
    private func stepper(_ direction: Direction, height: CGFloat) -> some View {
        let current = value.wrappedValue
        let atEnd: Bool =
            switch direction {
            case .decrease: current.map { $0 <= (range?.lowerBound ?? $0 - 1) } ?? false
            case .increase: current.map { $0 >= (range?.upperBound ?? $0 + 1) } ?? false
            }
        let innerCorner = max(0, QeetrixInputTokens.corner - QeetrixStroke.hairline)
        return Button {
            let next = QeetrixNumberParser.stepped(current, by: direction == .increase ? step : -step, range: range)
            value.wrappedValue = next
            text = display(next)
        } label: {
            QeetrixIcon(direction == .increase ? .plus : .minus, size: QeetrixIconSize(QeetrixWebScale.spacing(4)))  // [&_svg]:size-4
                .qeetrixIconSquare(height, icon: QeetrixWebScale.spacing(4))  // w-(--qx-component-input-height)
                .contentShape(Rectangle())
        }
        .buttonStyle(
            QeetrixFieldActionStyle(cornerRadius: innerCorner)
        )
        .disabled(atEnd)
        .overlay(alignment: direction == .decrease ? .trailing : .leading) {
            Rectangle().fill(QeetrixColor.borderDefault).frame(width: QeetrixStroke.hairline)  // border-e / border-s
        }
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
