#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Spinner snapshots")
    struct SpinnerSnapshotTests {
        @Test("Every size, neutral and brand, at rest")
        func sizes() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(QeetrixSpinnerTone.allCases, id: \.self) { tone in
                        HStack(spacing: 16) {
                            ForEach(QeetrixSpinnerSize.allCases, id: \.self) { size in
                                QeetrixSpinner(size: size, tone: tone)
                            }
                        }
                        .foregroundStyle(QeetrixColor.textDefault)
                    }
                }
            )
        }
    }
#endif
