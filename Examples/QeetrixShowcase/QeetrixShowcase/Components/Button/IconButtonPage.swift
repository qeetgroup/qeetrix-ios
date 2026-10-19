import Qeetrix
import SwiftUI

struct IconButtonPage: View {
    @State private var dismissals = 0

    var body: some View {
        ComponentPage(
            title: "Icon button",
            summary: "A square button holding one icon. Its label is what VoiceOver reads."
        ) {
            DemoSection("Variants") {
                FlowLayout {
                    ForEach(QeetrixButtonVariant.allCases, id: \.self) { variant in
                        QeetrixIconButton(.bell, label: "Notifications, \(variant.rawValue)", variant: variant) {}
                    }
                }
            }
            DemoSection("Sizes") {
                FlowLayout {
                    ForEach(QeetrixButtonSize.allCases, id: \.self) { size in
                        QeetrixIconButton(.search, label: "Search, \(size.rawValue)", variant: .outline, size: size) {}
                    }
                }
            }
            DemoSection("Action, loading and disabled") {
                FlowLayout {
                    QeetrixIconButton(.x, label: "Close") { dismissals += 1 }
                    QeetrixIconButton(.send, label: "Send", variant: .default, isLoading: true) {}
                    QeetrixIconButton(.lock, label: "Lock", variant: .outline) {}.disabled(true)
                }
                QeetrixText("Closed \(dismissals) times", variant: .muted)
                    .accessibilityIdentifier("close-count")
            }
        }
    }
}

#Preview {
    NavigationStack { IconButtonPage() }
}
