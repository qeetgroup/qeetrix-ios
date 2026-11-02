import Qeetrix
import SwiftUI

struct DateRangePickerPage: View {
    @State private var period: ClosedRange<Date>? = nil
    @State private var stay: ClosedRange<Date>? = nil

    var body: some View {
        ComponentPage(
            title: "Date range picker",
            summary: "A range in the field box, chosen in Qeetrix's range calendar — iOS has no range picker — or from presets."
        ) {
            DemoSection("With presets") {
                QeetrixDateRangePicker(
                    "Billing period", selection: $period, presets: [.today, .last7Days, .last30Days, .thisMonth, .lastMonth],
                    description: Text("Invoices dated in this period."))
            }
            DemoSection("Limits") {
                QeetrixDateRangePicker(
                    "Stay", selection: $stay, min: .now, max: .now.addingTimeInterval(180 * 86_400), presets: [.last7Days],
                    placeholder: Text("Check-in – check-out"), isOptional: true)
                QeetrixText("Past days can't be chosen, so “Last 7 days” is cut to today.", size: .sm, tone: .subtle)
            }
            DemoSection("States") {
                QeetrixDateRangePicker("Report period", selection: $period, error: "Choose up to a year", isRequired: true)
                QeetrixDateRangePicker("Billed", selection: .constant(Date()...Date().addingTimeInterval(30 * 86_400)), isReadOnly: true)
                QeetrixDateRangePicker("Billing period", selection: .constant(nil)).disabled(true)
            }
        }
    }
}

#Preview {
    NavigationStack { DateRangePickerPage() }
}
