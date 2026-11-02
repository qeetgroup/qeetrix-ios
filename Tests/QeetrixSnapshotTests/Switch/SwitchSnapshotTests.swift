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
    }
#endif
