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

        @Test("Without a visible label: off, on, mixed, disabled and in an invalid group, the box alone beside a card's words")
        func bare() {
            let mixed: [Binding<Bool>] = [.constant(true), .constant(false)]
            let label = Text("Also report Meera")
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        QeetrixCheckbox(isOn: .constant(false), accessibilityLabel: label)
                        QeetrixCheckbox(isOn: .constant(true), accessibilityLabel: label)
                        QeetrixCheckbox(sources: mixed, isOn: \.self, accessibilityLabel: Text("All"))
                        QeetrixCheckbox(isOn: .constant(true), accessibilityLabel: label).disabled(true)
                        QeetrixCheckbox(isOn: .constant(false), accessibilityLabel: label).environment(\.qeetrixGroupIsInvalid, true)
                    }
                    HStack(alignment: .top, spacing: QeetrixSpace.gapMd) {
                        QeetrixCheckbox(isOn: .constant(true), accessibilityLabel: label)
                        VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                            Text("Also report Meera").qeetrixTextStyle(.bodyMd, weight: .medium)
                            Text("We'll look at the last 20 messages.").qeetrixTextStyle(.bodySm).foregroundStyle(QeetrixColor.textSubtle)
                        }
                    }
                }
            )
        }
    }
#endif
