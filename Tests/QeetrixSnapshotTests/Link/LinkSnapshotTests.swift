#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Link snapshots")
    struct LinkSnapshotTests {
        @Test("Each tone, with an icon, disabled, wrapping, inside a sentence, and right to left")
        func tones() {
            var consent = AttributedString("By tapping Agree and continue, you accept the ")
            var terms = AttributedString("Terms of Service")
            terms.link = URL(string: "https://qeet.in/terms")
            consent.append(terms)
            consent.append(AttributedString("."))
            assertSpecimen(
                VStack(alignment: .leading, spacing: 12) {
                    QeetrixLink("Change number") {}
                    QeetrixLink("Why do you need my SIM?", tone: .subtle) {}
                    QeetrixLink("Report a problem", tone: .inherit) {}.foregroundStyle(QeetrixColor.textDanger)
                    QeetrixLink("Read in another language", icon: .globe) {}
                    QeetrixLink("Resend in 0:42") {}.disabled(true)
                    QeetrixLink("A long link that wraps with its words onto a second line", destination: URL(string: "https://qeet.in")!)
                        .frame(width: 200, alignment: .leading)
                    Text(consent.qeetrixLinks()).foregroundStyle(QeetrixColor.textSubtle).qeetrixLinkTone()
                    QeetrixLink("Change number", icon: .arrowLeft) {}.environment(\.layoutDirection, .rightToLeft)
                }
                .qeetrixTextStyle(.bodySm)
            )
        }
    }
#endif
