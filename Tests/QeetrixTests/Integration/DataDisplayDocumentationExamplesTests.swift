import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing

// The examples from Sources/Qeetrix/Qeetrix.docc/Collections.md and Searching.md, copied verbatim inside
// views that supply the names they use. The component pages' examples are in the other
// *DocumentationExamplesTests files.

private struct Member: Identifiable {
    let id: Int
    let name: String
    let email: String
    let role: String
}

private struct Document: Identifiable {
    enum Status: Hashable { case open, closed }
    let id: Int
    let title: String
    let status: Status
}

/// Collections.md.
private struct Members: View {
    let members: [Member]
    @State private var selected: Member.ID?

    var body: some View {
        List {
            Section {
                ForEach(members) { member in
                    QeetrixListItem(member.name, description: Text(verbatim: member.email), isSelected: selected == member.id) {
                        selected = member.id
                    } leading: {
                        QeetrixAvatar(name: member.name, isDecorative: true)
                    } trailing: {
                        QeetrixBadge(member.role)
                    }
                }
            } header: {
                QeetrixSectionHeader("Members", isRuled: false)
            }
            .listSectionSeparator(.hidden)
        }
        .qeetrixListStyle()
    }
}

/// Searching.md.
private struct Documents: View {
    let documents: [Document]
    @State private var query = ""
    @State private var status: Document.Status? = nil
    let statusOptions = [QeetrixOption("All", value: Document.Status?.none), QeetrixOption("Open", value: Document.Status.open)]

    private var results: [Document] {
        documents.filter { ($0.status == status || status == nil) && (query.isEmpty || $0.title.localizedCaseInsensitiveContains(query)) }
    }

    var body: some View {
        List {
            QeetrixChipGroup("Status", selection: $status, options: statusOptions)
            if results.isEmpty {
                QeetrixEmptyState("No results", description: "Nothing matches your search.", icon: .search, size: .section) {
                    QeetrixButton("Clear search", variant: .soft, size: .sm) {
                        query = ""; status = nil
                    }
                }
            }
            ForEach(results) { document in
                QeetrixListItem(document.title) { QeetrixListItemIcon(.fileText) }
            }
        }
        .qeetrixSearchable(text: $query, prompt: Text("Search documents"))
    }
}

@MainActor
@Suite("Collection and search documentation examples")
struct DataDisplayDocumentationExamplesTests {
    @Test("The collection and search articles' examples compile against the public API")
    func examplesBuild() {
        // Lists are hosted by UIKit, which ImageRenderer does not draw; building them is the check.
        _ = Members(members: [Member(id: 1, name: "Asha Rao", email: "asha@example.com", role: "Owner")]).body
        _ = Documents(documents: [Document(id: 1, title: "Roadmap", status: .open)]).body
    }
}
