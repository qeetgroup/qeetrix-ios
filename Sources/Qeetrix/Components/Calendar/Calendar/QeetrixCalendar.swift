import SwiftUI

/// A month of days to choose one from, as `@qeetrix/react`'s Calendar, drawn by Qeetrix.
///
/// ```swift
/// QeetrixCalendar(selection: $deliveryDay, min: .now, isDateDisabled: { isHoliday($0) })
/// ```
///
/// The month and year sit between previous and next month buttons; under them, the weekdays from the
/// locale's first day (Sunday in India and the US, Monday in most of Europe) and six weeks of days in
/// `body.md` with tabular figures. Today has a thin Ember outline; the chosen day is filled Ember;
/// days outside `min` and `max`, or ruled out by `isDateDisabled`, are grey and can't be chosen, and
/// the arrows stop at the limits. The title opens the years, a decade a page; choosing a year shows its
/// months, and choosing a month its days. Choosing a day plays ``QeetrixFeedback/selection``.
///
/// Days are the environment's: a date is the day it falls on in the environment's time zone, and a
/// chosen day is written to `selection` as the moment it starts there; names follow the environment's
/// locale, always in the Gregorian calendar.
///
/// For one date in a form, use ``QeetrixDatePicker``, which opens the system's calendar where it can.
/// VoiceOver reads each day in full — "Today, Sunday, 25 October 2026" — with the selected trait on the
/// chosen one; a hardware keyboard moves through the days with the arrow keys.
public struct QeetrixCalendar: View {
    let selection: Binding<Date?>
    let min: Date?
    let max: Date?
    let isDateDisabled: ((Date) -> Bool)?
    let isReadOnly: Bool
    let today: Date?
    var fillsWidth = false
    var onChoose: (() -> Void)?
    @Environment(\.timeZone) private var timeZone

    /// - Parameters:
    ///   - selection: The chosen day, as the moment it starts in the environment's time zone; `nil` for
    ///     none.
    ///   - min: The earliest day that can be chosen.
    ///   - max: The latest day that can be chosen.
    ///   - isDateDisabled: Rules out more days, such as weekends or holidays; it is given each day's start.
    ///   - isReadOnly: Shows the date and lets the months be browsed, but no day can be chosen.
    ///   - today: A fixed today, for previews, tests and screenshots; by default, today in the
    ///     environment's time zone.
    public init(
        selection: Binding<Date?>,
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

    /// The calendar inside a date picker: as wide as the picker, closing it when a day is chosen.
    init(
        selection: Binding<Date?>, min: Date?, max: Date?, isDateDisabled: ((Date) -> Bool)?, fillsWidth: Bool,
        onChoose: @escaping () -> Void
    ) {
        self.init(selection: selection, min: min, max: max, isDateDisabled: isDateDisabled)
        self.fillsWidth = fillsWidth
        self.onChoose = onChoose
    }

    public var body: some View {
        let timeZone = self.timeZone
        let chosen = selection.wrappedValue.map { QeetrixCalendarDay($0, in: timeZone) }
        QeetrixCalendarCore(
            initial: chosen, chosen: chosen, mark: { $0 == chosen ? .single : nil },
            limits: QeetrixCalendarLimits(min: min, max: max, isDateDisabled: isDateDisabled, timeZone: timeZone),
            today: QeetrixCalendarDay(today ?? Date(), in: timeZone), isReadOnly: isReadOnly, isRange: false, fillsWidth: fillsWidth
        ) { day in
            selection.wrappedValue = day.start(in: timeZone)
            onChoose?()
        }
    }
}
