import Qeetrix
import SwiftUI

struct CalendarPage: View {
    @State private var day: Date? = nil
    @State private var weekday: Date? = nil

    var body: some View {
        ComponentPage(
            title: "Calendar",
            summary: "A month of days to choose one from, drawn by Qeetrix. The title opens the years and months."
        ) {
            DemoSection("Choose a day") {
                QeetrixCalendar(selection: $day)
                QeetrixText("Chosen: \(day.map { $0.formatted(date: .complete, time: .omitted) } ?? "none")", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("calendar-value")
            }
            DemoSection("Limits and ruled-out days") {
                QeetrixCalendar(
                    selection: $weekday, min: .now, max: .now.addingTimeInterval(90 * 86_400),
                    isDateDisabled: { Calendar.current.isDateInWeekend($0) })
            }
            DemoSection("Read-only and disabled") {
                QeetrixCalendar(selection: .constant(Date()), isReadOnly: true)
                QeetrixCalendar(selection: .constant(Date())).disabled(true)
            }
            DemoSection("Monday first") {
                QeetrixCalendar(selection: $day)
                    .environment(\.locale, Locale(identifier: "en_GB"))
            }
        }
    }
}

#Preview {
    NavigationStack { CalendarPage() }
}
