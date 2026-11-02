#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Copy button snapshots")
    struct CopyButtonSnapshotTests {
        @Test("Icon-only and titled, each variant, at rest, copied and failed; every size, and disabled")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(QeetrixCopyState.allCases, id: \.self) { state in
                        FlowLayout(spacing: 12) {
                            ForEach(QeetrixButtonVariant.allCases, id: \.self) { variant in
                                QeetrixCopyButtonFace(
                                    state: state, label: Text("Copy user ID"), title: nil, variant: variant, tone: .neutral, size: .md,
                                    action: {})
                            }
                            QeetrixCopyButtonFace(
                                state: state, label: nil, title: Text("Copy link"), variant: .ghost, tone: .neutral, size: .md, action: {})
                            QeetrixCopyButtonFace(
                                state: state, label: nil, title: Text("Copy link"), variant: .soft, tone: .brand, size: .md, action: {})
                        }
                    }
                    FlowLayout(spacing: 12) {
                        ForEach(QeetrixControlSize.allCases, id: \.self) { size in
                            QeetrixCopyButton(value: "acme-user-0042", size: size)
                        }
                        QeetrixCopyButton(value: "acme-user-0042").disabled(true)
                        QeetrixCopyButton("Copy link", value: "https://qeet.in/i/7Hq2").disabled(true)
                    }
                }
            )
        }
    }
#endif
