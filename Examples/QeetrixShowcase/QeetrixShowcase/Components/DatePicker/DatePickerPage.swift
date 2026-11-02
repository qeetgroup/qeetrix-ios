import Qeetrix
import SwiftUI

struct DatePickerPage: View {
    @State private var joiningDate: Date? = nil
    @State private var delivery: Date? = nil
    @State private var dueDate: Date? = Date()

    var body: some View {
        ComponentPage(
            title: "Date picker",
            summary: "A date in the field box, opening the system's calendar — or Qeetrix's, when days are ruled out."
        ) {
            DemoSection("The system's calendar") {
                QeetrixDatePicker(
                    "Joining date", selection: $joiningDate, min: .now, placeholder: Text("Choose a date"),
                    description: Text("From today. Done sets it."))
                QeetrixText(
                    "Joining date: \(joiningDate.map { $0.formatted(date: .long, time: .omitted) } ?? "none")", size: .sm, tone: .subtle
                )
                .accessibilityIdentifier("joining-date-value")
            }
            DemoSection("Ruled-out days: Qeetrix's calendar") {
                QeetrixDatePicker(
                    "Delivery", selection: $delivery, min: .now, isDateDisabled: { Calendar.current.isDateInWeekend($0) },
                    description: Text("Weekdays only. Choosing a day sets it."), isOptional: true)
            }
            DemoSection("States") {
                QeetrixDatePicker("Due date", selection: $dueDate, error: "Choose a date after the invoice date", isRequired: true)
                QeetrixDatePicker("Issued", selection: .constant(Date()), isReadOnly: true)
                QeetrixDatePicker("Due date", selection: .constant(Date())).disabled(true)
            }
            DemoSection("In another locale") {
                QeetrixDatePicker("Liefertermin", selection: $dueDate)
                    .environment(\.locale, Locale(identifier: "de_DE"))
            }
        }
    }
}

#Preview {
    NavigationStack { DatePickerPage() }
}
