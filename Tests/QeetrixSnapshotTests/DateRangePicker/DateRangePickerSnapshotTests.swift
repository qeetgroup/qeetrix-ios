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
    @Suite("Date range picker snapshots")
    struct DateRangePickerSnapshotTests {
        /// The field only: both ends in the all-number form, wrapping at large text sizes.
        @Test("Empty with a placeholder, a range with help, an error, read-only and disabled")
        func states() {
            let december = date(2026, 12, 1)...date(2026, 12, 31)
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixDateRangePicker("Billing period", selection: .constant(nil), placeholder: Text("Choose dates"))
                    QeetrixDateRangePicker("Billing period", selection: .constant(december), description: Text("Invoices dated in it."))
                    QeetrixDateRangePicker("Stay", selection: .constant(december), error: "Choose up to 14 nights")
                    QeetrixDateRangePicker("Billed", selection: .constant(december), isReadOnly: true)
                    QeetrixDateRangePicker("Billing period", selection: .constant(december)).disabled(true)
                }
                .environment(\.timeZone, kolkata)
            )
        }
    }
#endif
