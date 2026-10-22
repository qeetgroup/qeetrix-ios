import Qeetrix
import SwiftUI

/// A whole collection screen from the pieces: a data state around a searchable, filterable list, rows that
/// open a detail, swipe and context-menu actions with a confirmation and an undo toast.
struct CollectionPatternsPage: View {
    enum Load: String, CaseIterable, Identifiable {
        case loaded = "Loaded"
        case loading = "Loading"
        case failed = "Failed"
        case empty = "Empty"
        var id: Self { self }
    }

    @State private var load = Load.loaded
    @State private var documents = ShowcaseDocument.samples
    @State private var query = ""
    @State private var showsArchived = false
    @State private var confirmDelete: QeetrixConfirmationDialog?
    @State private var toast: QeetrixToast?

    private var visible: [ShowcaseDocument] {
        documents.filter { document in
            (showsArchived || document.status != .archived)
                && (query.isEmpty || document.title.localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        QeetrixDataState(
            isLoading: load == .loading, isEmpty: load == .empty || documents.isEmpty,
            failure: load == .failed ? QeetrixDataFailure("Couldn't load documents. Check your connection.") { load = .loaded } : nil
        ) {
            List {
                Section {
                    QeetrixChip("Show archived", isSelected: $showsArchived, icon: .folder)
                        .listRowBackground(Color.clear)
                }
                Section {
                    if visible.isEmpty {
                        QeetrixEmptyState("No results", description: Text("Nothing matches “\(query)”."), variant: .noResults, size: .sm)
                            .listRowBackground(Color.clear)
                    }
                    ForEach(visible) { document in
                        NavigationLink {
                            DocumentDetail(document: document)
                        } label: {
                            QeetrixListItem(document.title, description: Text(document.owner), icon: .fileText) {
                                QeetrixBadge(document.status.rawValue, variant: document.status == .active ? .success : .secondary)
                            }
                        }
                        .qeetrixListRow()
                        .swipeActions {
                            Button(role: .destructive) {
                                askToDelete(document)
                            } label: {
                                Label {
                                    Text("Delete")
                                } icon: {
                                    Image(qeetrix: .trash)
                                }
                            }
                        }
                        .contextMenu {
                            QeetrixMenuItem("Delete", icon: .trash, role: .destructive) { askToDelete(document) }
                        }
                    }
                } header: {
                    QeetrixSectionHeader(title: Text("Documents: \(visible.count)")).accessibilityIdentifier("collection-count")
                }
            }
            .scrollContentBackground(.hidden)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search documents"))
        } empty: {
            QeetrixEmptyState(
                "No documents yet", description: Text("Documents you create appear here."), variant: .firstUse, icon: .fileText
            ) {
                QeetrixButton("Create a document") {
                    documents = ShowcaseDocument.samples
                    load = .loaded
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(QeetrixColor.surfaceCanvas)
        .qeetrixConfirmationDialog($confirmDelete)
        .qeetrixToast($toast)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                // Simulates what the app's data source reports; nothing is loaded here.
                Menu {
                    Picker("Load state", selection: $load) {
                        ForEach(Load.allCases) { Text($0.rawValue).tag($0) }
                    }
                } label: {
                    Label {
                        Text("Load state")
                    } icon: {
                        Image(qeetrix: .ellipsis)
                    }
                }
            }
        }
        .navigationTitle("Collection patterns")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func askToDelete(_ document: ShowcaseDocument) {
        confirmDelete = QeetrixConfirmationDialog(
            "Delete \(document.title)?",
            actions: [QeetrixDialogAction("Delete", role: .destructive) { delete(document) }])
    }

    private func delete(_ document: ShowcaseDocument) {
        guard let index = documents.firstIndex(of: document) else { return }
        documents.remove(at: index)
        toast = QeetrixToast(
            .info, title: "\(document.title) deleted",
            action: .init("Undo") {
                documents.insert(document, at: min(index, documents.count))
            })
    }
}

#Preview {
    NavigationStack { CollectionPatternsPage() }
}
