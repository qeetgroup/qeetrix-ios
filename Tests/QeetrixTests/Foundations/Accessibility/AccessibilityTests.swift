import SwiftUI
import Testing

@testable import Qeetrix

/// The WCAG 2.2 AA pairs qeetrix-ui's contrast gate enforces on its semantic colours
/// (`src/__tests__/token-governance.test.ts`, `AA_PAIRS`), measured on the converted iOS values. This
/// proves the OKLCH conversion preserves the web's accessibility promises. Pairs on the web-only
/// shadcn bridge and component variables are not mirrored.
@Suite("WCAG contrast of semantic pairs")
struct ContrastTests {
    static let surfaces: [QeetrixColor] = [
        .surfaceCanvas, .surfaceDefault, .surfaceElevated, .surfaceOverlay, .surfaceSunken, .surfaceSubtle,
        .surfaceInteractive, .surfaceInteractiveHover, .surfaceBrandSubtle, .surfaceBrandSubtleHover, .surfaceRail,
    ]

    struct Pair: CustomStringConvertible, Sendable {
        let foreground: QeetrixColor
        /// Innermost first; composited onto surface-default when the bottom layer is translucent.
        let background: [QeetrixColor]
        let minimum: Double
        var description: String {
            "\(foreground) on \(background.map(\.rawValue).joined(separator: " over ")) ≥ \(minimum)"
        }
    }

    static let pairs: [Pair] = {
        var pairs: [Pair] = []
        for text in [QeetrixColor.textPrimary, .textSecondary, .textTertiary, .textPlaceholder, .textLink, .textLinkHover, .textBrand] {
            pairs += surfaces.map { Pair(foreground: text, background: [$0], minimum: 4.5) }
        }
        pairs += surfaces.map { Pair(foreground: .textBrandDisplay, background: [$0], minimum: 3) }
        pairs += [QeetrixColor.actionPrimary, .actionPrimaryHover, .actionPrimaryActive].map {
            Pair(foreground: .textOnBrand, background: [$0], minimum: 4.5)
        }
        pairs += [QeetrixColor.surfaceBrandSubtle, .surfaceBrandSubtleHover, .surfaceBrandSubtleActive].map {
            Pair(foreground: .textOnSubtle, background: [$0], minimum: 4.5)
        }
        let statuses: [(QeetrixColor, QeetrixColor, QeetrixColor)] = [
            (.textSuccess, .feedbackSuccessSubtle, .feedbackSuccess),
            (.textWarning, .feedbackWarningSubtle, .feedbackWarning),
            (.textDanger, .feedbackErrorSubtle, .feedbackError),
            (.textInfo, .feedbackInfoSubtle, .feedbackInfo),
        ]
        for (text, subtle, solid) in statuses {
            pairs += [
                Pair(foreground: text, background: [.surfaceDefault], minimum: 4.5),
                Pair(foreground: text, background: [.surfaceCanvas], minimum: 4.5),
                Pair(foreground: text, background: [subtle, .surfaceDefault], minimum: 4.5),
                Pair(foreground: .textOnFeedback, background: [solid], minimum: 4.5),
            ]
        }
        pairs += [
            Pair(foreground: .textOnFeedbackStrong, background: [.feedbackErrorStrong], minimum: 4.5),
            Pair(foreground: .textOnFeedbackStrong, background: [.feedbackSuccessStrong], minimum: 4.5),
            Pair(foreground: .textOnFeedbackStrong, background: [.feedbackInfoStrong], minimum: 4.5),
            Pair(foreground: .textOnWarningStrong, background: [.feedbackWarningStrong], minimum: 4.5),
        ]
        for boundary in [QeetrixColor.borderControl, .borderBrand] {
            pairs += surfaces.map { Pair(foreground: boundary, background: [$0], minimum: 3) }
        }
        for base in [QeetrixColor.surfaceOverlay, .surfaceElevated] {
            pairs += [
                Pair(foreground: .textOnSubtle, background: [.surfaceBrandSubtle, base], minimum: 4.5),
                Pair(foreground: .textBrand, background: [.surfaceBrandSubtle, base], minimum: 4.5),
                Pair(foreground: .borderBrand, background: [.surfaceBrandSubtle, base], minimum: 3),
            ]
        }
        return pairs
    }()

    /// Source-over in gamma-encoded sRGB, as browsers composite and as the upstream gate measures.
    static func over(_ top: Color.Resolved, _ bottom: Color.Resolved) -> Color.Resolved {
        let a = top.opacity
        return Color.Resolved(
            red: top.red * a + bottom.red * (1 - a), green: top.green * a + bottom.green * (1 - a),
            blue: top.blue * a + bottom.blue * (1 - a), opacity: 1)
    }

    static func surface(_ layers: [QeetrixColor], _ theme: QeetrixTheme) -> Color.Resolved {
        var stack = layers.map(theme.resolve)
        var result = stack.removeLast()
        if result.opacity < 1 { result = over(result, theme.resolve(.surfaceDefault)) }
        while let next = stack.popLast() { result = over(next, result) }
        return result
    }

    @Test("Every pair meets its minimum in both themes", arguments: [QeetrixTheme.light, .dark])
    func pairsMeetMinimum(theme: QeetrixTheme) {
        for pair in Self.pairs {
            let ratio = QeetrixAccessibility.contrastRatio(theme.resolve(pair.foreground), on: Self.surface(pair.background, theme))
            #expect(ratio >= pair.minimum, "\(theme.colorScheme): \(pair) — \(String(format: "%.2f", ratio)):1")
        }
    }

    @Test("The contrast formula matches WCAG reference values")
    func formula() {
        let black = Color.Resolved(red: 0, green: 0, blue: 0)
        let white = Color.Resolved(red: 1, green: 1, blue: 1)
        #expect(abs(QeetrixAccessibility.contrastRatio(black, on: white) - 21) < 1e-9)
        #expect(abs(QeetrixAccessibility.contrastRatio(white, on: white) - 1) < 1e-9)
        // #767676 on white is the classic 4.54:1.
        let grey = Color.Resolved(red: 118 / 255, green: 118 / 255, blue: 118 / 255)
        #expect(abs(QeetrixAccessibility.contrastRatio(grey, on: white) - 4.54) < 0.01)
    }
}

@Suite("Touch targets")
struct TouchTargetTests {
    @Test("A small view gets a 44 × 44 pt hit area without growing a larger one")
    @MainActor
    func minimumTarget() throws {
        let small = try #require(Rendered(Color.red.frame(width: 10, height: 10).qeetrixMinimumTouchTarget()))
        #expect(small.width == 44 && small.height == 44)
        let large = try #require(Rendered(Color.red.frame(width: 60, height: 50).qeetrixMinimumTouchTarget()))
        #expect(large.width == 60 && large.height == 50)
    }
}
