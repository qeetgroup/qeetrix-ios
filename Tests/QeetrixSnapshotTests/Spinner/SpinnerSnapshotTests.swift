#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Spinner snapshots")
    struct SpinnerSnapshotTests {
        @Test("Every size, at rest")
        func sizes() {
            assertSpecimen(
                HStack(spacing: 16) {
                    ForEach(QeetrixSpinnerSize.allCases, id: \.self) { size in
                        QeetrixSpinner(size: size)
                    }
                }
            )
        }
    }
#endif
