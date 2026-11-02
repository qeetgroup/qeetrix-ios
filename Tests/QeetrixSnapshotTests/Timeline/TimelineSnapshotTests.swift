#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Timeline snapshots")
    struct TimelineSnapshotTests {
        @Test("Grouped events in every tone, joined by their line and broken between groups")
        func grouped() {
            assertSpecimen(
                QeetrixTimeline {
                    QeetrixTimelineGroup("Today") {
                        QeetrixTimelineItem(
                            "Signed in with a passkey", description: "Bengaluru · Safari on iPhone", time: Text("2 min ago"),
                            icon: .keyRound)
                        QeetrixTimelineItem(
                            "Sign-in refused", description: "An unknown device in Pune, from a browser not seen before",
                            time: Text("1 h ago"),
                            icon: .circleX, tone: .danger)
                        QeetrixTimelineItem("New phone linked", time: Text("3 h ago"), icon: .smartphone, tone: .success)
                        QeetrixTimelineItem("Recovery codes viewed", time: Text("4 h ago"), icon: .info, tone: .info)
                    }
                    QeetrixTimelineGroup("Yesterday") {
                        QeetrixTimelineItem("Passkey added", time: Text("18:02"), icon: .keyRound, tone: .brand)
                        QeetrixTimelineItem(
                            "Sign-in from a new place", description: "Mumbai", time: Text("09:15"), icon: .mapPin, tone: .warning)
                        QeetrixTimelineItem("Session ended", time: Text("08:40"))
                    }
                }
            )
        }

        @Test("Compact: minor events as dots, no line")
        func compact() {
            assertSpecimen(
                QeetrixTimeline(variant: .compact) {
                    QeetrixTimelineItem("Approved on iPhone", time: Text("2 min ago"), tone: .success)
                    QeetrixTimelineItem("Approval requested", description: "Qeet Pay, Bengaluru", time: Text("3 min ago"))
                    QeetrixTimelineItem("Refused on iPad", time: Text("1 h ago"), tone: .danger)
                }
            )
        }
    }
#endif
