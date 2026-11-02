import Qeetrix
import SwiftUI

struct TimelinePage: View {
    var body: some View {
        ComponentPage(
            title: "Timeline",
            summary: "What happened, newest first: a 28 pt marker per event joined by a line, failures in the danger colour."
        ) {
            DemoSection("Sign-in activity") {
                QeetrixTimeline {
                    QeetrixTimelineGroup("Today") {
                        QeetrixTimelineItem(
                            "Signed in with a passkey", description: "Bengaluru · Safari on iPhone", time: Text("2 min ago"),
                            icon: .keyRound)
                        QeetrixTimelineItem(
                            "Sign-in refused", description: "Unknown device in Pune", time: Text("1 h ago"), icon: .circleX, tone: .danger)
                        QeetrixTimelineItem("New phone linked", time: Text("3 h ago"), icon: .smartphone, tone: .success)
                    }
                    QeetrixTimelineGroup("Yesterday") {
                        QeetrixTimelineItem("Passkey added", time: Text("18:02"), icon: .keyRound, tone: .brand)
                        QeetrixTimelineItem(
                            "Sign-in from a new place", description: "Mumbai · Chrome on macOS", time: Text("09:15"), icon: .mapPin,
                            tone: .warning)
                        QeetrixTimelineItem("Recovery codes viewed", time: Text("08:40"), icon: .info, tone: .info)
                    }
                }
            }
            DemoSection("Critical audit events") {
                QeetrixCard(title: Text("Critical events")) {
                    QeetrixTimeline {
                        QeetrixTimelineItem(
                            "Admin role granted", description: "By Rahul Verma",
                            time: Text(.now.addingTimeInterval(-600), style: .relative), icon: .userPlus, tone: .warning)
                        QeetrixTimelineItem(
                            "Directory sync failed", description: "SAML certificate expired", time: Text("Yesterday"), icon: .circleAlert,
                            tone: .danger)
                        QeetrixTimelineItem("Signing key rotated", time: Text("12 Oct"), icon: .keyRound)
                    }
                }
            }
            DemoSection("Compact: minor events") {
                QeetrixTimeline(variant: .compact) {
                    QeetrixTimelineItem("Approved on iPhone", time: Text("2 min ago"), tone: .success)
                    QeetrixTimelineItem("Approval requested", description: "Qeet Pay, Bengaluru", time: Text("3 min ago"))
                    QeetrixTimelineItem("Refused on iPad", time: Text("1 h ago"), tone: .danger)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { TimelinePage() }
}
