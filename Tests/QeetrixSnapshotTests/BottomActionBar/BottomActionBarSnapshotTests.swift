#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Bottom action bar snapshots")
    struct BottomActionBarSnapshotTests {
        @Test("One action; two side by side; two stacked; busy, unavailable and destructive; the rule")
        func phone() {
            assertSpecimen(
                VStack(spacing: 16) {
                    QeetrixBottomActionBar(primary: QeetrixScreenAction("Pay ₹1,200") {}, secondary: nil, showsRule: false)
                    QeetrixBottomActionBar(
                        primary: QeetrixScreenAction("Pay", icon: .lock) {}, secondary: QeetrixScreenAction("Later") {}, showsRule: true)
                    QeetrixBottomActionBar(
                        primary: QeetrixScreenAction("Pay ₹1,20,000 now with UPI") {},
                        secondary: QeetrixScreenAction("Save this invoice for later") {}, showsRule: true)
                    QeetrixBottomActionBar(
                        primary: QeetrixScreenAction("Paying", isLoading: true) {},
                        secondary: QeetrixScreenAction("Later", isDisabled: true) {}, showsRule: false)
                    QeetrixBottomActionBar(primary: QeetrixScreenAction("Remove member", tone: .danger) {}, secondary: nil, showsRule: true)
                }
                .padding(.horizontal, -16)
            )
        }

        @Test("A ghost tertiary under the primary, with long labels, and a tertiary alone")
        func tertiary() {
            assertSpecimen(
                VStack(spacing: 16) {
                    QeetrixBottomActionBar(
                        primary: QeetrixScreenAction("Continue") {}, secondary: nil,
                        tertiary: QeetrixScreenAction("Not now", tone: .neutral) {}, showsRule: true)
                    QeetrixBottomActionBar(
                        primary: QeetrixScreenAction("Scan the code", icon: .scanQrCode) {}, secondary: nil,
                        tertiary: QeetrixScreenAction("Type the code instead") {}, showsRule: false)
                    QeetrixBottomActionBar(
                        primary: nil, secondary: nil, tertiary: QeetrixScreenAction("Done", tone: .neutral) {}, showsRule: true)
                }
                .padding(.horizontal, -16)
            )
        }

        @Test("Regular width: a primary over a tertiary at the end, at the wider one's width")
        func tertiaryTablet() {
            assertSpecimen(
                QeetrixBottomActionBar(
                    primary: QeetrixScreenAction("Continue") {}, secondary: nil,
                    tertiary: QeetrixScreenAction("Type the code instead", tone: .neutral) {}, showsRule: true
                )
                .padding(.horizontal, -16)
                .environment(\.horizontalSizeClass, .regular)
            )
        }

        @Test("Regular width: the actions at their own widths, at the end")
        func tablet() {
            assertSpecimen(
                QeetrixBottomActionBar(
                    primary: QeetrixScreenAction("Pay ₹1,200") {}, secondary: QeetrixScreenAction("Save for later") {}, showsRule: true
                )
                .padding(.horizontal, -16)
                .environment(\.horizontalSizeClass, .regular)
            )
        }
    }
#endif
