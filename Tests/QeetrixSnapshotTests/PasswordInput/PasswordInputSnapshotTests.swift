#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Password input snapshots")
    struct PasswordInputSnapshotTests {
        @Test("Empty, hidden, shown, error and disabled")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixPasswordInput("Password", text: .constant(""))
                    QeetrixPasswordInput("Password", text: .constant("correct horse battery"))
                    QeetrixPasswordInput(
                        "Client secret", text: .constant("qs_live_51Hc"), autoComplete: .off, description: Text("Shown once. Copy it now."),
                        isVisible: .constant(true))
                    QeetrixPasswordInput(
                        "Password", text: .constant("short"), autoComplete: .newPassword, error: "Use at least 12 characters")
                    QeetrixPasswordInput("Password", text: .constant("secret")).disabled(true)
                }
            )
        }
    }
#endif
