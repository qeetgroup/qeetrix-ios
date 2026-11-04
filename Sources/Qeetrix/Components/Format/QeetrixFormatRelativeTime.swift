import Foundation

extension QeetrixFormat {
    /// How long ago or how soon, in the largest whole unit, as `formatRelativeTime`: "2 minutes ago",
    /// "in 3 days", "yesterday", "last week", "now".
    ///
    /// It rounds first and then picks the unit, so 59 minutes 40 seconds is "1 hour ago", not "60
    /// minutes ago", and 364 days is "last year", not "12 months ago". A month is 30 days, so four weeks
    /// are not yet a month and five are; a year is 365 days. Less than half a second either way is
    /// "now". Halves round away from now, in the past and the future alike.
    ///
    /// `now` is a parameter so a list of rows reads one clock, and tests a fixed one;
    /// ``QeetrixRelativeTime`` keeps the text current on screen.
    public static func relativeTime(_ date: Date, now: Date = .now, locale: Locale = .current) -> String {
        let delta = date.timeIntervalSince(now)
        for unit in QeetrixFormatRelativeUnit.allCases {
            let amount = (abs(delta) / unit.seconds).rounded(rounding)
            if amount < unit.next {
                return QeetrixFormatCache.shared.relative(amount == 0 ? 0 : Int(amount) * (delta < 0 ? -1 : 1), unit, locale: locale)
            }
        }
        return QeetrixFormatCache.shared.relative(0, .second, locale: locale)
    }
}

/// `UNITS`: each unit, its length, and how many of it make the next.
enum QeetrixFormatRelativeUnit: CaseIterable, Sendable {
    case second, minute, hour, day, week, month, year

    var seconds: TimeInterval {
        switch self {
        case .second: 1
        case .minute: 60
        case .hour: 3600
        case .day: 86_400
        case .week: 7 * 86_400
        case .month: 30 * 86_400
        case .year: 365 * 86_400
        }
    }

    /// How many of this unit make the next: a month is 30 days, so 30 / 7 weeks; 12 months a year.
    var next: Double {
        switch self {
        case .second, .minute: 60
        case .hour: 24
        case .day: 7
        case .week: 30.0 / 7
        case .month: 12
        case .year: .infinity
        }
    }

    /// The date component `RelativeDateTimeFormatter` names the unit by.
    var component: Calendar.Component {
        switch self {
        case .second: .second
        case .minute: .minute
        case .hour: .hour
        case .day: .day
        case .week: .weekOfMonth
        case .month: .month
        case .year: .year
        }
    }
}
