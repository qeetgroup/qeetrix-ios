import Qeetrix
import SwiftUI

struct CopyButtonPage: View {
    @State private var toast: QeetrixToast?
    @State private var copies = 0
    // Synthetic values: no real identifier, link or key is involved.
    let userID = "usr_01HZX4B7Q2M9"
    let inviteLink = "https://id.qeet.in/invite/7Hq2Xk9"

    var body: some View {
        ComponentPage(
            title: "Copy button",
            summary:
                "Copies text with a light haptic and a toast. The icon turns into a check for 2 s; a secret stays on this device and expires."
        ) {
            DemoSection("Icon-only") {
                FlowLayout {
                    QeetrixCopyButton(value: userID, label: Text("Copy user ID"), toast: $toast) { _ in copies += 1 }
                    QeetrixCopyButton(value: userID, label: Text("Copy user ID, soft"), variant: .soft, toast: $toast)
                    QeetrixCopyButton(value: userID, label: Text("Copy user ID, solid"), variant: .solid, tone: .brand, toast: $toast)
                    ForEach(QeetrixControlSize.allCases, id: \.self) { size in
                        QeetrixCopyButton(value: userID, label: Text("Copy user ID, \(size.rawValue)"), size: size, toast: $toast)
                    }
                }
                QeetrixText("Copied \(copies) times", size: .sm, tone: .subtle).accessibilityIdentifier("copy-button-count")
            }
            DemoSection("With a title") {
                FlowLayout {
                    QeetrixCopyButton("Copy link", value: inviteLink, toast: $toast)
                    QeetrixCopyButton("Copy link", value: inviteLink, variant: .soft, toast: $toast)
                }
            }
            DemoSection("A secret") {
                QeetrixCopyButton("Copy recovery code", value: "QX7H-2K9M-4F8A", isSensitive: true, variant: .soft, toast: $toast)
                QeetrixText("Kept on this device and cleared from the clipboard after a minute.", size: .sm, tone: .subtle)
            }
            DemoSection("Read when tapped") {
                FlowLayout {
                    QeetrixCopyButton(label: Text("Copy a fresh token"), isSensitive: true, toast: $toast) {
                        try await Task.sleep(for: .milliseconds(300))
                        return "qt_test_\(Int.random(in: 1000...9999))"
                    }
                    QeetrixCopyButton(label: Text("Copy a token that can't be read"), toast: $toast) {
                        throw CopyButtonDemoError.unavailable
                    }
                }
                QeetrixText("The second fails: a circle-alert and \"Couldn't copy\", never silent.", size: .sm, tone: .subtle)
            }
            DemoSection("Disabled") {
                FlowLayout {
                    QeetrixCopyButton(value: userID, label: Text("Copy user ID")).disabled(true)
                    QeetrixCopyButton("Copy link", value: inviteLink).disabled(true)
                }
            }
        }
        .qeetrixToast($toast)
    }
}

private enum CopyButtonDemoError: Error {
    case unavailable
}

#Preview {
    NavigationStack { CopyButtonPage() }
}
