import CoreText
import CryptoKit
import Foundation
import SwiftUI
import Testing

@testable import Qeetrix

@Suite("Font registry")
struct FontRegistryTests {
    @Test("Every bundled family registers and resolves to its own file, not a fallback")
    func registration() {
        let registrations = QeetrixFontRegistry.register()
        #expect(registrations.map(\.family) == QeetrixFontFamily.allCases)
        for registration in registrations {
            #expect(registration.isAvailable, "\(registration.family): \(registration.failure ?? "")")
        }
        // Registering again is a no-op, not a failure.
        #expect(QeetrixFontRegistry.register() == registrations)
    }

    @Test("Fonts are drawn from the bundled files, whatever else is installed")
    func drawnFromBundle() throws {
        for family in QeetrixFontFamily.allCases {
            let bundled = try #require(QeetrixFontRegistry.url(of: family))
            #expect(bundled.lastPathComponent == "\(family.face.resourceName).ttf")
            let font = try #require(QeetrixFontRegistry.font(family, size: 17, weight: .regular))
            let source = CTFontCopyAttribute(font, kCTFontURLAttribute) as? URL
            #expect(source?.standardizedFileURL == bundled.standardizedFileURL)
            #expect(CTFontCopyFamilyName(font) as String == family.face.familyName)
        }
    }

    @Test("Bundled TTFs are the files the provenance record names, with their licences beside them")
    func bundledFiles() throws {
        let provenance = try QeetrixProvenance.bundled()
        for family in QeetrixFontFamily.allCases {
            let face = family.face
            let url = try #require(Bundle.module.url(forResource: face.resourceName, withExtension: "ttf", subdirectory: "Fonts"))
            let digest = SHA256.hash(data: try Data(contentsOf: url)).map { String(format: "%02x", $0) }.joined()
            #expect(provenance.fonts.first { $0.family == family.rawValue }?.sha256 == digest)
        }
        #expect(Bundle.module.url(forResource: "CalSans-OFL", withExtension: "txt", subdirectory: "Fonts") != nil)
        #expect(Bundle.module.url(forResource: "FiraCode-OFL", withExtension: "txt", subdirectory: "Fonts") != nil)
    }

    @Test("Qeet Sans carries the variation axes the roles set")
    func axes() throws {
        let face = QeetrixFontFamily.sans.face
        #expect(face.webFamily == "Qeet Sans")
        let geometry = try #require(face.axis("GEOM"))
        #expect(geometry.minimum == 0 && geometry.maximum == 100)
        #expect(face.axis("wght")?.minimum == 400 && face.axis("wght")?.maximum == 700)
        #expect(face.axis("opsz") != nil)
        #expect(QeetrixFontFamily.mono.face.axis("wght") != nil)
    }

    @Test("A font carries the weight, letter style and optical size it was asked for")
    func variations() throws {
        let font = try #require(QeetrixFontRegistry.font(.sans, size: 20, weight: .semibold, geometry: .base))
        let variations = QeetrixFontRegistry.variations(of: font)
        #expect(variations["wght"] == 600)
        #expect(variations["GEOM"] == 50)
        #expect(variations["opsz"] == 20)
        #expect(CTFontGetSize(font) == 20)
        // Out-of-range requests clamp to the axis, as CSS does.
        let clamped = try #require(QeetrixFontRegistry.font(.sans, size: 64, weight: QeetrixFontWeight(900), geometry: .ui))
        #expect(QeetrixFontRegistry.variations(of: clamped)["wght"] == 700)
        #expect(QeetrixFontRegistry.variations(of: clamped)["opsz"] == 45)
    }

