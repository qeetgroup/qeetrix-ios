import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Skeleton")
struct SkeletonTests {
    @Test("The fill is the skeleton token: a translucent tint of the foreground")
    func fill() throws {
        let rendered = try #require(Rendered(QeetrixSkeleton().frame(width: 40, height: 20).environment(\.colorScheme, .light)))
        let pixel = rendered.pixel(20, 10)
        #expect(pixel.a > 15 && pixel.a < 40, "About 10% of the foreground")
        #expect(QeetrixSkeletonTokens.background.light == .rgba(QeetrixSkeletonTokens.background.light.rgba(for: .light)))
    }

    @Test("Shapes: a rounded block, a circle, a pill")
    func shapes() throws {
        let circle = try #require(Rendered(QeetrixSkeleton(.circle).frame(width: 40, height: 40)))
        #expect(circle.pixel(1, 1).a == 0, "The corner is outside the circle")
        #expect(circle.pixel(20, 20).a > 0)
        let block = try #require(Rendered(QeetrixSkeleton(.rectangle).frame(width: 40, height: 40)))
        #expect(block.pixel(20, 1).a > 0)
        #expect(ImageRenderer(content: QeetrixSkeleton(.capsule).frame(width: 60, height: 20)).cgImage != nil)
    }

    @Test("Text lines: the role's size tall, the last one 60% wide")
    func text() throws {
        let metrics = QeetrixSkeletonTextMetrics(size: 14, lineHeight: 1.5)
        #expect(metrics.barHeight == 14)
        #expect(metrics.spacing == 7)
        let lines = try #require(Rendered(QeetrixSkeletonText(lines: 2, role: .body).frame(width: 200)))
        let last = lines.height - 4
        #expect(lines.pixel(150, 4).a > 0, "The first line runs the full width")
        #expect(lines.pixel(150, last).a == 0, "The last stops at 60%")
        #expect(lines.pixel(100, last).a > 0)
        let one = try #require(Rendered(QeetrixSkeletonText(lines: 1).frame(width: 200)))
        #expect(one.pixel(190, one.height / 2).a > 0, "A single line runs the full width")
        #expect(try #require(Rendered(QeetrixSkeletonText(lines: 0).frame(width: 200))).height == one.height, "At least one line")
    }
}
