import Qeetrix
import QeetrixIconsExtended
import SwiftUI

struct ButtonPage: View {
    @State private var saves = 0
    @State private var isSaving = false
    @State private var size: QeetrixControlSize = .md

    var body: some View {
        ComponentPage(
            title: "Button",
            summary: "An action. Label first, a trailing icon in its own zone. One solid and one soft per region; the rest are ghost."
        ) {
            DemoSection("Variants") {
                FlowLayout {
                    QeetrixButton("Create invoice") {}
                    QeetrixButton("Export", variant: .soft) {}
                    QeetrixButton("Cancel", variant: .ghost) {}
                }
            }
            DemoSection("Tones") {
                FlowLayout {
                    QeetrixButton("Revoke key", tone: .danger) {}
                    QeetrixButton("Remove", variant: .ghost, tone: .danger) {}
                }
                FlowLayout {
                    QeetrixButton("Filters", variant: .ghost, tone: .neutral) {}
                    QeetrixButton("Neutral solid looks soft", tone: .neutral) {}
                }
            }
            DemoSection("Sizes") {
                Picker("Size", selection: $size) {
                    ForEach(QeetrixControlSize.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                FlowLayout {
                    QeetrixButton("Continue", size: size) {}
                    QeetrixButton("Share", icon: .share2, variant: .soft, size: size) {}
                    QeetrixButton("Search", icon: .search, variant: .ghost, size: size) {}
                }
            }
            DemoSection("A trailing icon") {
                FlowLayout {
                    QeetrixButton("Send", icon: .send) {}
                    QeetrixButton("Settings", icon: .settings, variant: .ghost) {}
                }
            }
            DemoSection("Action and loading") {
                FlowLayout {
                    QeetrixButton("Save", isLoading: isSaving) {
                        saves += 1
                    }
                    QeetrixButton(isSaving ? "Stop" : "Simulate work", variant: .ghost) {
                        isSaving.toggle()
                    }
                }
                QeetrixText("Saved \(saves) times", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("save-count")
            }
            DemoSection("Disabled") {
                FlowLayout {
                    QeetrixButton("Unavailable") {}.disabled(true)
                    QeetrixButton("Unavailable", variant: .soft) {}.disabled(true)
                    QeetrixButton("Unavailable", variant: .ghost) {}.disabled(true)
                }
            }
            DemoSection("Full width") {
                QeetrixButton("Continue with passkey", icon: .lock, size: .lg, isFullWidth: true) {}
            }
            DemoSection("An icon of your own") {
                // The call-end sign: the filled phone, turned 135°, in the zone a named icon takes.
                QeetrixButton("Hang up and report", variant: .soft, tone: .neutral, size: .lg, isFullWidth: true) {
                } icon: {
                    QeetrixIcon(.phone, size: .md, variant: .filled).rotationEffect(.degrees(135))
                }
                FlowLayout {
                    QeetrixButton("Hang up", tone: .danger) {
                    } icon: {
                        QeetrixIcon(.phone, size: .sm, variant: .filled).rotationEffect(.degrees(135))
                    }
                    QeetrixIconButton(label: "Hang up", variant: .solid, tone: .danger) {
                    } icon: {
                        QeetrixIcon(.phone, size: .sm, variant: .filled).rotationEffect(.degrees(135))
                    }
                }
            }
            DemoSection("The style on native controls") {
                FlowLayout {
                    Button("Native style") {}
                        .buttonStyle(.qeetrix(.soft))
                    ShareLink(item: URL(string: "https://ui.qeet.in")!) {
                        Text("Share link")
                    }
                    .buttonStyle(.qeetrix(.ghost))
                }
            }
        }
    }
}

#Preview {
    NavigationStack { ButtonPage() }
}
