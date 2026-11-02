import Qeetrix
import SwiftUI

/// The system search bar (`searchable`) over a list, a chip filter, and the no-results state. The page filters; Qeetrix
/// presents.
struct SearchPage: View {
    @State private var query = ""
    @State private var status: ShowcaseDocument.Status? = nil
    @State private var submitted = "none"

    private var results: [ShowcaseDocument] {
        ShowcaseDocument.samples.filter { document in
            (status == nil || document.status == status)
                && (query.isEmpty || document.title.localizedCaseInsensitiveContains(query)
                    || document.owner.localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        List {
            Section {
                QeetrixChipGroup(
                    "Status", selection: $status,
                    options: [QeetrixOption("All", value: ShowcaseDocument.Status?.none)]
                        + ShowcaseDocument.Status.allCases.map { QeetrixOption($0.rawValue, value: Optional($0)) }
                )
                .padding(.horizontal, QeetrixSpace.insetLg)
                .padding(.vertical, QeetrixSpace.gapSm)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            Section {
                if results.isEmpty {
                    QeetrixEmptyState("No results", description: "Nothing matches your search and filter.", icon: .search, size: .section) {
                        QeetrixButton("Clear search and filter", variant: .soft, size: .sm) {
                            query = ""
                            status = nil
                        }
                    }
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(results) { document in
                        QeetrixListItem(document.title, description: Text(verbatim: document.owner)) {
                            QeetrixListItemIcon(.fileText)
                        } trailing: {
                            QeetrixBadge(document.status.rawValue, tone: document.status == .active ? .success : .neutral)
                        }
                    }
                }
            } header: {
                QeetrixSectionHeader(title: Text("Documents: \(results.count)"), isRuled: false)
                    .accessibilityIdentifier("search-count")
            } footer: {
                QeetrixText("Submitted: \(submitted)", tone: .subtle).accessibilityIdentifier("search-submitted")
            }
        }
        .scrollContentBackground(.hidden)
        .background(QeetrixColor.surfaceCanvas)
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search documents"))
        .onSubmit(of: .search) { submitted = query }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { SearchPage() }
}
