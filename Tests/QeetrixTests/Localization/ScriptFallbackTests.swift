import CoreText
import Foundation
import Testing

@testable import Qeetrix

/// Qeet Sans covers Latin; other scripts reach the system's fonts through CoreText's cascade. These tests
/// show both halves on the machine they run on: the gap, and that the cascade fills it.
@Suite("Script fallback")
struct ScriptFallbackTests {
    static let samples = [
        ("Devanagari", "हिन्दी"),
        ("Tamil", "தமிழ்"),
        ("Arabic", "العربية"),
        ("Bengali", "বাংলা"),
    ]

    @Test("Qeet Sans has Latin glyphs, and none for other scripts")
    func coverage() throws {
        let font = try #require(QeetrixFontRegistry.font(.sans, size: 17, weight: .regular))
        #expect(covers(font, "Qeetrix"))
        for (script, sample) in Self.samples {
            #expect(!covers(font, sample), "\(script) is not in Qeet Sans; the cascade supplies it")
        }
    }

    @Test("For each script, CoreText's cascade finds a system font that has the glyphs")
    func cascade() throws {
        let font = try #require(QeetrixFontRegistry.font(.sans, size: 17, weight: .regular))
        for (script, sample) in Self.samples {
            let fallback = CTFontCreateForString(font, sample as CFString, CFRange(location: 0, length: (sample as NSString).length))
            #expect(covers(fallback, sample), "A fallback covers \(script)")
            #expect(CTFontCopyPostScriptName(fallback) as String != CTFontCopyPostScriptName(font) as String)
        }
    }

    private func covers(_ font: CTFont, _ text: String) -> Bool {
        let utf16 = Array(text.utf16)
        var glyphs = [CGGlyph](repeating: 0, count: utf16.count)
        return CTFontGetGlyphsForCharacters(font, utf16, &glyphs, utf16.count)
    }
}
