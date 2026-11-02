#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Tabs snapshots")
    struct TabsSnapshotTests {
        static let tabs = [
            QeetrixTab("Overview", value: 1),
            QeetrixTab("Invoices", value: 2, icon: .inbox, filledWhenSelected: true, badge: 3),
            QeetrixTab("Settings", value: 3, isDisabled: true),
        ]

        @Test("Line and contained, selected, with an icon and a count, and a disabled tab")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 24) {
                    QeetrixTabs(selection: .constant(1), tabs: Self.tabs)
                    QeetrixTabs(selection: .constant(2), tabs: Self.tabs)
                    QeetrixTabs(selection: .constant(1), tabs: Array(Self.tabs.prefix(2)), variant: .contained)
                    QeetrixTabs(selection: .constant(1), tabs: Self.tabs).qeetrixDensity(.compact)
                }
            )
        }
    }
#endif
