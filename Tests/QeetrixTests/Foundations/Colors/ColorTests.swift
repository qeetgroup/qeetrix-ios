import SwiftUI
import Testing

@testable import Qeetrix

@Suite("Semantic colours")
struct ColorTests {
    /// The brand values in `@qeetrix/tokens` 0.0.13: Ember #D04800 for the primary action in both
    /// schemes; links Qeet #B73D10 in light and the logo orange #F26D0E in dark; brand text one step
    /// darker in light (#9B3314) and lighter in dark (#FF9646), for contrast on the tints.
    @Test("Brand roles resolve to the agreed brand colours in each scheme")
    func brand() {
        #expect(QeetrixColor.bgBrandBold.resolve(in: environment(.light)).hex == "#D04800")
        #expect(QeetrixColor.bgBrandBold.resolve(in: environment(.dark)).hex == "#D04800")
        #expect(QeetrixColor.textLink.resolve(in: environment(.light)).hex == "#B73D10")
        #expect(QeetrixColor.textLink.resolve(in: environment(.dark)).hex == "#F26D0E")
        #expect(QeetrixColor.textBrand.resolve(in: environment(.light)).hex == "#9B3314")
        #expect(QeetrixColor.textBrand.resolve(in: environment(.dark)).hex == "#FF9646")
        #expect(QeetrixColor.borderFocus.resolve(in: environment(.light)).hex == "#D04800")
        #expect(QeetrixColor.borderFocus.resolve(in: environment(.dark)).hex == "#F26D0E")
    }

    @Test("Colours follow the environment's colour scheme")
    func schemes() {
        let light = QeetrixColor.surfaceDefault.resolve(in: environment(.light))
        let dark = QeetrixColor.surfaceDefault.resolve(in: environment(.dark))
        #expect(light.hex == "#FFFFFF")
        #expect(light != dark)
        #expect(dark.red < 0.2)
        // Warm graphite: the secondary fill inverts between schemes.
        #expect(QeetrixColor.bgNeutralBold.resolve(in: environment(.light)).hex == "#191818")
        #expect(QeetrixColor.bgNeutralBold.resolve(in: environment(.dark)).hex == "#F3F1EF")
    }

    @Test("Increased contrast resolves to the standard values (no contrast context upstream)")
    func increasedContrast() {
        for color in QeetrixColor.allCases {
            for scheme in [ColorScheme.light, .dark] {
                #expect(color.resolve(in: environment(scheme, contrast: .increased)) == color.resolve(in: environment(scheme)))
            }
        }
    }

    @Test("Translucent tokens keep their alpha")
    func alpha() {
        #expect(abs(QeetrixColor.overlayScrim.resolve(in: environment(.light)).opacity - 0.4) < 0.001)
        #expect(abs(QeetrixColor.overlayScrim.resolve(in: environment(.dark)).opacity - 0.62) < 0.001)
        #expect(abs(QeetrixColor.selection.resolve(in: environment(.dark)).opacity - 0.2) < 0.001)
        #expect(abs(QeetrixColor.overlayHover.resolve(in: environment(.light)).opacity - 0.06) < 0.001)
        #expect(QeetrixColor.bgBrandSubtle.resolve(in: environment(.dark)).opacity == 1, "Dark tints are mixed, not translucent")
    }

    @Test("The one colour outside sRGB is drawn in Display P3")
    func wideGamut() {
        let wide = QeetrixColor.allCases.filter { $0.rgba(for: .light).space == .displayP3 || $0.rgba(for: .dark).space == .displayP3 }
        #expect(wide == [.datavizCategorical2])
    }

    @Test("color(for:) and the ShapeStyle agree")
    func colorAccessor() {
        for color in QeetrixColor.allCases {
            #expect(color.color(for: .dark).resolve(in: environment(.dark)) == color.resolve(in: environment(.dark)))
        }
    }
}
