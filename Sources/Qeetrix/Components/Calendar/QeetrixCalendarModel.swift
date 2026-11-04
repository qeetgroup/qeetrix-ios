import Foundation

/// What a calendar shows: a month of days, or — from its title — the months of a year or a decade's
/// years, as `@qeetrix/react`'s Calendar `view`.
enum QeetrixCalendarZoom: Hashable, Sendable {
    case days
    case months
    case years
}

/// How a day takes part in the selection (`mark`): the one chosen day, or a range's start, middle or end.
enum QeetrixCalendarMark: Hashable, Sendable {
    case single
    case start
    case middle
    case end

    /// The ends and a single day are filled Ember; days between sit on the band (range-calendar.css).
    var isFilled: Bool { self != .middle }
}

/// The keys the calendar answers, named apart from SwiftUI so the moves can be tested on their own.
enum QeetrixCalendarKey: Hashable, Sendable {
    case left, right, up, down, home, end, pageUp, pageDown
}

/// A month or year in the months or years view (`panel`).
struct QeetrixCalendarOption: Hashable, Sendable {
    /// The day focus moves to when it's chosen: the same day number in that month or year.
    let day: QeetrixCalendarDay
    /// Whether the focused day is in it.
    let isFocused: Bool
    /// Whether the chosen day is in it.
    let isSelected: Bool
    /// This month or this year.
    let isCurrent: Bool
    let isDisabled: Bool
    /// The years either side of the decade, muted (`data-outside`).
    let isOutside: Bool
}

/// The calendar's arithmetic, as `@qeetrix/react`'s CalendarCore and `internal/date.ts` do it: the
/// month grid, where keys move focus, the months and years panels and how far the arrows can go.
enum QeetrixCalendarModel {
    /// Six weeks, so the height never jumps.
    static let cellCount = 42

    /// The month of `focused` as six rows of seven, starting on `firstWeekday` (0 = Sunday); days of
    /// other months are `nil`, drawn blank.
    static func cells(_ focused: QeetrixCalendarDay, firstWeekday: Int) -> [QeetrixCalendarDay?] {
        let first = focused.firstOfMonth
        let lead = (first.weekday - firstWeekday + 7) % 7
        let length = QeetrixCalendarDay.daysInMonth(year: focused.year, month: focused.month)
        return (0..<cellCount).map { index in
            let day = index - lead + 1
            return (1...length).contains(day) ? QeetrixCalendarDay(year: focused.year, month: focused.month, day: day) : nil
        }
    }

    /// A week of days from `firstWeekday`, to write the weekdays' names from (1 January 2023 was a Sunday).
    static func weekdays(firstWeekday: Int) -> [QeetrixCalendarDay] {
        (0..<7).map { QeetrixCalendarDay(year: 2023, month: 1, day: 1).adding(days: firstWeekday + $0) }
    }

    /// The first year of the decade `year` is in.
    static func decade(_ year: Int) -> Int {
        Int((Double(year) / 10).rounded(.down)) * 10
    }

    /// Where a key moves focus, or `nil` for a key the view leaves alone (`keyTarget`). Days: arrows by
    /// a day and a week, left and right mirrored right to left; Home and End to the week's ends; Page Up
    /// and Page Down by a month, with Shift by a year. Months and years sit in rows of three: arrows by
    /// one and by a row, Home and End to the row's ends, Page Up and Page Down by a year or a decade.
    static func target(
        of key: QeetrixCalendarKey, shift: Bool, from focused: QeetrixCalendarDay, zoom: QeetrixCalendarZoom, firstWeekday: Int,
        isRightToLeft: Bool
    ) -> QeetrixCalendarDay {
        let step = isRightToLeft ? -1 : 1
        if zoom == .days {
            let offset = (focused.weekday - firstWeekday + 7) % 7
            switch key {
            case .left: return focused.adding(days: -step)
            case .right: return focused.adding(days: step)
            case .up: return focused.adding(days: -7)
            case .down: return focused.adding(days: 7)
            case .home: return focused.adding(days: -offset)
            case .end: return focused.adding(days: 6 - offset)
            case .pageUp: return focused.adding(months: shift ? -12 : -1)
            case .pageDown: return focused.adding(months: shift ? 12 : 1)
            }
        }
        let unit = zoom == .months ? 1 : 12
        let column = (zoom == .months ? focused.month - 1 : focused.year - decade(focused.year) + 1) % 3
        let page = zoom == .months ? 12 : 10
        let steps: Int
        switch key {
        case .left: steps = -step
        case .right: steps = step
        case .up: steps = -3
        case .down: steps = 3
        case .home: steps = -column
        case .end: steps = 2 - column
        case .pageUp: steps = -page
        case .pageDown: steps = page
        }
        return focused.adding(months: steps * unit)
    }

