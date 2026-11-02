import SwiftUI
import Testing

@testable import Qeetrix

private let enIN = Locale(identifier: "en-IN")
private let kolkata = TimeZone(identifier: "Asia/Kolkata")!
private let utc = TimeZone(identifier: "UTC")!

private func day(_ year: Int, _ month: Int, _ day: Int) -> QeetrixCalendarDay {
    QeetrixCalendarDay(year: year, month: month, day: day)
}

@MainActor
@Suite("Calendar")
struct CalendarTests {
    @Test("Days count as the web's internal/date.ts does: day numbers, weekdays, leap years, months that clamp")
    func arithmetic() {
        #expect(day(1970, 1, 1).dayNumber == 0)
        #expect(day(2026, 10, 25).dayNumber == 20_751)
        for number in [-800_000, -1, 0, 59, 11_016, 20_751, 2_000_000] {
            #expect(QeetrixCalendarDay(dayNumber: number).dayNumber == number)
        }
        #expect(day(2026, 10, 25).weekday == 0, "a Sunday")
        #expect(day(1970, 1, 1).weekday == 4, "a Thursday")
        #expect(day(2024, 2, 28).adding(days: 1) == day(2024, 2, 29))
        #expect(day(2026, 2, 28).adding(days: 1) == day(2026, 3, 1))
        #expect(day(2026, 12, 31).adding(days: 1) == day(2027, 1, 1))
        // addMonths: the same day, or the month's last when it's shorter.
        #expect(day(2026, 1, 31).adding(months: 1) == day(2026, 2, 28))
        #expect(day(2024, 1, 31).adding(months: 1) == day(2024, 2, 29))
        #expect(day(2026, 1, 15).adding(months: -1) == day(2025, 12, 15))
        #expect(day(2026, 3, 31).adding(months: -13) == day(2025, 2, 28))
        #expect([1900, 2023, 2100].map(QeetrixCalendarDay.isLeap) == [false, false, false])
        #expect([2000, 2024].map(QeetrixCalendarDay.isLeap) == [true, true])
        #expect(day(2026, 2, 31) == day(2026, 2, 28), "dayIn: 31 February is the month's last day")
        #expect(day(2026, 10, 5).description == "2026-10-05")
    }

    @Test("A moment is the day it falls on in the time zone, and a day is the moment it starts there")
    func timeZones() throws {
        // 20:00 UTC on 25 October is 01:30 on the 26th in India.
        let evening = try #require(ISO8601DateFormatter().date(from: "2026-10-25T20:00:00Z"))
        #expect(QeetrixCalendarDay(evening, in: utc) == day(2026, 10, 25))
        #expect(QeetrixCalendarDay(evening, in: kolkata) == day(2026, 10, 26))
        let start = day(2026, 10, 26).start(in: kolkata)
        #expect(start == ISO8601DateFormatter().date(from: "2026-10-25T18:30:00Z"))
        #expect(QeetrixCalendarDay(start, in: kolkata) == day(2026, 10, 26))
        // A day whose midnight a daylight-saving change skips (Santiago, 7 September 2025) still starts on
        // that day.
        let santiago = try #require(TimeZone(identifier: "America/Santiago"))
        #expect(QeetrixCalendarDay(day(2025, 9, 7).start(in: santiago), in: santiago) == day(2025, 9, 7))
        #expect(day(2026, 10, 25).utcMidnight == ISO8601DateFormatter().date(from: "2026-10-25T00:00:00Z"))
    }

    @Test("The week starts on the locale's first day: Sunday in India and the US, Monday in Britain, Saturday in Egypt")
    func firstWeekday() {
        #expect(Locale(identifier: "en-IN").qeetrixCalendarFirstWeekday == 0)
        #expect(Locale(identifier: "en-US").qeetrixCalendarFirstWeekday == 0)
        #expect(Locale(identifier: "en-GB").qeetrixCalendarFirstWeekday == 1)
        #expect(Locale(identifier: "de-DE").qeetrixCalendarFirstWeekday == 1)
        #expect(Locale(identifier: "ar-EG").qeetrixCalendarFirstWeekday == 6)
        #expect(QeetrixCalendarModel.weekdays(firstWeekday: 1).map(\.weekday) == [1, 2, 3, 4, 5, 6, 0])
        #expect(QeetrixFormat.calendarWeekday(QeetrixCalendarModel.weekdays(firstWeekday: 0)[0], locale: enIN) == "Sun")
    }

