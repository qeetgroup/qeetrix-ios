#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Checkbox snapshots")
    struct CheckboxSnapshotTests {
        @Test("Unchecked, checked, mixed, with a description, disabled, focus and an invalid group")
        func states() {
            let mixed: [Binding<Bool>] = [.constant(true), .constant(false)]
            assertSpecimen(
                VStack(alignment: .leading, spacing: 0) {
                    QeetrixCheckbox("Email me receipts", isOn: .constant(false))
                    QeetrixCheckbox("Email me receipts", isOn: .constant(true))
                    QeetrixCheckbox("Select all", sources: mixed, isOn: \.self)
                    QeetrixCheckbox("Weekly summary", isOn: .constant(true), description: Text("Every Monday at 9 am."))
                    QeetrixCheckbox("Locked off", isOn: .constant(false)).disabled(true)
                    QeetrixCheckbox("Locked on", isOn: .constant(true), description: Text("Your admin turned this on.")).disabled(true)
                    QeetrixChoiceRow(description: nil, isEnabled: true) {
                        QeetrixCheckboxBox(mark: .checked, isHovered: false, isEnabled: true, isInvalid: false, isFocused: true)
                    } label: {
                        Text("Focused")
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        QeetrixCheckbox("I accept the terms", isOn: .constant(false))
                    }
                    .environment(\.qeetrixGroupIsInvalid, true)
                }
            )
        }
    }
#endif
