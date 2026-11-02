import SwiftUI

/// What a stat's note says about the number, as `@qeetrix/react`'s `StatTone`: it colours the note.
public enum QeetrixStatTone: String, CaseIterable, Sendable {
    /// Context, not a judgement: `color.text.subtlest`. The default.
    case neutral
    /// Better: `color.text.success`.
    case positive
    /// Worse: `color.text.danger`.
    case negative
    /// Worth a look: `color.text.warning`.
    case warning

    var color: QeetrixColor {
        switch self {
        case .neutral: .textSubtlest
        case .positive: .textSuccess
        case .negative: .textDanger
        case .warning: .textWarning
        }
    }
}

/// A stat's number, written by ``QeetrixFormat`` in the environment's locale, as the web formats a
/// numeric `value` (or shows a node as given).
///
/// ```swift
/// QeetrixStat("Active users", value: 1_240_512)  // "12,40,512" in en-IN
/// QeetrixStat("Collected", value: .currency(1_842_600, code: "INR"))  // "₹18,42,600"
/// QeetrixStat("Uptime", value: .percent(0.999, fractionDigits: 1...1))  // "99.9%"
/// ```
public struct QeetrixStatValue: Sendable, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    enum Kind: Sendable {
        case integer(Int)
        case double(Double, ClosedRange<Int>?)
        case decimal(Decimal, ClosedRange<Int>?)
        case currency(Decimal, String)
        case percent(Double, ClosedRange<Int>?)
        case text(Text)
    }

    let kind: Kind

    /// A whole number: "12,40,512".
    public static func number(_ value: Int) -> QeetrixStatValue { QeetrixStatValue(kind: .integer(value)) }

    /// A number, with up to three fraction digits unless `fractionDigits` says otherwise.
    public static func number(_ value: Double, fractionDigits: ClosedRange<Int>? = nil) -> QeetrixStatValue {
        QeetrixStatValue(kind: .double(value, fractionDigits))
    }

    /// An exact number, with up to three fraction digits unless `fractionDigits` says otherwise.
    public static func number(_ value: Decimal, fractionDigits: ClosedRange<Int>? = nil) -> QeetrixStatValue {
        QeetrixStatValue(kind: .decimal(value, fractionDigits))
    }

    /// An amount of money in an ISO 4217 currency: a whole amount shows no fraction, as the web's Stat
    /// writes it — "₹18,42,600" — and any other the currency's own digits.
    public static func currency(_ amount: Decimal, code: String) -> QeetrixStatValue {
        QeetrixStatValue(kind: .currency(amount, code))
    }

    /// A fraction as a percentage: 0.4 is "40%"; whole percentages unless `fractionDigits` says
    /// otherwise.
    public static func percent(_ fraction: Double, fractionDigits: ClosedRange<Int>? = nil) -> QeetrixStatValue {
        QeetrixStatValue(kind: .percent(fraction, fractionDigits))
    }

    /// Anything else, as given — a value with its unit, already formatted: `Text("42 ms")`.
    public static func text(_ text: Text) -> QeetrixStatValue { QeetrixStatValue(kind: .text(text)) }

    /// A whole number written as a literal: `value: 42`.
    public init(integerLiteral value: Int) {
        kind = .integer(value)
    }

    /// A number written as a literal, with up to three fraction digits: `value: 2.5`.
    public init(floatLiteral value: Double) {
        kind = .double(value, nil)
    }

    init(kind: Kind) {
        self.kind = kind
    }

    /// The written number, or `nil` for text.
    func string(locale: Locale) -> String? {
        switch kind {
        case .integer(let value): QeetrixFormat.number(value, locale: locale)
        case .double(let value, let digits): QeetrixFormat.number(value, fractionDigits: digits, locale: locale)
        case .decimal(let value, let digits): QeetrixFormat.number(value, fractionDigits: digits, locale: locale)
        case .currency(let amount, let code):
            QeetrixFormat.currency(amount, code: code, fractionDigits: amount.qeetrixStatIsWhole ? 0...0 : nil, locale: locale)
        case .percent(let fraction, let digits): QeetrixFormat.percent(fraction, fractionDigits: digits, locale: locale)
        case .text: nil
        }
    }

    func text(locale: Locale) -> Text {
        if case .text(let text) = kind { return text }
        return Text(verbatim: string(locale: locale) ?? "")
    }
}

