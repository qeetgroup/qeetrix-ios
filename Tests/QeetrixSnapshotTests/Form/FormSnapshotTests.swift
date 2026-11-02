#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Form snapshots")
    struct FormSnapshotTests {
        @Test("An error summary, a fieldset and the actions")
        func registration() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixErrorSummary(items: [
                        .init(id: "email", message: "Enter a work email") {},
                        .init(id: "pan", message: "Enter the PAN as 10 characters") {},
                    ])
                    QeetrixFieldset("Business details", description: Text("As registered with the tax office.")) {
                        QeetrixTextField("Work email", text: .constant(""), error: "Enter a work email")
                        QeetrixTextField("PAN", text: .constant("ABCDE"), error: "Enter the PAN as 10 characters")
                        QeetrixTextField("Trade name", text: .constant(""), prompt: Text("e.g. Acme Pvt Ltd"), isOptional: true)
                    }
                    QeetrixFormActions {
                        QeetrixButton("Save draft", variant: .ghost, size: .lg) {}
                        QeetrixButton("Register", size: .lg) {}
                    }
                }
            )
        }
    }
#endif
