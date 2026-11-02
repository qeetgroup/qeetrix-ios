import Foundation

/// How much of a date to write, as `formatDate`'s `dateStyle`.
public enum QeetrixFormatDateStyle: String, CaseIterable, Sendable {
    /// Numbers: "25/10/26" in `en-IN`, "10/25/26" in `en-US`.
    case short
    /// The month abbreviated, the default: "25 Oct 2026" in `en-IN`, "Oct 25, 2026" in `en-US`.
    case medium
    /// The month in full: "25 October 2026".
    case long

    var formatterStyle: DateFormatter.Style {
        switch self {
        case .short: .short
        case .medium: .medium
        case .long: .long
        }
    }
}

/// How much of a time to write, as `formatDateTime`'s `timeStyle`.
public enum QeetrixFormatTimeStyle: String, CaseIterable, Sendable {
    /// Hours and minutes, the default: "2:30 pm" in `en-IN`, "14:30" in `en-GB`.
    case short
    /// With seconds: "2:30:45 pm".
    case medium

    var formatterStyle: DateFormatter.Style {
        switch self {
        case .short: .short
        case .medium: .medium
        }
    }
}

// MARK: - Dates and times

extension QeetrixFormat {
    /// A moment's date, as `formatDate`: "25 Oct 2026" in `en-IN`, "Oct 25, 2026" in `en-US`, "25
    /// अक्तू॰ 2026" in `hi-IN`.
    ///
    /// Shown in `timeZone`, so a moment late in the evening in UTC is the next day in India. Always
    /// Gregorian, whatever the locale's own calendar.
    public static func date(
        _ date: Date, style: QeetrixFormatDateStyle = .medium, locale: Locale = .current, timeZone: TimeZone = .current
    ) -> String {
        QeetrixFormatCache.shared.string(from: date, .init(locale: locale, timeZone: timeZone, layout: .styles(style, nil)))
    }

    /// A calendar date — a year, a month and a day, with no time or zone — as `formatDate` writes a
    /// "YYYY-MM-DD" date: no time zone can move it to another day. `""` when the components aren't a
    /// date (31 February).
    public static func date(_ date: DateComponents, style: QeetrixFormatDateStyle = .medium, locale: Locale = .current) -> String {
        guard let moment = QeetrixFormatMoment(date: date) else { return "" }
        return format(moment, date: style, time: nil, locale: locale, timeZone: .current)
    }

    /// An ISO 8601 date or date-time, read as `formatDate` reads one: "2026-10-25" is a calendar date
    /// and shows as written; "2026-10-25T20:00:00Z" or "…+05:30" is a moment, shown in `timeZone`;
    /// "2026-10-25T14:30", with no offset, shows as written. Anything else — "25/10/2026", "2026-02-31",
    /// "soon" — gives `""`.
    public static func date(
        _ iso8601: String, style: QeetrixFormatDateStyle = .medium, locale: Locale = .current, timeZone: TimeZone = .current
    ) -> String {
        guard let moment = QeetrixFormatMoment(iso8601: iso8601) else { return "" }
        return format(moment, date: style, time: nil, locale: locale, timeZone: timeZone)
    }

    /// A moment's date and time, as `formatDateTime`: "25 Oct 2026, 2:30 pm" in `en-IN`, "Oct 25,
    /// 2026, 2:30 PM" in `en-US`. Shown in `timeZone`; always Gregorian.
    public static func dateTime(
        _ date: Date, dateStyle: QeetrixFormatDateStyle = .medium, timeStyle: QeetrixFormatTimeStyle = .short,
        locale: Locale = .current, timeZone: TimeZone = .current
    ) -> String {
        format(.instant(date), date: dateStyle, time: timeStyle, locale: locale, timeZone: timeZone)
    }

    /// A wall-clock date and time with no zone, shown as written; a calendar date alone — no `hour` —
    /// shows as ``date(_:style:locale:)`` writes it, never borrowing midnight. `""` when the components
    /// aren't a date and time.
    public static func dateTime(
        _ date: DateComponents, dateStyle: QeetrixFormatDateStyle = .medium, timeStyle: QeetrixFormatTimeStyle = .short,
        locale: Locale = .current
    ) -> String {
        guard let moment = QeetrixFormatMoment(date: date) else { return "" }
        return format(moment, date: dateStyle, time: timeStyle, locale: locale, timeZone: .current)
    }