/// Which way a ``QeetrixStatChange`` goes.
public enum QeetrixStatDirection: String, CaseIterable, Sendable {
    /// An increase: the arrow up, "Up" for VoiceOver.
    case up
    /// A decrease: the arrow down, "Down" for VoiceOver.
    case down
}

/// A change in a stat's number, shown at the start of its note: an arrow up or down, the amount, and —
/// for VoiceOver — the direction in words, "Up 3.2%". Its tone follows from its direction: an
/// increase is ``QeetrixStatTone/positive`` and a decrease ``QeetrixStatTone/negative``, the other way
/// round when fewer is better (errors, churn), and no change is neutral.
///
/// ```swift
/// QeetrixStat("Active users", value: 1_240_512, change: .percent(0.032), note: Text("this week"))
/// QeetrixStat("Failed payments", value: 42, change: .number(-6, isIncreaseGood: false), note: Text("since yesterday"))
/// ```
public struct QeetrixStatChange: Sendable {
    enum Amount: Sendable {
        case number(Double, ClosedRange<Int>?)
        case currency(Decimal, String)
        case percent(Double, ClosedRange<Int>)
    }

    let amount: Amount
    let isIncreaseGood: Bool

    /// A change in percentage points of a fraction — 0.032 is "3.2%" — with one fraction digit at most
    /// unless `fractionDigits` says otherwise.
    public static func percent(
        _ fraction: Double, fractionDigits: ClosedRange<Int> = 0...1, isIncreaseGood: Bool = true
    )
        -> QeetrixStatChange
    {
        QeetrixStatChange(amount: .percent(fraction, fractionDigits), isIncreaseGood: isIncreaseGood)
    }

    /// A change in the number itself: 38 is "38".
    public static func number(_ delta: Double, fractionDigits: ClosedRange<Int>? = nil, isIncreaseGood: Bool = true) -> QeetrixStatChange {
        QeetrixStatChange(amount: .number(delta, fractionDigits), isIncreaseGood: isIncreaseGood)
    }

    /// A change in an amount of money, written as the stat's value is: "₹12,500".
    public static func currency(_ delta: Decimal, code: String, isIncreaseGood: Bool = true) -> QeetrixStatChange {
        QeetrixStatChange(amount: .currency(delta, code), isIncreaseGood: isIncreaseGood)
    }

    /// Up, down, or `nil` for no change.
    public var direction: QeetrixStatDirection? {
        let sign: Double
        switch amount {
        case .number(let value, _), .percent(let value, _): sign = value
        case .currency(let value, _): sign = value == 0 ? 0 : (value < 0 ? -1 : 1)
        }
        return sign > 0 ? .up : sign < 0 ? .down : nil
    }

    /// The tone it gives the note.
    public var tone: QeetrixStatTone {
        switch direction {
        case .up: isIncreaseGood ? .positive : .negative
        case .down: isIncreaseGood ? .negative : .positive
        case nil: .neutral
        }
    }

    /// The amount without its sign — the arrow shows the direction: "3.2%".
    func magnitude(locale: Locale) -> String {
        switch amount {
        case .number(let value, let digits): QeetrixFormat.number(abs(value), fractionDigits: digits, locale: locale)
        case .currency(let value, let code):
            QeetrixFormat.currency(abs(value), code: code, fractionDigits: value.qeetrixStatIsWhole ? 0...0 : nil, locale: locale)
        case .percent(let value, let digits): QeetrixFormat.percent(abs(value), fractionDigits: digits, locale: locale)
        }
    }

    /// What VoiceOver reads: "Up 3.2%", "Down ₹12,500", or the amount alone for no change.
    func spoken(locale: Locale) -> String {
        let amount = magnitude(locale: locale)
        switch direction {
        case .up: return String(localized: "qeetrix.stat.up", defaultValue: "Up \(amount)", bundle: .module, locale: locale)
        case .down: return String(localized: "qeetrix.stat.down", defaultValue: "Down \(amount)", bundle: .module, locale: locale)
        case nil: return amount
        }
    }
}

