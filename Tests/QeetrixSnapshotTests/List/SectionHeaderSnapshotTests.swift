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

        @Test("An authenticator's account rows: a monogram tile and the code under the account")
        func accountRows() {
            let start = Date(timeIntervalSince1970: 1_800_000_000)
            assertSpecimen(
                VStack(spacing: 0) {
                    QeetrixListItem("GitHub", description: Text(verbatim: "priya")) { QeetrixListItemIcon(monogram: "G") }
                        .qeetrixListItemContent {
                            QeetrixOTPCode(
                                code: "482105", validity: start...start.addingTimeInterval(30), label: Text(verbatim: "GitHub"),
                                size: .md, isHidden: false, toast: nil, onCopied: nil, now: start.addingTimeInterval(12))
                        }
                    QeetrixSeparator()
                    QeetrixListItem("Verify your email", description: Text("Step 2 of 3")) { QeetrixListItemIcon(monogram: "2") }
                }
            )
        }
    }
#endif
