import Qeetrix
import SwiftUI

/// A searchable collection as an app builds one: the app's data and filtering, a native `List` and
/// `searchable`, Qeetrix rows, and Qeetrix's no-results state.
struct DocumentsScreen: View {
    struct Document: Identifiable {
        let id: Int
        let title: String
        let owner: String
        let isActive: Bool
    }

    @State private var query = ""
    private let documents = [
        Document(id: 1, title: "Roadmap", owner: "Meera Iyer", isActive: true),
        Document(id: 2, title: "Pricing", owner: "Asha Rao", isActive: true),
        Document(id: 3, title: "Release notes", owner: "Asha Rao", isActive: false),
        Document(id: 4, title: "Onboarding", owner: "Ravi Kumar", isActive: true),
    ]

    private var results: [Document] {
        query.isEmpty ? documents : documents.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        List {
            Section {
                if results.isEmpty {
                    QeetrixEmptyState("No documents found", description: "Try another search.", icon: .search, size: .section)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(results) { document in
                        QeetrixListItem(document.title, description: Text(verbatim: document.owner)) {
                            QeetrixAvatar(name: document.owner, size: .sm, isDecorative: true)
                        } trailing: {
                            QeetrixBadge(document.isActive ? "Active" : "Archived", tone: document.isActive ? .success : .neutral)
                        }
                    }
                }
            } header: {
                QeetrixSectionHeader(title: Text("Documents: \(results.count)"), isRuled: false)
                    .accessibilityIdentifier("documents-count")
            }
        }
        .scrollContentBackground(.hidden)
        .background(QeetrixColor.surfaceCanvas)
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search documents"))
        .navigationTitle("Documents")
    }
}
