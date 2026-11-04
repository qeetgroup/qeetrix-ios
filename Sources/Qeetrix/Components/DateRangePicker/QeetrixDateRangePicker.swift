import SwiftUI

/// A range of dates in a form, with its label, help text and error — `@qeetrix/react`'s
/// DateRangePicker in a Field, opening Qeetrix's range calendar.
///
/// ```swift
/// QeetrixDateRangePicker("Billing period", selection: $period, presets: [.thisMonth, .lastMonth, .last30Days])
/// ```
///
/// The field is the Qeetrix field box showing both ends in the locale's all-number form joined by an en
/// dash, as the web writes them — "01/12/2026 – 31/12/2026" — in tabular figures, with a sharp
/// `calendar` icon at its end; it wraps rather than truncating at large text sizes. The whole box is
/// one button; it opens a popover under the field (a sheet on a phone at the accessibility text sizes,
/// or in landscape) with a ``QeetrixRangeCalendar``, because iOS has no system range picker. The first
/// day chosen starts the range and the second ends it and closes the popover; Escape first undoes a
/// half-chosen range.
///
/// `presets` list ranges to choose in one step under the calendar, behind a rule — the ready-made ones
/// (``QeetrixDateRangePreset/last7Days``, ``QeetrixDateRangePreset/thisMonth``, …) or your own. Each is
/// cut to `min` and `max`; one wholly outside them, or that would start or end on a disabled day, is
/// dimmed. "Clear" empties a range that isn't required.
///
/// The range runs from the moment its first day starts to the moment its last day starts, in the
/// environment's time zone. VoiceOver reads the field by its label, with the range in words — "1
/// December 2026 to 31 December 2026" — as its value.
public struct QeetrixDateRangePicker: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let selection: Binding<ClosedRange<Date>?>
    let min: Date?
    let max: Date?
    let isDateDisabled: ((Date) -> Bool)?
    let presets: [QeetrixDateRangePreset]
    let placeholder: Text?
    let isReadOnly: Bool
    @State private var isPresented = false
    @Environment(\.locale) private var locale
    @Environment(\.timeZone) private var timeZone

    /// A date range picker with a localised label.
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<ClosedRange<Date>?>,
        min: Date? = nil,
        max: Date? = nil,
        isDateDisabled: ((Date) -> Bool)? = nil,
        presets: [QeetrixDateRangePreset] = [],
        placeholder: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false
    ) {
        self.init(
            label: Text(titleKey), selection: selection, min: min, max: max, isDateDisabled: isDateDisabled, presets: presets,
            placeholder: placeholder, description: description, error: error, isRequired: isRequired, isOptional: isOptional,
            isReadOnly: isReadOnly)
    }

    /// A date range picker with a label shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<ClosedRange<Date>?>,
        min: Date? = nil,
        max: Date? = nil,
        isDateDisabled: ((Date) -> Bool)? = nil,
        presets: [QeetrixDateRangePreset] = [],
        placeholder: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false
    ) {
        self.init(
            label: Text(title), selection: selection, min: min, max: max, isDateDisabled: isDateDisabled, presets: presets,
            placeholder: placeholder, description: description, error: error, isRequired: isRequired, isOptional: isOptional,
            isReadOnly: isReadOnly)
    }

    /// A date range picker with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: Names the field, and the button for VoiceOver.
    ///   - selection: The range, from the start of its first day to the start of its last in the
    ///     environment's time zone; `nil` for none.
    ///   - min: The earliest day that can be an end.
    ///   - max: The latest day that can be an end.
    ///   - isDateDisabled: Rules out more days as ends, such as holidays; it is given each day's start.
    ///   - presets: Ranges to choose in one step, under the calendar.
    ///   - placeholder: Shown in `color.text.subtlest` while there is no range.
    ///   - description: Help under the field, read by VoiceOver as its hint.
    ///   - error: What to fix, already localised; it replaces the description and marks the field invalid.
    ///   - isRequired: Tells VoiceOver the field is required, and offers no "Clear".
    ///   - isOptional: Appends "(optional)" to the label.
    ///   - isReadOnly: Shows the range without the fill; it can't be changed.
    public init(
        label: Text,
        selection: Binding<ClosedRange<Date>?>,
        min: Date? = nil,
        max: Date? = nil,
        isDateDisabled: ((Date) -> Bool)? = nil,
        presets: [QeetrixDateRangePreset] = [],
        placeholder: Text? = nil,
        description: Text? = nil,
        error: String? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        isReadOnly: Bool = false
    ) {
        context = QeetrixFieldContext(label: label, description: description, error: error, isRequired: isRequired)
        self.isOptional = isOptional
        self.selection = selection
        self.min = min
        self.max = max
        self.isDateDisabled = isDateDisabled
        self.presets = presets
        self.placeholder = placeholder
        self.isReadOnly = isReadOnly
    }

    public var body: some View {
        let range = selection.wrappedValue
        QeetrixFieldLayout(context: context, isOptional: isOptional) {
            QeetrixPickerField(
                text: range.map { QeetrixFormat.dateRange($0, locale: locale, timeZone: timeZone) },
                spokenText: range.map { range in
                    QeetrixCalendarStrings.rangeSelected(
                        QeetrixFormat.date(range.lowerBound, style: .long, locale: locale, timeZone: timeZone),
                        QeetrixFormat.date(range.upperBound, style: .long, locale: locale, timeZone: timeZone), locale: locale)
                },
                placeholder: placeholder, icon: .calendar, tooltip: QeetrixDateRangePickerStrings.choose, isReadOnly: isReadOnly,
                isPresented: $isPresented
            ) {
                panel
            }
        }
    }

    /// "Clear", for a range that isn't required.
    private var clear: (@MainActor () -> Void)? {
        guard !context.isRequired, selection.wrappedValue != nil else { return nil }
        let selection = self.selection
        let isPresented = $isPresented
        return {
            selection.wrappedValue = nil
            isPresented.wrappedValue = false
        }
    }

    private var panel: some View {
        let isPresented = $isPresented
        return VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) {
            QeetrixRangeCalendar(selection: selection, min: min, max: max, isDateDisabled: isDateDisabled, fillsWidth: true) {
                isPresented.wrappedValue = false
            }
            if !presets.isEmpty {
                QeetrixDateRangePresetList(presets: presets, limits: limits) { range in
                    selection.wrappedValue = range
                    isPresented.wrappedValue = false
                }
            }
            QeetrixPickerActions(clear: clear, done: nil)
        }
    }

    private var limits: QeetrixCalendarLimits {
        QeetrixCalendarLimits(min: min, max: max, isDateDisabled: isDateDisabled, timeZone: timeZone)
    }
}

