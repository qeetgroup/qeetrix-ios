import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Badge")
struct BadgeTests {
    @Test("Each variant takes the web's colours")
    func colours() {
        let solid = QeetrixBadge.colors(.default, colorScheme: .light)
        #expect(solid.background == QeetrixBadgeTokens.defaultBackground)
        #expect(solid.foreground == QeetrixBadgeTokens.defaultForeground)
        let tones: [(QeetrixBadgeVariant, QeetrixColor, QeetrixColor, QeetrixComponentColor)] = [
            (.brand, .surfaceBrandSubtle, .textBrand, QeetrixBadgeTokens.borderBrand),
            (.info, .feedbackInfoSubtle, .textInfo, QeetrixBadgeTokens.borderInfo),
            (.success, .feedbackSuccessSubtle, .textSuccess, QeetrixBadgeTokens.borderSuccess),
            (.warning, .feedbackWarningSubtle, .textWarning, QeetrixBadgeTokens.borderWarning),
            (.destructive, .feedbackErrorSubtle, .textDanger, QeetrixBadgeTokens.borderDanger),
        ]
        for (variant, background, foreground, border) in tones {
            let colors = QeetrixBadge.colors(variant, colorScheme: .light)
            #expect(colors.background == QeetrixComponentColor(background))
            #expect(colors.foreground == QeetrixComponentColor(foreground))
            #expect(colors.border == border)
        }
        #expect(QeetrixBadge.colors(.secondary, colorScheme: .light).background == QeetrixComponentColor(.surfaceInteractive))
        #expect(QeetrixBadge.colors(.muted, colorScheme: .light).foreground == QeetrixComponentColor(.textTertiary))
    }

    @Test("The outline badge's boundary is stronger in dark")
    func outline() {
        #expect(QeetrixBadge.colors(.outline, colorScheme: .light).border == QeetrixComponentColor(.borderDefault))
        #expect(QeetrixBadge.colors(.outline, colorScheme: .dark).border == QeetrixComponentColor(.borderStrong))
    }

    @Test("Label: 12 pt medium in the UI letter style; 12 pt icons")
    func metrics() {
        #expect(QeetrixBadge.labelType.tokens.size == 12)
        #expect(QeetrixBadge.labelType.tokens.weight == .medium)
        #expect(QeetrixBadge.labelType.tokens.geometry == QeetrixTextRole.label.tokens.geometry)
        #expect(QeetrixBadge.iconSize.points == 12)
    }
}
