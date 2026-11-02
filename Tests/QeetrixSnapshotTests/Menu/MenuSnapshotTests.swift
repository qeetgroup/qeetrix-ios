#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Menu snapshots")
    struct MenuSnapshotTests {
        @Test("Titled and icon-only triggers")
        func triggers() {
            assertSpecimen(
                FlowLayout {
                    QeetrixMenu("View") {
                        QeetrixMenuItem("Edit", icon: .pencil) {}
                    }
                    QeetrixMenu("Export", icon: .share2, variant: .ghost) {
                        QeetrixMenuItem("Export as CSV") {}
                    }
                    QeetrixMenu(icon: .ellipsis, label: "Actions for Priya Sharma") {
                        QeetrixMenuItem("Remove", icon: .trash, tone: .danger) {}
                    }
                }
            )
        }
    }
#endif
