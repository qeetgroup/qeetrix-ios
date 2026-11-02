import Qeetrix
import SwiftUI

struct TabsPage: View {
    private enum Section: String { case overview, activity, archive }
    private enum Report: String, CaseIterable { case summary, revenue, usage, invoices, refunds, taxes, payouts, disputes }
    private enum Inbox: String { case all, mentions, settings }

    @State private var section = Section.overview
    @State private var report = Report.summary
    @State private var inbox = Inbox.all
    @State private var period = "month"

    var body: some View {
        ComponentPage(
            title: "Tabs",
            summary: "The views of one context. A 2 pt line under the list and the 3 pt Ember bar under the selected tab, which slides."
        ) {
            DemoSection("Line, the default") {
                QeetrixTabs(
                    selection: $section,
                    tabs: [
                        QeetrixTab("Overview", value: .overview),
                        QeetrixTab("Activity", value: .activity),
                        QeetrixTab("Archive", value: .archive, isDisabled: true),
                    ])
                QeetrixText("Panel: \(section.rawValue)", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("section-panel")
                    .padding(.top, QeetrixSpace.gapMd)
            }
            DemoSection("Wider than the screen") {
                QeetrixTabs(
                    selection: $report,
                    tabs: Report.allCases.map { QeetrixTab($0.rawValue.capitalized, value: $0) })
                QeetrixText("Panel: \(report.rawValue)", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("report-panel")
                    .padding(.top, QeetrixSpace.gapMd)
            }
            DemoSection("Icons and counts") {
                QeetrixTabs(
                    selection: $inbox,
                    tabs: [
                        QeetrixTab("All", value: .all, icon: .inbox),
                        QeetrixTab("Mentions", value: .mentions, icon: .bell, badge: 3),
                        QeetrixTab("Settings", value: .settings, icon: .settings),
                    ])
            }
            DemoSection("Contained, for a few views of one panel") {
                QeetrixTabs(
                    selection: $period,
                    tabs: [QeetrixTab("Week", value: "week"), QeetrixTab("Month", value: "month"), QeetrixTab("Year", value: "year")],
                    variant: .contained)
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
