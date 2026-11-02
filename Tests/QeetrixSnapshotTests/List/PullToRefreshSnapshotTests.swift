#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Pull to refresh snapshots")
    struct PullToRefreshSnapshotTests {
        /// The refresh control is drawn by iOS, only while the list is pulled, and covered by the
        /// showcase's UI tests: what Qeetrix draws is the list at rest, unchanged by being refreshable.
        @Test("A refreshable plain List of rows, at rest")
        func atRest() {
            assertSpecimen(
                List {
                    Section {
                        QeetrixListItem("Qeet Pay console", description: Text("Bengaluru · MacBook Pro")) {
                            QeetrixListItemIcon(.lock)
                        }
                        QeetrixListItem("Qeet People", description: Text("Pune · iPhone 17")) {
                            QeetrixListItemIcon(.smartphone)
                        }
                    } header: {
                        QeetrixSectionHeader("Pending approvals", isRuled: false)
                    }
                    .listSectionSeparator(.hidden)
                }
                .qeetrixListStyle()
                .qeetrixRefreshable {}
                .frame(height: 240)
            )
        }
    }
#endif
