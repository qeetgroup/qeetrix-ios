import Qeetrix
import SwiftUI

/// Each feedback role on a button, and the toggles that play selection feedback. On a device with System
/// Haptics on; the simulator plays nothing.
struct HapticsPage: View {
    @State private var plays: [QeetrixFeedback: Int] = [:]
    @State private var autoRenew = true
    @State private var receipts = false
    @State private var cycle = "monthly"

    var body: some View {
        ComponentPage(
            title: "Haptics",
            summary:
                "Five roles — selection, success, warning, error and light impact — played as the system's haptics, and silent when System Haptics is off."
        ) {
            DemoSection("Roles") {
                FlowLayout {
                    ForEach(QeetrixFeedback.allCases, id: \.self) { feedback in
                        QeetrixButton(Self.title(feedback), variant: .soft, tone: .neutral, size: .sm) {
                            plays[feedback, default: 0] += 1
                        }
                        .qeetrixFeedback(feedback, trigger: plays[feedback, default: 0])
                    }
                }
            }
            DemoSection("Played directly") {
                QeetrixButton("Play error", variant: .ghost, tone: .danger, size: .sm) {
                    QeetrixFeedback.error.play()
                }
            }
            DemoSection("Selection, built in") {
                VStack(alignment: .leading, spacing: 0) {
                    QeetrixSwitch("Auto-renew", isOn: $autoRenew)
                    QeetrixCheckbox("Email me receipts", isOn: $receipts)
                }
                QeetrixRadioGroup(
                    "Billing cycle", selection: $cycle,
                    options: [QeetrixOption("Monthly", value: "monthly"), QeetrixOption("Yearly", value: "yearly")])
                QeetrixButton("Turn auto-renew off from the app", variant: .ghost, tone: .neutral, size: .sm) {
                    // The app's own change: the switch moves, and plays nothing.
                    autoRenew = false
                }
            }
        }
    }

    private static func title(_ feedback: QeetrixFeedback) -> String {
        switch feedback {
        case .selection: "Selection"
        case .success: "Success"
        case .warning: "Warning"
        case .error: "Error"
        case .lightImpact: "Light impact"
        }
    }
}

#Preview {
    NavigationStack { HapticsPage() }
}
