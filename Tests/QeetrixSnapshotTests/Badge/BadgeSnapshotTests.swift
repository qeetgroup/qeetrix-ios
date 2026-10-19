#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Badge snapshots")
    struct BadgeSnapshotTests {
        @Test("Every variant, with and without an icon")
        func variants() {
            assertSpecimen(
                FlowLayout {
                    ForEach(QeetrixBadgeVariant.allCases, id: \.self) { variant in
                        QeetrixBadge(variant.rawValue, variant: variant)
                    }
                    QeetrixBadge("Paid", variant: .success, icon: .circleCheck)
                    QeetrixBadge("Overdue", variant: .destructive, icon: .circleAlert)
                    QeetrixBadge("Review", variant: .warning, icon: .triangleAlert)
                }
            )
        }
    }
#endif
