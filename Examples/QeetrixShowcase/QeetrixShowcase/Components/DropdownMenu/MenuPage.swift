import Qeetrix
import SwiftUI

struct MenuPage: View {
    @State private var result = "none"
    @State private var sort = "Newest"

    var body: some View {
        ComponentPage(
            title: "Menu",
            summary:
                "Actions behind a Qeetrix button, in the system menu. Items take Qeetrix icons and roles; Divider, Section and Picker work as usual."
        ) {
            DemoSection("Actions") {
                QeetrixMenu(icon: .ellipsis, label: "More actions") {
                    items
                }
                QeetrixText("Last action: \(result)", variant: .muted).accessibilityIdentifier("menu-result")
            }
            DemoSection("With a title and a choice") {
                QeetrixMenu("Sort: \(sort)") {
                    Picker("Sort", selection: $sort) {
                        ForEach(["Newest", "Oldest", "Name"], id: \.self) { Text($0).tag($0) }
                    }
                }
            }
            DemoSection("Context menu") {
                QeetrixCard(variant: .outline) {
                    QeetrixCardHeader("Q3 summary", description: "Touch and hold for actions")
                }
                .contextMenu { items }
            }
        }
    }

    @ViewBuilder
    private var items: some View {
        QeetrixMenuItem("Rename", icon: .pencil) { result = "rename" }
        QeetrixMenuItem("Duplicate", icon: .copy) { result = "duplicate" }
            .disabled(true)
        QeetrixMenuItem("Share", icon: .share2) { result = "share" }
        Divider()
        QeetrixMenuItem("Delete", icon: .trash, role: .destructive) { result = "delete" }
    }
}

#Preview {
    NavigationStack { MenuPage() }
}