    /// How far the previous and next arrows move in a view: a month, a year or ten years.
    static func months(per zoom: QeetrixCalendarZoom) -> Int {
        switch zoom {
        case .days: 1
        case .months: 12
        case .years: 120
        }
    }

    /// Whether the previous arrow would leave the limits (`previousOut`).
    static func isPreviousOut(_ focused: QeetrixCalendarDay, zoom: QeetrixCalendarZoom, limits: QeetrixCalendarLimits) -> Bool {
        guard let min = limits.min else { return false }
        switch zoom {
        case .days: return focused.firstOfMonth.adding(months: -1) < min.firstOfMonth
        case .months: return focused.year - 1 < min.year
        case .years: return decade(focused.year) - 1 < min.year
        }
    }

    /// Whether the next arrow would leave the limits (`nextOut`).
    static func isNextOut(_ focused: QeetrixCalendarDay, zoom: QeetrixCalendarZoom, limits: QeetrixCalendarLimits) -> Bool {
        guard let max = limits.max else { return false }
        switch zoom {
        case .days: return focused.firstOfMonth.adding(months: 1) > max.firstOfMonth
        case .months: return focused.year + 1 > max.year
        case .years: return decade(focused.year) + 10 > max.year
        }
    }

    /// The twelve months of the focused year, or the twelve years of its decade page — the decade with
    /// the year either side, muted (2019–2030 for the 2020s), as Ant Design's panels.
    static func options(
        _ focused: QeetrixCalendarDay, zoom: QeetrixCalendarZoom, chosen: QeetrixCalendarDay?, today: QeetrixCalendarDay,
        limits: QeetrixCalendarLimits
    ) -> [QeetrixCalendarOption] {
        (0..<12).map { index in
            if zoom == .months {
                let month = index + 1
                return QeetrixCalendarOption(
                    day: QeetrixCalendarDay(year: focused.year, month: month, day: focused.day),
                    isFocused: month == focused.month,
                    isSelected: chosen?.year == focused.year && chosen?.month == month,
                    isCurrent: today.year == focused.year && today.month == month,
                    isDisabled: limits.isOutside(year: focused.year, month: month),
                    isOutside: false)
            }
            let year = decade(focused.year) - 1 + index
            return QeetrixCalendarOption(
                day: QeetrixCalendarDay(year: year, month: focused.month, day: focused.day),
                isFocused: year == focused.year,
                isSelected: chosen?.year == year,
                isCurrent: today.year == year,
                isDisabled: limits.isOutside(year: year),
                isOutside: index == 0 || index == 11)
        }
    }
}

// MARK: - Writing dates

extension QeetrixFormat {
    /// A calendar's month title: "October 2026" (`month: "long", year: "numeric"`), Gregorian.
    static func calendarMonthTitle(_ day: QeetrixCalendarDay, locale: Locale) -> String {
        calendarString(day, template: "yMMMM", locale: locale)
    }

    /// A year as the calendar writes it: "2026".
    static func calendarYear(_ year: Int, locale: Locale) -> String {
        calendarString(QeetrixCalendarDay(year: year, month: 1, day: 1), template: "y", locale: locale)
    }

    /// A day read in full: "Sunday, 25 October 2026" (`weekday: "long", day: "numeric", month: "long",
    /// year: "numeric"`).
    static func calendarFullDate(_ day: QeetrixCalendarDay, locale: Locale) -> String {
        calendarString(day, template: "yMMMMEEEEd", locale: locale)
    }

    /// A weekday's short name for the grid's header: "Sun" (`weekday: "short"`).
    static func calendarWeekday(_ day: QeetrixCalendarDay, locale: Locale) -> String {
        calendarString(day, template: "EEE", locale: locale)
    }

    /// A month's short name for the months view: "Oct" (`month: "short"`).
    static func calendarMonth(_ day: QeetrixCalendarDay, locale: Locale) -> String {
        calendarString(day, template: "MMM", locale: locale)
    }

    /// A day's number in the grid, in the locale's digits.
    static func calendarDayNumber(_ day: QeetrixCalendarDay, locale: Locale) -> String {
        calendarString(day, template: "d", locale: locale)
    }

    /// A day written from a skeleton at its UTC midnight in UTC, as the web's `dateFormat` writes its
    /// dates, so no zone can move it.
    static func calendarString(_ day: QeetrixCalendarDay, template: String, locale: Locale) -> String {
        QeetrixFormatCache.shared.string(from: day.utcMidnight, .init(locale: locale, timeZone: .gmt, layout: .template(template)))
    }
}