/// One key number with its label, and a note — `@qeetrix/react`'s Stat. Put several in a
/// ``QeetrixStatGroup``.
///
/// ```swift
/// QeetrixStatGroup {
///     QeetrixStat("Active users", value: 1_240_512, change: .percent(0.032), note: Text("this week"), trend: weeklyUsers)
///     QeetrixStat("Collected", value: .currency(1_842_600, code: "INR"), note: Text("18 invoices"))
///     QeetrixStat("Disputes", value: 3, note: Text("2 need a reply"), tone: .warning)
/// }
/// ```
///
/// The label is `label.sm` in `color.text.subtle`; the value `heading.sm` in tabular figures, 4 pt under
/// it (stat.css); the note `body.sm`, 2 pt under the value, in `color.text.subtlest` or its tone's
/// colour. A `change` starts the note with a sharp arrow up or down and the amount — the direction is in
/// the arrow's shape and, for VoiceOver, in words, never in the colour alone — and gives the note its
/// tone unless `tone` says otherwise. The stat sits 12 pt × 16 pt inside its cell.
///
/// `trend` draws recent values, oldest first, as the web's 88 × 28 pt line beside the number — under it
/// where the number wouldn't fit beside it — in `color.icon.subtle` over a 10% area, its last point the
/// one Ember mark: "now". It needs two values; a constant series draws flat. It is decorative: say what
/// matters about it in the note.
///
/// While `isLoading`, skeletons stand on the value's and the note's lines at those lines' heights, so
/// nothing moves when the number arrives; the trend waits, and VoiceOver reads "Loading" in the value's
/// place. VoiceOver reads a stat as one element: the label, then the value and the note.
public struct QeetrixStat: View {
    let label: Text
    let value: QeetrixStatValue
    let note: Text?
    let change: QeetrixStatChange?
    let tone: QeetrixStatTone?
    let trend: [Double]
    let isLoading: Bool
    @Environment(\.locale) private var locale
    @Environment(\.qeetrixStatIsInGroup) private var isInGroup
    @ScaledMetric(relativeTo: QeetrixTextRole.headingSm.textStyle) private var valueEm = QeetrixTextRole.headingSm.tokens.size
    @ScaledMetric(relativeTo: QeetrixTextRole.bodySm.textStyle) private var noteEm = QeetrixTextRole.bodySm.tokens.size

    /// A stat with a localised label.
    public init(
        _ titleKey: LocalizedStringKey,
        value: QeetrixStatValue,
        change: QeetrixStatChange? = nil,
        note: Text? = nil,
        tone: QeetrixStatTone? = nil,
        trend: [Double] = [],
        isLoading: Bool = false
    ) {
        self.init(label: Text(titleKey), value: value, change: change, note: note, tone: tone, trend: trend, isLoading: isLoading)
    }

