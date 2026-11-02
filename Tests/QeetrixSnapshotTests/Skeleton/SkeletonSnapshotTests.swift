#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Skeleton snapshots")
    struct SkeletonSnapshotTests {
        /// The shapes at rest, without the pulse: the harness disables animations, which would leave a
        /// pulsing skeleton at 45% rather than at either end of its cycle.
        @Test("An account row, a line, a block, a paragraph and every circle, at rest")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 12) {
                        QeetrixSkeletonSingle(variant: .circle, size: .lg, height: nil)
                        QeetrixSkeletonLines(count: 2, role: .bodyMd)
                    }
                    QeetrixSkeletonSingle(variant: .text, size: .md, height: nil).frame(width: 160)
                    QeetrixSkeletonSingle(variant: .block, size: .md, height: nil)
                    QeetrixSkeletonLines(count: 3, role: .bodyMd)
                    HStack(spacing: 12) {
                        ForEach(QeetrixSkeletonSize.allCases, id: \.self) { size in
                            QeetrixSkeletonSingle(variant: .circle, size: size, height: nil)
                        }
                    }
                }
            )
        }
    }
#endif
