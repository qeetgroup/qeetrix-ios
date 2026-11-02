#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Popover snapshots")
    struct PopoverSnapshotTests {
        @Test("The surface with a title, a description and content")
        func surface() {
            assertSpecimen(
                QeetrixPopoverSurface(title: Text("Roles"), description: Text("Who can do what."), compactAdaptation: .popover) {
                    QeetrixText("Admins can invite members and manage billing. Members can view invoices.")
                    QeetrixButton("Manage roles", variant: .ghost, size: .sm) {}
                }
                .background(QeetrixColor.surfaceOverlay)
                .overlay { RoundedRectangle(cornerRadius: QeetrixRadius.overlay).strokeBorder(QeetrixColor.borderSubtle) }
            )
        }
    }
#endif
