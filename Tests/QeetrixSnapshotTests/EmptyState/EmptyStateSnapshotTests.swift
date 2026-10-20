#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Empty state snapshots")
    struct EmptyStateSnapshotTests {
        @Test("First use with an action; no results, small; no permission; error")
        func variants() {
            assertSpecimen(
                VStack(spacing: 8) {
                    QeetrixEmptyState(
                        "No invoices yet", description: Text("Invoices appear here once you bill a customer."), variant: .firstUse,
                        icon: .fileText
                    ) {
                        QeetrixButton("Create invoice") {}
                    }
                    QeetrixEmptyState("No results", description: Text("Nothing matches “roadmap”."), variant: .noResults, size: .sm)
                    QeetrixEmptyState(
                        "You can't see these reports", description: Text("Ask a workspace admin for access."), variant: .noPermission,
                        size: .sm)
                    QeetrixEmptyState("Couldn't load reports", variant: .error, size: .sm)
                }
            )
        }

        @Test("Data state: the failure branch with a retry")
        func dataStateFailure() {
            assertSpecimen(
                QeetrixDataState(isLoading: false, isEmpty: false, failure: QeetrixDataFailure("Couldn't load members.") {}) {
                    Text("Content")
                } empty: {
                    EmptyView()
                }
            )
        }

        @Test("Data state: the default loading rows")
        func dataStateLoading() {
            assertSpecimen(QeetrixDataLoadingRows(rows: 3))
        }
    }
#endif
