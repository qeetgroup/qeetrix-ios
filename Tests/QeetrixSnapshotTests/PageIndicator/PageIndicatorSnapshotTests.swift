#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Page indicator snapshots")
    struct PageIndicatorSnapshotTests {
        @Test("The first, a middle and the last page current; two pages, one, eight; disabled")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 0) {
                    QeetrixPageIndicator(page: .constant(0), count: 4)
                    QeetrixPageIndicator(page: .constant(1), count: 4)
                    QeetrixPageIndicator(page: .constant(3), count: 4)
                    QeetrixPageIndicator(page: .constant(1), count: 2)
                    QeetrixPageIndicator(page: .constant(0), count: 1)
                    QeetrixPageIndicator(page: .constant(5), count: 8)
                    QeetrixPageIndicator(page: .constant(2), count: 4).disabled(true)
                }
            )
        }
    }
#endif
