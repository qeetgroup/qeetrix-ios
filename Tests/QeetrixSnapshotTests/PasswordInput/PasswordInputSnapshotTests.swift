#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @testable import Qeetrix

    /// Synthetic values only — never a real password.
    @MainActor
    @Suite("Password input snapshots")
    struct PasswordInputSnapshotTests {
        @Test("Empty, masked, revealed, warning, without a toggle and disabled")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixPasswordInput("Password", text: .constant(""), prompt: Text("Your password"), isRequired: true)
                    QeetrixPasswordInput("Password", text: .constant("sample-only"))
                    QeetrixField("Password, revealed") {
                        QeetrixPasswordField(
                            text: .constant("sample-only"), purpose: .current, prompt: nil, showsToggle: true, revealed: true)
                    }
                    QeetrixPasswordInput(
                        "New password", text: .constant("short"), purpose: .new,
                        message: QeetrixFieldMessage(.warning, text: "Use at least 12 characters."))
                    QeetrixPasswordInput("PIN", text: .constant(""), showsToggle: false)
                    QeetrixPasswordInput("Managed password", text: .constant("")).disabled(true)
                }
            )
        }
    }
#endif
