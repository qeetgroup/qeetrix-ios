import Qeetrix
import SwiftUI

struct TextPage: View {
    var body: some View {
        ComponentPage(
            title: "Text",
            summary:
                "Running text, labels and inline code on the body roles, in Qeet Sans's A11y letter style. It scales with Dynamic Type."
        ) {
            DemoSection("Sizes") {
                QeetrixText("Large: sign in without a password, on any device you trust.", size: .lg)
                QeetrixText("Medium, the default: passkeys are stored in your password manager.")
                QeetrixText("Small: last used 2 days ago.", size: .sm)
            }
            DemoSection("Weights") {
                QeetrixText("Regular", weight: .regular)
                QeetrixText("Medium", weight: .medium)
                QeetrixText("Semibold", weight: .semibold)
            }
            DemoSection("Tones") {
                FlowLayout {
                    ForEach([QeetrixTextTone.default, .subtle, .subtlest, .brand, .info, .success, .warning, .danger], id: \.self) { tone in
                        QeetrixText(tone.rawValue, tone: tone)
                    }
                }
                QeetrixText("Inverse on graphite", tone: .inverse)
                    .padding(QeetrixSpace.insetSm)
                    .background(QeetrixColor.surfaceInverse)
            }
            DemoSection("Code, truncation and alignment") {
                QeetrixText("navigator.credentials.create()", mono: true)
                QeetrixText(
                    "A long description that stops after one line with an ellipsis, however much more it has to say.", truncate: 1)
                QeetrixText("Centred", align: .center)
            }
        }
    }
}

#Preview {
    NavigationStack { TextPage() }
}
