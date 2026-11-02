import Qeetrix
import SwiftUI

/// The overlays together: each owns one piece of the page's state, and each hands over to the next.
struct OverlayPatternsPage: View {
    private struct Document: Identifiable, Hashable {
        let id: Int
        var title: String
    }

    @State private var documents = [
        Document(id: 1, title: "Q3 summary"), Document(id: 2, title: "Design review"), Document(id: 3, title: "Roadmap"),
    ]
    @State private var confirmDelete: QeetrixConfirmationDialog?
    @State private var editing: Document?
    @State private var draft = ""
    @State private var toast: QeetrixToast?

    var body: some View {
        ComponentPage(
            title: "Overlay patterns",
            summary: "Menu → confirmation → toast with undo, and sheet → save → toast. Each overlay is one optional value in the page."
        ) {
            DemoSection("Documents") {
                VStack(spacing: QeetrixSpace.gapSm) {
                    ForEach(documents) { document in
                        row(document)
                    }
                }
                // One dialog for the list: on iPad it points at the list rather than the row's button.
                .qeetrixConfirmationDialog($confirmDelete)
                QeetrixText("\(documents.count) documents", size: .sm, tone: .subtle).accessibilityIdentifier("document-count")
            }
        }
        .qeetrixSheet(item: $editing) { document in
            QeetrixSheetContent("Rename document") {
                QeetrixTextField("Title", text: $draft)
            } actions: {
                QeetrixButton("Cancel", variant: .ghost, size: .lg) { editing = nil }
                QeetrixButton("Save", size: .lg) { rename(document) }
                    .disabled(draft.isEmpty)
            }
        }
        .qeetrixToast($toast)
    }

    private func row(_ document: Document) -> some View {
        HStack {
            QeetrixText(document.title)
            Spacer()
            QeetrixMenu(icon: .ellipsis, label: Text("Actions for \(document.title)")) {
                QeetrixMenuItem("Rename", icon: .pencil) {
                    draft = document.title
                    editing = document
                }
                QeetrixMenuItem("Delete", icon: .trash, tone: .danger) {
                    confirmDelete = QeetrixConfirmationDialog(
                        "Delete \(document.title)?",
                        actions: [QeetrixDialogAction("Delete", role: .destructive) { delete(document) }])
                }
            }
        }
        .padding(.vertical, QeetrixSpace.gapXs)
    }

    private func delete(_ document: Document) {
        guard let index = documents.firstIndex(of: document) else { return }
        documents.remove(at: index)
        toast = QeetrixToast(
            .info, title: "\(document.title) deleted",
            action: .init("Undo") { documents.insert(document, at: min(index, documents.count)) })
    }

    private func rename(_ document: Document) {
        if let index = documents.firstIndex(where: { $0.id == document.id }) {
            documents[index].title = draft
        }
        editing = nil
        toast = QeetrixToast(.success, title: "Renamed to \(draft)")
    }
}

#Preview {
    NavigationStack { OverlayPatternsPage() }
}
