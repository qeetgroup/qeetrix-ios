#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Progress snapshots")
    struct ProgressSnapshotTests {
        @Test("Values, sizes, labels and the indeterminate forms")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixProgress("Uploading", value: 0)
                    QeetrixProgress("Uploading", value: 0.4)
                    QeetrixProgress("Uploaded", value: 1)
                    QeetrixProgress("Value hidden", value: 0.65, showsValue: false)
                    ForEach(QeetrixProgressSize.allCases, id: \.self) { size in
                        QeetrixProgress(label: nil, value: 0.3, size: size)
                    }
                    // The Reduce Motion form of an indeterminate bar.
                    QeetrixProgressHatch()
                        .fill(QeetrixProgressTokens.indicator)
                        .frame(height: 8)
                        .background(QeetrixProgressTokens.track)
                        .clipShape(Capsule())
                    ProgressView(value: 0.75)
                        .progressViewStyle(.qeetrix(size: .lg))
                }
            )
        }
    }
#endif
