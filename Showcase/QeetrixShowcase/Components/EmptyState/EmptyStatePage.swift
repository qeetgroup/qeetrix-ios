import Qeetrix
import SwiftUI

struct EmptyStatePage: View {
    @State private var added = 0

    var body: some View {
        ComponentPage(
            title: "Empty state",
            summary: "The message where content would be: a 24 pt icon, what's missing, why, and the way forward."
        ) {
            DemoSection("A screen: no accounts yet") {
                QeetrixEmptyState(
                    "No accounts yet", description: "Add an account to sign in with this phone.", icon: .userPlus, level: 2
                ) {
                    QeetrixButton("Add account", icon: .plus) { added += 1 }
                } footer: {
                    Text("Or scan the code on qeet.in")
                }
                QeetrixText("Added: \(added)", size: .sm, tone: .subtle).accessibilityIdentifier("empty-state-added")
            }
            DemoSection("A section: no pending approvals") {
                QeetrixCard(title: Text("Approvals")) {
                    QeetrixEmptyState(
                        "No pending approvals", description: "Sign-in requests from your accounts appear here.", icon: .inbox,
                        size: .section)
                }
            }
            DemoSection("Danger: offline") {
                QeetrixEmptyState(
                    "You're offline", description: "Connect to the internet to see your accounts.", icon: .wifiOff, size: .section,
                    tone: .danger
                ) {
                    QeetrixButton("Try again", variant: .soft) {}
                }
            }
        }
    }
}

#Preview {
    NavigationStack { EmptyStatePage() }
}
