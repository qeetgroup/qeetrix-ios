import Qeetrix
import SwiftUI

struct SegmentedControlPage: View {
    private enum Filter: String { case all, pending }
    private enum Scheme: String { case light, dark, system }
    private enum Audience: String { case everyone, contacts, nobody }

    @State private var filter = Filter.all
    @State private var scheme = Scheme.system
    @State private var period = 30
    @State private var audience = Audience.contacts

    var body: some View {
        ComponentPage(
            title: "Segmented control",
            summary:
                "One choice among a few that applies at once: one joined control, ruled between its segments, the chosen one in warm graphite."
        ) {
            DemoSection("A filter") {
                QeetrixSegmentedControl(
                    "Show", selection: $filter,
                    options: [QeetrixOption("All", value: .all), QeetrixOption("Pending", value: .pending)])
                QeetrixText("Showing: \(filter.rawValue)", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("segmented-filter")
            }
            DemoSection("A short setting") {
                QeetrixSegmentedControl(
                    "Theme", selection: $scheme,
                    options: [
                        QeetrixOption("Light", value: .light), QeetrixOption("Dark", value: .dark), QeetrixOption("System", value: .system),
                    ])
            }
            DemoSection("Across the row") {
                // A profile field's "Who sees it": three equal parts across the field, at sm.
                QeetrixSegmentedControl(
                    "Who sees it", selection: $audience,
                    options: [
                        QeetrixOption("Everyone", value: .everyone), QeetrixOption("My contacts", value: .contacts),
                        QeetrixOption("Nobody", value: .nobody),
                    ],
                    size: .sm, isFullWidth: true)
                QeetrixText("Who sees it: \(audience.rawValue)", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("segmented-audience")
            }
            DemoSection("Sizes") {
                ForEach(QeetrixControlSize.allCases, id: \.self) { size in
                    QeetrixSegmentedControl(
                        "Period", selection: $period,
                        options: [
                            QeetrixOption("7 days", value: 7), QeetrixOption("30 days", value: 30), QeetrixOption("90 days", value: 90),
                        ],
                        size: size)
                }
            }
            DemoSection("A disabled option, and disabled") {
                QeetrixSegmentedControl(
                    "Period", selection: $period,
                    options: [
                        QeetrixOption("7 days", value: 7), QeetrixOption("30 days", value: 30),
                        QeetrixOption("90 days", value: 90, description: Text("On the Growth plan"), isDisabled: true),
                    ])
                QeetrixSegmentedControl(
                    "Theme", selection: $scheme,
                    options: [
                        QeetrixOption("Light", value: .light), QeetrixOption("Dark", value: .dark), QeetrixOption("System", value: .system),
                    ]
                )
                .disabled(true)
            }
            DemoSection("Compact density") {
                QeetrixSegmentedControl(
                    "Show", selection: $filter,
                    options: [QeetrixOption("All", value: .all), QeetrixOption("Pending", value: .pending)]
                )
                .qeetrixDensity(.compact)
            }
        }
    }
}

#Preview {
    NavigationStack { SegmentedControlPage() }
}
