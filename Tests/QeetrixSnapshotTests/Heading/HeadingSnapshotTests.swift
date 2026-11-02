#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Heading snapshots")
    struct HeadingSnapshotTests {
        @Test("Every size, and the subtle and inverse tones")
        func sizes() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(QeetrixHeadingSize.allCases, id: \.self) { size in
                        QeetrixHeading("Sign in to Qeet", level: 2, size: size)
                    }
                    QeetrixHeading("Subtle", level: 3, tone: .subtle)
                    QeetrixHeading("Inverse", level: 3, tone: .inverse)
                        .padding(4)
                        .background(QeetrixColor.surfaceInverse)
                }
            )
        }
    }
#endif
