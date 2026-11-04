import Foundation

/// A day of the Gregorian calendar — a year, a month and a day, with no time or zone — as
/// `@qeetrix/react`'s calendars count in (`internal/date.ts`: "YYYY-MM-DD"). The arithmetic is on day
/// numbers, so no time zone or daylight-saving change can shift a day; a `Date` becomes a day only in
/// a time zone, and a day a `Date` only as the moment it starts there.
struct QeetrixCalendarDay: Hashable, Comparable, Sendable, CustomStringConvertible {
    let year: Int
    /// 1–12.
    let month: Int
    /// 1–31.
    let day: Int

    /// A real day, or the month's last day when `day` is past it (`dayIn`: 31 February → 28 or 29).
    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = min(max(month, 1), 12)
        self.day = min(max(day, 1), Self.daysInMonth(year: year, month: self.month))
    }

    /// The day `date` falls on in `timeZone`.
    init(_ date: Date, in timeZone: TimeZone) {
        let parts = Self.calendar(timeZone).dateComponents([.year, .month, .day], from: date)
        self.init(year: parts.year ?? 1970, month: parts.month ?? 1, day: parts.day ?? 1)
    }

    /// The day `number` days after 1 January 1970.
    init(dayNumber number: Int) {
        // Howard Hinnant's `civil_from_days`, on the proleptic Gregorian calendar the web's `Date.UTC`
        // counts in.
        let shifted = number + 719_468
        let era = (shifted >= 0 ? shifted : shifted - 146_096) / 146_097
        let dayOfEra = shifted - era * 146_097
        let yearOfEra = (dayOfEra - dayOfEra / 1460 + dayOfEra / 36_524 - dayOfEra / 146_096) / 365
        let dayOfYear = dayOfEra - (365 * yearOfEra + yearOfEra / 4 - yearOfEra / 100)
        let monthIndex = (5 * dayOfYear + 2) / 153
        let day = dayOfYear - (153 * monthIndex + 2) / 5 + 1
        let month = monthIndex < 10 ? monthIndex + 3 : monthIndex - 9
        self.init(year: yearOfEra + era * 400 + (month <= 2 ? 1 : 0), month: month, day: day)
    }

    /// Days since 1 January 1970 (`days_from_civil`).
    var dayNumber: Int {
        let shiftedYear = month <= 2 ? year - 1 : year
        let era = (shiftedYear >= 0 ? shiftedYear : shiftedYear - 399) / 400
        let yearOfEra = shiftedYear - era * 400
        let dayOfYear = (153 * ((month + 9) % 12) + 2) / 5 + day - 1
        let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
        return era * 146_097 + dayOfEra - 719_468
    }

    /// The moment the day starts in `timeZone` — its midnight, or the first moment after it where a
    /// daylight-saving change skips midnight.
    func start(in timeZone: TimeZone) -> Date {
        let calendar = Self.calendar(timeZone)
        let noon = calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12)) ?? utcMidnight
        return calendar.startOfDay(for: noon)
    }

    /// The day's UTC midnight, for writing it with a formatter set to UTC, as the web's `toUTC` is.
    var utcMidnight: Date {
        Date(timeIntervalSince1970: TimeInterval(dayNumber) * 86_400)
    }

    /// The weekday, 0 = Sunday … 6 = Saturday (`weekday`). 1 January 1970 was a Thursday.
    var weekday: Int {
        ((dayNumber + 4) % 7 + 7) % 7
    }

    /// The day `days` later, or earlier when negative (`addDays`).
    func adding(days: Int) -> QeetrixCalendarDay {
        QeetrixCalendarDay(dayNumber: dayNumber + days)
    }

    /// The same day `months` later, or the month's last day when it's shorter (`addMonths`: 31 January
    /// plus one month is 28 or 29 February).
    func adding(months: Int) -> QeetrixCalendarDay {
        let index = year * 12 + (month - 1) + months
        let newYear = Int((Double(index) / 12).rounded(.down))
        return QeetrixCalendarDay(year: newYear, month: index - newYear * 12 + 1, day: day)
    }

    /// The first day of the day's month.
    var firstOfMonth: QeetrixCalendarDay {
        QeetrixCalendarDay(year: year, month: month, day: 1)
    }

    /// The last day of the day's month.
    var lastOfMonth: QeetrixCalendarDay {
        QeetrixCalendarDay(year: year, month: month, day: Self.daysInMonth(year: year, month: month))
    }

    /// The day kept inside a range; either end may be open (`clampDate`).
    func clamped(min lower: QeetrixCalendarDay?, max upper: QeetrixCalendarDay?) -> QeetrixCalendarDay {
        if let lower, self < lower { return lower }
        if let upper, self > upper { return upper }
        return self
    }

    static func < (lhs: QeetrixCalendarDay, rhs: QeetrixCalendarDay) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }

    /// Days in a month (1–12) (`daysInMonth`).
    static func daysInMonth(year: Int, month: Int) -> Int {
        switch month {
        case 2: isLeap(year) ? 29 : 28
        case 4, 6, 9, 11: 30
        default: 31
        }
    }

    static func isLeap(_ year: Int) -> Bool {
        (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
    }

    /// "YYYY-MM-DD", the web's value.
    var description: String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }

    /// The Gregorian calendar in `timeZone`: a `Date`'s day is the day there, whatever the locale's own
    /// calendar (`calendar: "gregory"`).
    static func calendar(_ timeZone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }
}

