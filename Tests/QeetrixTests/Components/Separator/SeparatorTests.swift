import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Separator")
struct SeparatorTests {
    @Test("Tones: subtle (the default), default, strong — each its border token")
    func tones() {
        #expect(QeetrixSeparatorTone.allCases.map(\.color) == [.borderSubtle, .borderDefault, .borderStrong])
    }

    @Test("1 pt, horizontal by default, stretching along its axis")
    func geometry() throws {
        let horizontal = try #require(Rendered(QeetrixSeparator().frame(width: 80)))
        #expect(horizontal.width == 80 && horizontal.height == 1)
        let vertical = try #require(Rendered(QeetrixSeparator(.vertical, tone: .strong).frame(height: 30)))
        #expect(vertical.width == 1 && vertical.height == 30)
        let drawn = try #require(Rendered(QeetrixSeparator(tone: .strong).frame(width: 10).environment(\.colorScheme, .light)))
        #expect(close(QeetrixTheme.light.resolve(.borderStrong).bytes, drawn.pixel(5, 0)))
    }

    @Test("Decorative or not, it renders")
    func renders() {
        #expect(ImageRenderer(content: QeetrixSeparator(isDecorative: false).frame(width: 50)).cgImage != nil)
    }
}
