#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Toast snapshots")
    struct ToastSnapshotTests {
        @AccessibilityFocusState private var focus: QeetrixToastFocus?

        @Test("Info, success, warning and danger")
        func tones() {
            assertSpecimen(
                // Spaced so each toast's overlay shadow shows, as it does with one toast on screen.
                VStack(spacing: 24) {
                    toast(QeetrixToast(.info, title: "Message archived"))
                    toast(QeetrixToast(.success, title: "Settings saved", description: "They apply to new sessions."))
                    toast(QeetrixToast(.warning, title: "Saved offline", description: "Changes sync when you reconnect."))
                    toast(QeetrixToast(.danger, title: "Report not sent", description: "Check your connection."))
                }
            )
        }

        @Test("With an action")
        func action() {
            assertSpecimen(toast(QeetrixToast(.info, title: "Message archived", action: .init("Undo") {})))
        }

        private func toast(_ toast: QeetrixToast) -> some View {
            QeetrixToastView(toast: toast, focus: $focus, close: {}, act: {})
        }
    }
#endif
