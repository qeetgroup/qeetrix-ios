import Qeetrix
import QeetrixIconsExtended
import SwiftUI

struct LinkPage: View {
    @State private var taps = 0
    @State private var opened = "nothing"

    private static let consent = AttributedString(
        localized:
            "By tapping Agree and continue, you accept the [Terms of Service](https://qeet.in/terms) and [Privacy Policy](https://qeet.in/privacy)."
    )

    var body: some View {
        ComponentPage(
            title: "Link",
            summary: "An action in place or a page to open, in the words around it: the link colour, underlined 3 pt under the baseline."
        ) {
            DemoSection("Under a field") {
                QeetrixText("We sent a code to +91 98765 43210.", size: .sm, tone: .subtle)
                QeetrixLink("Change number") { taps += 1 }
                    .qeetrixTextStyle(.bodySm)
                QeetrixText("Changed \(taps) times", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("link-taps")
            }
            DemoSection("Two actions on a line") {
                HStack(spacing: QeetrixSpace.gapSm) {
                    QeetrixLink("Resend SMS") {}
                    Text(verbatim: "·").foregroundStyle(QeetrixColor.textSubtlest).accessibilityHidden(true)
                    QeetrixLink("Call me instead") {}
                }
                .qeetrixTextStyle(.bodySm)
            }
            DemoSection("With an icon") {
                QeetrixLink("Read in another language", icon: .languages) {}
                    .qeetrixTextStyle(.bodyMd)
            }
            DemoSection("Tones") {
                QeetrixLink("Why do you need my SIM?", tone: .subtle) {}
                    .qeetrixTextStyle(.bodySm)
                QeetrixLink("Report a problem", tone: .inherit) {}
                    .qeetrixTextStyle(.bodySm)
                    .foregroundStyle(QeetrixColor.textDanger)
                QeetrixLink("Privacy Policy", destination: URL(string: "https://qeet.in/privacy")!, tone: .subtle)
                    .qeetrixTextStyle(.bodySm)
                    .accessibilityIdentifier("privacy-link")
            }
            DemoSection("Inside a sentence") {
                Text(Self.consent.qeetrixLinks())
                    .qeetrixTextStyle(.bodySm)
                    .foregroundStyle(QeetrixColor.textSubtle)
                    .qeetrixLinkTone()
                QeetrixText("Opened: \(opened)", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("link-opened")
            }
            DemoSection("Disabled") {
                QeetrixLink("Resend in 0:42") {}
                    .qeetrixTextStyle(.bodySm)
                    .disabled(true)
            }
        }
        // Opened in place, so the page shows which link was followed.
        .environment(
            \.openURL,
            OpenURLAction { url in
                opened = url.lastPathComponent
                return .handled
            })
    }
}

#Preview {
    NavigationStack { LinkPage() }
}
