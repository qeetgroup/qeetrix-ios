import SwiftUI

/// How a ``QeetrixSlider`` writes its value and its bounds, with ``QeetrixFormat`` in the environment's
/// locale — the web's `format` (`Intl.NumberFormatOptions`) as typed choices.
public struct QeetrixSliderFormat: Hashable, Sendable {
    enum Kind: Hashable, Sendable {
        case number
        case percent
        case currency(String)
    }

    let kind: Kind
    let fractionDigits: ClosedRange<Int>?

    /// A number, with up to three fraction digits: "40", "2.5". The default.
    public static let number = QeetrixSliderFormat(kind: .number, fractionDigits: nil)
    /// A number with these fraction digits.
    public static func number(fractionDigits: ClosedRange<Int>) -> QeetrixSliderFormat {
        QeetrixSliderFormat(kind: .number, fractionDigits: fractionDigits)
    }
    /// A fraction as a whole percentage: 0.4 is "40%". Give the slider bounds such as `0...1`.
    public static let percent = QeetrixSliderFormat(kind: .percent, fractionDigits: nil)
    /// A fraction as a percentage with these fraction digits.
    public static func percent(fractionDigits: ClosedRange<Int>) -> QeetrixSliderFormat {
        QeetrixSliderFormat(kind: .percent, fractionDigits: fractionDigits)
    }
    /// An amount of money in an ISO 4217 currency: "₹25,000" with `fractionDigits: 0...0`.
    public static func currency(_ code: String, fractionDigits: ClosedRange<Int>? = nil) -> QeetrixSliderFormat {
        QeetrixSliderFormat(kind: .currency(code), fractionDigits: fractionDigits)
    }

    func string(_ value: Double, locale: Locale) -> String {
        switch kind {
        case .number: QeetrixFormat.number(value, fractionDigits: fractionDigits, locale: locale)
        case .percent: QeetrixFormat.percent(value, fractionDigits: fractionDigits, locale: locale)
        case .currency(let code): QeetrixFormat.currency(value, code: code, fractionDigits: fractionDigits, locale: locale)
        }
    }
}

/// A number, or a range, on a continuous scale where the position matters more than the exact value —
/// `@qeetrix/react`'s Slider, as its own field.
///
/// ```swift
/// QeetrixSlider("Discount", value: $discount, in: 0...50, step: 5, showsValue: true)
/// QeetrixSlider(
///     "Budget", range: $budget, in: 0...100_000, step: 500, format: .currency("INR", fractionDigits: 0...0), showsBounds: true)
/// ```
///
/// The label (the field label's look) is at the start of the header and, with `showsValue`, the value in
/// `label.sm` tabular figures at its end. Under them, a 4 pt `color.border.default` track with square
/// ends, filled `color.bg.brand.bold` up to the thumb — or between the two thumbs of a range — and each
/// thumb a 16 pt square with 2 pt corners in Ember, inside a 2 pt `color.surface.default` ring so it reads
/// on the fill (slider.css). `showsBounds` writes the minimum and the maximum under the track's ends.
/// The description, or the error that replaces it, is under the slider as in every field. When the
/// exact value matters, use a ``QeetrixNumberField``.
///
/// The control is 44 pt tall and each thumb a 44 pt target: a drag anywhere on it moves the nearest
/// thumb, and a tap moves it there; a range's thumbs never cross. Values snap to `step` from the
/// minimum. VoiceOver reads each thumb as adjustable, by the label — a range's as "Budget, minimum" and
/// "Budget, maximum" — with its value written by `format`; swiping up or down moves it a step, or by
/// `largeStep` when the slider has more than 20 steps. A hardware keyboard steps with the arrow keys,
/// takes `largeStep` with Page Up and Page Down, and jumps to the ends with Home and End. In right-to-left
/// layouts the minimum is at the right.
///
/// Qeetrix draws the control rather than styling SwiftUI's `Slider`: the system slider takes only a
/// tint — its round thumb, rounded track and shadow can't take the web's look — and has no range.
public struct QeetrixSlider: View {
    let context: QeetrixFieldContext
    let values: [Double]
    let set: (Int, Double) -> Void
    let model: QeetrixSliderModel
    let format: QeetrixSliderFormat
    let showsValue: Bool
    let showsBounds: Bool
    let onEditingChanged: (Bool) -> Void
    @Environment(\.locale) private var locale
    @Environment(\.isEnabled) private var isEnabled

