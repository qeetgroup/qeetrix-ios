import Qeetrix
import SwiftUI

struct SeparatorPage: View {
    var body: some View {
        ComponentPage(
            title: "Separator",
            summary: "A 1 pt rule between groups. Decorative by default: spacing and headings carry the grouping."
        ) {
            DemoSection("Subtle, the default") {
                VStack(alignment: .leading, spacing: QeetrixSpace.gapSm) {
                    QeetrixText("MacBook Pro")
                    QeetrixSeparator()
                    QeetrixText("iPhone")
                    QeetrixSeparator()
                    QeetrixText("iPad")
                }
            }
            DemoSection("Default and strong") {
                QeetrixText("Profile")
                QeetrixSeparator(tone: .default)
                QeetrixText("Security")
                QeetrixSeparator(tone: .strong)
                QeetrixText("Billing")
            }
            DemoSection("Vertical") {
                HStack(spacing: QeetrixSpace.gapMd) {
                    QeetrixText("Docs", size: .sm)
                    QeetrixSeparator(.vertical, tone: .default)
                    QeetrixText("API", size: .sm)
                    QeetrixSeparator(.vertical, tone: .default)
                    QeetrixText("Status", size: .sm)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    NavigationStack { SeparatorPage() }
}
