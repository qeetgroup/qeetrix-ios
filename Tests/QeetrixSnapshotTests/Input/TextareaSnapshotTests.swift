#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Textarea snapshots")
    struct TextareaSnapshotTests {
        @Test("Prompt, text, error, read-only and disabled")
        func states() {
            assertSpecimen(
                VStack(spacing: 16) {
                    QeetrixTextarea("Feedback", text: .constant(""), prompt: Text("What could be better?"), isRequired: true)
                    QeetrixTextarea("Feedback", text: .constant("The export is quick.\nThe import could show progress."))
                    QeetrixTextarea("Feedback", text: .constant(""), message: QeetrixFieldMessage(.error, text: "Tell us what to improve."))
                    QeetrixTextarea("Audit note", text: .constant("Reviewed by security."), isReadOnly: true)
                    QeetrixTextarea("Archived note", text: .constant("No longer editable.")).disabled(true)
                }
            )
        }
    }
#endif
