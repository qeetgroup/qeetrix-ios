#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Circular progress snapshots")
    struct CircularProgressSnapshotTests {
        @Test("Every size and tone, empty and full, and the style on a ProgressView with and without a value, at rest")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        ForEach(QeetrixCircularProgressSize.allCases, id: \.self) { size in
                            QeetrixCircularProgress(value: 0.4, size: size)
                        }
                    }
                    HStack(spacing: 16) {
                        ForEach(QeetrixCircularProgressTone.allCases, id: \.self) { tone in
                            QeetrixCircularProgress(value: tone == .warning ? 0.15 : 0.65, size: .xl, tone: tone)
                        }
                    }
                    HStack(spacing: 16) {
                        QeetrixCircularProgress(value: 0, size: .xl)
                        QeetrixCircularProgress(value: 1, size: .xl, tone: .success)
                        ProgressView(value: 0.25).progressViewStyle(.qeetrixCircular(size: .xl))
                        ProgressView().progressViewStyle(.qeetrixCircular(size: .xl))
                    }
                    // A one-time code with its seconds left, as the authenticator shows it.
                    HStack(spacing: QeetrixSpace.gapSm) {
                        QeetrixText("482 913", size: .lg, mono: true)
                        QeetrixCircularProgress(value: 4.0 / 30, size: .lg, tone: .warning, label: Text("Time left"))
                    }
                }
            )
        }
    }
#endif
