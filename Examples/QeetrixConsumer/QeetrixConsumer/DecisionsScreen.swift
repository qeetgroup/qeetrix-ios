import Qeetrix
import SwiftUI

/// Presentation as an app uses it: an alert for a decision, a sheet for a task, both as state the app owns.
struct DecisionsScreen: View {
    @State private var alert: QeetrixAlertDialog?
    @State private var isRenaming = false
    @State private var draft = "Roadmap"
    @State private var outcome = "None"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QeetrixSpacing.l) {
                QeetrixButton("Delete document", variant: .destructive) {
                    alert = QeetrixAlertDialog(
                        "Delete this document?",
                        message: Text("It is removed for everyone."),
                        actions: [QeetrixDialogAction("Delete", role: .destructive) { outcome = "Deleted" }])
                }
                QeetrixButton("Rename document", variant: .outline) { isRenaming = true }
                Text("Outcome: \(outcome)")
                    .qeetrixTextStyle(.body)
                    .foregroundStyle(QeetrixColor.textSecondary)
                    .accessibilityIdentifier("outcome")
            }
            .padding(QeetrixSpacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(QeetrixColor.surfaceCanvas)
        .navigationTitle("Decisions")
        .qeetrixAlertDialog($alert)
        .qeetrixSheet(isPresented: $isRenaming) {
            QeetrixSheetContent("Rename document", onClose: { isRenaming = false }) {
                QeetrixTextField("Name", text: $draft)
            } actions: {
                QeetrixButton("Save") {
                    outcome = "Renamed to \(draft)"
                    isRenaming = false
                }
            }
        }
    }
}
