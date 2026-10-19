#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Tabs snapshots")
    struct TabsSnapshotTests {
        private let tabs = [
            QeetrixTab("Overview", value: 0),
            QeetrixTab("Activity", value: 1, icon: .bell),
            QeetrixTab("Archive", value: 2, isDisabled: true),
        ]

        // The strip is a horizontal scroll view. In the snapshot host its content is measured before the pinned
        // Dynamic Type size applies, so in the AX3 image the contained well keeps its default height while the
        // labels grow. In the app the well grows with the text (checked on the simulator at accessibility sizes).
        @Test("Default and line, selected, with an icon and a disabled tab")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixTabs(selection: .constant(1), tabs: tabs)
                    QeetrixTabs(selection: .constant(0), tabs: tabs, variant: .line)
                }
            )
        }
    }
#endif
