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

    var body: some View {
        ComponentPage(
            title: "Radio group",
            summary: "One choice from a few, all visible. A selection no option has shows nothing selected."
        ) {
            DemoSection("Optional selection") {
                QeetrixRadioGroup(
                    "Plan", selection: $plan,
                    options: [
                        QeetrixOption("Starter", value: .starter, description: Text("For individuals")),
                        QeetrixOption("Team", value: .team, description: Text("Up to 25 members")),
                        QeetrixOption("Enterprise", value: .enterprise, description: Text("Talk to sales"), isDisabled: true),
                    ],
                    message: plan == nil ? .warning("Choose a plan to continue.") : nil,
                    isRequired: true)
                QeetrixText("Selected: \(plan?.rawValue ?? "none")", variant: .muted)
                    .accessibilityIdentifier("plan-selected")
            }
            DemoSection("A default") {
                QeetrixRadioGroup(
                    "Billing", selection: $billing,
                    options: [QeetrixOption("Monthly", value: "monthly"), QeetrixOption("Yearly", value: "yearly")])
            }
        }
    }
}

#Preview {
    NavigationStack { RadioGroupPage() }
}
