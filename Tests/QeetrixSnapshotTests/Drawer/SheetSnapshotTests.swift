#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Sheet snapshots")
    struct SheetSnapshotTests {
        @Test("Header, content and actions")
        func layout() {
            assertSpecimen(
                QeetrixSheetContent("Edit profile", description: Text("Your team sees these details.")) {
                    QeetrixTextField("Display name", text: .constant("Asha Rao"))
                } actions: {
                    QeetrixButton("Cancel", variant: .outline) {}
                    QeetrixButton("Save") {}
                }
                .frame(height: 400)
            )
        }
    }
#endif
