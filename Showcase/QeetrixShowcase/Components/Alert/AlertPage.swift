import Qeetrix
import SwiftUI

struct AlertPage: View {
    @State private var isOfflineShown = true
    @State private var isFailureShown = false
    @State private var opened = 0

    var body: some View {
        ComponentPage(
            title: "Alert",
            summary: "A message in the page: the tone's tint, a 3 pt status edge and its icon. It stays until the app removes it."
        ) {
            DemoSection("Tones") {
                QeetrixAlert("New sign-in requests arrive here", description: "Approve them from this phone.")
                QeetrixAlert("Phone linked", description: "You can approve sign-ins from this phone.", tone: .success)
                QeetrixAlert("Push notifications are off", description: "Turn them on to hear about sign-in requests.", tone: .warning)
                QeetrixAlert("This phone isn't linked", description: "Scan the code on qeet.in to link it.", tone: .danger)
            }
            DemoSection("With actions") {
                QeetrixAlert(
                    "Push notifications are off", description: "Turn them on to approve sign-ins from this phone.", tone: .warning
                ) {
                    QeetrixButton("Open Settings", size: .sm) { opened += 1 }
                    QeetrixButton("Not now", variant: .ghost, tone: .neutral, size: .sm) {}
                }
                QeetrixText("Opened: \(opened)", size: .sm, tone: .subtle).accessibilityIdentifier("alert-opened")
            }
            DemoSection("Dismissible") {
                if isOfflineShown {
                    QeetrixAlert(
                        "You're offline", description: "Approvals arrive when you reconnect.", onDismiss: { isOfflineShown = false })
                } else {
                    QeetrixButton("Show again", variant: .ghost) { isOfflineShown = true }
                }
            }
            DemoSection("Announced when it appears") {
                if isFailureShown {
                    QeetrixAlert(
                        "Couldn't link this phone", description: "The code has expired. Scan a new one.", tone: .danger,
                        announce: .urgent, onDismiss: { isFailureShown = false })
                } else {
                    QeetrixButton("Link this phone", variant: .soft) { isFailureShown = true }
                }
                QeetrixText("An urgent alert interrupts VoiceOver; a polite one waits.", size: .sm, tone: .subtle)
            }
            DemoSection("Another icon") {
                QeetrixAlert("Viewing as Priya Sharma", description: "Changes you make are made for her.", icon: .eye)
            }
        }
    }
}

#Preview {
    NavigationStack { AlertPage() }
}
