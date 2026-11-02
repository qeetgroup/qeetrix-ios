#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Alert snapshots")
    struct AlertSnapshotTests {
        @Test("Info, success, warning and danger; with a description, actions and Dismiss")
        func tones() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 12) {
                    QeetrixAlert("You're offline", description: "Approvals arrive when you reconnect.")
                    QeetrixAlert("Phone linked", tone: .success)
                    QeetrixAlert(
                        "Push notifications are off", description: "Turn them on to approve sign-ins from this phone.", tone: .warning
                    ) {
                        QeetrixButton("Open Settings", size: .sm) {}
                        QeetrixButton("Not now", variant: .ghost, tone: .neutral, size: .sm) {}
                    }
                    QeetrixAlert(
                        "This phone isn't linked", description: "Scan the code on qeet.in to link it.", tone: .danger, onDismiss: {})
                    QeetrixAlert("Viewing as Priya Sharma", tone: .info, icon: .eye, onDismiss: {})
                }
            )
        }
    }
#endif
