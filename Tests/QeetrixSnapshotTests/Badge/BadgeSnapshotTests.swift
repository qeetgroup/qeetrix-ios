#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Badge snapshots")
    struct BadgeSnapshotTests {
        @Test("Every tone, subtle and solid, both sizes, with an icon")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(QeetrixBadgeVariant.allCases, id: \.self) { variant in
                        FlowLayout {
                            ForEach(QeetrixBadgeTone.allCases, id: \.self) { tone in
                                QeetrixBadge(tone.rawValue.capitalized, tone: tone, variant: variant)
                            }
                        }
                    }
                    FlowLayout {
                        QeetrixBadge("Paid", tone: .success, icon: .circleCheck)
                        QeetrixBadge("Overdue", tone: .danger, variant: .solid, icon: .circleAlert)
                        QeetrixBadge("3", size: .sm)
                        QeetrixBadge("Beta", tone: .brand, size: .sm, icon: .info)
                    }
                    QeetrixBadge("A long status that has to truncate when there is no more room for it", tone: .warning)
                        .frame(maxWidth: 200, alignment: .leading)
                }
            )
        }
    }
#endif
