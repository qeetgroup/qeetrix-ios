#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Timeline snapshots")
    struct TimelineSnapshotTests {
        @Test("Icon markers, dots, minor events, times and descriptions")
        func events() {
            assertSpecimen(
                QeetrixTimeline {
                    QeetrixTimelineItem(
                        "Invoice paid", time: Text(verbatim: "09:41"), description: Text(verbatim: "INV-2041"), tone: .success, icon: .check
                    )
                    QeetrixTimelineItem("Reminder sent", time: Text(verbatim: "Yesterday"), tone: .info)
                    QeetrixTimelineItem("Label changed", time: Text(verbatim: "Yesterday"), emphasis: .minor)
                    QeetrixTimelineItem("Synced", emphasis: .minor)
                    QeetrixTimelineItem(
                        "Payment failed", time: Text(verbatim: "12 Oct"), description: Text("The card was declined."), tone: .destructive,
                        icon: .circleX)
                }
            )
        }
    }
#endif
