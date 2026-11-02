#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Permission primer snapshots")
    struct PermissionPrimerSnapshotTests {
        @Test("Before the system's prompt with Not now, and denied with Open Settings")
        func statuses() {
            assertSpecimen(
                VStack(spacing: 0) {
                    QeetrixPermissionPrimer(
                        .notifications, title: "Know when a payment arrives",
                        message: "Qeet Pay sends a notification when a customer pays an invoice. Nothing else.", onContinue: {},
                        onNotNow: {})
                    QeetrixSeparator()
                    QeetrixPermissionPrimer(
                        .camera, status: .denied, title: "Camera access is off",
                        message: "To scan the QR code, turn on Camera for this app in Settings.", onContinue: {})
                }
            )
        }
    }
#endif
