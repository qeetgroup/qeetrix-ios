import Qeetrix
import SwiftUI

/// A searchable collection as an app builds one: the app's data and filtering, a native `List` and
/// `searchable`, rows built from Qeetrix text and badges, and a no-results message.
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
                    VStack(spacing: QeetrixSpace.gapSm) {
                        QeetrixIcon(.search, size: .lg, shape: .sharp)
                            .foregroundStyle(QeetrixColor.iconSubtle)
                        QeetrixHeading("No documents found", level: 2, size: .titleSm)
                        QeetrixText("Try another search.", tone: .subtle)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, QeetrixSpace.layoutSm)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(results) { document in
                        HStack(spacing: QeetrixSpace.gapMd) {
                            QeetrixAvatar(name: document.owner, size: .sm, isDecorative: true)
                            VStack(alignment: .leading, spacing: 2) {
                                QeetrixText(document.title, weight: .medium, tone: .default)
                                QeetrixText(document.owner, size: .sm, tone: .subtle)
                            }
                            Spacer(minLength: QeetrixSpace.gapSm)
                            QeetrixBadge(document.isActive ? "Active" : "Archived", tone: document.isActive ? .success : .neutral)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            } header: {
                ConsumerSectionHeader(title: Text("Documents: \(results.count)"))
                    .accessibilityIdentifier("documents-count")
            }
        }
        .scrollContentBackground(.hidden)
        .background(QeetrixColor.surfaceCanvas)
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search documents"))
        .navigationTitle("Documents")
    }
}
