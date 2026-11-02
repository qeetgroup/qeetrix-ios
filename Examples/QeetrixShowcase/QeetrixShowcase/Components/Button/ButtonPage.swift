import Qeetrix
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
            DemoSection("The style on native controls") {
                FlowLayout {
                    Button("Native button") {}
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
