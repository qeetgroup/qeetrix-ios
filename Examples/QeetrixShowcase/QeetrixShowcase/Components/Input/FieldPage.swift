import Qeetrix
import SwiftUI

struct FieldPage: View {
    @State private var seats = 5
    @State private var region = "Mumbai"
    @State private var showError = false

    var body: some View {
        ComponentPage(
            title: "Field",
            summary: "A label, any control, a description and a message. Qeetrix inputs build on it; use it for anything else."
        ) {
            DemoSection("Around a native control") {
                QeetrixField("Seats", description: Text("You can add more later."), isRequired: true) {
                    Stepper("\(seats) seats", value: $seats, in: 1...25)
                }
                QeetrixField("Data region", message: showError ? .error("Choose a region near your users.") : nil) {
                    Picker("Data region", selection: $region) {
                        ForEach(["Mumbai", "Frankfurt", "Virginia"], id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                }
                QeetrixButton(showError ? "Clear the error" : "Show an error", variant: .outline, size: .sm) {
                    showError.toggle()
                }
            }
            DemoSection("Required and optional") {
                QeetrixTextField("Company", text: .constant(""), isRequired: true)
                QeetrixTextField("Nickname", text: .constant(""), isOptional: true)
            }
            DemoSection("Field set") {
                QeetrixFieldSet("Contact", description: Text("How we reach the account owner.")) {
                    QeetrixTextField("Name", text: .constant("Asha Rao"))
                    QeetrixTextField("Phone", text: .constant("+91 98765 43210"), isOptional: true)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { FieldPage() }
}
