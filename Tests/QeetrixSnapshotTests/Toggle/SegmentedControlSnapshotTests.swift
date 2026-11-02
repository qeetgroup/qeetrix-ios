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
    }
#endif
