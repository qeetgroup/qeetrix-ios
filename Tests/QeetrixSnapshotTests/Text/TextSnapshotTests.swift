#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Text snapshots")
    struct TextSnapshotTests {
        @Test("Sizes, weights, tones, mono and truncation")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(QeetrixTextSize.allCases, id: \.self) { size in
                        QeetrixText("Body \(size.rawValue): invoices are sent on the 1st.", size: size, tone: .default)
                    }
                    ForEach(QeetrixTextWeight.allCases, id: \.self) { weight in
                        QeetrixText("Weight \(weight.rawValue)", weight: weight, tone: .default)
                    }
                    FlowLayout {
                        ForEach(QeetrixTextTone.allCases, id: \.self) { tone in
                            QeetrixText(tone.rawValue, tone: tone)
                                .padding(.horizontal, tone == .inverse ? 4 : 0)
                                .background(tone == .inverse ? QeetrixColor.surfaceInverse : QeetrixColor.surfaceCanvas)
                        }
                    }
                    QeetrixText("INV-2026-0042 · gst_live_7Yf2", tone: .default, mono: true)
                    QeetrixText("One line with an ellipsis when the text is longer than the row it sits in", tone: .subtle, truncate: 1)
                    QeetrixText("label.caps", tone: .subtle)
                    Text("GROUP LABEL").qeetrixTextStyle(.labelCaps).foregroundStyle(QeetrixColor.textSubtle)
                }
            )
        }
    }
#endif
