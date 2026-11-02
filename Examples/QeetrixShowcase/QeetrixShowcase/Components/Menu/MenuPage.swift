import Qeetrix
import SwiftUI

struct MenuPage: View {
    @State private var result = "none"
    @State private var sort = "Newest"

    var body: some View {
        ComponentPage(
            title: "Menu",
            summary:
                "Actions behind a Qeetrix button, in the system menu. Items take sharp Qeetrix icons, descriptions and the danger tone."
        ) {
            DemoSection("Behind an icon button") {
                QeetrixMenu(icon: .ellipsis, label: "More actions") {
                    items
                }
                QeetrixText("Last action: \(result)", size: .sm, tone: .subtle).accessibilityIdentifier("menu-result")
            }
            DemoSection("Behind a soft button, with a choice") {
                QeetrixMenu("Sort: \(sort)") {
                    Picker("Sort", selection: $sort) {
                        ForEach(["Newest", "Oldest", "Name"], id: \.self) { Text($0).tag($0) }
                    }
                }
            }
            DemoSection("Descriptions") {
                QeetrixMenu("Export", icon: .share2) {
                    QeetrixMenuItem("Export as CSV", icon: .copy, description: Text("Opens in a spreadsheet")) { result = "csv" }
                    QeetrixMenuItem("Export as JSON", icon: .copy, description: Text("For another system to read")) { result = "json" }
                }
            }
            DemoSection("Context menu") {
                QeetrixCard(title: Text("Q3 summary"), description: Text("Touch and hold for actions")) {
                    QeetrixText("Revenue up 12% on Q2.")
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
        QeetrixMenuItem("Delete", icon: .trash, tone: .danger) { result = "delete" }
    }
}

#Preview {
    NavigationStack { MenuPage() }
}
