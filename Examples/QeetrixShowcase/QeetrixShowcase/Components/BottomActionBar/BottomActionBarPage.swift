import Qeetrix
import SwiftUI

/// The bar pinned to this page itself: change its actions with the switches, scroll to see the rule
/// come and go (iOS 18), and focus the field to see it ride above the keyboard.
struct BottomActionBarPage: View {
    @State private var hasSecondary = true
    @State private var hasLongLabels = false
    @State private var isLoading = false
    @State private var isDestructive = false
    @State private var note = ""
    @State private var lastAction = "None"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QeetrixSpace.layoutMd) {
                QeetrixText(
                    "A screen's main actions, pinned to the bottom: at most one solid and one soft. Above the home indicator, and above the keyboard while it is open.",
                    size: .lg, tone: .subtle)
                DemoSection("The bar's actions") {
                    QeetrixSwitch("A secondary action", isOn: $hasSecondary)
                    QeetrixSwitch("Long labels", isOn: $hasLongLabels, description: Text("They stack, the primary on top."))
                    QeetrixSwitch("Paying", isOn: $isLoading)
                    QeetrixSwitch("A destructive confirmation", isOn: $isDestructive)
                    QeetrixText("Last action: \(lastAction)", size: .sm, tone: .subtle)
                        .accessibilityIdentifier("bottom-bar-last-action")
                }
                DemoSection("The keyboard") {
                    QeetrixTextField("Note to the payee", text: $note, prompt: Text("e.g. October rent"), isOptional: true)
                }
                DemoSection("Content under the bar") {
                    ForEach(1...12, id: \.self) { line in
                        QeetrixText("Invoice line \(line): ₹100")
                    }
                    QeetrixText("The end of the invoice: scrolled clear of the bar, the rule goes (iOS 18).", size: .sm, tone: .subtle)
                }
            }
            .padding(QeetrixSpace.insetLg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(QeetrixColor.surfaceCanvas)
        .navigationTitle("Bottom action bar")
        .navigationBarTitleDisplayMode(.inline)
        .qeetrixBottomActionBar(primary: primary, secondary: hasSecondary ? secondary : nil)
    }

    private var primary: QeetrixScreenAction {
        if isDestructive {
            return QeetrixScreenAction(hasLongLabels ? "Remove Asha Rao from Acme Pvt Ltd" : "Remove member", tone: .danger) {
                lastAction = "Remove"
            }
        }
        return QeetrixScreenAction(hasLongLabels ? "Pay ₹1,20,000 now with UPI" : "Pay ₹1,200", isLoading: isLoading) {
            lastAction = "Pay"
        }
    }

    private var secondary: QeetrixScreenAction {
        QeetrixScreenAction(hasLongLabels ? "Save this invoice for later" : "Later") { lastAction = "Later" }
    }
}

#Preview {
    NavigationStack { BottomActionBarPage() }
}
