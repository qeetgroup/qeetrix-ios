#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    private struct Item: Identifiable, Sendable {
        let id: Int
        let isOn: Bool
    }

    @MainActor
    @Suite("Checkbox snapshots")
    struct CheckboxSnapshotTests {
        @Test("Unchecked, checked, mixed, with a description, disabled, and an invalid group")
        func states() {
            let items = [Binding.constant(true), Binding.constant(false)]
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    VStack(spacing: 0) {
                        QeetrixCheckbox("Unchecked", isOn: .constant(false))
                        QeetrixCheckbox("Checked", isOn: .constant(true))
                        QeetrixCheckbox("Mixed", sources: items, isOn: \.self)
                        QeetrixCheckbox("With a description", isOn: .constant(true), description: Text("Shown under the label."))
                        QeetrixCheckbox("Disabled", isOn: .constant(true)).disabled(true)
                    }
                    QeetrixFieldSet("Notifications", message: QeetrixFieldMessage(.error, text: "Choose at least one.")) {
                        QeetrixCheckbox("Email", isOn: .constant(false))
                        QeetrixCheckbox("Push", isOn: .constant(false))
                    }
                }
            )
        }
    }
#endif
