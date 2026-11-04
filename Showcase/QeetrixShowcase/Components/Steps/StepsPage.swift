import Qeetrix
import SwiftUI

struct StepsPage: View {
    @State private var current = 1
    @State private var wentBackTo: Int?

    let setup = [QeetrixStep("Account"), QeetrixStep("Phone"), QeetrixStep("Passkey")]
    let longer = [
        QeetrixStep("Create your account"), QeetrixStep("Verify your phone number"), QeetrixStep("Add a passkey"), QeetrixStep("Finish"),
    ]

    var body: some View {
        ComponentPage(
            title: "Steps",
            summary: "Where a person is in a flow: done steps Ember with a tick, the current one outlined, those to come grey."
        ) {
            DemoSection("Across the screen") {
                QeetrixSteps(setup, current: current)
                FlowLayout {
                    QeetrixButton("Back", variant: .ghost, size: .sm) { current = max(0, current - 1) }
                    QeetrixButton(current >= setup.count - 1 ? "Finish" : "Continue", size: .sm) {
                        current = min(setup.count, current + 1)
                    }
                }
            }
            DemoSection("Compact, where the labels don't fit") {
                QeetrixSteps(longer, current: 1)
                QeetrixText("Every step is still read by VoiceOver, with its position and state.", size: .sm, tone: .subtle)
            }
            DemoSection("A failed check and one that needs attention") {
                QeetrixSteps(
                    [QeetrixStep("Connect"), QeetrixStep("Verify", status: .failed), QeetrixStep("Review", status: .attention)],
                    current: 2)
            }
            DemoSection("Vertical, with descriptions") {
                QeetrixSteps(
                    [
                        QeetrixStep("Connect the directory", description: "Okta, over SAML"),
                        QeetrixStep("Map attributes", description: "Email and name"),
                        QeetrixStep("Test a sign-in", status: .failed),
                        QeetrixStep("Go live"),
                    ],
                    current: 2, orientation: .vertical)
            }
            DemoSection("Done steps that go back") {
                QeetrixSteps(setup, current: 2) { index in wentBackTo = index }
                QeetrixText("Went back to: \(wentBackTo.map { "step \($0 + 1)" } ?? "nothing yet")", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("steps-went-back")
            }
        }
    }
}

#Preview {
    NavigationStack { StepsPage() }
}
