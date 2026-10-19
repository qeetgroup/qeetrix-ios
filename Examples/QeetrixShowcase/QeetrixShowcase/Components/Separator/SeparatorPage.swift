import Qeetrix
import SwiftUI

struct SeparatorPage: View {
    var body: some View {
        ComponentPage(
            title: "Separator",
            summary: "A 1 pt rule between groups. Decorative: spacing and headings carry the grouping."
        ) {
            DemoSection("Default") {
                QeetrixText("Profile")
                QeetrixSeparator()
                QeetrixText("Security")
            }
            DemoSection("Muted, between items in a section") {
                VStack(alignment: .leading, spacing: QeetrixSpacing.s) {
                    QeetrixText("MacBook Pro")
                    QeetrixSeparator(variant: .muted)
                    QeetrixText("iPhone")
                    QeetrixSeparator(variant: .muted)
                    QeetrixText("iPad")
                }
            }
            DemoSection("Vertical") {
                HStack(spacing: QeetrixSpacing.m) {
                    QeetrixText("Docs", variant: .small)
                    QeetrixSeparator(.vertical)
                    QeetrixText("API", variant: .small)
                    QeetrixSeparator(.vertical)
                    QeetrixText("Status", variant: .small)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    NavigationStack { SeparatorPage() }
}
