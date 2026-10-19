#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Separator snapshots")
    struct SeparatorSnapshotTests {
        @Test("Both variants, horizontal and vertical")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 12) {
                    QeetrixText("Default", variant: .small)
                    QeetrixSeparator()
                    QeetrixText("Muted", variant: .small)
                    QeetrixSeparator(variant: .muted)
                    HStack(spacing: 12) {
                        QeetrixText("Docs", variant: .small)
                        QeetrixSeparator(.vertical)
                        QeetrixText("API", variant: .small)
                        QeetrixSeparator(.vertical, variant: .muted)
                        QeetrixText("Status", variant: .small)
                    }
                    .frame(height: 20)
                }
            )
        }
    }
#endif
