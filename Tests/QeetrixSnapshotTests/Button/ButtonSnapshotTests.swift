#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Button snapshots")
    struct ButtonSnapshotTests {
        @Test("Variants by tone, sizes with an icon, disabled, loading, focus and full width")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(QeetrixButtonTone.allCases, id: \.self) { tone in
                        FlowLayout {
                            ForEach(QeetrixButtonVariant.allCases, id: \.self) { variant in
                                QeetrixButton("\(variant.rawValue) \(tone.rawValue)", variant: variant, tone: tone) {}
                            }
                        }
                    }
                    FlowLayout {
                        ForEach(QeetrixControlSize.allCases, id: \.self) { size in
                            QeetrixButton("Export \(size.rawValue)", icon: .share2, variant: .soft, size: size) {}
                        }
                    }
                    FlowLayout {
                        ForEach(QeetrixButtonVariant.allCases, id: \.self) { variant in
                            QeetrixButton(variant.rawValue, icon: .send, variant: variant) {}.disabled(true)
                        }
                    }
                    FlowLayout {
                        QeetrixButton("Save", isLoading: true) {}
                        QeetrixButton("Export", icon: .share2, variant: .soft, isLoading: true) {}
                        QeetrixButton("Revoke key", tone: .danger, isLoading: true) {}
                    }
                    FlowLayout {
                        // Keyboard focus, drawn as the style draws it.
                        QeetrixButton("Focused", icon: .send) {}
                            .overlay { QeetrixInnerFocusFrame(shape: RoundedRectangle(cornerRadius: QeetrixRadius.control)) }
                        QeetrixButton("Focused", variant: .ghost) {}
                            .overlay { QeetrixInnerFocusFrame(shape: RoundedRectangle(cornerRadius: QeetrixRadius.control)) }
                    }
                    QeetrixButton("Continue with passkey", icon: .lock, size: .lg, isFullWidth: true) {}
                }
            )
        }

        @Test("Icon buttons: variants by tone, sizes, disabled and loading")
        func iconButtons() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(QeetrixButtonTone.allCases, id: \.self) { tone in
                        FlowLayout {
                            ForEach(QeetrixButtonVariant.allCases, id: \.self) { variant in
                                QeetrixIconButton(.bell, label: "Notifications", variant: variant, tone: tone) {}
                            }
                        }
                    }
                    FlowLayout {
                        ForEach(QeetrixControlSize.allCases, id: \.self) { size in
                            QeetrixIconButton(.x, label: "Close", tone: .neutral, size: size) {}
                        }
                        QeetrixIconButton(.trash, label: "Delete", variant: .soft) {}.disabled(true)
                        QeetrixIconButton(.send, label: "Send", variant: .solid, isLoading: true) {}
                    }
                }
            )
        }

        @Test("An icon of the app's own: a turned icon in the zone, full width, loading, and in an icon button")
        func customIcon() {
            let hangUp = QeetrixIcon(.x, size: .md).rotationEffect(.degrees(45))
            assertSpecimen(
                VStack(alignment: .leading, spacing: 12) {
                    QeetrixButton("Hang up and report", variant: .soft, tone: .neutral, size: .lg, isFullWidth: true) {
                    } icon: {
                        hangUp
                    }
                    QeetrixButton("Hang up", tone: .danger) {
                    } icon: {
                        QeetrixIcon(.x, size: .sm).rotationEffect(.degrees(45))
                    }
                    QeetrixButton("Hang up", tone: .danger, isLoading: true) {
                    } icon: {
                        QeetrixIcon(.x, size: .sm)
                    }
                    QeetrixIconButton(label: "Hang up", variant: .solid, tone: .danger) {
                    } icon: {
                        QeetrixIcon(.x, size: .sm).rotationEffect(.degrees(45))
                    }
                }
            )
        }
    }
#endif