/// A range to choose in one step, listed under a ``QeetrixDateRangePicker``'s calendar — one of the
/// web's ready-made ranges by name, or your own.
///
/// ```swift
/// QeetrixDateRangePicker(
///     "Period", selection: $period,
///     presets: [
///         .last7Days, .thisMonth,
///         QeetrixDateRangePreset("This quarter") { quarter(containing: .now) },
///     ])
/// ```
///
/// The "last …" ranges are that many days ending today, today included; ``thisMonth`` and
/// ``lastMonth`` are whole calendar months. Today is today in the environment's time zone.
public struct QeetrixDateRangePreset {
    enum Kind {
        case today
        case lastDays(Int)
        case thisMonth
        case lastMonth
        case custom(Text, () -> ClosedRange<Date>)
    }

    let kind: Kind

    /// A preset of your own, worked out when the list shows.
    ///
    /// - Parameters:
    ///   - titleKey: What its button says: "Last quarter".
    ///   - range: The range, from the start of its first day to the start of its last.
    public init(_ titleKey: LocalizedStringKey, range: @escaping () -> ClosedRange<Date>) {
        self.init(label: Text(titleKey), range: range)
    }

    /// A preset of your own with a label shown as given, without localisation.
    public init<S: StringProtocol>(_ title: S, range: @escaping () -> ClosedRange<Date>) {
        self.init(label: Text(title), range: range)
    }

    /// A preset of your own with a `Text` label.
    public init(label: Text, range: @escaping () -> ClosedRange<Date>) {
        kind = .custom(label, range)
    }

    init(_ kind: Kind) {
        self.kind = kind
    }

    /// Today: "Today" (`dateRangePicker.today`).
    public static var today: QeetrixDateRangePreset { QeetrixDateRangePreset(.today) }
    /// The 7 days ending today: "Last 7 days".
    public static var last7Days: QeetrixDateRangePreset { QeetrixDateRangePreset(.lastDays(7)) }
    /// The 30 days ending today: "Last 30 days".
    public static var last30Days: QeetrixDateRangePreset { QeetrixDateRangePreset(.lastDays(30)) }
    /// The 90 days ending today: "Last 90 days".
    public static var last90Days: QeetrixDateRangePreset { QeetrixDateRangePreset(.lastDays(90)) }
    /// This calendar month, the 1st to its last day: "This month".
    public static var thisMonth: QeetrixDateRangePreset { QeetrixDateRangePreset(.thisMonth) }
    /// Last calendar month: "Last month".
    public static var lastMonth: QeetrixDateRangePreset { QeetrixDateRangePreset(.lastMonth) }

    /// What its button says.
    func label(locale: Locale) -> Text {
        switch kind {
        case .today: Text("qeetrix.date-range-picker.today", bundle: .module)
        case .lastDays(let count): Text(verbatim: QeetrixDateRangePickerStrings.lastDays(count, locale: locale))
        case .thisMonth: Text("qeetrix.date-range-picker.this-month", bundle: .module)
        case .lastMonth: Text("qeetrix.date-range-picker.last-month", bundle: .module)
        case .custom(let label, _): label
        }
    }

