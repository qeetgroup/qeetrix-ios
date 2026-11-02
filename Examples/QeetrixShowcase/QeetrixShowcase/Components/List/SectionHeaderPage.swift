import Qeetrix
import SwiftUI

struct SectionHeaderPage: View {
    @State private var faceID = true
    @State private var signedOut = false

    var body: some View {
        ComponentPage(
            title: "Section header",
            summary: "The label of a group of rows: small, tracked capitals under a rule, with an optional description and action."
        ) {
            DemoSection("Groups of rows") {
                VStack(spacing: 0) {
                    QeetrixSectionHeader("Security", isRuled: false)
                    QeetrixListItem("Face ID", isOn: $faceID) { QeetrixListItemIcon(.scanLine) }
                    QeetrixSectionHeader("Signed-in devices", description: Text("Where your account is in use.")) {
                        QeetrixButton("Sign out all", variant: .ghost, tone: .danger, size: .sm) { signedOut = true }
                    }
                    if !signedOut {
                        QeetrixListItem("iPhone 17", description: Text("This device")) { QeetrixListItemIcon(.smartphone) }
                        QeetrixListItem("MacBook Pro", description: Text("Yesterday")) { QeetrixListItemIcon(.keyboard) }
                    }
                }
            }
            DemoSection("Indic titles keep their letters") {
                VStack(spacing: 0) {
                    QeetrixSectionHeader("सुरक्षा", isRuled: false)
                    QeetrixSectionHeader("பாதுகாப்பு", description: Text("Written as is, without the tracking."))
                }
            }
            DemoSection("In a List") {
                List {
                    Section {
                        QeetrixListItem("Face ID", isOn: $faceID)
                    } header: {
                        QeetrixSectionHeader("Security", isRuled: false)
                    }
                    .listSectionSeparator(.hidden)
                    Section {
                        QeetrixListItem("iPhone 17", description: Text("This device"))
                        QeetrixListItem("MacBook Pro", description: Text("Yesterday"))
                    } header: {
                        QeetrixSectionHeader("Signed-in devices", description: Text("Where your account is in use."))
                    }
                    .listSectionSeparator(.hidden)
                }
                .qeetrixListStyle()
                .frame(height: 360)
            }
        }
    }
}

#Preview {
    NavigationStack { SectionHeaderPage() }
}
