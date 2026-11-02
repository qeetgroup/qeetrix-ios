#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    private let kolkata = TimeZone(identifier: "Asia/Kolkata")!

    private func time(_ hour: Int, _ minute: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = kolkata
        return calendar.date(from: DateComponents(year: 2026, month: 10, day: 25, hour: hour, minute: minute))!
    }

    @MainActor
    @Suite("Time picker snapshots")
    struct TimePickerSnapshotTests {
        /// The field only: the wheel it opens is the system's. 12 hours in the specimens' `en_US`; 24 in
        /// `en_GB`.
        @Test("Empty with a placeholder, a time with help, 24 hours, an error, read-only and disabled")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixTimePicker("Reminder", selection: .constant(nil), minuteStep: 15, placeholder: Text("Choose a time"))
                    QeetrixTimePicker("Reminder", selection: .constant(time(14, 30)), description: Text("We'll send it at this time."))
                    QeetrixTimePicker("Reminder", selection: .constant(time(14, 30))).environment(\.locale, Locale(identifier: "en_GB"))
                    QeetrixTimePicker("Standup", selection: .constant(time(9, 0)), error: "Choose a time in office hours")
                    QeetrixTimePicker("Sent at", selection: .constant(time(9, 0)), isReadOnly: true)
                    QeetrixTimePicker("Reminder", selection: .constant(time(14, 30))).disabled(true)
                }
                .environment(\.timeZone, kolkata)
            )
        }
    }
#endif