    /// A slider for one value with a localised label.
    public init(
        _ titleKey: LocalizedStringKey,
        value: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...100,
        step: Double = 1,
        largeStep: Double? = nil,
        format: QeetrixSliderFormat = .number,
        showsValue: Bool = false,
        showsBounds: Bool = false,
        description: Text? = nil,
        error: String? = nil,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.init(
            label: Text(titleKey), value: value, in: bounds, step: step, largeStep: largeStep, format: format, showsValue: showsValue,
            showsBounds: showsBounds, description: description, error: error, onEditingChanged: onEditingChanged)
    }

    /// A slider for one value with a label shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        value: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...100,
        step: Double = 1,
        largeStep: Double? = nil,
        format: QeetrixSliderFormat = .number,
        showsValue: Bool = false,
        showsBounds: Bool = false,
        description: Text? = nil,
        error: String? = nil,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.init(
            label: Text(title), value: value, in: bounds, step: step, largeStep: largeStep, format: format, showsValue: showsValue,
            showsBounds: showsBounds, description: description, error: error, onEditingChanged: onEditingChanged)
    }

    /// A slider for one value with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: Names the slider, and its thumb for VoiceOver.
    ///   - value: The value, kept inside `bounds` on a step.
    ///   - bounds: The minimum and the maximum: `0...100` by default.
    ///   - step: The distance between the values it takes, from the minimum: 1 by default.
    ///   - largeStep: How far Page Up and Page Down move it, and VoiceOver on a slider of more than 20
    ///     steps; by default a tenth of the range, on a step.
    ///   - format: How the value and bounds are written.
    ///   - showsValue: Shows the value at the end of the header.
    ///   - showsBounds: Writes the minimum and the maximum under the track's ends.
    ///   - description: Help under the slider, read by VoiceOver as the thumb's hint.
    ///   - error: What to fix, already localised; it replaces the description.
    ///   - onEditingChanged: Called with `true` when a drag starts and `false` when it ends, to commit a
    ///     value once (the web's `onValueCommitted`).
    public init(
        label: Text,
        value: Binding<Double>,
        in bounds: ClosedRange<Double> = 0...100,
        step: Double = 1,
        largeStep: Double? = nil,
        format: QeetrixSliderFormat = .number,
        showsValue: Bool = false,
        showsBounds: Bool = false,
        description: Text? = nil,
        error: String? = nil,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        let model = QeetrixSliderModel(bounds: bounds, step: step, largeStep: largeStep)
        context = QeetrixFieldContext(label: label, description: description, error: error)
        values = [model.snapped(value.wrappedValue)]
        set = { _, newValue in value.wrappedValue = newValue }
        self.model = model
        self.format = format
        self.showsValue = showsValue
        self.showsBounds = showsBounds
        self.onEditingChanged = onEditingChanged
    }

    /// A slider for a range with a localised label.
    public init(
        _ titleKey: LocalizedStringKey,
        range: Binding<ClosedRange<Double>>,
        in bounds: ClosedRange<Double> = 0...100,
        step: Double = 1,
        largeStep: Double? = nil,
        format: QeetrixSliderFormat = .number,
        showsValue: Bool = false,
        showsBounds: Bool = false,
        description: Text? = nil,
        error: String? = nil,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.init(
            label: Text(titleKey), range: range, in: bounds, step: step, largeStep: largeStep, format: format, showsValue: showsValue,
            showsBounds: showsBounds, description: description, error: error, onEditingChanged: onEditingChanged)
    }

    /// A slider for a range with a label shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        range: Binding<ClosedRange<Double>>,
        in bounds: ClosedRange<Double> = 0...100,
        step: Double = 1,
        largeStep: Double? = nil,
        format: QeetrixSliderFormat = .number,
        showsValue: Bool = false,
        showsBounds: Bool = false,
        description: Text? = nil,
        error: String? = nil,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.init(
            label: Text(title), range: range, in: bounds, step: step, largeStep: largeStep, format: format, showsValue: showsValue,
            showsBounds: showsBounds, description: description, error: error, onEditingChanged: onEditingChanged)
    }

    /// A slider for a range with a `Text` label: two thumbs, the fill between them. The parameters are
    /// the one-value slider's; `range` is kept inside `bounds`, each end on a step.
    public init(
        label: Text,
        range: Binding<ClosedRange<Double>>,
        in bounds: ClosedRange<Double> = 0...100,
        step: Double = 1,
        largeStep: Double? = nil,
        format: QeetrixSliderFormat = .number,
        showsValue: Bool = false,
        showsBounds: Bool = false,
        description: Text? = nil,
        error: String? = nil,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        let model = QeetrixSliderModel(bounds: bounds, step: step, largeStep: largeStep)
        context = QeetrixFieldContext(label: label, description: description, error: error)
        values = [model.snapped(range.wrappedValue.lowerBound), model.snapped(range.wrappedValue.upperBound)]
        set = { index, newValue in range.wrappedValue = model.moving(range.wrappedValue, end: index, to: newValue) }
        self.model = model
        self.format = format
        self.showsValue = showsValue
        self.showsBounds = showsBounds
        self.onEditingChanged = onEditingChanged
    }

    public var body: some View {
        let written = values.map { format.string($0, locale: locale) }
        QeetrixFieldLayout(context: context, isOptional: false, isLabelHidden: true) {
            VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                // `.qx-slider-header`: the label at the start, the value at the end, on one baseline.
                HStack(alignment: .firstTextBaseline, spacing: QeetrixSpace.gapMd) {
                    QeetrixFieldLabel(label: context.label, isOptional: false)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if showsValue {
                        Text(verbatim: written.joined(separator: " – "))
                            .qeetrixTextStyle(.labelSm)
                            .monospacedDigit()
                            .foregroundStyle(isEnabled ? QeetrixColor.textDefault : QeetrixColor.textDisabled)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                // The thumbs say the label and the value.
                .accessibilityHidden(true)
                QeetrixSliderControl(
                    values: values, model: model, names: names, spoken: written, set: set, onEditingChanged: onEditingChanged)
                if showsBounds {
                    HStack(alignment: .firstTextBaseline, spacing: QeetrixSpace.gapMd) {
                        Text(verbatim: format.string(model.bounds.lowerBound, locale: locale))
                        Spacer(minLength: 0)
                        Text(verbatim: format.string(model.bounds.upperBound, locale: locale))
                    }
                    .qeetrixTextStyle(.labelSm)
                    .monospacedDigit()
                    .foregroundStyle(isEnabled ? QeetrixColor.textSubtle : QeetrixColor.textDisabled)
                    .accessibilityHidden(true)
                }
            }
        }
    }

    /// Each thumb's VoiceOver name: the label, or in a range "Budget, minimum" and "Budget, maximum"
    /// (`slider.minimumOf`, `slider.maximumOf`), with "Required" after it.
    private var names: [Text] {
        guard values.count == 2 else { return [context.accessibilityLabel] }
        return [QeetrixSliderStrings.minimumOf(context.label), QeetrixSliderStrings.maximumOf(context.label)]
    }
}

