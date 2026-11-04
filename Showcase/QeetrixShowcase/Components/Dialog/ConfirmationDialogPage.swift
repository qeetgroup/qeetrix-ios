import Qeetrix
import SwiftUI

struct ConfirmationDialogPage: View {
    @State private var share: QeetrixConfirmationDialog?
    @State private var remove: QeetrixConfirmationDialog?
    @State private var result = "none"

    var body: some View {
        ComponentPage(
            title: "Confirmation dialog",
            summary:
                "A choice among actions, from the bottom on iPhone and pointing at its button on iPad. Attach it to the control that opens it."
        ) {
            DemoSection("Several actions") {
                QeetrixButton("Share report", variant: .soft) {
                    share = QeetrixConfirmationDialog(
                        "Share the Q3 summary",
                        message: Text("Anyone with the link can view it."),
                        actions: [
                            QeetrixDialogAction("Copy link") { result = "copied link" },
                            QeetrixDialogAction("Send by email") { result = "sent by email" },
                        ])
                }
                .qeetrixConfirmationDialog($share)
            }
            DemoSection("Confirming a destructive action") {
                QeetrixButton("Remove member", tone: .danger) {
                    remove = QeetrixConfirmationDialog(
                        "Remove Asha Rao?",
                        message: Text("They lose access to this workspace."),
                        actions: [QeetrixDialogAction("Remove", role: .destructive) { result = "removed" }])
                }
                .qeetrixConfirmationDialog($remove)
                QeetrixText(
                    "Confirming is not authorising: the server still decides whether the action is allowed.", size: .sm, tone: .subtle)
            }
            QeetrixText("Result: \(result)").accessibilityIdentifier("confirmation-result")
        }
    }
}

#Preview {
    NavigationStack { ConfirmationDialogPage() }
}
