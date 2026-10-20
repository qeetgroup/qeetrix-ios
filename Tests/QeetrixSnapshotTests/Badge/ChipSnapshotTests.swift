#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Chip snapshots")
    struct ChipSnapshotTests {
        @Test("Selected and not, with an icon, removable, disabled, three sizes")
        func states() {
            assertSpecimen(
                FlowLayout {
                    QeetrixChip("Unread", isSelected: .constant(true))
                    QeetrixChip("Following", isSelected: .constant(false), icon: .bell)
                    QeetrixChip("Shared", isSelected: .constant(false)).disabled(true)
                    QeetrixChip("Design", icon: .folder) {}
                    QeetrixChip("Small", isSelected: .constant(true), size: .sm)
                    QeetrixChip("Large", isSelected: .constant(false), size: .lg)
                }
            )
        }

        @Test("A single-choice group that wraps")
        func group() {
            assertSpecimen(
                QeetrixChipGroup(
                    "Status", selection: .constant("open"),
                    options: ["All", "Open", "In review", "Closed", "Archived"].map { QeetrixOption($0, value: $0.lowercased()) })
            )
        }
    }
#endif
