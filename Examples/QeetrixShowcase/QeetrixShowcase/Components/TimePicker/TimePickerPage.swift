import Qeetrix
import SwiftUI

struct TimePickerPage: View {
    @State private var reminder: Date? = nil
    @State private var standup: Date? = nil

    var body: some View {
        ComponentPage(
            title: "Time picker",
            summary: "A time in the field box, opening the system's wheel: 12 or 24 hours as the device is set, in minute steps."
        ) {
            DemoSection("Quarter hours") {
                QeetrixTimePicker(
                    "Reminder", selection: $reminder, minuteStep: 15, placeholder: Text("Choose a time"),
                    description: Text("In steps of 15 minutes."))
            }
            DemoSection("Every minute, 24 hours") {
                QeetrixTimePicker("Standup", selection: $standup, isOptional: true)
                    .environment(\.locale, Locale(identifier: "en_GB"))
            }
            DemoSection("States") {
                QeetrixTimePicker("Cut-off", selection: $reminder, error: "Choose a time in office hours", isRequired: true)
                QeetrixTimePicker("Sent at", selection: .constant(Date()), isReadOnly: true)
                QeetrixTimePicker("Reminder", selection: .constant(Date())).disabled(true)
            }
        }
    }
}

#Preview {
    NavigationStack { TimePickerPage() }
}
