import Qeetrix
import SwiftUI

struct FieldsetPage: View {
    @State private var street = "12 MG Road"
    @State private var city = "Bengaluru"
    @State private var postcode = ""
    @State private var isLocked = false

    var body: some View {
        ComponentPage(
            title: "Fieldset",
            summary:
                "A section of fields under a title.sm legend, spaced by the density's form gap. A choice question is a radio group instead."
        ) {
            DemoSection("A section") {
                QeetrixFieldset("Billing address", description: Text("Where invoices are sent.")) {
                    QeetrixTextField("Street", text: $street)
                    QeetrixTextField("City", text: $city)
                    QeetrixTextField("PIN code", text: $postcode, prompt: Text("e.g. 560001"), isOptional: true)
                        .keyboardType(.numberPad)
                }
                .disabled(isLocked)
                QeetrixSwitch("Lock the address", isOn: $isLocked, description: Text("Disabling the fieldset disables every field in it."))
            }
            DemoSection("Compact density") {
                QeetrixFieldset("Contact") {
                    QeetrixTextField("Name", text: .constant("Asha Rao"))
                    QeetrixTextField("Phone", text: .constant("+91 98765 43210"), isOptional: true)
                }
                .qeetrixDensity(.compact)
            }
        }
    }
}

#Preview {
    NavigationStack { FieldsetPage() }
}
