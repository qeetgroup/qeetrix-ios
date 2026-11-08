import Qeetrix
import SwiftUI

struct EmptyStatePage: View {
    @State private var added = 0
    @State private var unlocks = 0

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
            DemoSection("Outcomes: success and warning") {
                QeetrixEmptyState(
                    "Sign-in approved", description: "You're signed in on your Mac.", icon: .circleCheck, size: .section, tone: .success)
                QeetrixEmptyState(
                    "Approve on your other phone", description: "This request was sent to Priya's Pixel.", icon: .triangleAlert,
                    size: .section, tone: .warning)
            }
            DemoSection("A lock screen: an image in place of the icon") {
                QeetrixEmptyState(
                    title: Text("Qeet ID is locked"), description: Text("Unlock to see your codes."), image: ShowcaseAppIcon(), level: 2
                ) {
                    QeetrixButton("Unlock", icon: .lockOpen) { unlocks += 1 }
                }
                .centredInHeight()
                .frame(height: 360)
                QeetrixText("The image is decorative: VoiceOver skips it. On its own, the same tile is read:", size: .sm, tone: .subtle)
                ShowcaseAppIcon().accessibilityIdentifier("app-icon-alone")
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

/// A stand-in for the app's icon, read by VoiceOver as one image when it stands alone.
private struct ShowcaseAppIcon: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(QeetrixColor.bgBrandBold)
            .frame(width: 64, height: 64)
            .overlay { QeetrixIcon(.key, size: .lg, shape: .sharp).foregroundStyle(QeetrixColor.textOnBrand) }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: "Qeet ID app icon"))
            .accessibilityAddTraits(.isImage)
    }
}

#Preview {
    NavigationStack { EmptyStatePage() }
}
