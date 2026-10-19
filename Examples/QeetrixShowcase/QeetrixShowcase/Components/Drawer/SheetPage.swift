import Qeetrix
import SwiftUI

struct SheetPage: View {
    @State private var isEditing = false
    @State private var name = "Asha Rao"
    @State private var draft = ""
    @State private var discard: QeetrixConfirmationDialog?
    @State private var showsFilters = false
    @State private var sort = "newest"

    private var hasChanges: Bool { draft != name }

    var body: some View {
        ComponentPage(
            title: "Sheet",
            summary:
                "A focused task over the page: from the bottom on iPhone, a centred form sheet on iPad. The page owns whether it shows."
        ) {
            DemoSection("A form, guarded against losing changes") {
                QeetrixText("Display name: \(name)").accessibilityIdentifier("profile-name")
                QeetrixButton("Edit profile", variant: .outline) {
                    draft = name
                    isEditing = true
                }
                QeetrixText("With unsaved changes a swipe down does not dismiss it, and Close asks first.", variant: .muted)
            }
            DemoSection("Detents") {
                QeetrixButton("Show filters", variant: .outline) { showsFilters = true }
                    .qeetrixSheet(isPresented: $showsFilters, detents: [.medium, .large]) {
                        QeetrixSheetContent("Filters", description: Text("Medium or large; drag the handle.")) {
                            QeetrixRadioGroup(
                                "Sort by", selection: $sort,
                                options: [QeetrixOption("Newest", value: "newest"), QeetrixOption("Oldest", value: "oldest")])
                        } actions: {
                            QeetrixButton("Done") { showsFilters = false }
                        }
                    }
                QeetrixText("Sort: \(sort)", variant: .muted).accessibilityIdentifier("filters-sort")
            }
        }
        .qeetrixSheet(isPresented: $isEditing, isDismissDisabled: hasChanges) {
            QeetrixSheetContent("Edit profile", description: Text("Your team sees these details."), onClose: close) {
                QeetrixTextField("Display name", text: $draft)
            } actions: {
                QeetrixButton("Cancel", variant: .outline) { close() }
                QeetrixButton("Save") {
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