    @Test("Different letter styles shape to different glyphs")
    func geometryChangesGlyphs() throws {
        // 'a' is single-storey in the Base style and double-storey in UI (qeetrix-ui CHANGELOG, 2.1.6).
        // Cal Sans swaps the form with OpenType feature variations, which apply when text is shaped.
        func shapedGlyphs(_ geometry: QeetrixFontGeometry) throws -> [CGGlyph] {
            let font = try #require(QeetrixFontRegistry.font(.sans, size: 40, weight: .regular, geometry: geometry))
            let text = NSAttributedString(string: "aga", attributes: [NSAttributedString.Key(kCTFontAttributeName as String): font])
            let line = CTLineCreateWithAttributedString(text)
            let runs = CTLineGetGlyphRuns(line) as? [CTRun] ?? []
            return runs.flatMap { run -> [CGGlyph] in
                var glyphs = [CGGlyph](repeating: 0, count: CTRunGetGlyphCount(run))
                CTRunGetGlyphs(run, CFRange(location: 0, length: 0), &glyphs)
                return glyphs
            }
        }
        let base = try shapedGlyphs(.base)
        let ui = try shapedGlyphs(.ui)
        #expect(base.count == 3 && ui.count == 3)
        #expect(base != ui, "base \(base) ui \(ui)")
    }
}

@Suite("Typography roles")
struct TypographyTests {
    @Test(
        "Each role scales with the Dynamic Type style of its purpose",
        arguments: [
            (QeetrixTextRole.display, Font.TextStyle.largeTitle), (.title, .title), (.heading, .title3), (.body, .body),
            (.label, .subheadline), (.labelCompact, .footnote), (.caption, .caption), (.micro, .caption2), (.code, .body),
        ])
    func dynamicType(role: QeetrixTextRole, style: Font.TextStyle) {
        #expect(role.textStyle == style)
    }

    @Test("Metrics use the bundled font, the token size and the role's line height")
    func metrics() throws {
        for role in QeetrixTextRole.allCases {
            let metrics = QeetrixTextMetrics(role: role)
            #expect(metrics.usesBundledFont, "\(role)")
            #expect(metrics.pointSize == role.tokens.size)
            #expect(metrics.weight == role.tokens.weight)
            #expect(metrics.lineSpacing >= 0)
            let tracking: CGFloat = CGFloat(role.tokens.letterSpacing) * role.tokens.size
            #expect(metrics.tracking == tracking)
        }
        // Body is 14 pt at 1.5×: 21 pt lines, so the spacing is 21 minus the font's natural height.
        let body = QeetrixTextMetrics(role: .body)
        let font = try #require(QeetrixFontRegistry.font(.sans, size: 14, weight: .regular, geometry: .ui))
        let natural = CTFontGetAscent(font) + CTFontGetDescent(font) + CTFontGetLeading(font)
        #expect(abs(body.lineSpacing - max(0, 21 - natural)) < 1e-9)
    }

    @Test("A scaled size flows into the font and the paragraph metrics")
    func scaledSize() throws {
        let metrics = QeetrixTextMetrics(role: .body, size: 28)
        #expect(metrics.pointSize == 28)
        let font = try #require(QeetrixFontRegistry.font(.sans, size: 28, weight: .regular, geometry: .ui))
        #expect(QeetrixFontRegistry.variations(of: font)["opsz"] == 28)
    }

    @Test("Bold Text moves one step up the weight scale, capped at the heaviest")
    func boldText() {
        #expect(QeetrixTextMetrics(role: .body, legibilityWeight: .bold).weight == .medium)
        #expect(QeetrixTextMetrics(role: .title, legibilityWeight: .bold).weight == .bold)
        #expect(QeetrixTextMetrics(role: .body, legibilityWeight: .regular).weight == .regular)
        #expect(QeetrixFontWeight.scale.last == .bold)
    }

    @Test("The system-font fallback keeps the role's weight")
    func fallbackWeights() {
        #expect(QeetrixTextMetrics.systemWeight(.regular) == .regular)
        #expect(QeetrixTextMetrics.systemWeight(.medium) == .medium)
        #expect(QeetrixTextMetrics.systemWeight(.semibold) == .semibold)
        #expect(QeetrixTextMetrics.systemWeight(.bold) == .bold)
    }

    @Test("Styled text renders with ink")
    @MainActor
    func renders() throws {
        let image = try #require(Rendered(Text("Qeet").qeetrixTextStyle(.title).foregroundStyle(.black).padding(4).background(.white)))
        var inked = 0
        for y in 0..<image.height {
            for x in 0..<image.width where image.pixel(x, y).r < 128 { inked += 1 }
        }
        #expect(inked > 50)
    }
}
