#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Textarea snapshots")
    struct TextareaSnapshotTests {
        @Test("Prompt, text, error, read-only and disabled")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixTextarea("Notes", text: .constant(""), prompt: Text("e.g. Deliver after 5 pm"))
                    QeetrixTextarea(
                        "Notes", text: .constant("Deliver to the side gate.\nCall on arrival."), description: Text("Shown on the invoice."),
                        rows: 2)
                    QeetrixTextarea("Reason", text: .constant("x"), error: "Tell us why in at least 10 characters", rows: 2)
                    QeetrixTextarea("Terms", text: .constant("Payment within 30 days of the invoice date."), rows: 2, isReadOnly: true)
                    QeetrixTextarea("Notes", text: .constant("Locked by the owner."), rows: 2).disabled(true)
                }
            )
        }
    }
#endif
