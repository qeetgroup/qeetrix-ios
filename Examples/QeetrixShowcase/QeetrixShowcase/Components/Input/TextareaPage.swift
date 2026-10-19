import Qeetrix
import SwiftUI

struct TextareaPage: View {
    @State private var feedback = ""
    @State private var submitted = false

    var body: some View {
        ComponentPage(
            title: "Textarea",
            summary: "Multi-line text that grows with its content, then scrolls."
        ) {
            DemoSection("Feedback") {
                QeetrixTextarea(
                    "Feedback", text: $feedback,
                    prompt: Text("What could be better?"),
                    description: Text("Up to 500 characters."),
                    message: submitted && feedback.isEmpty ? .error("Tell us what to improve.") : nil,
                    isRequired: true
                )
                QeetrixButton("Send feedback", variant: .outline, size: .sm) { submitted = true }
                QeetrixText(
                    "\(feedback.count) characters, \(feedback.split(separator: "\n", omittingEmptySubsequences: false).count) lines",
                    variant: .muted
                )
                .accessibilityIdentifier("feedback-count")
            }
            DemoSection("Read-only and disabled") {
                QeetrixTextarea("Audit note", text: .constant("Created by the workspace owner.\nReviewed by security."), isReadOnly: true)
                QeetrixTextarea("Archived note", text: .constant("No longer editable.")).disabled(true)
            }
        }
    }
}

#Preview {
    NavigationStack { TextareaPage() }
}