    /// An ISO 8601 date or date-time with its time, as `formatDateTime`: a moment shows in `timeZone`,
    /// a date-time with no offset as written, and a calendar date without a time. Offsets may have a
    /// colon or not ("+05:30", "+0530"), and seconds a fraction. Anything else gives `""`.
    public static func dateTime(
        _ iso8601: String, dateStyle: QeetrixFormatDateStyle = .medium, timeStyle: QeetrixFormatTimeStyle = .short,
        locale: Locale = .current, timeZone: TimeZone = .current
    ) -> String {
        guard let moment = QeetrixFormatMoment(iso8601: iso8601) else { return "" }
        return format(moment, date: dateStyle, time: timeStyle, locale: locale, timeZone: timeZone)
    }

    /// A moment's time of day: "2:30 pm" in `en-IN`, "14:30" in `en-GB`, in `timeZone`. The time
    /// `formatDateTime` writes after the date.
    public static func time(
        _ date: Date, style: QeetrixFormatTimeStyle = .short, locale: Locale = .current, timeZone: TimeZone = .current
    ) -> String {
        QeetrixFormatCache.shared.string(from: date, .init(locale: locale, timeZone: timeZone, layout: .styles(nil, style)))
    }

    /// A date in the locale's all-number form, in Latin digits, as `@qeetrix/react`'s date fields write
    /// it so it can be typed back: "25/10/2026" in `en-IN`, "10/25/2026" in `en-US`, "2026/10/25" in
    /// `fa`. In `timeZone`; always Gregorian.
    public static func numericDate(_ date: Date, locale: Locale = .current, timeZone: TimeZone = .current) -> String {
        QeetrixFormatCache.shared.string(from: date, .init(locale: locale, timeZone: timeZone, layout: .numeric))
    }

    /// A calendar date in the locale's all-number form, in Latin digits: "25/10/2026" in `en-IN`. `""`
    /// when the components aren't a date; a time in them is ignored.
    public static func numericDate(_ date: DateComponents, locale: Locale = .current) -> String {
        guard let day = QeetrixFormatMoment.utcDate(year: date.year, month: date.month, day: date.day) else { return "" }
        return QeetrixFormatCache.shared.string(from: day, .init(locale: locale, timeZone: .gmt, layout: .numeric))
    }

    /// A range of days in the locale's all-number form, joined by an en dash, as `@qeetrix/react`'s
    /// DateRangePicker writes one: "01/12/2026 – 31/12/2026" in `en-IN`. Each end's date in `timeZone`.
    public static func dateRange(_ range: ClosedRange<Date>, locale: Locale = .current, timeZone: TimeZone = .current) -> String {
        "\(numericDate(range.lowerBound, locale: locale, timeZone: timeZone)) – \(numericDate(range.upperBound, locale: locale, timeZone: timeZone))"
    }

    /// A range of calendar dates in the locale's all-number form, joined by an en dash: "01/12/2026 –
    /// 31/12/2026" in `en-IN`. `""` when either end isn't a date.
    public static func dateRange(from start: DateComponents, to end: DateComponents, locale: Locale = .current) -> String {
        let first = numericDate(start, locale: locale)
        let last = numericDate(end, locale: locale)
        return first.isEmpty || last.isEmpty ? "" : "\(first) – \(last)"
    }

    /// A moment's date in the locale's words with the month abbreviated — "10 Sept 2026" in `en-IN` —
    /// as RelativeTime writes a date past its threshold (`day: "numeric", month: "short", year:
    /// "numeric"`).
    static func abbreviatedDate(_ date: Date, locale: Locale, timeZone: TimeZone) -> String {
        QeetrixFormatCache.shared.string(from: date, .init(locale: locale, timeZone: timeZone, layout: .template("yMMMd")))
    }

    /// `formatMoment`: a moment in `timeZone`; a calendar date, or a date-time with no zone, as
    /// written; a calendar date never with a time.
    static func format(
        _ moment: QeetrixFormatMoment, date: QeetrixFormatDateStyle, time: QeetrixFormatTimeStyle?, locale: Locale, timeZone: TimeZone
    ) -> String {
        switch moment {
        case .instant(let instant):
            QeetrixFormatCache.shared.string(from: instant, .init(locale: locale, timeZone: timeZone, layout: .styles(date, time)))
        case .plainDate(let day):
            QeetrixFormatCache.shared.string(from: day, .init(locale: locale, timeZone: .gmt, layout: .styles(date, nil)))
        case .plainDateTime(let wall):
            QeetrixFormatCache.shared.string(from: wall, .init(locale: locale, timeZone: .gmt, layout: .styles(date, time)))
        }
    }
}

