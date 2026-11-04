import Qeetrix
import SwiftUI

struct TextareaPage: View {
    @State private var feedback = ""
    @State private var submitted = false

    var body: some View {
        ComponentPage(
            title: "Textarea",
            summary: "Multi-line text in the field box. At least its rows tall; it grows with its content, then scrolls."
        ) {
            DemoSection("Feedback") {
                QeetrixTextarea(
                    "Feedback", text: $feedback,
                    prompt: Text("e.g. The export took too long"),
                    description: Text("Up to 500 characters."),
                    error: submitted && feedback.isEmpty ? "Tell us what to improve." : nil,
                    rows: 3, maxRows: 8,
                    isRequired: true
                )
                QeetrixButton("Send feedback", variant: .ghost, size: .sm) { submitted = true }
                QeetrixText(
                    "\(feedback.count) characters, \(feedback.split(separator: "\n", omittingEmptySubsequences: false).count) lines",
                    size: .sm, tone: .subtle
                )
                .accessibilityIdentifier("feedback-count")
            }
            DemoSection("Read-only and disabled") {
                QeetrixTextarea("Audit note", text: .constant("Created by the workspace owner.\nReviewed by security."), isReadOnly: true)
                QeetrixTextarea("Archived note", text: .constant("No longer editable."), rows: 2).disabled(true)
            }
        }
    }
}

#Preview {
    NavigationStack { TextareaPage() }
}
