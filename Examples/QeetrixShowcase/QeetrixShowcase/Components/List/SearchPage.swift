import Qeetrix
import SwiftUI

/// Native `.searchable` over a list, a chip filter, and the no-results state. The page filters; Qeetrix
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
                .padding(.horizontal, QeetrixSpacing.l)
                .padding(.vertical, QeetrixSpacing.s)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            Section {
                if results.isEmpty {
                    QeetrixEmptyState(
                        "No results", description: Text("Nothing matches your search and filter."), variant: .noResults, size: .sm
                    ) {
                        QeetrixButton("Clear search and filter", variant: .outline, size: .sm) {
                            query = ""
                            status = nil
                        }
                    }
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(results) { document in
                        QeetrixListItem(document.title, description: Text(document.owner), icon: .fileText) {
                            QeetrixBadge(document.status.rawValue, variant: document.status == .active ? .success : .secondary)
                        }
                    }
                }
            } header: {
                QeetrixSectionHeader(title: Text("Documents: \(results.count)"))
                    .accessibilityIdentifier("search-count")
            } footer: {
                QeetrixText("Submitted: \(submitted)", variant: .muted).accessibilityIdentifier("search-submitted")
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
