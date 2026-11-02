#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Chip snapshots")
    struct ChipSnapshotTests {
        static let statuses = [
            QeetrixOption("All", value: 0),
            QeetrixOption("Open", value: 1),
            QeetrixOption("Closed", value: 2),
            QeetrixOption("Archived", value: 3, isDisabled: true),
        ]

        @Test("Selectable off, chosen, with an icon, disabled off and on, focused; removable, with an icon, disabled; three sizes")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 12) {
                    QeetrixChipFlowLayout {
                        QeetrixChip("Unread", isSelected: .constant(false))
                        QeetrixChip("Unread", isSelected: .constant(true))
                        QeetrixChip("Mentions", isSelected: .constant(true), icon: .bell)
                        QeetrixChip("Starred", isSelected: .constant(false)).disabled(true)
                        QeetrixChip("Starred", isSelected: .constant(true)).disabled(true)
                        QeetrixChipContent(mark: nil, metrics: QeetrixChipMetrics(size: .md, density: .default)) { Text("Focused") }
                            .modifier(
                                QeetrixChipFrame(
                                    metrics: QeetrixChipMetrics(size: .md, density: .default),
                                    colors: QeetrixChipColors.colors(isSelected: false, isRemovable: false, state: .resting),
                                    isFocused: true))
                    }
                    QeetrixChipFlowLayout {
                        QeetrixChip("Status: Active") {}
                        QeetrixChip("Team: Finance", icon: .userRound) {}
                        QeetrixChip("Plan: Growth") {}.disabled(true)
                    }
                    QeetrixChipFlowLayout {
                        ForEach(QeetrixControlSize.allCases, id: \.self) { size in
                            QeetrixChip(size.rawValue, isSelected: .constant(true), size: size)
                        }
                        ForEach(QeetrixControlSize.allCases, id: \.self) { size in
                            QeetrixChip(size.rawValue, size: size) {}
                        }
                    }
                    QeetrixChip("Invoices overdue by more than thirty days, across every customer", isSelected: .constant(true))
                }
            )
        }

        @Test("Groups: one value, several, wrapping onto more lines and scrolling sideways")
        func groups() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 12) {
                    QeetrixChipGroup("Status", selection: .constant(1), options: Self.statuses, size: .sm)
                    QeetrixChipGroup(
                        "Departments", selection: .constant(Set([1, 2])),
                        options: ["Engineering", "Finance", "Design", "Sales", "Support", "Legal", "People"].enumerated().map {
                            QeetrixOption($0.element, value: $0.offset)
                        })
                    QeetrixChipGroup("Status", selection: .constant(0), options: Self.statuses, overflow: .scroll)
                        .frame(width: 200)
                    QeetrixChipGroup("Status", selection: .constant(1), options: Self.statuses).qeetrixDensity(.compact)
                }
            )
        }
    }
#endif
