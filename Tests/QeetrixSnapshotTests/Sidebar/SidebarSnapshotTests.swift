#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Sidebar snapshots")
    struct SidebarSnapshotTests {
        private enum Destination: Hashable { case accounts, devices, audit, settings, new }

        /// The rows, as the sidebar column draws them: at rest, current (the Ember bar, the tint, the
        /// filled Ember icon, weight 600), with a count, disabled, and current without a filled drawing.
        @Test("Rows at rest, current, with a count, disabled, and an icon with no filled drawing")
        func rows() {
            let items = [
                QeetrixNavigationItem("Accounts", value: Destination.accounts, icon: .keyRound),
                QeetrixNavigationItem("Devices", value: Destination.devices, icon: .smartphone, badge: 1_284),
                QeetrixNavigationItem("Audit log", value: Destination.audit, icon: .fileText, isDisabled: true),
                QeetrixNavigationItem("Settings", value: Destination.settings, icon: .settings),
            ]
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixSidebarList(selection: .constant(Destination.devices), items: items)
                    QeetrixSidebarList(
                        selection: .constant(Destination.new),
                        items: [QeetrixNavigationItem("New request", value: Destination.new, icon: .plus)])
                }
                .frame(width: 280)
                .background(QeetrixColor.surfaceCanvas)
            )
        }
    }
#endif
