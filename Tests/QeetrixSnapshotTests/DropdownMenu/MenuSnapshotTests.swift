#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Menu snapshots")
    struct MenuSnapshotTests {
        @Test("Titled and icon-only triggers")
        func triggers() {
            assertSpecimen(
                FlowLayout {
                    QeetrixMenu("Sort", icon: .navigation) { QeetrixMenuItem("Newest") {} }
                    QeetrixMenu("Export", variant: .secondary, size: .sm) { QeetrixMenuItem("CSV") {} }
                    QeetrixMenu(icon: .ellipsis, label: "More actions") { QeetrixMenuItem("Rename", icon: .pencil) {} }
                }
            )
        }
    }
#endif
