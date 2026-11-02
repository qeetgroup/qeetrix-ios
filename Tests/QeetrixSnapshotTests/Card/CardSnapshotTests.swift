#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Card snapshots")
    struct CardSnapshotTests {
        @Test("Titled with actions and a footer, untitled, subdued, danger, and the selectable card")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixCard(title: Text("Team plan"), description: Text("Billed monthly")) {
                        QeetrixText("Up to 25 members, with audit logs and SSO.")
                    } actions: {
                        QeetrixButton("View all", variant: .ghost, size: .sm) {}
                    } footer: {
                        QeetrixButton("Cancel", variant: .ghost) {}
                        QeetrixButton("Upgrade") {}
                    }
                    QeetrixCard {
                        QeetrixText("An untitled card is a plain ruled surface.")
                    }
                    QeetrixCard("Recent activity", variant: .subdued) {
                        QeetrixText("No activity this week.", tone: .subtle)
                    }
                    QeetrixCard(title: Text("Delete organisation"), description: Text("This can't be undone."), tone: .danger) {
                        QeetrixText("Every project, member and invoice is removed.")
                    } footer: {
                        QeetrixButton("Delete organisation", tone: .danger) {}
                    }
                    HStack(spacing: 8) {
                        Button {
                        } label: {
                            QeetrixText("Monthly", weight: .semibold)
                        }
                        .buttonStyle(.qeetrixCard(isSelected: true))
                        Button {
                        } label: {
                            QeetrixText("Yearly", weight: .semibold)
                        }
                        .buttonStyle(.qeetrixCard())
                    }
                }
            )
        }
    }
#endif
