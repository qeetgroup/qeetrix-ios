#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Skeleton snapshots")
    struct SkeletonSnapshotTests {
        @Test("Shapes, text lines and a composed row")
        func shapes() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        QeetrixSkeleton(.circle).frame(width: 40, height: 40)
                        QeetrixSkeleton().frame(width: 64, height: 40)
                        QeetrixSkeleton(.capsule).frame(width: 72, height: 24)
                    }
                    QeetrixSkeletonText(lines: 3)
                    HStack(spacing: 12) {
                        QeetrixSkeleton(.circle).frame(width: 32, height: 32)
                        QeetrixSkeletonText(lines: 2, role: .label)
                    }
                }
                // Snapshots run without animation, so the sweep rests outside the shape: the image doesn't
                // depend on timing.
            )
        }
    }
#endif
