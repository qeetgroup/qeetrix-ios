#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Sheet snapshots")
    struct SheetSnapshotTests {
        @Test("A drawer layout, and a danger dialog that isn't dismissible")
        func layout() {
            assertSpecimen(
                VStack(spacing: 16) {
                    QeetrixSheetContent("Edit address", description: Text("Used on every invoice.")) {
                        QeetrixTextField("Street", text: .constant("12 MG Road"))
                    } actions: {
                        QeetrixButton("Cancel", variant: .ghost, size: .lg) {}
                        QeetrixButton("Save", size: .lg) {}
                    }
                    .frame(minHeight: 330)
                    .background(QeetrixColor.surfaceOverlay)
                    QeetrixSheetContent("Revoke this API key?", intent: .danger, isDismissible: false) {
                        QeetrixText("Apps using it stop working at once.")
                    } actions: {
                        QeetrixButton("Cancel", variant: .ghost, size: .lg) {}
                        QeetrixButton("Revoke key", tone: .danger, size: .lg) {}
                    }
                    .frame(minHeight: 260)
                    .background(QeetrixColor.surfaceOverlay)
                }
                .environment(\.horizontalSizeClass, .regular)
            )
        }
    }
#endif
