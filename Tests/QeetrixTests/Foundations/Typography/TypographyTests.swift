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
        #expect(QeetrixFontFamily.sans.face.resourceName == "QeetSans")
        #expect(QeetrixFontFamily.mono.face.resourceName == "FiraCode-VF")
        for family in QeetrixFontFamily.allCases {
            let bundled = try #require(QeetrixFontRegistry.url(of: family))
            #expect(bundled.lastPathComponent == "\(family.face.resourceName).ttf")
            let font = try #require(QeetrixFontRegistry.font(family, size: 17, weight: .regular))
            let source = CTFontCopyAttribute(font, kCTFontURLAttribute) as? URL
            #expect(source?.standardizedFileURL == bundled.standardizedFileURL)
            #expect(CTFontCopyFamilyName(font) as String == family.face.familyName)
        }
    }

    @Test("Bundled TTFs are the files @qeetrix/tokens ships, by the sha256 its native.json and the provenance record give")
    func bundledFiles() throws {
        let provenance = try QeetrixProvenance.bundled()
        let lock = try Repository.json("Upstream/upstream.lock.json") as? [String: Any]
        let locked = lock?["fonts"] as? [[String: String]] ?? []
        for family in QeetrixFontFamily.allCases {
            let face = family.face
            let url = try #require(Bundle.module.url(forResource: face.resourceName, withExtension: "ttf", subdirectory: "Fonts"))
            let digest = SHA256.hash(data: try Data(contentsOf: url)).map { String(format: "%02x", $0) }.joined()
            #expect(provenance.fonts.first { $0.family == family.rawValue }?.sha256 == digest)
            #expect(locked.first { $0["family"] == family.rawValue }?["ttfSHA256"] == digest)
        }
        #expect(Bundle.module.url(forResource: "QeetSans-OFL", withExtension: "txt", subdirectory: "Fonts") != nil)
        #expect(Bundle.module.url(forResource: "FiraCode-OFL", withExtension: "txt", subdirectory: "Fonts") != nil)
    }

    @Test("Qeet Sans carries all six axes; Fira Code its weight")
    func axes() throws {
        let face = QeetrixFontFamily.sans.face
        #expect(face.webFamily == "Qeet Sans")
        #expect(face.axes.map(\.tag) == ["opsz", "GEOM", "wght", "YTAS", "SHRP", "ital"])
        let geometry = try #require(face.axis("GEOM"))
        #expect(geometry.minimum == 0 && geometry.maximum == 100)
        #expect(face.axis("wght")?.minimum == 400 && face.axis("wght")?.maximum == 700)
        #expect(face.axis("opsz")?.minimum == 8 && face.axis("opsz")?.maximum == 45)
        #expect(QeetrixFontFamily.mono.face.webFamily == "Fira Code")
        #expect(QeetrixFontFamily.mono.face.axes.map(\.tag) == ["wght"])
    }

    @Test("A font carries the weight, letter style and optical size it was asked for")
    func variations() throws {
        let font = try #require(QeetrixFontRegistry.font(.sans, size: 20, weight: .semibold, geometry: .heading))
        let variations = QeetrixFontRegistry.variations(of: font)
        #expect(variations["wght"] == 600)
        #expect(variations["GEOM"] == 50)
        #expect(variations["opsz"] == 20, "font-optical-sizing: auto — the point size")
        #expect(CTFontGetSize(font) == 20)
        // Out-of-range requests clamp to the axis, as CSS does.
        let clamped = try #require(QeetrixFontRegistry.font(.sans, size: 64, weight: QeetrixFontWeight(900), geometry: .display))
        #expect(QeetrixFontRegistry.variations(of: clamped)["wght"] == 700)
        #expect(QeetrixFontRegistry.variations(of: clamped)["opsz"] == 45)
        #expect(QeetrixFontRegistry.variations(of: clamped)["GEOM"] == 100)
    }

    @Test("Different letter styles shape to different glyphs")
    func geometryChangesGlyphs() throws {
        // Cal Sans swaps letterforms along GEOM with OpenType feature variations, applied when text is shaped.
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
        let body = try shapedGlyphs(.body)
        let display = try shapedGlyphs(.display)
        #expect(body.count == 3 && display.count == 3)
        #expect(body != display, "A11y \(body) Geo \(display)")
    }
}

@Suite("Typography roles")
struct TypographyTests {
    @Test(
        "Each role scales with the Dynamic Type style of its purpose",
        arguments: [
            (QeetrixTextRole.displayLg, Font.TextStyle.largeTitle), (.displayMd, .largeTitle), (.displaySm, .largeTitle),
            (.headingLg, .largeTitle), (.headingMd, .title), (.headingSm, .title2), (.titleLg, .title3), (.titleMd, .headline),
            (.titleSm, .headline), (.bodyLg, .body), (.bodyMd, .body), (.bodySm, .footnote), (.labelLg, .callout),
            (.labelMd, .subheadline), (.labelSm, .footnote), (.labelCaps, .caption2), (.codeMd, .body), (.codeSm, .footnote),
        ])
    func dynamicType(role: QeetrixTextRole, style: Font.TextStyle) {
        #expect(role.textStyle == style)
    }

