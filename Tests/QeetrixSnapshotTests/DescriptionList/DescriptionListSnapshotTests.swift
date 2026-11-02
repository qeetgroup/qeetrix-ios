#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Description list snapshots")
    struct DescriptionListSnapshotTests {
        /// The specimen is 358 pt wide, under 24 rem, so `rows` stack their terms above their values, as
        /// on a phone in portrait.
        @Test("Rows on a phone: text, a badge, an empty value, a description and an action")
        func rows() {
            assertSpecimen(specimen)
        }

        /// At the smallest text size a rem is about 13 pt, so 24 rem fits the specimen and the terms sit
        /// beside their values, as on an iPad. The text size is the specimen's own, so its `ax3` image
        /// is the same size as the others.
        @Test("Rows where there is room: the term beside its value, on its first line")
        func wideRows() {
            assertSpecimen(specimen.environment(\.dynamicTypeSize, .xSmall))
        }

        @Test("Columns: two, and three where there is room")
        func columns() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 24) {
                    QeetrixDescriptionList(layout: .columns) {
                        QeetrixDescriptionItem("Actor", value: "priya@acme.in")
                        QeetrixDescriptionItem("Event", value: "Signed in")
                        QeetrixDescriptionItem("IP address", value: "203.0.113.24")
                        QeetrixDescriptionItem("Time", value: "30 Oct 2026, 10:42")
                    }
                    QeetrixDescriptionList(layout: .columns, columns: 3) {
                        QeetrixDescriptionItem("App", value: "Qeet Pay")
                        QeetrixDescriptionItem("Status") { QeetrixBadge("Approved", tone: .success) }
                        QeetrixDescriptionItem("Place", value: nil)
                    }
                }
            )
        }

        private var specimen: some View {
            QeetrixDescriptionList {
                QeetrixDescriptionItem("App", value: "Qeet Pay console")
                QeetrixDescriptionItem("Phone", value: "+91 98765 43210")
                QeetrixDescriptionItem("Status") { QeetrixBadge("Pending", tone: .warning) }
                QeetrixDescriptionItem("Place", value: nil)
                QeetrixDescriptionItem("Display name", value: "Acme", description: Text("Shown in the top bar and in invitations.")) {
                    QeetrixButton("Change", variant: .ghost, size: .sm) {}
                }
            }
        }
    }
#endif
