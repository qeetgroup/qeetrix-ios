#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Switch snapshots")
    struct SwitchSnapshotTests {
        @Test("Off, on, with a description, disabled off and on, and focus")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 0) {
                    QeetrixSwitch("Auto-renew", isOn: .constant(false))
                    QeetrixSwitch("Auto-renew", isOn: .constant(true))
                    QeetrixSwitch("Two-step sign-in", isOn: .constant(true), description: Text("A code by SMS at each sign-in."))
                    QeetrixSwitch("Locked off", isOn: .constant(false)).disabled(true)
                    QeetrixSwitch("Locked on", isOn: .constant(true)).disabled(true)
                    QeetrixChoiceRow(description: nil, isEnabled: true) {
                        QeetrixSwitchTrack(isOn: true, isHovered: false, isEnabled: true, isFocused: true)
                    } label: {
                        Text("Focused")
                    }
                }
            )
        }

        @Test("Without a visible label: off, on and disabled, the track alone at the end of a settings row")
        func bare() {
            let label = Text("Unlock with Face ID")
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        QeetrixSwitch(isOn: .constant(false), accessibilityLabel: label)
                        QeetrixSwitch(isOn: .constant(true), accessibilityLabel: label)
                        QeetrixSwitch(isOn: .constant(true), accessibilityLabel: label).disabled(true)
                    }
                    HStack(spacing: QeetrixSpace.gapMd) {
                        VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                            Text("Unlock with Face ID").qeetrixTextStyle(.bodyMd)
                            Text("Asks for your face before it shows a code.").qeetrixTextStyle(.bodySm)
                                .foregroundStyle(QeetrixColor.textSubtle)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        QeetrixSwitch(isOn: .constant(true), accessibilityLabel: label)
                    }
                }
            )
        }
    }
#endif
