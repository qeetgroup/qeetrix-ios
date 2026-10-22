#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("List item snapshots")
    struct ListItemSnapshotTests {
        // The AX3 image shows the snapshot host's limit, not the row: the host measures the specimen at the
        // default text size and draws it at AX3, so rows that reflow at the accessibility sizes overlap there.
        // In the app they don't — ListItemUITests checks the reflow at an accessibility size.
        @Test("Rows: plain, icon and metadata, avatar and badge, selected, disabled; a section header")
        func rows() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 0) {
                    QeetrixSectionHeader("Documents", description: Text("Shared with the team")) {
                        QeetrixButton("See all", variant: .link, size: .sm) {}
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    QeetrixListItem("Q3 summary")
                    QeetrixSeparator()
                    QeetrixListItem(
                        "Design review", description: Text("Edited by Ravi Kumar"), metadata: Text(verbatim: "860 KB"), icon: .fileText
                    ) {
                        QeetrixBadge("Draft", variant: .secondary)
                    }
                    QeetrixSeparator()
                    QeetrixListItem("Asha Rao", description: Text(verbatim: "asha@example.com")) {
                        QeetrixBadge("Owner", variant: .brand)
                    } leading: {
                        QeetrixAvatar(name: "Asha Rao")
                    }
                    QeetrixSeparator()
                    QeetrixListItem("Roadmap", description: Text("Meera Iyer"), icon: .fileText, isSelected: true)
                    QeetrixSeparator()
                    QeetrixListItem("Archived workspace", description: Text("Read-only"), icon: .folder).disabled(true)
                }
            )
        }
    }
#endif
