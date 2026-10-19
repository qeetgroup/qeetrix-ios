import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Component foundations")
struct ComponentFoundationTests {
    @Test("The hit area is at least 44 pt, centred, and never smaller than the view")
    func hitArea() {
        let small = QeetrixHitArea().path(in: CGRect(x: 0, y: 0, width: 32, height: 24)).boundingRect
        #expect(small == CGRect(x: -6, y: -10, width: 44, height: 44))
        let large = QeetrixHitArea().path(in: CGRect(x: 0, y: 0, width: 120, height: 48)).boundingRect
        #expect(large == CGRect(x: 0, y: 0, width: 120, height: 48))
    }

    @Test("The web scale restates Tailwind's defaults")
    func webScale() {
        #expect(QeetrixWebScale.spacing(2.5) == 10)
        #expect(QeetrixWebScale.textSM.size == 14)
        #expect(abs(QeetrixWebScale.textSM.lineHeight * 14 - 20) < 1e-9)
        #expect(abs(QeetrixWebScale.textXS.lineHeight * 12 - 16) < 1e-9)
        #expect(abs(QeetrixWebScale.textLG.lineHeight * 18 - 28) < 1e-9)
    }

    @Test("A component colour resolves per scheme: one semantic colour, or a value per theme")
    func componentColor() {
        var light = EnvironmentValues()
        light.colorScheme = .light
        var dark = EnvironmentValues()
        dark.colorScheme = .dark
        let semantic = QeetrixComponentColor(.actionPrimary)
        #expect(semantic.resolve(in: light) == QeetrixColor.actionPrimary.resolve(in: light))
        #expect(semantic.resolve(in: dark) == QeetrixColor.actionPrimary.resolve(in: dark))
        // The outline button's background: the surface in light, a translucent wash in dark.
        let outline = QeetrixButtonTokens.outlineBackground
        #expect(outline.resolve(in: light) == QeetrixColor.surfaceDefault.resolve(in: light))
        #expect(outline.resolve(in: dark).opacity < 1)
    }

    @Test("Component text styles scale like their curve; fixed ones do not")
    func scaling() {
        let fixed = QeetrixComponentType.ui(QeetrixWebScale.textSM, .medium, scalesLike: nil)
        #expect(fixed.textStyle == nil)
        #expect(fixed.fixedSize == fixed)
        #expect(QeetrixComponentType.ui(QeetrixWebScale.textSM, .medium, scalesLike: .body).fixedSize.textStyle == nil)
        #expect(QeetrixComponentType.role(.caption, .medium).textStyle == QeetrixTextRole.caption.textStyle)
    }
}
