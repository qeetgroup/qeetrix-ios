import SwiftUI
import Testing

@testable import Qeetrix

private let enIN = Locale(identifier: "en-IN")
private let kolkata = TimeZone(identifier: "Asia/Kolkata")!

private func day(_ year: Int, _ month: Int, _ day: Int) -> QeetrixCalendarDay {
    QeetrixCalendarDay(year: year, month: month, day: day)
}

@MainActor
@Suite("Date range picker")
struct DateRangePickerTests {
    @Test("The field writes both ends as the web does, joined by an en dash")
    func text() {
        let range = day(2026, 12, 1).start(in: kolkata)...day(2026, 12, 31).start(in: kolkata)
        #expect(QeetrixFormat.dateRange(range, locale: enIN, timeZone: kolkata) == "01/12/2026 – 31/12/2026")
        let spoken = QeetrixCalendarStrings.rangeSelected(
            QeetrixFormat.date(range.lowerBound, style: .long, locale: enIN, timeZone: kolkata),
            QeetrixFormat.date(range.upperBound, style: .long, locale: enIN, timeZone: kolkata), locale: enIN)
        #expect(spoken == "1 December 2026 to 31 December 2026")
    }

    @Test("The named presets are namedRange's: the last n days end today, today included; months are whole")
    func named() {
        let today = day(2026, 1, 15)
        func days(_ preset: QeetrixDateRangePreset) -> [QeetrixCalendarDay] {
            let range = preset.days(today: today, timeZone: kolkata)
            return [range.start, range.end]
        }
        #expect(days(.today) == [today, today])
        #expect(days(.last7Days) == [day(2026, 1, 9), today])
        #expect(days(.last30Days) == [day(2025, 12, 17), today])
        #expect(days(.last90Days) == [day(2025, 10, 18), today])
        #expect(days(.thisMonth) == [day(2026, 1, 1), day(2026, 1, 31)])
        #expect(days(.lastMonth) == [day(2025, 12, 1), day(2025, 12, 31)])
        #expect(days(.lastMonth).count == 2)
        // A custom range's moments are the days they fall on in the picker's time zone.
        let custom = QeetrixDateRangePreset("Two days") {
            day(2026, 3, 1).start(in: kolkata).addingTimeInterval(3600)...day(2026, 3, 2).start(in: kolkata).addingTimeInterval(23 * 3600)
        }
        #expect(days(custom) == [day(2026, 3, 1), day(2026, 3, 2)])
    }

    @Test("A preset is cut to the limits, and can't be chosen wholly outside them or ending on a ruled-out day")
    func fitting() {
        let limits = QeetrixCalendarLimits(min: day(2026, 1, 10), max: day(2026, 1, 20)) { $0 == day(2026, 1, 18) }
        let cut = QeetrixDateRangePreset.fitted((day(2026, 1, 1), day(2026, 1, 15)), to: limits)
        #expect(cut?.start == day(2026, 1, 10) && cut?.end == day(2026, 1, 15))
        #expect(QeetrixDateRangePreset.fitted((day(2025, 12, 1), day(2025, 12, 31)), to: limits) == nil)
        #expect(QeetrixDateRangePreset.fitted((day(2026, 1, 12), day(2026, 1, 18)), to: limits) == nil)
        #expect(QeetrixDateRangePreset.fitted((day(2026, 1, 12), day(2026, 1, 19)), to: limits) != nil, "a ruled-out day inside is fine")
    }

    @Test("Presets are labelled from the catalogue")
    func labels() {
        #expect(QeetrixDateRangePickerStrings.lastDays(7, locale: enIN) == "Last 7 days")
        #expect(QeetrixDateRangePickerStrings.lastDays(30, locale: enIN) == "Last 30 days")
    }

    @Test("It renders empty, with a range, with presets, an error, read-only and disabled")
    func renders() {
        let zone = TimeZone.current
        let range = day(2026, 12, 1).start(in: zone)...day(2026, 12, 31).start(in: zone)
        let views: [AnyView] = [
            AnyView(QeetrixDateRangePicker("Billing period", selection: .constant(nil))),
            AnyView(QeetrixDateRangePicker("Billing period", selection: .constant(range), presets: [.thisMonth, .lastMonth])),
            AnyView(QeetrixDateRangePicker("Billing period", selection: .constant(nil), error: "Choose a period of up to a year")),
            AnyView(QeetrixDateRangePicker("Billing period", selection: .constant(range), isReadOnly: true)),
            AnyView(QeetrixDateRangePicker("Billing period", selection: .constant(range)).disabled(true)),
            AnyView(QeetrixDateRangePicker("Billing period", selection: .constant(range)).dynamicTypeSize(.accessibility3)),
        ]
        for view in views {
            #expect(ImageRenderer(content: view.frame(width: 390)).cgImage != nil)
        }
    }
}
