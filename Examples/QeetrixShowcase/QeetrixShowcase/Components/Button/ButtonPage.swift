import Qeetrix
import SwiftUI

struct ButtonPage: View {
    @State private var saves = 0
    @State private var isSaving = false
    @State private var size: QeetrixButtonSize = .default

    var body: some View {
        ComponentPage(
            title: "Button",
            summary: "The Qeet action control. One primary button per screen; the rest are quieter."
        ) {
            DemoSection("Variants") {
                FlowLayout {
                    ForEach(QeetrixButtonVariant.allCases, id: \.self) { variant in
                        QeetrixButton(variant.rawValue.capitalized, variant: variant) {}
                    }
                }
            }
            DemoSection("Sizes") {
                Picker("Size", selection: $size) {
                    ForEach(QeetrixButtonSize.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                FlowLayout {
                    QeetrixButton("Continue", size: size) {}
                    QeetrixButton("Search", leadingIcon: .search, variant: .outline, size: size) {}
                    QeetrixButton("Send", trailingIcon: .send, variant: .secondary, size: size) {}
                }
            }
            DemoSection("Action and loading") {
                FlowLayout {
                    QeetrixButton("Save", isLoading: isSaving, loadingLabel: "Saving") {
                        saves += 1
                    }
                    QeetrixButton(isSaving ? "Stop" : "Simulate work", variant: .outline) {
                        isSaving.toggle()
                    }
                }
                QeetrixText("Saved \(saves) times", variant: .muted)
                    .accessibilityIdentifier("save-count")
            }
            DemoSection("Disabled") {
                FlowLayout {
                    QeetrixButton("Unavailable") {}.disabled(true)
                    QeetrixButton("Unavailable", variant: .outline) {}.disabled(true)
                }
            }
            DemoSection("The style on native controls") {
                FlowLayout {
                    Button("Native style") {}
                        .buttonStyle(.qeetrix(.secondary))
                    ShareLink(item: URL(string: "https://ui.qeet.in")!) {
                        Label("Share", systemImage: "square.and.arrow.up")
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
