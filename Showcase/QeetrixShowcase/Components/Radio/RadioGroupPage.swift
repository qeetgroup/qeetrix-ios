import Qeetrix
import SwiftUI

enum Plan: String, Hashable {
    case starter = "Starter"
    case team = "Team"
    case enterprise = "Enterprise"
}

struct RadioGroupPage: View {
    @State private var plan: Plan? = nil
    @State private var billing = "monthly"
    @State private var size = "m"

    var body: some View {
        ComponentPage(
            title: "Radio group",
            summary: "One choice from a few, all visible: the question as the legend, a 16 pt circle with a 5 pt Ember ring when chosen."
        ) {
            DemoSection("No selection yet") {
                QeetrixRadioGroup(
                    "Plan", selection: $plan,
                    options: [
                        QeetrixOption("Starter", value: .starter, description: Text("For individuals")),
                        QeetrixOption("Team", value: .team, description: Text("Up to 25 members")),
                        QeetrixOption("Enterprise", value: .enterprise, description: Text("Talk to sales"), isDisabled: true),
                    ],
                    error: plan == nil ? "Choose a plan to continue." : nil,
                    isRequired: true)
                QeetrixText("Selected: \(plan?.rawValue ?? "none")", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("plan-selected")
            }
            DemoSection("A default") {
                QeetrixRadioGroup(
                    "Billing cycle", selection: $billing,
                    options: [QeetrixOption("Monthly", value: "monthly"), QeetrixOption("Yearly", value: "yearly")],
                    description: Text("Yearly saves two months."))
            }
            DemoSection("Horizontal, for short options") {
                QeetrixRadioGroup(
                    "Size", selection: $size,
                    options: [QeetrixOption("S", value: "s"), QeetrixOption("M", value: "m"), QeetrixOption("L", value: "l")],
                    orientation: .horizontal)
            }
        }
    }
}

#Preview {
    NavigationStack { RadioGroupPage() }
}
