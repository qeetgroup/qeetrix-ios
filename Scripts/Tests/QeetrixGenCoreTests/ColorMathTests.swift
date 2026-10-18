import Foundation
import Testing

@testable import QeetrixGenCore

@Suite("Colour conversion")
struct ColorMathTests {
    func encode(_ css: String) throws -> ColorMath.EncodedColor {
        ColorMath.encode(try ColorValues.color(try CSSParser.parse(css, context: "t"), context: "t"))
    }

    /// The brand values agreed for the Qeet orange ramp (logo #F26D0E, Qeet Ember #D04800, AA text
    /// #B73D10). They were chosen on the web from these OKLCH tokens, so the conversion must reproduce
    /// them exactly — an oracle independent of this code.
    @Test(
        "Qeet ramp converts to the agreed brand hex values",
        arguments: [
            ("oklch(0.686 0.1855 47.1629)", "#F26D0E"),
            ("oklch(0.585 0.1835 40)", "#D04800"),
            ("oklch(0.53 0.165 38)", "#B73D10"),
        ])
    func brandOracles(css: String, hex: String) throws {
        let color = try encode(css)
        #expect(color.space == .sRGB)
        #expect(color.hex == hex)
    }

    @Test("Achromatic extremes are exact sRGB white and black, not out-of-gamut noise")
    func extremes() throws {
        let white = try encode("oklch(1 0 0)")
        #expect(white.space == .sRGB && white.red == 1 && white.green == 1 && white.blue == 1)
        let black = try encode("oklch(0 0 0)")
        #expect(black.red == 0 && black.green == 0 && black.blue == 0)
    }

    /// The CSS Color 4 matrix pairs are inverses to about 1e-8 in linear light; the sRGB curve's 12.92×
    /// segment near black magnifies that to about 1e-7 — still thousands of times finer than one
    /// 8-bit step (1/255).
    @Test("sRGB → OKLab → sRGB round-trips")
    func roundTrip() {
        for rgb in [[0.2, 0.4, 0.6], [1, 0.5, 0], [0.05, 0.9, 0.3]] {
            let back = ColorMath.sRGB(from: ColorMath.okLab(sRGB: rgb))
            for (a, b) in zip(rgb, back) { #expect(abs(a - b) < 1e-6, "\(a) → \(b)") }
        }
    }

    @Test("A colour outside sRGB but inside P3 is drawn in Display P3")
    func displayP3() throws {
        // Tailwind v4 blue-500, which qeetrix-ui's data palette uses; outside sRGB.
        let color = try encode("oklch(0.623 0.214 259.815)")
        #expect(color.space == .displayP3)
        #expect(color.gamutMapped == false)
    }

    @Test("A colour outside P3 is gamut-mapped into it, keeping lightness and hue")
    func gamutMapping() throws {
        let color = try encode("oklch(0.7 0.4 150)")
        #expect(color.space == .displayP3 && color.gamutMapped)
        for channel in [color.red, color.green, color.blue] { #expect((0...1).contains(channel)) }
        let p3 = [color.red, color.green, color.blue]
        let lab = ColorMath.okLab(fromXYZ: ColorMath.multiply(ColorMath.linearP3ToXYZ, p3.map(ColorMath.decode)), alpha: 1)
        // CSS Color 4 accepts a clipped result within one JND (ΔE_OK 0.02) of the chroma-reduced
        // colour: lightness and hue move by less than that, chroma comes down.
        let chroma = hypot(lab.a, lab.b)
        let target = ColorMath.oklch(l: 0.7, c: chroma, h: 150)
        let deltaE = sqrt(pow(lab.l - target.l, 2) + pow(lab.a - target.a, 2) + pow(lab.b - target.b, 2))
        #expect(deltaE < 0.02, "ΔE_OK \(deltaE) from \(target), got \(lab)")
        #expect(chroma < 0.4)
    }

    @Test("color-mix with transparent keeps the colour and scales alpha (CSS Color 5)")
    func mixWithTransparent() throws {
        let scrim = try ColorValues.color(
            try CSSParser.parse("color-mix(in oklab, oklch(0.11 0 0) 40%, transparent)", context: "t"), context: "t")
        #expect(abs(scrim.l - 0.11) < 1e-12 && abs(scrim.alpha - 0.4) < 1e-12)
    }

    @Test("An unweighted color-mix is the OKLab midpoint")
    func midpoint() throws {
        let a = ColorMath.oklch(l: 0.585, c: 0.1835, h: 40)
        let b = ColorMath.oklch(l: 0.53, c: 0.165, h: 38)
        let mixed = try ColorValues.color(
            try CSSParser.parse("color-mix(in oklab, oklch(0.585 0.1835 40), oklch(0.53 0.165 38))", context: "t"), context: "t")
        #expect(abs(mixed.l - (a.l + b.l) / 2) < 1e-12)
        #expect(abs(mixed.a - (a.a + b.a) / 2) < 1e-12)
        #expect(mixed.alpha == 1)
    }

    @Test("Percentages summing below 100% scale the result's alpha")
    func partialMix() throws {
        let mixed = try ColorMath.mix(ColorMath.oklch(l: 0.5, c: 0, h: 0), 30, ColorMath.oklch(l: 0.9, c: 0, h: 0), 20)
        #expect(abs(mixed.alpha - 0.5) < 1e-12)
        #expect(abs(mixed.l - (0.5 * 0.6 + 0.9 * 0.4)) < 1e-12)
    }

    @Test("Unsupported colour syntax fails with the token named")
    func unsupported() {
        for css in ["#ff0000", "hsl(10 50% 50%)", "color-mix(in srgb, red, blue)", "currentColor"] {
            #expect(throws: GeneratorError.self) { try ColorValues.color(try CSSParser.parse(css, context: "color.x"), context: "color.x") }
        }
    }
}
