#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Steps snapshots")
    struct StepsSnapshotTests {
        @Test("Across the screen: done, current and upcoming; failed and attention")
        func horizontal() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 24) {
                    QeetrixSteps([QeetrixStep("Account"), QeetrixStep("Phone"), QeetrixStep("Passkey")], current: 1)
                    QeetrixSteps(
                        [QeetrixStep("Connect"), QeetrixStep("Verify", status: .failed), QeetrixStep("Review", status: .attention)],
                        current: 2)
                    QeetrixSteps([QeetrixStep("Account"), QeetrixStep("Phone"), QeetrixStep("Passkey")], current: 3)
                }
            )
        }

        @Test("Compact where the labels don't fit: Step 2 of 4, the current step and the bar")
        func compact() {
            assertSpecimen(
                QeetrixSteps(
                    [
                        QeetrixStep("Create your account"), QeetrixStep("Verify your phone number"), QeetrixStep("Add a passkey"),
                        QeetrixStep("Finish"),
                    ], current: 1)
            )
        }

        @Test("Vertical, with descriptions and a failed check")
        func vertical() {
            assertSpecimen(
                QeetrixSteps(
                    [
                        QeetrixStep("Connect the directory", description: "Okta, over SAML"),
                        QeetrixStep("Map attributes", description: "Email and name"),
                        QeetrixStep("Test a sign-in", status: .failed),
                        QeetrixStep("Go live"),
                    ], current: 2, orientation: .vertical)
            )
        }
    }
#endif
