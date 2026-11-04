import SwiftUI

/// A month of days to choose a range from, as `@qeetrix/react`'s RangeCalendar, drawn by Qeetrix — iOS
/// has no system range calendar.
///
/// ```swift
/// QeetrixRangeCalendar(selection: $stay, min: .now)
/// ```
///
/// The first day chosen is one end; until the second is chosen, a pointer or the keyboard previews the
/// range, but only to days that can end it. A day before the first swaps them, and the same day twice
/// is a one-day range. The range is a band of `color.bg.brand.subtle` a day high, across the gutters,
/// whose ends are filled Ember; days between keep their colour and today's outline, and disabled days
/// in it stay grey. Escape — or VoiceOver's escape gesture — undoes a half-chosen range. Everything
/// else is ``QeetrixCalendar``'s: the keys, the months and years, the limits and the environment's days.
///
/// `selection` is set once both ends are chosen: from the moment the first day starts to the moment
/// the last day starts, in the environment's time zone. To test whether a moment falls on one of its
/// days, compare it with the start of the day after the last.
///
/// For a range in a form, use ``QeetrixDateRangePicker``. VoiceOver reads every day in the range as
/// selected, and announces each step: "Starts Monday, 12 October 2026. Now choose the end date.", then
/// "Monday, 12 October 2026 to Friday, 16 October 2026".
public struct QeetrixRangeCalendar: View {
    let selection: Binding<ClosedRange<Date>?>
    let min: Date?
    let max: Date?
    let isDateDisabled: ((Date) -> Bool)?
    let isReadOnly: Bool
    let today: Date?
    var fillsWidth = false
    var onChoose: (() -> Void)?
    @State private var anchor: QeetrixCalendarDay?
    @State private var point: QeetrixCalendarDay?
    @Environment(\.timeZone) private var timeZone
    @Environment(\.locale) private var locale

    /// - Parameters:
    ///   - selection: The chosen range, from the start of its first day to the start of its last, in the
    ///     environment's time zone; `nil` for none.
    ///   - min: The earliest day that can be an end.
    ///   - max: The latest day that can be an end.
    ///   - isDateDisabled: Rules out more days as ends, such as holidays; it is given each day's start.
    ///   - isReadOnly: Shows the range and lets the months be browsed, but no range can be started.
    ///   - today: A fixed today, for previews, tests and screenshots; by default, today in the
    ///     environment's time zone.
    public init(
        selection: Binding<ClosedRange<Date>?>,
        min: Date? = nil,
        max: Date? = nil,
        isDateDisabled: ((Date) -> Bool)? = nil,
        isReadOnly: Bool = false,
        today: Date? = nil
    ) {
        self.selection = selection
        self.min = min
        self.max = max
        self.isDateDisabled = isDateDisabled
        self.isReadOnly = isReadOnly
        self.today = today
    }

    /// The calendar inside a range picker: as wide as the picker, closing it when a range is chosen.
    init(
        selection: Binding<ClosedRange<Date>?>, min: Date?, max: Date?, isDateDisabled: ((Date) -> Bool)?, fillsWidth: Bool,
        onChoose: @escaping () -> Void
    ) {
        self.init(selection: selection, min: min, max: max, isDateDisabled: isDateDisabled)
        self.fillsWidth = fillsWidth
        self.onChoose = onChoose
    }

    public var body: some View {
        let timeZone = self.timeZone
        let range = selection.wrappedValue.map {
            QeetrixRangeCalendarSelection.ordered(
                QeetrixCalendarDay($0.lowerBound, in: timeZone), QeetrixCalendarDay($0.upperBound, in: timeZone))
        }
        let ends = QeetrixRangeCalendarSelection.ends(anchor: anchor, point: point, range: range)
        QeetrixCalendarCore(
            initial: range?.start, chosen: range?.start, mark: { QeetrixRangeCalendarSelection.mark($0, ends: ends) },
            limits: QeetrixCalendarLimits(min: min, max: max, isDateDisabled: isDateDisabled, timeZone: timeZone),
            today: QeetrixCalendarDay(today ?? Date(), in: timeZone), isReadOnly: isReadOnly, isRange: true, fillsWidth: fillsWidth,
            onPick: pick, onPoint: anchor == nil ? nil : { point = $0 },
            onEscape: {
                guard anchor != nil else { return false }
                anchor = nil
                point = nil
                return true
            })
    }

    private func pick(_ day: QeetrixCalendarDay) {
        let full = { (day: QeetrixCalendarDay) in QeetrixFormat.calendarFullDate(day, locale: locale) }
        guard let first = anchor else {
            anchor = day
            point = day
            AccessibilityNotification.Announcement(QeetrixCalendarStrings.rangeStart(full(day), locale: locale)).post()
            return
        }
        let (start, end) = QeetrixRangeCalendarSelection.ordered(first, day)
        anchor = nil
        point = nil
        AccessibilityNotification.Announcement(QeetrixCalendarStrings.rangeSelected(full(start), full(end), locale: locale)).post()
        selection.wrappedValue = start.start(in: timeZone)...end.start(in: timeZone)
        onChoose?()
    }
}

/// How a range is chosen and drawn (`RangeCalendar`): the ends shown while choosing, and each day's part.
enum QeetrixRangeCalendarSelection {
    /// Two days, earlier first.
    static func ordered(_ first: QeetrixCalendarDay, _ second: QeetrixCalendarDay) -> (start: QeetrixCalendarDay, end: QeetrixCalendarDay) {
        first <= second ? (first, second) : (second, first)
    }

    /// The ends drawn: while a range is half chosen, from the first day to the day pointed at (which
    /// replaces the old range); otherwise the chosen range.
    static func ends(
        anchor: QeetrixCalendarDay?, point: QeetrixCalendarDay?, range: (start: QeetrixCalendarDay, end: QeetrixCalendarDay)?
    ) -> (start: QeetrixCalendarDay, end: QeetrixCalendarDay)? {
        if let anchor { return ordered(anchor, point ?? anchor) }
        return range
    }

    /// A day's part in the range drawn, or `nil` outside it.
    static func mark(_ day: QeetrixCalendarDay, ends: (start: QeetrixCalendarDay, end: QeetrixCalendarDay)?) -> QeetrixCalendarMark? {
        guard let ends, day >= ends.start, day <= ends.end else { return nil }
        if ends.start == ends.end { return .single }
        if day == ends.start { return .start }
        return day == ends.end ? .end : .middle
    }
}
