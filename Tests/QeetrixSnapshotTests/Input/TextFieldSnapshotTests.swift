#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Text field snapshots")
    struct TextFieldSnapshotTests {
        @Test("Prompt, value, description, every message, required, read-only and disabled")
        func states() {
            assertSpecimen(
                VStack(spacing: 16) {
                    QeetrixTextField("Work email", text: .constant(""), prompt: Text("name@company.com"), isRequired: true)
                    QeetrixTextField(
                        "Display name", text: .constant("Asha Rao"), description: Text("Shown to your team on every comment."))
                    QeetrixTextField(
                        "Email", text: .constant("asha@"), message: QeetrixFieldMessage(.error, text: "Enter a full email address."))
                    QeetrixTextField(
                        "Password", text: .constant("hunter22"), message: QeetrixFieldMessage(.warning, text: "This password is common."))
                    QeetrixTextField("Username", text: .constant("asha"), message: QeetrixFieldMessage(.success, text: "Available."))
                    QeetrixTextField("Tenant ID", text: .constant("qeet-7f3a"), isReadOnly: true)
                    QeetrixTextField("Organisation", text: .constant("Qeet Group")).disabled(true)
                }
            )
        }
    }
#endif
