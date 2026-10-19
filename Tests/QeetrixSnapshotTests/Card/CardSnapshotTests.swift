#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Card snapshots")
    struct CardSnapshotTests {
        @Test("Variants, sizes, selection, footer and the button style")
        func variants() {
            assertSpecimen(
                VStack(spacing: 16) {
                    QeetrixCard {
                        QeetrixCardHeader("Team plan", description: "Billed monthly") {
                            QeetrixBadge("Current", variant: .brand)
                        }
                        QeetrixText("Up to 25 members, with audit logs and single sign-on.")
                    } footer: {
                        QeetrixButton("Upgrade") {}
                        QeetrixButton("Compare plans", variant: .ghost) {}
                    }
                    QeetrixCard(variant: .outline, size: .sm) {
                        QeetrixCardHeader("Outline, small", description: "No shadow, 12 pt rhythm")
                    }
                    QeetrixCard(variant: .elevated, isSelected: true) {
                        QeetrixCardHeader("Elevated and selected", description: "A 2 pt brand boundary")
                    }
                    Button {
                    } label: {
                        QeetrixCardHeader("A card that is a button", description: "QeetrixCardButtonStyle")
                    }
                    .buttonStyle(.qeetrixCard())
                    Button {
                    } label: {
                        QeetrixCardHeader("Disabled", description: "Faded")
                    }
                    .buttonStyle(.qeetrixCard(.outline))
                    .disabled(true)
                }
            )
        }
    }
#endif
