import Qeetrix
import SwiftUI

/// A whole collection screen from the pieces: a data state around a searchable, filterable list, rows that
/// open a detail, a swipe action that confirms and reaches the context menu, and an undo toast.
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
    @State private var toast: QeetrixToast?

    private var visible: [ShowcaseDocument] {
        documents.filter { document in
            (showsArchived || document.status != .archived)
                && (query.isEmpty || document.title.localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        QeetrixDataState(
            isLoading: load == .loading, error: load == .failed ? ShowcaseLoadError() : nil, isEmpty: load == .empty || documents.isEmpty,
            failure: QeetrixDataStateFailure(title: "Couldn't load documents", description: "Check your connection."),
            onRetry: { load = .loaded }
        ) {
            List {
                Section {
                    QeetrixChip("Show archived", isSelected: $showsArchived, icon: .folder)
                        .listRowBackground(Color.clear)
                }
                Section {
                    if visible.isEmpty {
                        QeetrixEmptyState(
                            title: Text("No results"), description: Text("Nothing matches “\(query)”."), icon: .search, size: .section
                        )
                        .listRowBackground(Color.clear)
                    }
                    ForEach(visible) { document in
                        QeetrixListItem(document.title, description: Text(verbatim: document.owner), value: document) {
                            QeetrixListItemIcon(.fileText)
                        } trailing: {
                            QeetrixBadge(document.status.rawValue, tone: document.status == .active ? .success : .neutral)
                        }
                        .qeetrixSwipeActions(actions: [
                            QeetrixSwipeAction(
                                "Delete", icon: .trash, tone: .danger, confirmation: Text("Delete \(document.title)?")
                            ) { delete(document) }
                        ])
                    }
                } header: {
                    QeetrixSectionHeader(title: Text("Documents: \(visible.count)"), isRuled: false).accessibilityIdentifier(
                        "collection-count")
                }
            }
            .qeetrixListStyle()
            .navigationDestination(for: ShowcaseDocument.self) { DocumentDetail(document: $0) }
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search documents"))
        } emptyState: {
            QeetrixEmptyState("No documents yet", description: "Documents you create appear here.", icon: .fileText) {
                QeetrixButton("Create a document") {
                    documents = ShowcaseDocument.samples
                    load = .loaded
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(QeetrixColor.surfaceCanvas)
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

/// What the page's simulated data source fails with.
struct ShowcaseLoadError: Error {}

/// A document's details: its fields, its owner and its history.
struct DocumentDetail: View {
    let document: ShowcaseDocument

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QeetrixSpace.layoutSm) {
                QeetrixDescriptionList {
                    QeetrixDescriptionItem("Title", value: document.title)
                    QeetrixDescriptionItem("Owner", value: document.owner)
                    QeetrixDescriptionItem("Size", value: document.size)
                    QeetrixDescriptionItem("Status") {
                        QeetrixBadge(document.status.rawValue, tone: document.status == .active ? .success : .neutral)
                    }
                }
                QeetrixCard {
                    QeetrixListItem("Owner", description: Text(verbatim: document.owner)) {
                        QeetrixListItemIcon(.contactRound)
                    } trailing: {
                        QeetrixBadge("Editor").accessibilityIdentifier("detail-owner-badge")
                    }
                    .accessibilityIdentifier("detail-owner-row")
                }
                QeetrixSectionHeader("History")
                QeetrixTimeline {
                    QeetrixTimelineItem("Shared with the team", time: Text(verbatim: "Today, 09:41"), icon: .contactRound, tone: .brand)
                    QeetrixTimelineItem("Edited", description: document.owner, time: Text(verbatim: "Yesterday"))
                    QeetrixTimelineItem("Created", time: Text(verbatim: "12 Oct"))
                }
            }
            .padding(QeetrixSpace.insetLg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(QeetrixColor.surfaceCanvas)
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("document-detail")
    }
}

#Preview {
    NavigationStack { CollectionPatternsPage() }
}
