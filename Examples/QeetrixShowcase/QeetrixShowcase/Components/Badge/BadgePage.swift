import Qeetrix
import SwiftUI

struct BadgePage: View {
    var body: some View {
        ComponentPage(
            title: "Badge",
            summary: "A small label for a count, a status or a category."
        ) {
            DemoSection("Variants") {
                FlowLayout {
                    QeetrixBadge("New")
                    QeetrixBadge("Draft", variant: .secondary)
                    QeetrixBadge("v2.1", variant: .outline)
                    QeetrixBadge("Beta", variant: .brand)
                    QeetrixBadge("Info", variant: .info)
                    QeetrixBadge("Paid", variant: .success)
                    QeetrixBadge("Pending", variant: .warning)
                    QeetrixBadge("Failed", variant: .destructive)
                    QeetrixBadge("Archived", variant: .muted)
                }
            }
            DemoSection("With an icon") {
                FlowLayout {
                    QeetrixBadge("Verified", variant: .success, icon: .circleCheck)
                    QeetrixBadge("Expiring", variant: .warning, icon: .triangleAlert)
                    QeetrixBadge("Blocked", variant: .destructive, icon: .circleAlert)
                    QeetrixBadge("Private", variant: .secondary, icon: .lock)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { BadgePage() }
}