/// The slider's arithmetic: values on steps inside the bounds, positions along the track, the keys' and
/// VoiceOver's moves.
struct QeetrixSliderModel {
    let bounds: ClosedRange<Double>
    let step: Double
    let largeStep: Double

    init(bounds: ClosedRange<Double>, step: Double, largeStep: Double? = nil) {
        self.bounds = bounds
        let span = bounds.upperBound - bounds.lowerBound
        let step = step > 0 && step.isFinite ? step : 1
        self.step = step
        // Base UI's default `largeStep` is 10 on its default 0–100: a tenth of the range, on a step.
        self.largeStep = largeStep.map { Swift.max($0, step) } ?? Swift.max(step, (span / 10 / step).rounded() * step)
    }

    var span: Double { bounds.upperBound - bounds.lowerBound }

    /// The value on the nearest step from the minimum, inside the bounds — the last step under the
    /// maximum where the bounds aren't a whole number of steps apart.
    func snapped(_ raw: Double) -> Double {
        guard raw.isFinite else { return bounds.lowerBound }
        let clamped = Swift.min(Swift.max(raw, bounds.lowerBound), bounds.upperBound)
        var steps = ((clamped - bounds.lowerBound) / step).rounded()
        if bounds.lowerBound + steps * step > bounds.upperBound + step * 1e-9 { steps -= 1 }
        // Shed floating-point noise, so 3 steps of 0.1 are 0.3.
        let value = ((bounds.lowerBound + steps * step) * 1e9).rounded() / 1e9
        return Swift.min(Swift.max(value, bounds.lowerBound), bounds.upperBound)
    }

    /// Where a value sits along the track, 0 at the minimum and 1 at the maximum.
    func fraction(_ value: Double) -> Double {
        span > 0 ? Swift.min(Swift.max((value - bounds.lowerBound) / span, 0), 1) : 0
    }

    /// The value at a point along the track, on a step.
    func value(atFraction fraction: Double) -> Double {
        snapped(bounds.lowerBound + Swift.min(Swift.max(fraction, 0), 1) * span)
    }

    /// How far VoiceOver's swipe moves a thumb: a step, or `largeStep` on a slider of more than 20 steps,
    /// so a fine slider doesn't take a hundred swipes.
    var accessibilityStep: Double {
        span / step > 20 ? largeStep : step
    }

