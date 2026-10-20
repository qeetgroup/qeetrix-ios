import Qeetrix
import SwiftUI

struct TimelinePage: View {
    var body: some View {
        ComponentPage(
            title: "Timeline",
            summary: "A history of events. Tone is a second channel; the title says what happened. The app orders and words the events."
        ) {
            DemoSection("Activity") {
                QeetrixTimeline {
                    QeetrixTimelineItem(
                        "Invoice paid", time: Text(verbatim: "09:41"), description: Text(verbatim: "INV-2041 · ₹12,400"), tone: .success,
                        icon: .check, label: Text("Succeeded"))
                    QeetrixTimelineItem("Reminder sent", time: Text(verbatim: "Yesterday"), tone: .info, icon: .mail)
                    QeetrixTimelineItem("Label changed", time: Text(verbatim: "Yesterday"), emphasis: .minor)
                    QeetrixTimelineItem("Synced", time: Text(verbatim: "Yesterday"), emphasis: .minor)
                    QeetrixTimelineItem(
                        "Payment failed", time: Text(verbatim: "12 Oct"), description: Text("The card was declined."), tone: .destructive,
                        icon: .circleX, label: Text("Failed"))
                    QeetrixTimelineItem("Invoice created", time: Text(verbatim: "11 Oct"), tone: .brand)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { TimelinePage() }
}