    @Test("Six weeks of seven: October 2026 starts on a Thursday, so four blanks from Sunday and three from Monday")
    func grid() {
        let sunday = QeetrixCalendarModel.cells(day(2026, 10, 25), firstWeekday: 0)
        #expect(sunday.count == 42)
        #expect(sunday.prefix(4).allSatisfy { $0 == nil })
        #expect(sunday[4] == day(2026, 10, 1))
        #expect(sunday[34] == day(2026, 10, 31))
        #expect(sunday[35...].allSatisfy { $0 == nil })
        let monday = QeetrixCalendarModel.cells(day(2026, 10, 25), firstWeekday: 1)
        #expect(monday.prefix(3).allSatisfy { $0 == nil })
        #expect(monday[3] == day(2026, 10, 1))
        #expect(QeetrixCalendarModel.cells(day(2026, 2, 10), firstWeekday: 0).compactMap { $0 }.count == 28)
    }

    @Test("Keys move as keyTarget does: by a day and a week, mirrored right to left; the week's ends; a month, or a year with Shift")
    func dayKeys() {
        let focused = day(2026, 10, 14)  // a Wednesday
        func move(_ key: QeetrixCalendarKey, shift: Bool = false, rtl: Bool = false, first: Int = 0) -> QeetrixCalendarDay {
            QeetrixCalendarModel.target(of: key, shift: shift, from: focused, zoom: .days, firstWeekday: first, isRightToLeft: rtl)
        }
        #expect(move(.left) == day(2026, 10, 13))
        #expect(move(.right) == day(2026, 10, 15))
        #expect(move(.left, rtl: true) == day(2026, 10, 15))
        #expect(move(.right, rtl: true) == day(2026, 10, 13))
        #expect(move(.up) == day(2026, 10, 7))
        #expect(move(.down) == day(2026, 10, 21))
        #expect(move(.home) == day(2026, 10, 11), "Sunday")
        #expect(move(.end) == day(2026, 10, 17), "Saturday")
        #expect(move(.home, first: 1) == day(2026, 10, 12), "Monday")
        #expect(move(.end, first: 1) == day(2026, 10, 18), "Sunday")
        #expect(move(.pageUp) == day(2026, 9, 14))
        #expect(move(.pageDown) == day(2026, 11, 14))
        #expect(move(.pageUp, shift: true) == day(2025, 10, 14))
        #expect(move(.pageDown, shift: true) == day(2027, 10, 14))
    }

    @Test("In the months and years, rows of three: arrows by one and a row, Home and End to the row's ends, pages by a year or a decade")
    func panelKeys() {
        let focused = day(2026, 10, 14)
        func move(_ key: QeetrixCalendarKey, _ zoom: QeetrixCalendarZoom) -> QeetrixCalendarDay {
            QeetrixCalendarModel.target(of: key, shift: false, from: focused, zoom: zoom, firstWeekday: 0, isRightToLeft: false)
        }
        #expect(move(.right, .months) == day(2026, 11, 14))
        #expect(move(.down, .months) == day(2027, 1, 14))
        #expect(move(.home, .months) == day(2026, 10, 14), "October starts its row")
        #expect(move(.end, .months) == day(2026, 12, 14))
        #expect(move(.pageDown, .months) == day(2027, 10, 14))
        #expect(move(.right, .years) == day(2027, 10, 14))
        #expect(move(.up, .years) == day(2023, 10, 14))
        // 2026 is the eighth of 2019–2030: the second in its row (2025, 2026, 2027).
        #expect(move(.home, .years) == day(2025, 10, 14))
        #expect(move(.end, .years) == day(2027, 10, 14))
        #expect(move(.pageUp, .years) == day(2016, 10, 14))
    }