    /// A range with one end moved, never past the other.
    func moving(_ range: ClosedRange<Double>, end index: Int, to value: Double) -> ClosedRange<Double> {
        let value = snapped(value)
        let lower = snapped(range.lowerBound)
        let upper = snapped(range.upperBound)
        return index == 0 ? Swift.min(value, upper)...upper : lower...Swift.max(value, lower)
    }

    /// The thumb a drag that starts at `value` moves: the nearest, or between two at the same place, the
    /// one on the side the drag goes.
    static func nearest(to value: Double, in values: [Double]) -> Int {
        guard values.count == 2 else { return 0 }
        let first = abs(values[0] - value)
        let second = abs(values[1] - value)
        if first == second { return value > values[1] ? 1 : 0 }
        return first < second ? 0 : 1
    }

    /// Where a key moves a value: the arrows a step (left and right mirrored right to left), Page Up and
    /// Page Down a large step, Home and End to the ends.
    func target(of key: KeyEquivalent, from value: Double, isRightToLeft: Bool) -> Double? {
        let forward = isRightToLeft ? -step : step
        switch key {
        case .rightArrow: return snapped(value + forward)
        case .leftArrow: return snapped(value - forward)
        case .upArrow: return snapped(value + step)
        case .downArrow: return snapped(value - step)
        case .pageUp: return snapped(value + largeStep)
        case .pageDown: return snapped(value - largeStep)
        case .home: return bounds.lowerBound
        case .end: return snapped(bounds.upperBound)
        default: return nil
        }
    }
}