/// What can be chosen: `min` and `max`, either open, and the days an app rules out (`isDateDisabled`).
struct QeetrixCalendarLimits {
    let min: QeetrixCalendarDay?
    let max: QeetrixCalendarDay?
    let isRuledOut: ((QeetrixCalendarDay) -> Bool)?

    init(min: QeetrixCalendarDay? = nil, max: QeetrixCalendarDay? = nil, isRuledOut: ((QeetrixCalendarDay) -> Bool)? = nil) {
        self.min = min
        self.max = max
        self.isRuledOut = isRuledOut
    }

    /// The limits of a calendar in `timeZone`, from the public API's moments: the days they fall on.
    init(min: Date?, max: Date?, isDateDisabled: ((Date) -> Bool)?, timeZone: TimeZone) {
        self.min = min.map { QeetrixCalendarDay($0, in: timeZone) }
        self.max = max.map { QeetrixCalendarDay($0, in: timeZone) }
        isRuledOut = isDateDisabled.map { rule in { day in rule(day.start(in: timeZone)) } }
    }

    /// Whether every day from `first` to `last` is outside `min` and `max` (`isOutside`).
    func isOutside(_ first: QeetrixCalendarDay, _ last: QeetrixCalendarDay) -> Bool {
        if let min, last < min { return true }
        if let max, first > max { return true }
        return false
    }

    /// Whether the day can't be chosen: outside the limits, or ruled out.
    func isDisabled(_ day: QeetrixCalendarDay) -> Bool {
        isOutside(day, day) || (isRuledOut?(day) ?? false)
    }

    /// Whether a whole month is outside the limits, for the months view.
    func isOutside(year: Int, month: Int) -> Bool {
        let first = QeetrixCalendarDay(year: year, month: month, day: 1)
        return isOutside(first, first.lastOfMonth)
    }

    /// Whether a whole year is outside the limits, for the years view.
    func isOutside(year: Int) -> Bool {
        isOutside(QeetrixCalendarDay(year: year, month: 1, day: 1), QeetrixCalendarDay(year: year, month: 12, day: 31))
    }

    func clamp(_ day: QeetrixCalendarDay) -> QeetrixCalendarDay {
        day.clamped(min: min, max: max)
    }
}

extension Locale {
    /// The locale's first day of the week, 0 = Sunday … 6 = Saturday, as the web's `firstDayOfWeek` reads
    /// it from `Intl.Locale`'s week info: Sunday for India and the US, Monday for most of Europe,
    /// Saturday for Egypt and Iran. The person's own choice in Settings is part of the current locale.
    var qeetrixCalendarFirstWeekday: Int {
        switch firstDayOfWeek {
        case .sunday: 0
        case .monday: 1
        case .tuesday: 2
        case .wednesday: 3
        case .thursday: 4
        case .friday: 5
        case .saturday: 6
        @unknown default: 1
        }
    }
}
