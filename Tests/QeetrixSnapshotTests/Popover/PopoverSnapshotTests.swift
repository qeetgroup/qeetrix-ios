#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Popover snapshots")
    struct PopoverSnapshotTests {
        @Test("Content on the popover surface")
        func surface() {
            assertSpecimen(
                QeetrixPopoverSurface(compactAdaptation: .popover) {
                    Text("Roles").qeetrixTextStyle(.label)
                    Text("Admins can invite members and manage billing. Members can view and edit projects.")
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: 288)
                // The system draws the presentation background; here it is drawn as the popover's surface.
                .background(QeetrixPopoverTokens.background, in: RoundedRectangle(cornerRadius: QeetrixPopoverTokens.corner))
            )
        }
    }
#endif