    @Test("Limits: days outside min and max or ruled out are disabled; the arrows stop at the limits; focus is kept inside")
    func limits() {
        let limits = QeetrixCalendarLimits(min: day(2026, 10, 10), max: day(2026, 12, 20)) { $0.weekday == 0 }
        #expect(limits.isDisabled(day(2026, 10, 9)))
        #expect(!limits.isDisabled(day(2026, 10, 10)))
        #expect(limits.isDisabled(day(2026, 10, 11)), "a Sunday, ruled out")
        #expect(limits.isDisabled(day(2026, 12, 21)))
        #expect(limits.clamp(day(2026, 1, 1)) == day(2026, 10, 10))
        #expect(limits.clamp(day(2027, 1, 1)) == day(2026, 12, 20))
        #expect(QeetrixCalendarModel.isPreviousOut(day(2026, 10, 15), zoom: .days, limits: limits))
        #expect(!QeetrixCalendarModel.isNextOut(day(2026, 10, 15), zoom: .days, limits: limits))
        #expect(QeetrixCalendarModel.isNextOut(day(2026, 12, 1), zoom: .days, limits: limits))
        #expect(QeetrixCalendarModel.isPreviousOut(day(2026, 12, 1), zoom: .months, limits: limits))
        #expect(QeetrixCalendarModel.isNextOut(day(2026, 12, 1), zoom: .years, limits: limits))
        #expect(!QeetrixCalendarModel.isPreviousOut(day(2026, 12, 1), zoom: .days, limits: QeetrixCalendarLimits()))
        #expect(limits.isOutside(year: 2026, month: 9))
        #expect(!limits.isOutside(year: 2026, month: 10))
        #expect(limits.isOutside(year: 2027))
        // The public API's moments become the days they fall on.
        let fromDates = QeetrixCalendarLimits(
            min: day(2026, 10, 10).start(in: kolkata), max: nil, isDateDisabled: { _ in false }, timeZone: kolkata)
        #expect(fromDates.min == day(2026, 10, 10))
    }

    @Test("The years view is a decade with a year either side, muted; the months view its year's twelve, each marked")
    func panels() {
        let limits = QeetrixCalendarLimits(min: day(2021, 3, 1))
        let years = QeetrixCalendarModel.options(
            day(2026, 10, 14), zoom: .years, chosen: day(2024, 5, 1), today: day(2026, 10, 30), limits: limits)
        #expect(years.map(\.day.year) == Array(2019...2030))
        #expect(years.map(\.isOutside) == [true] + Array(repeating: false, count: 10) + [true])
        #expect(years.filter(\.isDisabled).map(\.day.year) == [2019, 2020])
        #expect(years.first(where: \.isSelected)?.day.year == 2024)
        #expect(years.first(where: \.isCurrent)?.day.year == 2026)
        #expect(years.first(where: \.isFocused)?.day.year == 2026)
        let months = QeetrixCalendarModel.options(day(2026, 1, 31), zoom: .months, chosen: nil, today: day(2026, 10, 30), limits: limits)
        #expect(months.count == 12)
        #expect(months[1].day == day(2026, 2, 28), "February keeps the day as far as it goes")
        #expect(months.first(where: \.isCurrent)?.day.month == 10)
        #expect(QeetrixCalendarModel.decade(2026) == 2020)
        #expect(QeetrixCalendarModel.months(per: .years) == 120)
    }

