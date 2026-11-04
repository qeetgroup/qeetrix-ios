import Qeetrix
import SwiftUI

/// Five thousand rows in a native `List`, for scrolling and memory checks. The list is lazy; each row is
/// a plain value with the app's stable id.
struct LargeListPage: View {
    @State private var documents = ShowcaseDocument.generated(5_000)
    @State private var selected: Int?

    var body: some View {
        List(documents) { document in
            QeetrixListItem(
                document.title, description: Text(verbatim: document.owner), metadata: Text(verbatim: document.size),
                isSelected: selected == document.id
            ) {
                selected = document.id
            } leading: {
                QeetrixListItemIcon(.fileText)
            } trailing: {
                QeetrixBadge(document.status.rawValue, tone: document.status == .active ? .success : .neutral)
            }
        }
        .qeetrixListStyle()
        .accessibilityIdentifier("large-list")
        .navigationTitle("5,000 rows")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { LargeListPage() }
}
