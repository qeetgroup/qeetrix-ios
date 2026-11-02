#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Separator snapshots")
    struct SeparatorSnapshotTests {
        @Test("Every tone, horizontal and vertical")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(QeetrixSeparatorTone.allCases, id: \.self) { tone in
                        QeetrixText(tone.rawValue, size: .sm, tone: .subtle)
                        QeetrixSeparator(tone: tone)
                    }
                    HStack(spacing: 12) {
                        QeetrixText("Invoices")
                        QeetrixSeparator(.vertical, tone: .default)
                        QeetrixText("Payments")
                    }
                    .fixedSize()
                }
            )
        }
    }
#endif
