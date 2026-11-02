#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    private let kolkata = TimeZone(identifier: "Asia/Kolkata")!

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = kolkata
        return calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    @MainActor
    @Suite("Date picker snapshots")
    struct DatePickerSnapshotTests {
        /// The field only: the calendar it opens is the system's, or the calendar's own specimen.
        @Test("Empty with a placeholder, a date with help, an error, read-only and disabled")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixDatePicker("Joining date", selection: .constant(nil), placeholder: Text("Choose a date"), isOptional: true)
                    QeetrixDatePicker(
                        "Joining date", selection: .constant(date(2026, 10, 25)), description: Text("Your first day at work."))
                    QeetrixDatePicker("Delivery", selection: .constant(date(2026, 10, 25)), error: "Choose a weekday")
                    QeetrixDatePicker("Joined", selection: .constant(date(2026, 10, 25)), isReadOnly: true)
                    QeetrixDatePicker("Joining date", selection: .constant(date(2026, 10, 25))).disabled(true)
                }
                .environment(\.timeZone, kolkata)
            )
        }
    }
#endif
