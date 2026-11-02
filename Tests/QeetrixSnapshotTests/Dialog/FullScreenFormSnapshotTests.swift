#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Full-screen form snapshots")
    struct FullScreenFormSnapshotTests {
        @Test("The Ember line, the bar with Close, the title and Save, and the fields; a long title on its own line")
        func layout() {
            assertSpecimen(
                VStack(spacing: 16) {
                    QeetrixFullScreenForm("New contact", confirm: QeetrixScreenAction("Save") {}) {
                        QeetrixTextField("Name", text: .constant("Asha Rao"))
                        QeetrixTextField("Email", text: .constant(""), prompt: Text("e.g. asha@acme.in"), isOptional: true)
                    }
                    .frame(height: 300)
                    QeetrixFullScreenForm(
                        "Edit the billing address used on every invoice", confirm: QeetrixScreenAction("Save", isLoading: true) {},
                        hasChanges: true
                    ) {
                        QeetrixTextField("Street", text: .constant("12 MG Road"))
                    }
                    .frame(height: 260)
                }
                .padding(.horizontal, -16)
            )
        }

        @Test("A form sheet on a tablet: the Dialog's 24 pt gutter")
        func formSheet() {
            assertSpecimen(
                QeetrixFullScreenForm("Edit address", confirm: QeetrixScreenAction("Save", isDisabled: true) {}) {
                    QeetrixTextField("Street", text: .constant("12 MG Road"))
                    QeetrixTextField("City", text: .constant("Bengaluru"))
                }
                .frame(height: 320)
                .padding(.horizontal, -16)
                .environment(\.horizontalSizeClass, .regular)
            )
        }
    }
#endif
