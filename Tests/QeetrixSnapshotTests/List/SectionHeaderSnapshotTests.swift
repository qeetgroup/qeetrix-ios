#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Section header snapshots")
    struct SectionHeaderSnapshotTests {
        @Test("The first group's header, ruled headers with a description and an action, and an Indic title")
        func variants() {
            assertSpecimen(
                VStack(spacing: 0) {
                    QeetrixSectionHeader("Accounts", isRuled: false)
                    QeetrixListItem("Priya Sharma", description: Text(verbatim: "priya@acme.in")) {
                        QeetrixAvatar(name: "Priya Sharma", isDecorative: true)
                    }
                    QeetrixSectionHeader("Signed-in devices", description: Text("Where your account is in use.")) {
                        QeetrixButton("Sign out all", variant: .ghost, tone: .danger, size: .sm) {}
                    }
                    QeetrixListItem("iPhone 17", description: Text("This device")) { QeetrixListItemIcon(.smartphone) }
                    QeetrixSectionHeader("सुरक्षा")
                    QeetrixListItem("Face ID", isOn: .constant(true))
                }
            )
        }
    }
#endif
