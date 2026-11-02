#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Empty state snapshots")
    struct EmptyStateSnapshotTests {
        @Test("A page with an icon, actions and a footer; a section; the danger tone")
        func sizes() {
            assertSpecimen(
                VStack(spacing: 0) {
                    QeetrixEmptyState(
                        "No accounts yet", description: "Add an account to sign in with this phone.", icon: .userPlus, level: 2
                    ) {
                        QeetrixButton("Add account", icon: .plus) {}
                        QeetrixButton("Restore from backup", variant: .ghost) {}
                    } footer: {
                        Text("Or scan the code on qeet.in")
                    }
                    QeetrixSeparator()
                    QeetrixEmptyState("No pending approvals", description: "Sign-in requests appear here.", icon: .inbox, size: .section)
                    QeetrixSeparator()
                    QeetrixEmptyState(
                        "Couldn't load your accounts", description: "Your accounts are safe. Try again in a moment.", icon: .circleAlert,
                        size: .section, tone: .danger)
                }
            )
        }
    }
#endif
