#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Switch snapshots")
    struct SwitchSnapshotTests {
        @Test("On and off, both sizes, disabled")
        func variants() {
            assertSpecimen(
                VStack(spacing: 0) {
                    QeetrixSwitch("Email notifications", isOn: .constant(true))
                    QeetrixSwitch("Push notifications", isOn: .constant(false))
                    QeetrixSwitch("Small, on", isOn: .constant(true), size: .sm)
                    QeetrixSwitch("Small, off", isOn: .constant(false), size: .sm)
                    QeetrixSwitch("Disabled, on", isOn: .constant(true)).disabled(true)
                    QeetrixSwitch("Disabled, off", isOn: .constant(false)).disabled(true)
                }
            )
        }
    }
#endif
