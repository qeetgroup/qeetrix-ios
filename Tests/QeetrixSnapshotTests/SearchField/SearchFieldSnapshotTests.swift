#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Search field snapshots")
    struct SearchFieldSnapshotTests {
        @Test("Empty with a prompt, with text and Clear search, labelled with help, read-only and disabled")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    QeetrixSearchField(text: .constant(""), prompt: Text("e.g. Asha"))
                    QeetrixSearchField(text: .constant("Asha"))
                    QeetrixSearchField("Find a member", text: .constant("asha@acme.in"), description: Text("Name or email."))
                    QeetrixSearchField(text: .constant("Asha"), isReadOnly: true)
                    QeetrixSearchField(text: .constant("Asha")).disabled(true)
                }
            )
        }
    }
#endif
