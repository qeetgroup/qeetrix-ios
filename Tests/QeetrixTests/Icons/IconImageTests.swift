import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Icon images")
struct IconImageTests {
    @Test("An icon image is the icon's size and takes the foreground colour")
    func template() throws {
        let rendered = try #require(Rendered(Image(qeetrix: .x).foregroundStyle(Color.red)))
        #expect(rendered.width == 20, "md")
        #expect(rendered.height == 20)
        var red = 0
        for y in 0..<rendered.height {
            for x in 0..<rendered.width {
                let pixel = rendered.pixel(x, y)
                if pixel.a > 200 && pixel.r > 200 && pixel.g < 60 { red += 1 }
            }
        }
        #expect(red > 10, "Template rendering: drawn in the foreground colour")
    }

    @Test("Sizes follow the icon size scale")
    func sizes() throws {
        #expect(try #require(Rendered(Image(qeetrix: .house, size: .lg))).width == Int(QeetrixIconSize.lg.points))
        #expect(try #require(Rendered(Image(qeetrix: .house, size: .sm))).width == Int(QeetrixIconSize.sm.points))
    }

    @Test("Each icon and style is drawn once, then reused")
    func cache() {
        // A combination no other test draws, so the count is this test's alone.
        _ = Image(qeetrix: .copy, size: .xs, variant: .outline, stroke: .thin)
        let count = QeetrixIconImageCache.images.count
        _ = Image(qeetrix: .copy, size: .xs, variant: .outline, stroke: .thin)
        #expect(QeetrixIconImageCache.images.count == count)
        _ = Image(qeetrix: .copy, size: .xs, variant: .filled, stroke: .thin)
        #expect(QeetrixIconImageCache.images.count == count + 1)
    }

    @Test("The cache is bounded")
    func bounded() {
        for points in stride(from: 1, through: CGFloat(QeetrixIconImageCache.capacity + 8), by: 1) {
            _ = Image(qeetrix: .minus, size: QeetrixIconSize(points / 4 + 100))
        }
        #expect(QeetrixIconImageCache.images.count <= QeetrixIconImageCache.capacity)
    }
}
