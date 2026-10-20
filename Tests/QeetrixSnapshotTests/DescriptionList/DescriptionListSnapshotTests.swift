#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Description list snapshots")
    struct DescriptionListSnapshotTests {
        @Test("Horizontal and divided: stacked in compact width, beside in regular width")
        func horizontal() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 24) {
                    QeetrixDescriptionList(isDivided: true) { items }
                    QeetrixDescriptionList(isDivided: true) { items }
                        .environment(\.horizontalSizeClass, .regular)
                }
            )
        }

        @Test("Grid")
        func grid() {
            assertSpecimen(QeetrixDescriptionList(layout: .grid) { items })
        }

        @ViewBuilder
        private var items: some View {
            QeetrixDescriptionItem("Plan", value: Text("Team, billed monthly"))
            QeetrixDescriptionItem("Identifier", value: Text(verbatim: "ws_7f3a9c2e8b1d4f60a5e2c9d71b3f8a04"))
            QeetrixDescriptionItem("Status") { QeetrixBadge("Active", variant: .success) }
        }
    }
#endif