    @Test("Letter styles are the tokens': display Geo, heading and title Base, body and label A11y, code none (no GEOM axis)")
    func letterStyles() {
        for role in QeetrixTextRole.allCases {
            let group = role.rawValue.split(separator: ".").first.map(String.init) ?? ""
            let expected: QeetrixFontGeometry? =
                switch group {
                case "display": .display
                case "heading", "title": .heading
                case "body", "label": .body
                default: nil
                }
            #expect(role.tokens.geometry == expected, "\(role)")
            #expect(role.tokens.family == (group == "code" ? .mono : .sans), "\(role)")
        }
    }

    @Test("Metrics use the bundled font, the token size and the role's line height")
    func metrics() throws {
        for role in QeetrixTextRole.allCases {
            let metrics = QeetrixTextMetrics(role: role)
            #expect(metrics.usesBundledFont, "\(role)")
            #expect(metrics.pointSize == role.tokens.size)
            #expect(metrics.weight == role.tokens.weight)
            #expect(metrics.lineSpacing >= 0)
            #expect(metrics.tracking == CGFloat(role.tokens.letterSpacing))
        }
        // body.md is 14 pt with exactly 20 pt lines, so the spacing is 20 minus the font's natural height.
        let body = QeetrixTextMetrics(role: .bodyMd)
        let font = try #require(QeetrixFontRegistry.font(.sans, size: 14, weight: .regular, geometry: .body))
        let natural = CTFontGetAscent(font) + CTFontGetDescent(font) + CTFontGetLeading(font)
        #expect(QeetrixTextRole.bodyMd.tokens.size * QeetrixTextRole.bodyMd.tokens.lineHeight == 20)
        #expect(abs(body.lineSpacing - max(0, 20 - natural)) < 1e-9)
    }

    @Test("label.caps is the one tracked role, and its tracking scales with the text")
    func tracking() {
        #expect(QeetrixTextRole.allCases.filter { $0.tokens.letterSpacing != 0 } == [.labelCaps])
        #expect(QeetrixTextRole.labelCaps.tokens.letterSpacing == 0.66)
        #expect(abs(QeetrixTextMetrics(role: .labelCaps, size: 22).tracking - 1.32) < 1e-9)
    }

    @Test("A scaled size flows into the font and the optical size")
    func scaledSize() throws {
        let metrics = QeetrixTextMetrics(role: .bodyMd, size: 28)
        #expect(metrics.pointSize == 28)
        let font = try #require(QeetrixFontRegistry.font(.sans, size: 28, weight: .regular, geometry: .body))
        #expect(QeetrixFontRegistry.variations(of: font)["opsz"] == 28)
    }

    @Test("Bold Text steps up the scale, then 100 more up to the font's 700")
    func boldText() {
        #expect(QeetrixTextMetrics(role: .bodyMd, legibilityWeight: .bold).weight == .medium)
        #expect(QeetrixTextMetrics(role: .labelMd, legibilityWeight: .bold).weight == .semibold)
        #expect(QeetrixTextMetrics(role: .titleMd, legibilityWeight: .bold).weight == QeetrixFontWeight(700))
        #expect(QeetrixTextMetrics(role: .bodyMd, legibilityWeight: .regular).weight == .regular)
        #expect(QeetrixFontWeight(700).bolder(in: .sans) == QeetrixFontWeight(700), "Capped at the axis")
        #expect(QeetrixFontWeight.semibold.bolder(in: .mono) == QeetrixFontWeight(700))
    }

    @Test("The system-font fallback keeps the role's weight")
    func fallbackWeights() {
        #expect(QeetrixTextMetrics.systemWeight(.regular) == .regular)
        #expect(QeetrixTextMetrics.systemWeight(.medium) == .medium)
        #expect(QeetrixTextMetrics.systemWeight(.semibold) == .semibold)
        #expect(QeetrixTextMetrics.systemWeight(QeetrixFontWeight(700)) == .bold)
    }

    @Test("A role at another weight keeps everything else")
    func weighted() {
        let spec = QeetrixComponentType.role(.labelMd, .semibold)
        #expect(spec.tokens.weight == .semibold)
        #expect(spec.tokens.size == QeetrixTextRole.labelMd.tokens.size)
        #expect(spec.tokens.geometry == QeetrixTextRole.labelMd.tokens.geometry)
        #expect(spec.textStyle == QeetrixTextRole.labelMd.textStyle)
        #expect(QeetrixComponentType.fixed(.labelSm).textStyle == nil, "Fixed text never scales")
    }

    @Test("Styled text renders with ink")
    @MainActor
    func renders() throws {
        let image = try #require(Rendered(Text("Qeet").qeetrixTextStyle(.headingSm).foregroundStyle(.black).padding(4).background(.white)))
        var inked = 0
        for y in 0..<image.height {
            for x in 0..<image.width where image.pixel(x, y).r < 128 { inked += 1 }
        }
        #expect(inked > 50)
    }
}