    /// The days it covers on `today` (`namedRange`), or a custom range's days in `timeZone`.
    func days(today: QeetrixCalendarDay, timeZone: TimeZone) -> (start: QeetrixCalendarDay, end: QeetrixCalendarDay) {
        switch kind {
        case .today: return (today, today)
        case .lastDays(let count): return (today.adding(days: 1 - count), today)
        case .thisMonth: return (today.firstOfMonth, today.lastOfMonth)
        case .lastMonth:
            let month = today.adding(months: -1)
            return (month.firstOfMonth, month.lastOfMonth)
        case .custom(_, let range):
            let dates = range()
            return QeetrixRangeCalendarSelection.ordered(
                QeetrixCalendarDay(dates.lowerBound, in: timeZone), QeetrixCalendarDay(dates.upperBound, in: timeZone))
        }
    }

    /// The days it covers cut to the limits (`clampRange`), or `nil` when it can't be chosen: wholly
    /// outside them, or starting or ending on a ruled-out day.
    static func fitted(
        _ days: (start: QeetrixCalendarDay, end: QeetrixCalendarDay), to limits: QeetrixCalendarLimits
    ) -> (start: QeetrixCalendarDay, end: QeetrixCalendarDay)? {
        var start = days.start
        var end = days.end
        if let min = limits.min, start < min { start = min }
        if let max = limits.max, end > max { end = max }
        guard start <= end else { return nil }
        if limits.isRuledOut?(start) == true || limits.isRuledOut?(end) == true { return nil }
        return (start, end)
    }
}

/// The presets under the calendar (date-range-picker.css, the compact layout): behind a 1 pt
/// `color.border.subtle` rule, quiet buttons in `label.md` with 4 pt corners and the
/// `color.overlay.hover` tint, two to a row — one at the accessibility text sizes — and each a 44 pt row,
/// as stacked targets are on iOS (ADR 0012). VoiceOver finds them as a group, "Quick ranges".
struct QeetrixDateRangePresetList: View {
    let presets: [QeetrixDateRangePreset]
    let limits: QeetrixCalendarLimits
    let choose: (ClosedRange<Date>) -> Void
    @Environment(\.locale) private var locale
    @Environment(\.timeZone) private var timeZone
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let today = QeetrixCalendarDay(Date(), in: timeZone)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: dynamicTypeSize.isAccessibilitySize ? 1 : 2)
        VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) {
            Rectangle()
                .fill(QeetrixColor.borderSubtle)
                .frame(height: QeetrixBorderWidth.default)
                .accessibilityHidden(true)
            LazyVGrid(columns: columns, alignment: .leading, spacing: 0) {
                ForEach(presets.indices, id: \.self) { index in
                    let preset = presets[index]
                    let fitted = QeetrixDateRangePreset.fitted(preset.days(today: today, timeZone: timeZone), to: limits)
                    Button {
                        if let fitted { choose(fitted.start.start(in: timeZone)...fitted.end.start(in: timeZone)) }
                    } label: {
                        preset.label(locale: locale)
                    }
                    .buttonStyle(QeetrixDateRangePresetStyle())
                    .disabled(fitted == nil)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("qeetrix.date-range-picker.presets", bundle: .module))
    }
}

/// A preset's button (`.qx-date-range-picker-preset`).
struct QeetrixDateRangePresetStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        QeetrixDateRangePresetBody(configuration: configuration)
    }
}

struct QeetrixDateRangePresetBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.qeetrixDensity) private var density
    @State private var isHovered = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.control)
        configuration.label
            .qeetrixType(QeetrixComponentType.role(.labelMd))
            .foregroundStyle(isEnabled ? QeetrixColor.textDefault : QeetrixColor.textDisabled)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, QeetrixSpace.insetSm)
            .frame(minHeight: Swift.max(density.sizeControlMd, QeetrixAccessibility.minimumTouchTarget))
            .background {
                if isEnabled, configuration.isPressed || isHovered {
                    shape.fill(configuration.isPressed ? QeetrixColor.overlayPressed : QeetrixColor.overlayHover)
                }
            }
            .overlay {
                if isFocused { shape.strokeBorder(QeetrixColor.borderFocus, lineWidth: QeetrixFocus.ringWidth) }
            }
            .contentShape(Rectangle())
            .onHover { isHovered = $0 }
    }
}

/// The range picker's built-in strings (`dateRangePicker` in `@qeetrix/react`'s catalogue).
enum QeetrixDateRangePickerStrings {
    /// "Choose dates" — `dateRangePicker.choose`, the field's pointer tooltip.
    static var choose: Text { Text("qeetrix.date-range-picker.choose", bundle: .module) }

    /// "Last 7 days" — `dateRangePicker.lastDays`.
    static func lastDays(_ count: Int, locale: Locale) -> String {
        String(localized: "qeetrix.date-range-picker.last-days", defaultValue: "Last \(count) days", bundle: .module, locale: locale)
    }
}
