import Qeetrix
import SwiftUI

struct AlertDialogPage: View {
    @State private var alert: QeetrixAlertDialog?
    @State private var result = "none"
    @State private var deletions = 0

    var body: some View {
        ComponentPage(
            title: "Alert dialog",
            summary:
                "Interrupts to ask for a decision. The system alert, described by a value: setting it presents, every button dismisses."
        ) {
            DemoSection("A destructive decision") {
                QeetrixButton("Delete workspace", variant: .destructive) {
                    alert = QeetrixAlertDialog(
                        "Delete this workspace?",
                        message: Text("Its projects and files are removed for everyone. This cannot be undone."),
                        actions: [
                            QeetrixDialogAction("Delete", role: .destructive) {
                                deletions += 1
                                result = "deleted \(deletions)"
                            }
                        ])
                }
                QeetrixText("Cancel is added because the only action is destructive.", variant: .muted)
            }
            DemoSection("Two choices") {
                QeetrixButton("Leave the page", variant: .outline) {
                    alert = QeetrixAlertDialog(
                        "Leave without saving?",
                        message: Text("Your changes to this draft are lost."),
                        actions: [
                            QeetrixDialogAction("Keep editing", role: .cancel) { result = "kept editing" },
                            QeetrixDialogAction("Leave", role: .destructive) { result = "left" },
                        ])
                }
            }
            DemoSection("A notice") {
                QeetrixButton("Show a notice", variant: .outline) {
                    alert = QeetrixAlertDialog("Storage almost full", message: Text("Delete files or move them to free up space."))
                }
                QeetrixText("With no actions the system shows OK.", variant: .muted)
            }
            QeetrixText("Result: \(result)").accessibilityIdentifier("alert-result")
        }
        .qeetrixAlertDialog($alert)
    }
}

#Preview {
    NavigationStack { AlertDialogPage() }
}
