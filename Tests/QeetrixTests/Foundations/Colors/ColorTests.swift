import SwiftUI
import Testing

@testable import Qeetrix

@Suite("Semantic colours")
struct ColorTests {
    func environment(_ scheme: ColorScheme, contrast: ColorSchemeContrast = .standard) -> EnvironmentValues {
        var values = EnvironmentValues()
        values.colorScheme = scheme
        values._colorSchemeContrast = contrast
        return values
    }

    func hex(_ resolved: Color.Resolved) -> String {
        let bytes = resolved.bytes
        return String(format: "#%02X%02X%02X", bytes.r, bytes.g, bytes.b)
    }

    /// The brand decisions recorded with the web tokens: links and brand text use Qeet #B73D10 in light
    /// (the AA step) and the logo orange #F26D0E in dark; the primary action is Qeet Ember #D04800.
    @Test("Brand roles resolve to the agreed brand colours in each theme")
    func brand() {
        #expect(hex(QeetrixColor.textBrand.resolve(in: environment(.light))) == "#B73D10")
        #expect(hex(QeetrixColor.textLink.resolve(in: environment(.light))) == "#B73D10")
        #expect(hex(QeetrixColor.textBrand.resolve(in: environment(.dark))) == "#F26D0E")
        #expect(hex(QeetrixColor.actionPrimary.resolve(in: environment(.light))) == "#D04800")
        #expect(hex(QeetrixColor.actionPrimary.resolve(in: environment(.dark))) == "#D04800")
    }

    @Test("Colours follow the environment's colour scheme")
    func schemes() {
        let light = QeetrixColor.surfaceDefault.resolve(in: environment(.light))
        let dark = QeetrixColor.surfaceDefault.resolve(in: environment(.dark))
        #expect(hex(light) == "#FFFFFF")
        #expect(light != dark)
        #expect(dark.red < 0.2)
    }

    @Test("Increased contrast resolves to the standard values (no contrast theme upstream)")
    func increasedContrast() {
        for color in QeetrixColor.allCases {
            for scheme in [ColorScheme.light, .dark] {
                #expect(color.resolve(in: environment(scheme, contrast: .increased)) == color.resolve(in: environment(scheme)))
            }
        }
    }

    @Test("Translucent tokens keep their alpha")
    func alpha() {
        let scrim = QeetrixColor.overlayScrim.resolve(in: environment(.light))
        #expect(abs(scrim.opacity - 0.4) < 0.001)
        let darkTint = QeetrixColor.surfaceBrandSubtle.resolve(in: environment(.dark))
        #expect(abs(darkTint.opacity - 0.1) < 0.001)
    }

    @Test("color(for:) and the ShapeStyle agree")
    func colorAccessor() {
        for color in QeetrixColor.allCases {
            #expect(color.color(for: .dark).resolve(in: environment(.dark)) == color.resolve(in: environment(.dark)))
        }
    }
}