    @Test("Titles and VoiceOver's words: the month, the full date with today, and the title button")
    func words() {
        #expect(QeetrixFormat.calendarMonthTitle(day(2026, 10, 25), locale: enIN) == "October 2026")
        #expect(QeetrixFormat.calendarFullDate(day(2026, 10, 25), locale: enIN) == "Sunday, 25 October 2026")
        #expect(QeetrixFormat.calendarMonth(day(2026, 10, 25), locale: enIN) == "Oct")
        #expect(QeetrixFormat.calendarDayNumber(day(2026, 10, 5), locale: enIN) == "5")
        #expect(QeetrixFormat.calendarYear(2026, locale: enIN) == "2026")
        #expect(QeetrixCalendarStrings.today("Sunday, 25 October 2026", locale: enIN) == "Today, Sunday, 25 October 2026")
        #expect(QeetrixCalendarStrings.chooseYear("October 2026", locale: enIN) == "October 2026, choose year")
        // Gregorian whatever the locale's calendar: no Buddhist era in Thai.
        #expect(QeetrixFormat.calendarYear(2026, locale: Locale(identifier: "th-TH")).contains("2026"))
    }

    @Test("Days are size.control.md in cells at least 44 pt square, so their targets tile; they grow with the text")
    func metrics() {
        let standard = QeetrixCalendarMetrics(density: .default, scale: 1)
        #expect(standard.day == QeetrixDensity.default.sizeControlMd)
        #expect(standard.minimumColumn == standard.day + 2, "calendar.css: 1px cell padding")
        #expect((standard.column, standard.row) == (44, 44))
        #expect(standard.weekday == QeetrixDensity.default.sizeControlSm)
        #expect(standard.ownWidth == CGFloat(7 * 44))
        let large = QeetrixCalendarMetrics(density: .default, scale: 2)
        #expect(large.day == 2 * QeetrixDensity.default.sizeControlMd)
        #expect(large.row == large.day + 2)
        #expect(QeetrixCalendarMetrics.titleType.tokens.weight == QeetrixTextRole.titleSm.tokens.weight)
    }

    @Test("A day's look follows calendar.css and range-calendar.css: Ember when chosen, today's outline, grey when disabled, the band")
    func looks() {
        func state(
            _ mark: QeetrixCalendarMark? = nil, today: Bool = false, disabled: Bool = false, enabled: Bool = true, readOnly: Bool = false,
            range: Bool = false, hovered: Bool = false
        ) -> QeetrixCalendarDayState {
            QeetrixCalendarDayState(
                mark: mark, isToday: today, isDisabled: disabled, isCalendarEnabled: enabled, isReadOnly: readOnly, isRange: range,
                isHovered: hovered, isCursor: false)
        }
        #expect(state().fill == nil && state().foreground == .textDefault && state().outline == nil)
        #expect(state(hovered: true).fill == .overlayHover)
        #expect(state().pressed(true).fill == .overlayPressed)
        #expect(state(today: true).outline == .borderBrand)
        #expect(state(.single).fill == .bgBrandBold && state(.single).foreground == .textOnBrand)
        #expect(state(.single, hovered: true).fill == .bgBrandBoldHover)
        #expect(state(.single, today: true).outline == nil, "the fill takes over the outline")
        #expect(state(disabled: true).foreground == .textDisabled && state(disabled: true, hovered: true).fill == nil)
        #expect(state(.single, enabled: false).fill == .bgDisabled && state(.single, enabled: false).foreground == .textDisabled)
        #expect(state(today: true, enabled: false).outline == .borderDisabled)
        #expect(state(readOnly: true, hovered: true).fill == nil)
        #expect(state(.single, readOnly: true, hovered: true).fill == .bgBrandBold)
        // The range: Ember ends on the band, the middle on the band in the text's own colour.
        #expect(state(.start, range: true).fill == .bgBrandBold && state(.start, range: true).band == .bgBrandSubtle)
        #expect(state(.middle, range: true).fill == nil && state(.middle, range: true).foreground == .textDefault)
        #expect(state(.middle, range: true, hovered: true).fill == .bgBrandSubtleHover)
        #expect(state(.middle, today: true, range: true).outline == .borderBrand)
        #expect(state(.middle, disabled: true, range: true).foreground == .textDisabled)
        #expect(state(.middle, enabled: false, range: true).band == .bgDisabled)
        #expect(state(.single, range: true).band == nil, "a one-day range has no band")
        // Months and years either side of a decade are muted.
        var outside = state()
        outside.isOutside = true
        #expect(outside.foreground == .textSubtle)
    }

