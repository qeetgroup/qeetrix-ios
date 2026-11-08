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

        @Test("Outcome tones, success and warning; an image in place of the icon")
        func outcomes() {
            assertSpecimen(
                VStack(spacing: 0) {
                    QeetrixEmptyState(
                        "Sign-in approved", description: "You're signed in on your Mac.", icon: .circleCheck, size: .section, tone: .success
                    )
                    QeetrixSeparator()
                    QeetrixEmptyState(
                        "Approve on your other phone", description: "This request was sent to Priya's Pixel.", icon: .triangleAlert,
                        size: .section, tone: .warning)
                    QeetrixSeparator()
                    // A stand-in for the app's icon: a rounded tile in the brand colour.
                    QeetrixEmptyState(
                        title: Text("Qeet ID is locked"), description: Text("Unlock to see your codes."),
                        image: RoundedRectangle(cornerRadius: 14).fill(QeetrixColor.bgBrandBold).frame(width: 64, height: 64), level: 1
                    ) {
                        QeetrixButton("Unlock", icon: .lockOpen) {}
                    }
                }
            )
        }
    }
#endif
