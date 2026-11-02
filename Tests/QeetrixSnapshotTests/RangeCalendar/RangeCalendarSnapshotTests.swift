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

    @MainActor
    @Suite("Range calendar snapshots")
    struct RangeCalendarSnapshotTests {
        /// A range across weeks with today and a ruled-out day inside it, a one-day range, and a disabled
        /// range, whose band goes grey.
        @Test("A range with today and a ruled-out day in it, a one-day range, and disabled")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 24) {
                    QeetrixRangeCalendar(
                        selection: .constant(date(2026, 10, 12)...date(2026, 10, 23)),
                        isDateDisabled: { $0 == date(2026, 10, 15) }, today: date(2026, 10, 20))
                    QeetrixRangeCalendar(selection: .constant(date(2026, 10, 7)...date(2026, 10, 7)), today: date(2026, 10, 30))
                    QeetrixRangeCalendar(selection: .constant(date(2026, 10, 12)...date(2026, 10, 23)), today: date(2026, 10, 20))
                        .disabled(true)
                }
                .environment(\.timeZone, kolkata)
            )
        }
    }
#endif
