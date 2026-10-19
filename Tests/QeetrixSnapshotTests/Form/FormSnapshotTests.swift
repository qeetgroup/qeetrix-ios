#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Form snapshots")
    struct FormSnapshotTests {
        @Test("An error summary, a field set and the actions")
        func registration() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 24) {
                    QeetrixFormErrorSummary(errors: [
                        .init(id: "name", message: "Enter your name.") {},
                        .init(id: "email", message: "Enter an email address with an @.") {},
                    ])
                    QeetrixFieldSet("Your details") {
                        QeetrixTextField(
                            "Full name", text: .constant(""), message: QeetrixFieldMessage(.error, text: "Enter your name."),
                            isRequired: true)
                        QeetrixSwitch("Weekly digest", isOn: .constant(true))
                        QeetrixSwitch("Mentions", isOn: .constant(false))
                    }
                    QeetrixFormActions {
                        QeetrixButton("Reset", variant: .outline) {}
                        QeetrixButton("Create account") {}
                    }
                }
            )
        }
    }
#endif
