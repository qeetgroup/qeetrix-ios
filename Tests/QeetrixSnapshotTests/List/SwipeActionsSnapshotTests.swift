#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Swipe actions snapshots")
    struct SwipeActionsSnapshotTests {
        /// The actions themselves are drawn by iOS, only while a row is swiped, and covered by the
        /// showcase's UI tests (ADR 0014): what Qeetrix draws is the rows at rest, unchanged by the
        /// actions they carry — on a leading edge, a trailing edge, both, and a disabled row.
        @Test("Rows carrying actions, at rest in a plain List: leading, trailing, both, and disabled")
        func atRest() {
            let approve = QeetrixSwipeAction("Approve", icon: .check, tone: .brand) {}
            let deny = QeetrixSwipeAction("Deny", icon: .x, tone: .danger, confirmation: Text("Deny this sign-in?")) {}
            let later = QeetrixSwipeAction("Later", icon: .clock) {}
            assertSpecimen(
                List {
                    Section {
                        QeetrixListItem("Qeet Pay console", description: Text("Bengaluru · MacBook Pro")) {
                            QeetrixListItemIcon(.lock)
                        }
                        .qeetrixSwipeActions(leading: [approve], trailing: [deny, later])
                        QeetrixListItem("Acme", description: Text(verbatim: "priya@acme.in")) {
                            QeetrixAvatar(name: "Acme", shape: .square, isDecorative: true)
                        }
                        .qeetrixSwipeActions(actions: [QeetrixSwipeAction("Remove", icon: .trash, tone: .danger) {}])
                        QeetrixListItem("Weekly digest", metadata: Text("Mondays"), accessory: .chevron) {}
                            .qeetrixSwipeActions(edge: .leading, actions: [QeetrixSwipeAction("Pin", icon: .pin, tone: .brand) {}])
                        QeetrixListItem("Managed by Acme", description: Text("Your organisation sets this")) {
                            QeetrixListItemIcon(.lock)
                        }
                        .qeetrixSwipeActions(actions: [later])
                        .disabled(true)
                    } header: {
                        QeetrixSectionHeader("Pending approvals", isRuled: false)
                    }
                    .listSectionSeparator(.hidden)
                }
                .qeetrixListStyle()
                .frame(height: 420)
            )
        }
    }
#endif
