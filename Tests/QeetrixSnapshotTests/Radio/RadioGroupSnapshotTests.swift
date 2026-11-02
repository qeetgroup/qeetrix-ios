#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Radio group snapshots")
    struct RadioGroupSnapshotTests {
        static let options = [
            QeetrixOption("Monthly", value: 1),
            QeetrixOption("Yearly", value: 2, description: Text("Two months free")),
            QeetrixOption("Lifetime", value: 3, isDisabled: true),
        ]

        @Test("Nothing selected, selected, a disabled option, horizontal, an error and a disabled group")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixRadioGroup("Billing cycle", selection: .constant(0), options: Self.options)
                    QeetrixRadioGroup(
                        "Billing cycle", selection: .constant(2), options: Self.options, description: Text("Change it any time."))
                    QeetrixRadioGroup(
                        "Plan", selection: .constant(1), options: [QeetrixOption("Starter", value: 1), QeetrixOption("Team", value: 2)],
                        orientation: .horizontal)
                    QeetrixRadioGroup(
                        "Billing cycle", selection: .constant(0), options: Self.options, error: "Choose how often you're billed")
                    QeetrixRadioGroup("Billing cycle", selection: .constant(3), options: Self.options).disabled(true)
                }
            )
        }
    }
#endif
