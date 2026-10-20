import Qeetrix
import SwiftUI

struct DescriptionListPage: View {
    var body: some View {
        ComponentPage(
            title: "Description list",
            summary: "Labelled details of one thing. Terms are quiet; values are the data. The app formats the values."
        ) {
            DemoSection("Horizontal, divided") {
                QeetrixCard {
                    QeetrixDescriptionList(isDivided: true) { details }
                }
                QeetrixText("Term beside value in regular width (iPad, landscape); stacked on a portrait iPhone.", variant: .muted)
            }
            DemoSection("Vertical") {
                QeetrixDescriptionList(layout: .vertical) { details }
            }
            DemoSection("Grid") {
                QeetrixDescriptionList(layout: .grid) {
                    QeetrixDescriptionItem("Plan", value: Text("Team"))
                    QeetrixDescriptionItem("Region", value: Text(verbatim: "Mumbai"))
                    QeetrixDescriptionItem("Created", value: Text(verbatim: "12 October 2026"))
                    QeetrixDescriptionItem("Owner", value: Text(verbatim: "Asha Rao"))
                }
            }
        }
    }

    @ViewBuilder
    private var details: some View {
        QeetrixDescriptionItem("Workspace", value: Text(verbatim: "Qeet Design"))
        QeetrixDescriptionItem("Plan", value: Text("Team, billed monthly"))
        QeetrixDescriptionItem("Identifier", value: Text(verbatim: "ws_7f3a9c2e8b1d4f60a5e2c9d71b3f8a04"))
        QeetrixDescriptionItem("Status") { QeetrixBadge("Active", variant: .success) }
    }
}

#Preview {
    NavigationStack { DescriptionListPage() }
}
