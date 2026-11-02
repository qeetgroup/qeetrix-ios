#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    /// A fixed zone and fixed days, so the months shown and today's outline never move.
    private let kolkata = TimeZone(identifier: "Asia/Kolkata")!

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = kolkata
        return calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func isWeekend(_ date: Date) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = kolkata
        return calendar.isDateInWeekend(date)
    }

    @MainActor
    @Suite("Calendar snapshots")
    struct CalendarSnapshotTests {
        /// Today outlined, a chosen day, days before `min` and ruled-out weekends grey; then read-only and
        /// disabled.
        @Test("Chosen, today, limits and ruled-out days, read-only and disabled")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 24) {
                    QeetrixCalendar(
                        selection: .constant(date(2026, 10, 14)), min: date(2026, 10, 5), isDateDisabled: isWeekend,
                        today: date(2026, 10, 30))
                    QeetrixCalendar(selection: .constant(date(2026, 10, 30)), isReadOnly: true, today: date(2026, 10, 30))
                    QeetrixCalendar(selection: .constant(date(2026, 10, 14)), today: date(2026, 10, 30)).disabled(true)
                }
                .environment(\.timeZone, kolkata)
            )
        }
    }
#endif
