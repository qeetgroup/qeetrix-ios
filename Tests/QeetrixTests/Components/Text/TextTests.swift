import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Text")
struct TextTests {
    @Test("Sizes are the body roles; weights 400, 500, 600")
    func sizes() {
        #expect(QeetrixTextSize.allCases.map(\.role) == [.bodySm, .bodyMd, .bodyLg])
        #expect(QeetrixTextSize.allCases.map { $0.role.tokens.size } == [12, 14, 16])
        #expect(QeetrixTextWeight.allCases.map(\.fontWeight.value) == [400, 500, 600])
    }

    @Test("The spec: the body role's size, line height and A11y letters at the weight; mono is Fira Code at the same size")
    func spec() {
        let medium = QeetrixText.spec(size: .md, weight: .medium, mono: false)
        #expect(medium.tokens.size == 14 && medium.tokens.weight == .medium)
        #expect(medium.tokens.family == .sans && medium.tokens.geometry == .body)
        #expect(medium.textStyle == QeetrixTextRole.bodyMd.textStyle)
        let mono = QeetrixText.spec(size: .sm, weight: .regular, mono: true)
        #expect(mono.tokens.family == .mono && mono.tokens.geometry == nil)
        #expect(mono.tokens.size == 12 && mono.tokens.lineHeight == QeetrixTextRole.bodySm.tokens.lineHeight)
    }

    @Test("A tone colours the text; without one it inherits")
    func tones() throws {
        let toned = try #require(Rendered(QeetrixText("Qeet", tone: .danger).background(.white).environment(\.colorScheme, .light)))
        let danger = QeetrixTheme.light.resolve(.textDanger).bytes
        var found = false
        for y in 0..<toned.height {
            for x in 0..<toned.width where close(danger, toned.pixel(x, y), tolerance: 12) { found = true }
        }
        #expect(found)
        let inherited = try #require(Rendered(QeetrixText("Qeet").foregroundStyle(Color.red).background(.white)))
        var red = false
        for y in 0..<inherited.height {
            for x in 0..<inherited.width {
                let pixel = inherited.pixel(x, y)
                if pixel.r > 200 && pixel.g < 80 { red = true }
            }
        }
        #expect(red)
    }

    @Test("truncate limits the lines; align fills the width")
    func layout() throws {
        let long = String(repeating: "Invoices are sent on the first of each month. ", count: 6)
        let one = try #require(Rendered(QeetrixText(long, truncate: 1).frame(width: 200)))
        let all = try #require(Rendered(QeetrixText(long).frame(width: 200)))
        #expect(one.height < 30)
        #expect(all.height > 60)
        let centred = try #require(Rendered(QeetrixText("Hi", align: .center).frame(width: 200)))
        #expect(centred.width == 200)
    }

    @Test("Every size, weight and tone renders")
    func renders() {
        for size in QeetrixTextSize.allCases {
            for weight in QeetrixTextWeight.allCases {
                #expect(ImageRenderer(content: QeetrixText("Qeet", size: size, weight: weight)).cgImage != nil)
            }
        }
        for tone in QeetrixTextTone.allCases {
            #expect(ImageRenderer(content: QeetrixText("Qeet", tone: tone, mono: true)).cgImage != nil)
        }
    }
}
