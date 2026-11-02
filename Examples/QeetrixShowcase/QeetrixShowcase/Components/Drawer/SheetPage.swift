import Qeetrix
import SwiftUI

struct SheetPage: View {
    @State private var isEditing = false
    @State private var name = "Asha Rao"
    @State private var draft = ""
    @State private var discard: QeetrixConfirmationDialog?
    @State private var showsFilters = false
    @State private var sort = "newest"
    @State private var isRevoking = false
    @State private var revoked = false

    private var hasChanges: Bool { draft != name }

    var body: some View {
        ComponentPage(
            title: "Sheet",
            summary:
                "A focused task over the page, with ruled header and footer: from the bottom on iPhone, a form sheet on iPad. The page owns whether it shows."
        ) {
            DemoSection("A form, guarded against losing changes") {
                QeetrixText("Display name: \(name)").accessibilityIdentifier("profile-name")
                QeetrixButton("Edit profile", variant: .soft) {
                    draft = name
                    isEditing = true
                }
                QeetrixText("With unsaved changes a swipe down does not dismiss it, and Close asks first.", size: .sm, tone: .subtle)
            }
            DemoSection("Detents") {
                QeetrixButton("Show filters", variant: .ghost) { showsFilters = true }
                    .qeetrixSheet(isPresented: $showsFilters, detents: [.medium, .large]) {
                        QeetrixSheetContent("Filters", description: Text("Medium or large; drag the handle.")) {
                            QeetrixRadioGroup(
                                "Sort by", selection: $sort,
                                options: [QeetrixOption("Newest", value: "newest"), QeetrixOption("Oldest", value: "oldest")])
                        } actions: {
                            QeetrixButton("Done", size: .lg) { showsFilters = false }
                        }
                    }
                QeetrixText("Sort: \(sort)", size: .sm, tone: .subtle).accessibilityIdentifier("filters-sort")
            }
            DemoSection("A destructive decision, with the dialog's intent line") {
                QeetrixButton("Revoke API key", tone: .danger) { isRevoking = true }
                    .qeetrixSheet(isPresented: $isRevoking, detents: [.medium], isDismissDisabled: true) {
                        QeetrixSheetContent(
                            "Revoke this API key?", description: Text("Apps using it stop working at once."), intent: .danger,
                            isDismissible: false
                        ) {
                            QeetrixText("Key ending 4f2a, created 3 March.")
                        } actions: {
                            QeetrixButton("Cancel", variant: .ghost, size: .lg) { isRevoking = false }
                            QeetrixButton("Revoke key", tone: .danger, size: .lg) {
                                revoked = true
                                isRevoking = false
                            }
                        }
                    }
                QeetrixText(revoked ? "Key revoked" : "Key active", size: .sm, tone: .subtle).accessibilityIdentifier("key-state")
            }
        }
        .qeetrixSheet(isPresented: $isEditing, isDismissDisabled: hasChanges) {
            QeetrixSheetContent("Edit profile", description: Text("Your team sees these details."), onClose: close) {
                QeetrixTextField("Display name", text: $draft)
            } actions: {
                QeetrixButton("Cancel", variant: .ghost, size: .lg) { close() }
                QeetrixButton("Save", size: .lg) {
                    name = draft
                    isEditing = false
                }
                .disabled(!hasChanges || draft.isEmpty)
            }
            .qeetrixConfirmationDialog($discard)
        }
    }

    /// Close and Cancel: straight out when nothing changed, otherwise ask.
    private func close() {
        guard hasChanges else {
            isEditing = false
            return
        }
        discard = QeetrixConfirmationDialog(
            "Discard your changes?",
            actions: [
                QeetrixDialogAction("Discard changes", role: .destructive) { isEditing = false },
                QeetrixDialogAction("Keep editing", role: .cancel),
            ])
    }
}

#Preview {
    NavigationStack { SheetPage() }
}
