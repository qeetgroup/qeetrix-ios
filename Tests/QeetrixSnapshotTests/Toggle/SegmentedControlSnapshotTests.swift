#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Segmented control snapshots")
    struct SegmentedControlSnapshotTests {
        static let schemes = [
            QeetrixOption("Light", value: 0),
            QeetrixOption("Dark", value: 1),
            QeetrixOption("System", value: 2),
        ]

        @Test("Each size, the first, middle and last chosen, two segments, a disabled option, disabled, compact density")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(QeetrixControlSize.allCases, id: \.self) { size in
                        QeetrixSegmentedControl("Theme", selection: .constant(0), options: Self.schemes, size: size)
                    }
                    QeetrixSegmentedControl("Theme", selection: .constant(1), options: Self.schemes)
                    QeetrixSegmentedControl("Theme", selection: .constant(2), options: Self.schemes)
                    QeetrixSegmentedControl(
                        "Show", selection: .constant("all"),
                        options: [QeetrixOption("All", value: "all"), QeetrixOption("Pending", value: "pending")])
                    QeetrixSegmentedControl(
                        "Period", selection: .constant(7),
                        options: [
                            QeetrixOption("7 days", value: 7), QeetrixOption("30 days", value: 30),
                            QeetrixOption("90 days", value: 90, isDisabled: true),
                        ])
                    QeetrixSegmentedControl("Theme", selection: .constant(1), options: Self.schemes).disabled(true)
                    QeetrixSegmentedControl("Theme", selection: .constant(0), options: Self.schemes).qeetrixDensity(.compact)
                }
            )
        }

        @Test("Full width: equal shares at each size, a long label truncated, and right to left")
        func fullWidth() {
            let audience = [
                QeetrixOption("Everyone", value: 0), QeetrixOption("My contacts", value: 1), QeetrixOption("Nobody", value: 2),
            ]
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(QeetrixControlSize.allCases, id: \.self) { size in
                        QeetrixSegmentedControl("Who sees it", selection: .constant(1), options: audience, size: size, isFullWidth: true)
                    }
                    QeetrixSegmentedControl(
                        "Who sees it", selection: .constant(0),
                        options: [
                            QeetrixOption("All", value: 0), QeetrixOption("Everyone in my contacts", value: 1),
                            QeetrixOption("Nobody at all, not even me", value: 2),
                        ],
                        isFullWidth: true)
                    QeetrixSegmentedControl("Who sees it", selection: .constant(0), options: audience, isFullWidth: true)
                        .environment(\.layoutDirection, .rightToLeft)
                }
            )
        }
    }
#endif
