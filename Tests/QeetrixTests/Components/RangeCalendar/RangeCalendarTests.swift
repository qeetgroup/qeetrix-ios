import SwiftUI
import Testing

@testable import Qeetrix

private func day(_ year: Int, _ month: Int, _ day: Int) -> QeetrixCalendarDay {
    QeetrixCalendarDay(year: year, month: month, day: day)
}

@MainActor
@Suite("Range calendar")
struct RangeCalendarTests {
    @Test("Ends come out earlier first, whichever is picked first; the same day twice is a one-day range")
    func ordering() {
        let (start, end) = QeetrixRangeCalendarSelection.ordered(day(2026, 10, 16), day(2026, 10, 12))
        #expect((start, end) == (day(2026, 10, 12), day(2026, 10, 16)))
        let ends = (start: day(2026, 10, 12), end: day(2026, 10, 12))
        #expect(QeetrixRangeCalendarSelection.mark(day(2026, 10, 12), ends: ends) == .single)
    }

    @Test("Each day's part: the start, the middle and the end; nothing outside the range or with no range")
    func marks() {
        let ends = (start: day(2026, 10, 12), end: day(2026, 10, 16))
        #expect(QeetrixRangeCalendarSelection.mark(day(2026, 10, 11), ends: ends) == nil)
        #expect(QeetrixRangeCalendarSelection.mark(day(2026, 10, 12), ends: ends) == .start)
        #expect(QeetrixRangeCalendarSelection.mark(day(2026, 10, 14), ends: ends) == .middle)
        #expect(QeetrixRangeCalendarSelection.mark(day(2026, 10, 16), ends: ends) == .end)
        #expect(QeetrixRangeCalendarSelection.mark(day(2026, 10, 17), ends: ends) == nil)
        #expect(QeetrixRangeCalendarSelection.mark(day(2026, 10, 14), ends: nil) == nil)
        #expect(QeetrixCalendarMark.start.isFilled && QeetrixCalendarMark.end.isFilled && !QeetrixCalendarMark.middle.isFilled)
    }

    @Test("While half chosen, the preview runs from the first day to the one pointed at, either way, and replaces the old range")
    func preview() {
        let old = (start: day(2026, 9, 1), end: day(2026, 9, 5))
        let backwards = QeetrixRangeCalendarSelection.ends(anchor: day(2026, 10, 12), point: day(2026, 10, 8), range: old)
        #expect(backwards?.start == day(2026, 10, 8) && backwards?.end == day(2026, 10, 12))
        let alone = QeetrixRangeCalendarSelection.ends(anchor: day(2026, 10, 12), point: nil, range: old)
        #expect(alone?.start == day(2026, 10, 12) && alone?.end == day(2026, 10, 12))
        let settled = QeetrixRangeCalendarSelection.ends(anchor: nil, point: nil, range: old)
        #expect(settled?.start == day(2026, 9, 1) && settled?.end == day(2026, 9, 5))
    }

    @Test("Each step is announced as the web's live region says it")
    func announcements() {
        let locale = Locale(identifier: "en-IN")
        let start = QeetrixFormat.calendarFullDate(day(2026, 10, 12), locale: locale)
        let end = QeetrixFormat.calendarFullDate(day(2026, 10, 16), locale: locale)
        #expect(QeetrixCalendarStrings.rangeStart(start, locale: locale) == "Starts Monday, 12 October 2026. Now choose the end date.")
        #expect(QeetrixCalendarStrings.rangeSelected(start, end, locale: locale) == "Monday, 12 October 2026 to Friday, 16 October 2026")
    }

    @Test("The band is drawn where the drawn range has days of its own, not for a one-day range")
    func band() {
        func band(_ mark: QeetrixCalendarMark?) -> QeetrixColor? {
            QeetrixCalendarDayState(
                mark: mark, isToday: false, isDisabled: false, isCalendarEnabled: true, isReadOnly: false, isRange: true, isHovered: false,
                isCursor: false
            ).band
        }
        #expect([band(.start), band(.middle), band(.end)] == [.bgBrandSubtle, .bgBrandSubtle, .bgBrandSubtle])
        #expect(band(.single) == nil && band(nil) == nil)
    }

    #if os(macOS)
        @Test("VoiceOver finds every day of the range selected")
        func accessibilityTree() {
            let zone = TimeZone(identifier: "Asia/Kolkata")!
            let view = QeetrixRangeCalendar(
                selection: .constant(day(2026, 10, 12).start(in: zone)...day(2026, 10, 14).start(in: zone)),
                today: day(2026, 10, 30).start(in: zone)
            )
            .environment(\.timeZone, zone)
            let selected = ListsAccessibilityTree.elements(of: view).filter(\.isSelected).map(\.text)
            #expect(selected == ["Monday, October 12, 2026", "Tuesday, October 13, 2026", "Wednesday, October 14, 2026"])
        }
    #endif

    @Test("It renders empty, with a range across months, limited, read-only, disabled and right to left")
    func renders() {
        let zone = TimeZone.current
        let today = day(2026, 10, 30).start(in: zone)
        let range = day(2026, 10, 12).start(in: zone)...day(2026, 11, 3).start(in: zone)
        let views: [AnyView] = [
            AnyView(QeetrixRangeCalendar(selection: .constant(nil), today: today)),
            AnyView(QeetrixRangeCalendar(selection: .constant(range), today: today)),
            AnyView(QeetrixRangeCalendar(selection: .constant(range), min: today, isDateDisabled: { _ in false }, today: today)),
            AnyView(QeetrixRangeCalendar(selection: .constant(range), isReadOnly: true, today: today)),
            AnyView(QeetrixRangeCalendar(selection: .constant(range), today: today).disabled(true)),
            AnyView(QeetrixRangeCalendar(selection: .constant(range), today: today).environment(\.layoutDirection, .rightToLeft)),
        ]
        for view in views {
            #expect(ImageRenderer(content: view.frame(width: 390)).cgImage != nil)
        }
    }
}
