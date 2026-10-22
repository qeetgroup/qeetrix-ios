import Qeetrix
import SwiftUI

/// Five thousand rows in a native `List`, for scrolling and memory checks. The list is lazy; each row is
/// a plain value with the app's stable id.
struct LargeListPage: View {
    @State private var documents = ShowcaseDocument.generated(5_000)
    @State private var selected: Int?

    var body: some View {
        List(documents) { document in
            Button {
                selected = document.id
            } label: {
                QeetrixListItem(
                    document.title, description: Text(document.owner), metadata: Text(verbatim: document.size), icon: .fileText,
                    isSelected: selected == document.id
                ) {
                    QeetrixBadge(document.status.rawValue, variant: document.status == .active ? .success : .secondary)
                }
            }
            .foregroundStyle(QeetrixColor.textPrimary)
            .qeetrixListRow()
        }
        .listStyle(.plain)
        .accessibilityIdentifier("large-list")
        .navigationTitle("5,000 rows")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { LargeListPage() }
}
