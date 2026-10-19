#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Text snapshots")
    struct TextSnapshotTests {
        @Test("Every variant")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(QeetrixTextVariant.allCases, id: \.self) { variant in
                        QeetrixText(verbatim(variant), variant: variant)
                    }
                }
            )
        }

        private func verbatim(_ variant: QeetrixTextVariant) -> String {
            variant == .inlineCode ? "qeetrix.tokens.json" : "\(variant.rawValue) — Sign in with a passkey"
        }
    }
#endif
