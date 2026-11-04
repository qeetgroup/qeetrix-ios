import Qeetrix
import SwiftUI

struct FieldPage: View {
    @State private var seats = 5
    @State private var region = "Mumbai"
    @State private var showError = false

    var body: some View {
        ComponentPage(
            title: "Field",
            summary: "The label above any control, then help text — or the error that replaces it. Qeetrix inputs build on it."
        ) {
            DemoSection("Around a native control") {
                QeetrixField("Seats", description: Text("You can add more later."), isRequired: true) {
                    Stepper("\(seats) seats", value: $seats, in: 1...25)
                }
                QeetrixField(
                    "Data region", description: Text("Where your data is stored."),
                    error: showError ? "Choose a region near your users." : nil
                ) {
                    Picker("Data region", selection: $region) {
                        ForEach(["Mumbai", "Frankfurt", "Virginia"], id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                }
                QeetrixButton(showError ? "Clear the error" : "Show an error", variant: .ghost, size: .sm) {
                    showError.toggle()
                }
            }
            DemoSection("Optional, never asterisks") {
                QeetrixTextField("Company", text: .constant(""), prompt: Text("e.g. Acme Pvt Ltd"), isRequired: true)
                QeetrixTextField("Nickname", text: .constant(""), isOptional: true)
            }
            DemoSection("A hidden label, for a toolbar search") {
                QeetrixTextField("Search invoices", text: .constant(""), prompt: Text("Search"), icon: .search, isLabelHidden: true)
            }
            DemoSection("Disabled") {
                QeetrixTextField("Plan", text: .constant("Team"), description: Text("Your organisation manages this.")).disabled(true)
            }
        }
    }
}

#Preview {
    NavigationStack { FieldPage() }
}