    /// A stat with a label shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        value: QeetrixStatValue,
        change: QeetrixStatChange? = nil,
        note: Text? = nil,
        tone: QeetrixStatTone? = nil,
        trend: [Double] = [],
        isLoading: Bool = false
    ) {
        self.init(label: Text(title), value: value, change: change, note: note, tone: tone, trend: trend, isLoading: isLoading)
    }

    /// A stat with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: What's counted: "Total users".
    ///   - value: The number, formatted for the environment's locale, or text as given.
    ///   - change: A change up or down, at the start of the note.
    ///   - note: One line under the value: the change's context ("this week") or the stat's.
    ///   - tone: Colours the note; by default the change's tone, or neutral.
    ///   - trend: Recent values, oldest first, drawn as a small line beside the number.
    ///   - isLoading: Shows placeholders while the number is on its way.
    public init(
        label: Text,
        value: QeetrixStatValue,
        change: QeetrixStatChange? = nil,
        note: Text? = nil,
        tone: QeetrixStatTone? = nil,
        trend: [Double] = [],
        isLoading: Bool = false
    ) {
        self.label = label
        self.value = value
        self.change = change
        self.note = note
        self.tone = tone
        self.trend = trend
        self.isLoading = isLoading
    }

    /// The note's tone: as given, or the change's.
    var resolvedTone: QeetrixStatTone {
        tone ?? change?.tone ?? .neutral
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            label
                .qeetrixTextStyle(.labelSm)
                .foregroundStyle(QeetrixColor.textSubtle)
                .fixedSize(horizontal: false, vertical: true)
            Group {
                if !isLoading, let geometry = QeetrixStatTrendGeometry(trend) {
                    // `.qx-stat { column-gap: var(--qx-space-gap-md) }`: the trend at the value's end — or,
                    // where the number wouldn't fit beside it (a narrow cell, large text), under it, so a
                    // number never breaks across lines for the sake of a decoration.
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .bottom, spacing: QeetrixSpace.gapMd) {
                            valueLine
                                .fixedSize(horizontal: true, vertical: false)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            trendView(geometry)
                        }
                        VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                            valueLine
                            trendView(geometry)
                        }
                    }
                } else {
                    valueLine
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            // `.qx-stat-value { margin: var(--qx-space-gap-xs) 0 0 }`.
            .padding(.top, QeetrixSpace.gapXs)
            if isLoading || note != nil || change != nil {
                noteLine
                    // `.qx-stat-note { margin: 2px 0 0 }`.
                    .padding(.top, QeetrixStatMetrics.noteGap)
            }
        }
        // `.qx-stat { padding: var(--qx-space-inset-md) var(--qx-space-inset-lg) }`.
        .padding(.vertical, QeetrixSpace.insetMd)
        .padding(.horizontal, QeetrixSpace.insetLg)
        .modifier(QeetrixStatCell(isInGroup: isInGroup))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(spokenValue)
    }

    private func trendView(_ geometry: QeetrixStatTrendGeometry) -> some View {
        QeetrixStatTrend(geometry: geometry)
            // `.qx-stat-trend-cell { padding-block-end: var(--qx-space-gap-xs) }`.
            .padding(.bottom, QeetrixSpace.gapXs)
    }

    @ViewBuilder
    private var valueLine: some View {
        if isLoading {
            // `.qx-stat-value > .qx-skeleton { block-size: 1em; inline-size: min(100%, 5em) }`, centred in
            // the line.
            QeetrixSkeleton(lines: 1, role: .headingSm)
                .frame(maxWidth: QeetrixStatMetrics.valueSkeletonEms * valueEm, alignment: .leading)
        } else {
            value.text(locale: locale)
                .qeetrixTextStyle(.headingSm)
                .monospacedDigit()
                .foregroundStyle(QeetrixColor.textDefault)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var noteLine: some View {
        if isLoading {
            QeetrixSkeleton(lines: 1, role: .bodySm)
                .frame(maxWidth: QeetrixStatMetrics.noteSkeletonEms * noteEm, alignment: .leading)
        } else {
            HStack(alignment: .firstTextBaseline, spacing: QeetrixSpace.gapXs) {
                if let change {
                    if let direction = change.direction {
                        QeetrixIcon(direction == .up ? .arrowUp : .arrowDown, size: .xs, shape: .sharp, relativeTo: .footnote)
                    }
                    Text(verbatim: change.magnitude(locale: locale))
                        .qeetrixTextStyle(.bodySm)
                        .monospacedDigit()
                }
                if let note {
                    note
                        .qeetrixTextStyle(.bodySm)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .foregroundStyle(resolvedTone.color)
        }
    }

    /// The value, then the change in words and the note: "12,40,512, Up 3.2% this week"; "Loading" while
    /// loading.
    private var spokenValue: Text {
        if isLoading { return QeetrixStatStrings.loading }
        var spoken = value.text(locale: locale)
        if let change { spoken = spoken + Text(verbatim: ", \(change.spoken(locale: locale))") }
        if let note { spoken = spoken + Text(verbatim: change == nil ? ", " : " ") + note }
        return spoken
    }
}

/// In a group, a cell filling its column and row, with its rules.
private struct QeetrixStatCell: ViewModifier {
    let isInGroup: Bool

    func body(content: Content) -> some View {
        if isInGroup {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .modifier(QeetrixStatRules())
        } else {
            content
        }
    }
}

/// A stat's lengths from stat.css.
enum QeetrixStatMetrics {
    /// `.qx-stat-note { margin: 2px 0 0 }`.
    static let noteGap: CGFloat = 2
    /// `.qx-stat-value > .qx-skeleton { inline-size: min(100%, 5em) }`.
    static let valueSkeletonEms: CGFloat = 5
    /// `.qx-stat-note > .qx-skeleton { inline-size: min(100%, 10em) }`.
    static let noteSkeletonEms: CGFloat = 10
}

/// The trend's drawing, as the web's `trendGeometry`: the values scaled into an 88 × 28 box, 3 pt in
/// from its top and bottom; the line, the area under it, and the last point.
struct QeetrixStatTrendGeometry: Equatable {
    /// `const TREND = { width: 88, height: 28, pad: 3 }`.
    static let width: CGFloat = 88
    static let height: CGFloat = 28
    static let pad: CGFloat = 3
    /// `<circle r={2.5}>`.
    static let endRadius: CGFloat = 2.5
    /// `.qx-stat-trend-area { opacity: .1 }`.
    static let areaOpacity: Double = 0.1

    let points: [CGPoint]

    /// `nil` for fewer than two values, which draw nothing.
    init?(_ values: [Double]) {
        guard values.count > 1, let lowest = values.min(), let highest = values.max() else { return nil }
        let span = highest - lowest
        points = values.enumerated().map { index, value in
            CGPoint(
                x: CGFloat(index) / CGFloat(values.count - 1) * Self.width,
                y: span == 0 ? Self.height / 2 : Self.height - Self.pad - CGFloat((value - lowest) / span) * (Self.height - 2 * Self.pad))
        }
    }

    var line: Path {
        Path { path in path.addLines(points) }
    }

    var area: Path {
        Path { path in
            path.addLines(points)
            path.addLine(to: CGPoint(x: Self.width, y: Self.height))
            path.addLine(to: CGPoint(x: 0, y: Self.height))
            path.closeSubpath()
        }
    }

    var end: CGPoint { points[points.count - 1] }
}

/// The trend line (stat.css `.qx-stat-trend`): drawn as the web's SVG is, left to right in either
/// reading direction, and hidden from VoiceOver.
struct QeetrixStatTrend: View {
    let geometry: QeetrixStatTrendGeometry

    var body: some View {
        let radius = QeetrixStatTrendGeometry.endRadius
        ZStack(alignment: .topLeading) {
            geometry.area.fill(QeetrixColor.iconSubtle).opacity(QeetrixStatTrendGeometry.areaOpacity)
            geometry.line.stroke(
                QeetrixColor.iconSubtle, style: StrokeStyle(lineWidth: QeetrixIconStroke.thin.width, lineCap: .round, lineJoin: .round))
            Circle()
                .fill(QeetrixColor.borderBrand)
                .frame(width: 2 * radius, height: 2 * radius)
                .offset(x: geometry.end.x - radius, y: geometry.end.y - radius)
        }
        // `overflow: visible`: the end mark may sit past the box's edge.
        .frame(width: QeetrixStatTrendGeometry.width, height: QeetrixStatTrendGeometry.height, alignment: .topLeading)
        .environment(\.layoutDirection, .leftToRight)
        .accessibilityHidden(true)
    }
}

/// The stat's built-in strings (`stat` in `@qeetrix/react`'s catalogue, and the change's words).
enum QeetrixStatStrings {
    /// "Loading" — `stat.loading`.
    static var loading: Text { Text("qeetrix.stat.loading", bundle: .module) }
}

extension Decimal {
    /// Whether the amount has no fraction, so it is written without one.
    fileprivate var qeetrixStatIsWhole: Bool {
        var value = self
        var whole = Decimal()
        NSDecimalRound(&whole, &value, 0, .plain)
        return whole == self
    }
}
