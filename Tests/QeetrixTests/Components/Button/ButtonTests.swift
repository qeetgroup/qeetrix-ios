import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Button")
struct ButtonTests {
    @Test("Heights: 24, 28, the density's control height, 36")
    func heights() {
        #expect(QeetrixButtonMetrics(size: .xs, density: .default).height == 24)
        #expect(QeetrixButtonMetrics(size: .sm, density: .default).height == 28)
        #expect(QeetrixButtonMetrics(size: .lg, density: .compact).height == 36)
        for density in QeetrixDensity.allCases {
            #expect(QeetrixButtonMetrics(size: .default, density: density).height == density.controlHeight)
        }
    }

    @Test("Padding, icon-side padding, gap, corner, type and icon size per size")
    func metrics() {
        let xs = QeetrixButtonMetrics(size: .xs, density: .default)
        #expect((xs.padding, xs.iconSidePadding, xs.gap, xs.corner) == (8, 6, 4, QeetrixButtonTokens.cornerXs))
        #expect((xs.type.tokens.size, xs.iconSize.points) == (12, 12))
        let sm = QeetrixButtonMetrics(size: .sm, density: .default)
        #expect((sm.padding, sm.iconSidePadding, sm.gap, sm.corner) == (10, 6, 4, QeetrixButtonTokens.cornerSm))
        #expect((sm.type.tokens.size, sm.iconSize.points) == (QeetrixButtonTokens.fontSizeSm, 14))
        let regular = QeetrixButtonMetrics(size: .default, density: .default)
        #expect((regular.padding, regular.iconSidePadding, regular.gap, regular.corner) == (10, 8, 6, QeetrixButtonTokens.corner))
        #expect((regular.type.tokens.size, regular.iconSize.points) == (14, 16))
        #expect(regular.type.tokens.weight == .medium)
        let lg = QeetrixButtonMetrics(size: .lg, density: .default)
        #expect((lg.padding, lg.iconSidePadding, lg.gap) == (12, 10, 6))
        #expect(QeetrixButtonStyle.iconSize(for: .sm).points == 14)
    }

    @Test("Primary walks its component tokens and settles flat when pressed")
    func primary() {
        let rest = QeetrixButtonColors.colors(.default, .resting)
        #expect(rest.background == QeetrixButtonTokens.primaryBackground)
        #expect(rest.foreground == QeetrixButtonTokens.primaryForeground)
        #expect(rest.elevation == .rampXs)
        #expect(QeetrixButtonColors.colors(.default, .hovered).background == QeetrixButtonTokens.primaryBackgroundHover)
        let pressed = QeetrixButtonColors.colors(.default, .pressed)
        #expect(pressed.background == QeetrixButtonTokens.primaryBackgroundActive)
        #expect(pressed.elevation == .flat)
    }

    @Test("A disabled primary is the neutral fill at full opacity; other variants fade")
    func disabled() {
        let primary = QeetrixButtonColors.colors(.default, .disabled)
        #expect(primary.background == QeetrixComponentColor(.surfaceInteractive))
        #expect(primary.foreground == QeetrixComponentColor(.textDisabled))
        #expect(primary.opacity == 1)
        #expect(primary.elevation == .flat)
        for variant in QeetrixButtonVariant.allCases where variant != .default {
            #expect(QeetrixButtonColors.colors(variant, .disabled).opacity == QeetrixOpacity.disabled)
        }
    }

    @Test("Outline, secondary and ghost walk the interactive surface ladder")
    func ladder() {
        #expect(QeetrixButtonColors.colors(.outline, .resting).background == QeetrixButtonTokens.outlineBackground)
        #expect(QeetrixButtonColors.colors(.outline, .resting).border == QeetrixButtonTokens.outlineBorder)
        #expect(QeetrixButtonColors.colors(.secondary, .resting).background == QeetrixComponentColor(.surfaceInteractive))
        #expect(QeetrixButtonColors.colors(.secondary, .resting).foreground == QeetrixComponentColor(.textOnSubtle))
        for variant in [QeetrixButtonVariant.outline, .secondary, .ghost] {
            #expect(QeetrixButtonColors.colors(variant, .hovered).background == QeetrixComponentColor(.surfaceInteractiveHover))
            #expect(QeetrixButtonColors.colors(variant, .pressed).background == QeetrixComponentColor(.surfaceInteractiveActive))
        }
        #expect(QeetrixButtonColors.colors(.ghost, .resting).elevation == .flat)
    }

    @Test("Destructive is quiet at rest and solid on press; link underlines on press")
    func destructiveAndLink() {
        #expect(QeetrixButtonColors.colors(.destructive, .resting).background == QeetrixComponentColor(.feedbackErrorSubtle))
        #expect(QeetrixButtonColors.colors(.destructive, .resting).foreground == QeetrixComponentColor(.textDanger))
        #expect(QeetrixButtonColors.colors(.destructive, .pressed).background == QeetrixComponentColor(.feedbackErrorStrong))
        #expect(QeetrixButtonColors.colors(.destructive, .pressed).foreground == QeetrixComponentColor(.textOnFeedbackStrong))
        #expect(QeetrixButtonColors.colors(.link, .resting).foreground == QeetrixComponentColor(.textLink))
        #expect(!QeetrixButtonColors.colors(.link, .resting).isUnderlined)
        #expect(QeetrixButtonColors.colors(.link, .pressed).isUnderlined)
    }

    @Test("Busy is not unavailable: a loading button keeps its resting colours, even when disabled")
    func loading() {
        #expect(QeetrixButtonStyleBody.state(isEnabled: true, isPressed: true, isHovered: true, isLoading: true) == .resting)
        #expect(QeetrixButtonStyleBody.state(isEnabled: false, isPressed: false, isHovered: false, isLoading: true) == .resting)
        #expect(QeetrixButtonStyleBody.state(isEnabled: false, isPressed: true, isHovered: false, isLoading: false) == .disabled)
        #expect(QeetrixButtonStyleBody.state(isEnabled: true, isPressed: true, isHovered: true, isLoading: false) == .pressed)
        #expect(QeetrixButtonStyleBody.state(isEnabled: true, isPressed: false, isHovered: true, isLoading: false) == .hovered)
    }

    @Test("Icon buttons: 12 pt icons at xs, 16 pt otherwise")
    func iconButton() {
        #expect(QeetrixIconButton.iconSize(.xs).points == 12)
        for size in [QeetrixButtonSize.sm, .default, .lg] {
            #expect(QeetrixIconButton.iconSize(size).points == 16)
        }
    }

    @Test("Buttons render in every variant, loading or not")
    func renders() {
        for variant in QeetrixButtonVariant.allCases {
            #expect(ImageRenderer(content: QeetrixButton("Save", variant: variant) {}).cgImage != nil)
            #expect(
                ImageRenderer(content: QeetrixButton("Save", variant: variant, isLoading: true, loadingLabel: "Saving") {}).cgImage != nil)
            #expect(ImageRenderer(content: QeetrixIconButton(.x, label: "Close", variant: variant) {}).cgImage != nil)
        }
    }
}
