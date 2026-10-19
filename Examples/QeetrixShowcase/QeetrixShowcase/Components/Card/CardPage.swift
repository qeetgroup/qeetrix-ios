import Qeetrix
import SwiftUI

struct CardPage: View {
    @State private var selectedPlan = "Team"
    @State private var opened = 0

    var body: some View {
        ComponentPage(
            title: "Card",
            summary: "A surface that groups related content, with an optional header and footer."
        ) {
            DemoSection("Default, with a footer") {
                QeetrixCard {
                    QeetrixCardHeader("Team plan", description: "Billed monthly") {
                        QeetrixBadge("Current", variant: .brand)
                    }
                    QeetrixText("Up to 25 members, with audit logs and single sign-on.")
                } footer: {
                    QeetrixButton("Upgrade") {}
                    QeetrixButton("Compare", variant: .ghost) {}
                }
            }
            DemoSection("Outline and elevated") {
                QeetrixCard(variant: .outline, size: .sm) {
                    QeetrixCardHeader("Outline, small", description: "For dense, repeated tiles")
                }
                QeetrixCard(variant: .elevated) {
                    QeetrixCardHeader("Elevated", description: "The one surface that stands forward")
                }
            }
            DemoSection("Cards that are buttons") {
                ForEach(["Starter", "Team", "Enterprise"], id: \.self) { plan in
                    Button {
                        selectedPlan = plan
                        opened += 1
                    } label: {
                        QeetrixCardHeader(plan, description: plan == selectedPlan ? "Selected" : "Tap to choose")
                    }
                    .buttonStyle(.qeetrixCard(isSelected: plan == selectedPlan))
                }
                QeetrixText("Chosen \(opened) times", variant: .muted)
                    .accessibilityIdentifier("card-taps")
            }
        }
    }
}

#Preview {
    NavigationStack { CardPage() }
}
