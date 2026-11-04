import Qeetrix
import SwiftUI

struct IconButtonPage: View {
    @State private var dismissals = 0

    var body: some View {
        ComponentPage(
            title: "Icon button",
            summary: "A square button holding one sharp icon. Its label is what VoiceOver reads, and a tooltip with a pointer."
        ) {
            DemoSection("Variants") {
                FlowLayout {
                    ForEach(QeetrixButtonVariant.allCases, id: \.self) { variant in
                        QeetrixIconButton(.bell, label: "Notifications, \(variant.rawValue)", variant: variant) {}
                    }
                }
            }
            DemoSection("Tones") {
                FlowLayout {
                    ForEach(QeetrixButtonTone.allCases, id: \.self) { tone in
                        QeetrixIconButton(.ellipsis, label: "More, \(tone.rawValue)", tone: tone) {}
                    }
                }
            }
            DemoSection("Sizes") {
                FlowLayout {
                    ForEach(QeetrixControlSize.allCases, id: \.self) { size in
                        QeetrixIconButton(.search, label: "Search, \(size.rawValue)", tone: .neutral, size: size) {}
                    }
                }
            }
            DemoSection("Action, loading and disabled") {
                FlowLayout {
                    QeetrixIconButton(.x, label: "Close", tone: .neutral) { dismissals += 1 }
                    QeetrixIconButton(.send, label: "Send", variant: .solid, isLoading: true) {}
                    QeetrixIconButton(.lock, label: "Lock", variant: .soft) {}.disabled(true)
                }
                QeetrixText("Closed \(dismissals) times", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("close-count")
            }
        }
    }
}

#Preview {
    NavigationStack { IconButtonPage() }
}
