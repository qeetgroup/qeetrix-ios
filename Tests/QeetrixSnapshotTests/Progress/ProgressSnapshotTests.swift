#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Progress snapshots")
    struct ProgressSnapshotTests {
        @Test("Every tone, with and without the value, and indeterminate at rest")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixProgress("Uploading invoices", value: 0.4, showsValue: true)
                    QeetrixProgress("Import complete", value: 1, tone: .success, showsValue: true)
                    QeetrixProgress("Import failed", value: 0.62, tone: .danger)
                    QeetrixProgress(label: nil, value: 0.25)
                    QeetrixProgress("Preparing export", value: nil)
                }
            )
        }
    }
#endif
