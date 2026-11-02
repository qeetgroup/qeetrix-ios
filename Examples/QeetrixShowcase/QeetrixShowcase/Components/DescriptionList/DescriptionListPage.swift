import Qeetrix
import SwiftUI

struct DescriptionListPage: View {
    @State private var layout = QeetrixDescriptionListLayout.rows
    @State private var columns = 2
    @State private var displayName = "Acme"

    var body: some View {
        ComponentPage(
            title: "Description list",
            summary: "Facts about one record as term and value pairs. Rows stack on a phone and sit side by side where there is room."
        ) {
            DemoSection("An approval request") {
                QeetrixDescriptionList {
                    QeetrixDescriptionItem("App", value: "Qeet Pay console")
                    QeetrixDescriptionItem("Place", value: "Bengaluru, India")
                    QeetrixDescriptionItem("Device", value: "MacBook Pro · Safari")
                    QeetrixDescriptionItem("Time", value: "30 Oct 2026, 10:42")
                    QeetrixDescriptionItem("Status") { QeetrixBadge("Pending", tone: .warning) }
                }
            }
            DemoSection("Empty values, a description and an action") {
                QeetrixDescriptionList {
                    QeetrixDescriptionItem("Phone", value: nil)
                    QeetrixDescriptionItem(
                        "Display name", value: displayName, description: Text("Shown in the top bar and in invitations.")
                    ) {
                        QeetrixButton("Change", variant: .ghost, size: .sm) {
                            displayName = displayName == "Acme" ? "Acme Labs" : "Acme"
                        }
                    }
                }
            }
            DemoSection("Layout") {
                Picker("Layout", selection: $layout) {
                    ForEach(QeetrixDescriptionListLayout.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                if layout == .columns {
                    Stepper("At most \(columns) columns", value: $columns, in: 1...4)
                }
                QeetrixDescriptionList(layout: layout, columns: columns) {
                    QeetrixDescriptionItem("Actor", value: "priya@acme.in")
                    QeetrixDescriptionItem("Event", value: "Signed in")
                    QeetrixDescriptionItem("IP address", value: "203.0.113.24")
                    QeetrixDescriptionItem("Phone", value: "+91 98765 43210")
                }
            }
            DemoSection("In a card") {
                QeetrixCard(title: Text("Audit event")) {
                    QeetrixDescriptionList {
                        QeetrixDescriptionItem("Actor", value: "priya@acme.in")
                        QeetrixDescriptionItem("Event", value: "Passkey added")
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack { DescriptionListPage() }
}
