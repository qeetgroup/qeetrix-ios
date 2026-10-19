import Qeetrix
import SwiftUI

struct TabsPage: View {
    private enum Section: String { case overview, activity, archive }
    private enum Report: String, CaseIterable { case summary, revenue, usage, invoices, refunds, taxes, payouts, disputes }

    @State private var section = Section.overview
    @State private var report = Report.summary
    @State private var period = "month"

    var body: some View {
        ComponentPage(
            title: "Tabs",
            summary: "Switches between panels of related content in one place. The page owns the selection; the strip only selects."
        ) {
            DemoSection("Contained") {
                QeetrixTabs(
                    selection: $section,
                    tabs: [
                        QeetrixTab("Overview", value: .overview),
                        QeetrixTab("Activity", value: .activity, icon: .bell),
                        QeetrixTab("Archive", value: .archive, isDisabled: true),
                    ])
                QeetrixText("Panel: \(section.rawValue)", variant: .muted)
                    .accessibilityIdentifier("section-panel")
                    .padding(.top, QeetrixSpacing.m)
            }
            DemoSection("Line, wider than the screen") {
                QeetrixTabs(
                    selection: $report,
                    tabs: Report.allCases.map { QeetrixTab($0.rawValue.capitalized, value: $0) },
                    variant: .line)
                QeetrixText("Panel: \(report.rawValue)", variant: .muted)
                    .accessibilityIdentifier("report-panel")
                    .padding(.top, QeetrixSpacing.m)
            }
            DemoSection("Compact density") {
                QeetrixTabs(
                    selection: $period,
                    tabs: [QeetrixTab("Week", value: "week"), QeetrixTab("Month", value: "month"), QeetrixTab("Year", value: "year")]
                )
                .qeetrixDensity(.compact)
            }
        }
    }
}

#Preview {
    NavigationStack { TabsPage() }
}
