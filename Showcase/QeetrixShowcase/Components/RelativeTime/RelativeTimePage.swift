import Qeetrix
import SwiftUI

struct RelativeTimePage: View {
    /// When the page opened: the live rows count from it.
    @State private var opened = Date()
    @State private var refreshed = Date()

    private var fixedNow: Date { Date(timeIntervalSince1970: 1_792_920_600) }  // 2026-10-25T09:30:00Z

    var body: some View {
        ComponentPage(
            title: "Relative time",
            summary:
                "When something happened, as people say it: “2 minutes ago”, “yesterday”, then the date past 30 days. It keeps itself current."
        ) {
            DemoSection("Live") {
                row("Opened") { QeetrixRelativeTime(opened) }
                row("Refreshed") { QeetrixRelativeTime(refreshed, tone: .subtle) }
                QeetrixButton("Refresh now", variant: .ghost, size: .sm) { refreshed = Date() }
            }
            DemoSection("Units, rounded first") {
                ForEach(Self.ages, id: \.self) { age in
                    QeetrixRelativeTime(fixedNow.addingTimeInterval(age), now: fixedNow)
                }
            }
            DemoSection("Past the threshold") {
                row("45 days") { QeetrixRelativeTime(fixedNow.addingTimeInterval(-45 * 86_400), now: fixedNow) }
                row("7-day threshold") {
                    QeetrixRelativeTime(fixedNow.addingTimeInterval(-10 * 86_400), threshold: .seconds(7 * 86_400), now: fixedNow)
                }
            }
            DemoSection("Sizes and tones") {
                QeetrixRelativeTime(fixedNow.addingTimeInterval(-120), now: fixedNow, size: .sm, tone: .subtle)
                QeetrixRelativeTime(fixedNow.addingTimeInterval(-120), now: fixedNow)
                QeetrixRelativeTime(fixedNow.addingTimeInterval(-120), now: fixedNow, size: .lg, weight: .semibold)
            }
            DemoSection("In other locales") {
                ForEach(["en-IN", "en-US", "hi-IN", "ta-IN", "ar-EG"], id: \.self) { identifier in
                    row(identifier) {
                        QeetrixRelativeTime(fixedNow.addingTimeInterval(-26 * 3600), now: fixedNow)
                            .environment(\.locale, Locale(identifier: identifier))
                    }
                }
            }
        }
    }

    /// The moments of the “units” section, from 40 seconds ago to next year.
    private static let ages: [TimeInterval] = [-40, -59 * 60 - 40, -5 * 3600, -26 * 3600, -6.6 * 86_400, -32 * 86_400, 3 * 86_400]

    private func row<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: QeetrixSpace.gapMd) {
                QeetrixText(label, tone: .subtle)
                content()
            }
            VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                QeetrixText(label, tone: .subtle)
                content()
            }
        }
    }
}

#Preview {
    NavigationStack { RelativeTimePage() }
}