    @Test("The colours a calendar draws meet AA in both schemes, the ones the package's matrix doesn't test included")
    func contrast() {
        let pairs: [ContrastTests.Pair] = [
            // Days on the popover, hovered and pressed.
            ContrastTests.Pair(foreground: .textDefault, background: [.overlayHover, .surfaceOverlay], minimum: 4.5),
            ContrastTests.Pair(foreground: .textDefault, background: [.overlayPressed, .surfaceOverlay], minimum: 4.5),
            // A range's middle days, hovered and pressed, and today's outline inside it.
            ContrastTests.Pair(foreground: .textDefault, background: [.bgBrandSubtleHover], minimum: 4.5),
            ContrastTests.Pair(foreground: .textDefault, background: [.bgBrandSubtlePressed], minimum: 4.5),
            ContrastTests.Pair(foreground: .borderBrand, background: [.bgBrandSubtle], minimum: 3),
            // A chosen day pressed; today's outline and the weekdays on the popover.
            ContrastTests.Pair(foreground: .textOnBrand, background: [.bgBrandBoldPressed], minimum: 4.5),
            ContrastTests.Pair(foreground: .borderBrand, background: [.surfaceOverlay], minimum: 3),
            ContrastTests.Pair(foreground: .textSubtle, background: [.surfaceOverlay], minimum: 4.5),
        ]
        for theme in [QeetrixTheme.light, .dark] {
            for pair in pairs {
                let ratio = ContrastTests.ratio(pair, theme)
                #expect(ratio >= pair.minimum, "\(theme.colorScheme): \(pair) — \(ratio)")
            }
        }
    }

    #if os(macOS)
        @Test(
            "VoiceOver finds the arrows, the title and each day by its full date, the chosen one selected; weekdays and blanks are hidden")
        func accessibilityTree() {
            let view = QeetrixCalendar(
                selection: .constant(day(2026, 10, 14).start(in: kolkata)), today: day(2026, 10, 30).start(in: kolkata)
            )
            .environment(\.timeZone, kolkata)
            let elements = ListsAccessibilityTree.elements(of: view)
            #expect(elements.prefix(3).map(\.text) == ["Previous month", "October 2026, choose year", "Next month"])
            let days = elements.dropFirst(3)
            #expect(days.count == 31, "no weekday names, no blank days: \(elements)")
            #expect(days.allSatisfy { $0.role == "AXButton" })
            #expect(days.first?.text == "Thursday, October 1, 2026")
            #expect(days.filter(\.isSelected).map(\.text) == ["Wednesday, October 14, 2026"])
            #expect(days.contains { $0.text == "Today, Friday, October 30, 2026" })
        }
    #endif

    @Test("It renders inline, chosen, limited, read-only, disabled, in another density and right to left")
    func renders() {
        let today = day(2026, 10, 30).start(in: .current)
        let views: [AnyView] = [
            AnyView(QeetrixCalendar(selection: .constant(nil), today: today)),
            AnyView(QeetrixCalendar(selection: .constant(day(2026, 10, 25).start(in: .current)), today: today)),
            AnyView(QeetrixCalendar(selection: .constant(nil), min: today, isDateDisabled: { _ in true }, today: today)),
            AnyView(QeetrixCalendar(selection: .constant(today), isReadOnly: true, today: today)),
            AnyView(QeetrixCalendar(selection: .constant(today), today: today).disabled(true)),
            AnyView(QeetrixCalendar(selection: .constant(today), today: today).qeetrixDensity(.compact)),
            AnyView(QeetrixCalendar(selection: .constant(today), today: today).environment(\.layoutDirection, .rightToLeft)),
        ]
        for view in views {
            #expect(ImageRenderer(content: view.frame(width: 390)).cgImage != nil)
        }
    }
}