// MARK: - Reading

/// A value to format, as `@qeetrix/react`'s format reads one: a moment, or a date or date-time with no
/// zone, which is kept as its UTC equivalent and shown in UTC, so it shows exactly as written.
enum QeetrixFormatMoment: Equatable, Sendable {
    /// A point in time, shown in a time zone.
    case instant(Date)
    /// A calendar date, as its UTC midnight.
    case plainDate(Date)
    /// A wall-clock date and time, as the same wall time in UTC.
    case plainDateTime(Date)

    /// The proleptic calendar the web's `Date.UTC` counts in, in UTC.
    static let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }()

    /// `read`: "YYYY-MM-DD", or "YYYY-MM-DDTHH:MM" with optional seconds, fraction, and `Z` or an offset
    /// ("+05:30", "+0530"). Impossible dates and times are `nil`.
    init?(iso8601 text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // ASCII digits only, as JavaScript's `\d`: Swift's `\d` would take any script's.
        let date = #/^([0-9]{4})-([0-9]{2})-([0-9]{2})$/#
        let dateTime =
            #/^([0-9]{4})-([0-9]{2})-([0-9]{2})[Tt]([0-9]{2}):([0-9]{2})(?::([0-9]{2})(?:\.([0-9]{1,9}))?)?([Zz]|[+-][0-9]{2}:?[0-9]{2})?$/#
        if let match = trimmed.wholeMatch(of: date) {
            guard let day = Self.utcDate(year: Int(match.1), month: Int(match.2), day: Int(match.3)) else { return nil }
            self = .plainDate(day)
            return
        }
        guard let match = trimmed.wholeMatch(of: dateTime) else { return nil }
        let hour = Int(match.4) ?? -1
        let minute = Int(match.5) ?? -1
        let second = match.6.flatMap { Int($0) } ?? 0
        guard (0...23).contains(hour), (0...59).contains(minute), (0...59).contains(second),
            let day = Self.utcDate(year: Int(match.1), month: Int(match.2), day: Int(match.3))
        else { return nil }
        // Milliseconds, as the web keeps them: the fraction's first three digits.
        let milliseconds = Int(String((match.7.map(String.init) ?? "").prefix(3)).padding(toLength: 3, withPad: "0", startingAt: 0)) ?? 0
        let wall = day.addingTimeInterval(TimeInterval(hour * 3600 + minute * 60 + second) + TimeInterval(milliseconds) / 1000)
        guard let zone = match.8.map({ $0.uppercased() }) else {
            self = .plainDateTime(wall)
            return
        }
        if zone == "Z" {
            self = .instant(wall)
            return
        }
        let sign: Double = zone.hasPrefix("-") ? -1 : 1
        let digits = zone.dropFirst().filter(\.isNumber)
        guard let offsetHours = Int(digits.prefix(2)), let offsetMinutes = Int(digits.suffix(2)), offsetHours <= 23, offsetMinutes <= 59
        else { return nil }
        self = .instant(wall.addingTimeInterval(-sign * TimeInterval(offsetHours * 3600 + offsetMinutes * 60)))
    }

    /// A calendar date (`year`, `month`, `day`), or a wall-clock date and time when it has an `hour`.
    init?(date components: DateComponents) {
        guard let day = Self.utcDate(year: components.year, month: components.month, day: components.day) else { return nil }
        guard let hour = components.hour else {
            self = .plainDate(day)
            return
        }
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        guard (0...23).contains(hour), (0...59).contains(minute), (0...59).contains(second) else { return nil }
        let fraction = TimeInterval(components.nanosecond ?? 0) / 1e9
        self = .plainDateTime(day.addingTimeInterval(TimeInterval(hour * 3600 + minute * 60 + second) + fraction))
    }

    /// The UTC midnight of a real date, or `nil` for 31 February and the like.
    static func utcDate(year: Int?, month: Int?, day: Int?) -> Date? {
        guard let year, let month, let day, (1...12).contains(month), day >= 1 else { return nil }
        guard let date = utc.date(from: DateComponents(year: year, month: month, day: day)) else { return nil }
        let back = utc.dateComponents([.year, .month, .day], from: date)
        return back.year == year && back.month == month && back.day == day ? date : nil
    }
}