/// The track and thumbs (slider.css `.qx-slider-control`), drawn left to right and mirrored by hand in
/// right-to-left layouts, so a drag's position and the drawing agree.
struct QeetrixSliderControl: View {
    let values: [Double]
    let model: QeetrixSliderModel
    let names: [Text]
    let spoken: [String]
    let set: (Int, Double) -> Void
    let onEditingChanged: (Bool) -> Void
    @State private var dragging: Int?
    @State private var hovered: Int?
    @FocusState private var focused: Int?
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.qeetrixFieldContext) private var context

    /// `.qx-slider-track { block-size: 4px }`.
    static let trackHeight: CGFloat = 4
    /// `.qx-slider-thumb { block-size: 16px; inline-size: 16px }`.
    static let thumb: CGFloat = 16
    /// `.qx-slider-control { padding-inline: 8px }`: half a thumb, so it reaches each end.
    static let inset: CGFloat = 8

    var body: some View {
        let isRightToLeft = layoutDirection == .rightToLeft
        GeometryReader { proxy in
            let usable = Swift.max(0, proxy.size.width - 2 * Self.inset)
            let middle = proxy.size.height / 2
            // Fractions from the left edge.
            let positions = values.map { value -> CGFloat in
                let fraction = CGFloat(model.fraction(value))
                return isRightToLeft ? 1 - fraction : fraction
            }
            let filled = QeetrixSliderControl.filled(positions, isRightToLeft: isRightToLeft)
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(QeetrixColor.borderDefault)
                    .frame(width: usable, height: Self.trackHeight)
                    .position(x: Self.inset + usable / 2, y: middle)
                Rectangle()
                    .fill(isEnabled ? QeetrixColor.bgBrandBold : QeetrixColor.bgDisabled)
                    .frame(width: (filled.upperBound - filled.lowerBound) * usable, height: Self.trackHeight)
                    .position(x: Self.inset + (filled.lowerBound + filled.upperBound) / 2 * usable, y: middle)
                ForEach(values.indices, id: \.self) { index in
                    thumb(index, isRightToLeft: isRightToLeft)
                        .position(x: Self.inset + positions[index] * usable, y: middle)
                }
            }
            .contentShape(Rectangle())
            .gesture(drag(usable: usable, isRightToLeft: isRightToLeft), including: isEnabled ? .all : .none)
        }
        .frame(height: QeetrixAccessibility.minimumTouchTarget)
        .environment(\.layoutDirection, .leftToRight)
    }

    /// The filled part, from the left edge: up to a single thumb from the minimum's side, or between two.
    static func filled(_ positions: [CGFloat], isRightToLeft: Bool) -> ClosedRange<CGFloat> {
        guard positions.count == 2 else {
            let position = positions.first ?? 0
            return isRightToLeft ? position...1 : 0...position
        }
        return Swift.min(positions[0], positions[1])...Swift.max(positions[0], positions[1])
    }

    private func thumb(_ index: Int, isRightToLeft: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.sm)
        let ring = QeetrixBorderWidth.strong
        return
            shape
            .fill(thumbColor(index))
            .frame(width: Self.thumb, height: Self.thumb)
            // `box-shadow: 0 0 0 var(--qx-border-width-strong) var(--qx-color-surface-default)`.
            .background {
                RoundedRectangle(cornerRadius: QeetrixRadius.sm + ring).fill(QeetrixColor.surfaceDefault).padding(-ring)
            }
            .overlay {
                if focused == index { QeetrixOuterFocusFrame(shape: shape) }
            }
            .qeetrixAnimation(.standard, .fast, value: hovered == index)
            // Each thumb is a 44 pt target, and VoiceOver's frame for it.
            .frame(width: QeetrixAccessibility.minimumTouchTarget, height: QeetrixAccessibility.minimumTouchTarget)
            .contentShape(Rectangle())
            .onHover { isInside in hovered = isInside ? index : (hovered == index ? nil : hovered) }
            .focusable(isEnabled)
            .focused($focused, equals: index)
            .focusEffectDisabled()
            .onKeyPress(phases: [.down, .repeat]) { press in
                guard isEnabled, let value = model.target(of: press.key, from: values[index], isRightToLeft: isRightToLeft) else {
                    return .ignored
                }
                set(index, value)
                return .handled
            }
            // The system slider's semantics (ADR 0010) on this thumb's value: VoiceOver's adjustable
            // element, with Qeetrix's name, written value, help, error and step.
            .accessibilityRepresentation {
                Slider(value: accessibilityBinding(index), in: model.bounds, step: model.accessibilityStep) {
                    names[index]
                }
                .accessibilityValue(Text(verbatim: spoken[index]))
                .accessibilityHint(context?.description ?? Text(verbatim: ""))
                .accessibilityCustomContent(
                    AccessibilityCustomContentKey(QeetrixStrings.error, id: "qeetrix.field.error"),
                    context?.error.map { Text(verbatim: $0) }, importance: .high
                )
                .accessibilityAdjustableAction { direction in
                    guard isEnabled else { return }
                    switch direction {
                    case .increment: set(index, model.snapped(values[index] + model.accessibilityStep))
                    case .decrement: set(index, model.snapped(values[index] - model.accessibilityStep))
                    @unknown default: break
                    }
                }
            }
    }

    /// A thumb's value for its accessibility slider, written back on a step and, in a range, never past
    /// the other thumb.
    private func accessibilityBinding(_ index: Int) -> Binding<Double> {
        let values = self.values
        let set = self.set
        let model = self.model
        return Binding {
            values[index]
        } set: { newValue in
            set(index, model.snapped(newValue))
        }
    }

    private func thumbColor(_ index: Int) -> QeetrixColor {
        guard isEnabled else { return .iconDisabled }
        return hovered == index || dragging == index ? .bgBrandBoldHover : .bgBrandBold
    }

    private func drag(usable: CGFloat, isRightToLeft: Bool) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { drag in
                guard usable > 0 else { return }
                let fromLeft = (drag.location.x - Self.inset) / usable
                let value = model.value(atFraction: Double(isRightToLeft ? 1 - fromLeft : fromLeft))
                let index: Int
                if let dragging {
                    index = dragging
                } else {
                    index = QeetrixSliderModel.nearest(to: value, in: values)
                    dragging = index
                    onEditingChanged(true)
                }
                if value != values[index] { set(index, value) }
            }
            .onEnded { _ in
                if dragging != nil { onEditingChanged(false) }
                dragging = nil
            }
    }
}

/// The slider's built-in strings (`slider` in `@qeetrix/react`'s catalogue).
enum QeetrixSliderStrings {
    /// "Budget, minimum" — `slider.minimumOf`.
    static func minimumOf(_ label: Text) -> Text {
        filling(String(localized: "qeetrix.slider.minimum-of", defaultValue: "%@, minimum", bundle: .module), with: label)
    }

    /// "Budget, maximum" — `slider.maximumOf`.
    static func maximumOf(_ label: Text) -> Text {
        filling(String(localized: "qeetrix.slider.maximum-of", defaultValue: "%@, maximum", bundle: .module), with: label)
    }

    /// A template with its `%@` filled by a `Text`, which a format string can't take — as the web fills
    /// `{label}` with a node (`fillNode`).
    static func filling(_ template: String, with label: Text) -> Text {
        let parts = template.components(separatedBy: "%@")
        guard parts.count > 1 else { return Text(verbatim: template) }
        return Text(verbatim: parts[0]) + label + Text(verbatim: parts.dropFirst().joined(separator: "%@"))
    }
}
