#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Field snapshots")
    struct FieldSnapshotTests {
        @Test("Labels, indicators, every message, a field set and the focused boundary")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixField("Seats", description: Text("You can add more later."), isRequired: true) {
                        Text(verbatim: "Any control")
                    }
                    QeetrixTextField("Nickname", text: .constant(""), isOptional: true)
                    QeetrixTextField("Email", text: .constant("asha@"), message: QeetrixFieldMessage(.error, text: "Enter a full address."))
                    QeetrixField("Region", message: QeetrixFieldMessage(.warning, text: "Far from your users.")) {
                        Text(verbatim: "Mumbai")
                    }
                    QeetrixField("Domain", message: QeetrixFieldMessage(.success, text: "Verified.")) { Text(verbatim: "example.com") }
                    // The focused boundary, which a snapshot cannot reach through focus itself.
                    Text(verbatim: "Focused")
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .qeetrixFieldSurface(
                            QeetrixFieldState(isEnabled: true, isReadOnly: false, isFocused: true, isHovered: false, tone: nil))
                    QeetrixFieldSet("Contact", description: Text("How we reach the owner.")) {
                        QeetrixTextField("Name", text: .constant("Asha Rao"))
                    }
                }
            )
        }
    }
#endif
