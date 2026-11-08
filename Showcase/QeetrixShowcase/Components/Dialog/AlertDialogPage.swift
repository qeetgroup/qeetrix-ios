import Qeetrix
import SwiftUI

struct AlertDialogPage: View {
    @State private var alert: QeetrixAlertDialog?
    @State private var result = "none"
    @State private var deletions = 0
    @State private var issuer = "Acme"
    @State private var accountName = "priya@acme.in"
    @State private var renames = 0

    var body: some View {
        ComponentPage(
            title: "Alert dialog",
            summary:
                "Interrupts to ask for a decision. The system alert, described by a value: setting it presents, every button dismisses."
        ) {
            DemoSection("A destructive decision") {
                QeetrixButton("Delete workspace", tone: .danger) {
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
                QeetrixText("Cancel is added because the only action is destructive.", size: .sm, tone: .subtle)
            }
            DemoSection("Two choices") {
                QeetrixButton("Leave the page", variant: .ghost) {
                    alert = QeetrixAlertDialog(
                        "Leave without saving?",
                        message: Text("Your changes to this draft are lost."),
                        actions: [
                            QeetrixDialogAction("Keep editing", role: .cancel) { result = "kept editing" },
                            QeetrixDialogAction("Leave", role: .destructive) { result = "left" },
                        ])
                }
            }
            DemoSection("Text fields") {
                QeetrixButton("Rename account", variant: .soft) {
                    alert = QeetrixAlertDialog(
                        "Rename account",
                        message: Text("Change how it appears in your list."),
                        textFields: [
                            QeetrixAlertTextField("Issuer", text: $issuer, contentType: .organizationName),
                            QeetrixAlertTextField("Account name", text: $accountName, contentType: .username, isRequired: true),
                        ],
                        actions: [
                            QeetrixDialogAction("Cancel", role: .cancel),
                            QeetrixDialogAction("Save") {
                                renames += 1
                                result = "renamed \(renames): \(issuer), \(accountName)"
                            },
                        ])
                }
                QeetrixText(
                    "Save waits for an account name; Return in the last field saves. Return with it empty closes the alert, as Cancel.",
                    size: .sm, tone: .subtle)
            }
            DemoSection("A notice") {
                QeetrixButton("Show a notice", variant: .ghost) {
                    alert = QeetrixAlertDialog("Storage almost full", message: Text("Delete files or move them to free up space."))
                }
                QeetrixText("With no actions the system shows OK.", size: .sm, tone: .subtle)
            }
            QeetrixText("Result: \(result)").accessibilityIdentifier("alert-result")
        }
        .qeetrixAlertDialog($alert)
    }
}

#Preview {
    NavigationStack { AlertDialogPage() }
}
