import Qeetrix
import SwiftUI

struct RangeCalendarPage: View {
    @State private var stay: ClosedRange<Date>? = nil
    @State private var sprint: ClosedRange<Date>? = Date()...Date().addingTimeInterval(9 * 86_400)

    var body: some View {
        ComponentPage(
            title: "Range calendar",
            summary: "The first day chosen starts the range and the second ends it, on a band between Ember ends."
        ) {
            DemoSection("Choose a range") {
                QeetrixRangeCalendar(selection: $stay, min: .now)
                QeetrixText(
                    "Chosen: \(stay.map { "\($0.lowerBound.formatted(date: .abbreviated, time: .omitted)) to \($0.upperBound.formatted(date: .abbreviated, time: .omitted))" } ?? "none")",
                    size: .sm, tone: .subtle
                )
                .accessibilityIdentifier("range-calendar-value")
            }
            DemoSection("A range with ruled-out days") {
                QeetrixRangeCalendar(selection: $sprint, isDateDisabled: { Calendar.current.isDateInWeekend($0) })
            }
            DemoSection("Read-only and disabled") {
                QeetrixRangeCalendar(selection: .constant(sprint), isReadOnly: true)
                QeetrixRangeCalendar(selection: .constant(sprint)).disabled(true)
            }
        }
    }
}

#Preview {
    NavigationStack { RangeCalendarPage() }
}
