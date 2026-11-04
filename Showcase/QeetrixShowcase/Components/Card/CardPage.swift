import Qeetrix
import SwiftUI

struct CardPage: View {
    @State private var selectedPlan = "Team"
    @State private var opened = 0

    var body: some View {
        ComponentPage(
            title: "Card",
            summary: "Related content on a raised, ruled surface: no shadow, 4 pt corners, an optional ruled header and footer."
        ) {
            DemoSection("A titled card with actions and a footer") {
                QeetrixCard(title: Text("Team plan"), description: Text("Billed monthly")) {
                    QeetrixText("Up to 25 members, with audit logs and single sign-on.")
                } actions: {
                    QeetrixBadge("Current", tone: .brand)
                } footer: {
                    QeetrixButton("Compare", variant: .ghost) {}
                    QeetrixButton("Upgrade") {}
                }
            }
            DemoSection("Subdued and untitled") {
                QeetrixCard(title: Text("Usage"), description: Text("A secondary panel"), variant: .subdued) {
                    QeetrixText("1,240 of 5,000 API calls this month.")
                }
                QeetrixCard {
                    QeetrixText("A card without a title is a plain group.")
                }
            }
            DemoSection("A danger zone") {
                QeetrixCard(title: Text("Delete workspace"), description: Text("This can't be undone."), tone: .danger) {
                    QeetrixText("Every project, file and member is removed.")
                } footer: {
                    QeetrixButton("Delete workspace", tone: .danger) {}
                }
            }
            DemoSection("Cards that are buttons") {
                ForEach(["Starter", "Team", "Enterprise"], id: \.self) { plan in
                    Button {
                        selectedPlan = plan
                        opened += 1
                    } label: {
                        VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                            QeetrixHeading(plan, level: 3, size: .titleSm)
                            QeetrixText(plan == selectedPlan ? "Selected" : "Tap to choose", size: .sm, tone: .subtle)
                        }
                    }
                    .buttonStyle(.qeetrixCard(isSelected: plan == selectedPlan))
                }
                QeetrixText("Chosen \(opened) times", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("card-taps")
            }
        }
    }
}

#Preview {
    NavigationStack { CardPage() }
}
