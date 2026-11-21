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
    @State private var photo = "contacts"
    @State private var language = "en"

    private static let languages = [
        ("en", "English"), ("hi", "हिन्दी"), ("bn", "বাংলা"), ("te", "తెలుగు"), ("mr", "मराठी"),
        ("ta", "தமிழ்"), ("gu", "ગુજરાતી"), ("kn", "ಕನ್ನಡ"), ("ml", "മലയാളം"), ("pa", "ਪੰਜਾਬੀ"),
    ]

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
            DemoSection("Tiles, with an icon and a line") {
                QeetrixRadioGroup(
                    "Who can see your photo", selection: $photo,
                    options: [
                        QeetrixOption("Everyone", value: "everyone", description: Text("Anyone with your number"), icon: .users),
                        QeetrixOption(
                            "My contacts", value: "contacts", description: Text("People in your phone's contacts"), icon: .contactRound),
                        QeetrixOption("Nobody", value: "nobody", description: Text("Only you see it"), icon: .eyeOff),
                    ],
                    variant: .tile)
                QeetrixText("Photo: \(photo)", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("photo-selected")
            }
            DemoSection("Tiles in two columns") {
                // Each language in its own script.
                QeetrixRadioGroup(
                    "Language", selection: $language,
                    options: Self.languages.map { QeetrixOption($0.1, value: $0.0) },
                    variant: .tile, columns: 2)
            }
        }
    }
}

#Preview {
    NavigationStack { RadioGroupPage() }
}
