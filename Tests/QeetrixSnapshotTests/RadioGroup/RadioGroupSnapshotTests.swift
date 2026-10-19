#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Radio group snapshots")
    struct RadioGroupSnapshotTests {
        private let options: [QeetrixOption<String?>] = [
            QeetrixOption("Starter", value: "starter", description: Text("For individuals")),
            QeetrixOption("Team", value: "team", description: Text("Up to 25 members")),
            QeetrixOption("Enterprise", value: "enterprise", isDisabled: true),
        ]

        @Test("Nothing selected, selected, a disabled option and an error")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixRadioGroup("Plan", selection: .constant(nil), options: options, isRequired: true)
                    QeetrixRadioGroup("Plan", selection: .constant("team"), options: options)
                    QeetrixRadioGroup(
                        "Plan", selection: .constant(nil), options: options,
                        message: QeetrixFieldMessage(.error, text: "Choose a plan."))
                }
            )
        }
    }
#endif
