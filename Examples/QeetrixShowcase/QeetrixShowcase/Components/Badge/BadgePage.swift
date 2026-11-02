import Qeetrix
import SwiftUI

struct BadgePage: View {
    var body: some View {
        ComponentPage(
            title: "Badge",
            summary: "A short, static status or count on a pill. The word carries the meaning; the tone only reinforces it."
        ) {
            DemoSection("Subtle tones") {
                FlowLayout {
                    QeetrixBadge("Draft")
                    QeetrixBadge("Beta", tone: .brand)
                    QeetrixBadge("Scheduled", tone: .info)
                    QeetrixBadge("Paid", tone: .success)
                    QeetrixBadge("Pending", tone: .warning)
                    QeetrixBadge("Failed", tone: .danger)
                }
            }
            DemoSection("Solid, for the one status that must stand out") {
                FlowLayout {
                    ForEach(QeetrixBadgeTone.allCases, id: \.self) { tone in
                        QeetrixBadge(tone.rawValue.capitalized, tone: tone, variant: .solid)
                    }
                }
            }
            DemoSection("Small, for tight rows") {
                FlowLayout {
                    QeetrixBadge("3", size: .sm)
                    QeetrixBadge("New", tone: .brand, size: .sm)
                    QeetrixBadge("Overdue", tone: .danger, variant: .solid, size: .sm)
                }
            }
            DemoSection("With an icon") {
                FlowLayout {
                    QeetrixBadge("Verified", tone: .success, icon: .circleCheck)
                    QeetrixBadge("Expiring", tone: .warning, icon: .triangleAlert)
                    QeetrixBadge("Blocked", tone: .danger, variant: .solid, icon: .circleAlert)
                    QeetrixBadge("Private", icon: .lock)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { BadgePage() }
}
