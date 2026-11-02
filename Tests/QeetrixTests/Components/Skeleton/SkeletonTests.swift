import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Skeleton")
struct SkeletonTests {
    @Test("Variants and sizes are @qeetrix/react's; circles are the avatar's 24, 32, 40 and 48 pt")
    func names() {
        #expect(QeetrixSkeletonVariant.allCases.map(\.rawValue) == ["text", "block", "circle"])
        #expect(QeetrixSkeletonSize.allCases.map(\.rawValue) == ["sm", "md", "lg", "xl"])
        #expect(QeetrixSkeletonSize.allCases.map(\.points) == [24, 32, 40, 48])
        #expect(QeetrixSkeletonSize.allCases.map(\.points) == QeetrixAvatarSize.allCases.map(\.points))
    }

    @Test("Corners: radius.sm for text, radius.surface for a block, round for a circle")
    func corners() {
        #expect(QeetrixSkeletonMetrics.radius(.text) == QeetrixRadius.sm)
        #expect(QeetrixSkeletonMetrics.radius(.block) == QeetrixRadius.surface)
        #expect(QeetrixSkeletonMetrics.radius(.circle) == QeetrixRadius.full)
    }

    @Test("The pulse: to 45% and back, 4 × motion.duration.slower each way")
    func pulse() {
        #expect(QeetrixSkeletonMetrics.pulseOpacity == 0.45)
        #expect(QeetrixSkeletonMetrics.pulse.seconds == 4 * QeetrixDuration.slower.seconds)
        #expect(abs(QeetrixSkeletonMetrics.pulse.seconds - 1.6) < 1e-9)
    }

    @Test("A text line is body.md's 20 pt line, a block 64 pt, a circle its diameter; height replaces the default")
    func sizes() throws {
        func size(_ view: some View) throws -> (Int, Int) {
            let image = try #require(Rendered(view))
            return (image.width, image.height)
        }
        #expect(try size(QeetrixSkeleton().frame(width: 100)) == (100, 20))
        #expect(try size(QeetrixSkeleton(.block).frame(width: 100)) == (100, 64))
        #expect(try size(QeetrixSkeleton(.block, height: 120).frame(width: 100)) == (100, 120))
        #expect(try size(QeetrixSkeleton(.circle)) == (32, 32))
        #expect(try size(QeetrixSkeleton(.circle, size: .xl, height: 10)) == (48, 48))
    }

    @Test("Lines: 1em bars centred in their lines, so the paragraph is the text's height exactly")
    func lines() throws {
        let geometry = QeetrixSkeletonMetrics.lines(count: 3, em: 14, lineHeight: 20)
        #expect(geometry.bar == 14 && geometry.gap == 6 && geometry.height == 60)
        let image = try #require(Rendered(QeetrixSkeleton(lines: 3).frame(width: 100)))
        #expect(image.height == 60)
        #expect(try #require(Rendered(QeetrixSkeleton(lines: 0).frame(width: 100))).height == 20, "At least one line")
        #expect(try #require(Rendered(QeetrixSkeleton(lines: 2, role: .bodySm).frame(width: 100))).height == 32)
    }

    @Test("The fill is color.bg.neutral.subtle-pressed; the last of several lines is 60% wide, from the start")
    func look() throws {
        let fill = QeetrixTheme.light.resolve(.bgNeutralSubtlePressed).bytes
        let paragraph = QeetrixSkeletonLines(count: 2, role: .bodyMd)
            .frame(width: 100).environment(\.colorScheme, .light)
        let image = try #require(Rendered(paragraph))
        // Bars at 3–17 and 23–37 (14 pt bars, 6 pt apart, 3 pt in).
        #expect(close(fill, image.pixel(90, 10)), "The first line is full width")
        #expect(close(fill, image.pixel(50, 30)))
        #expect(image.pixel(70, 30).a == 0, "The last line stops at 60%")
        #expect(image.pixel(50, 1).a == 0, "Half the gap above the first bar")
        let rtl = try #require(Rendered(paragraph.environment(\.layoutDirection, .rightToLeft)))
        #expect(rtl.pixel(30, 30).a == 0, "In right to left the short line starts at the right")
        #expect(close(fill, rtl.pixel(50, 30)))
        let block = try #require(Rendered(QeetrixSkeletonSingle(variant: .block, size: .md, height: nil).frame(width: 100)))
        #expect(close(fill, block.pixel(50, 32)))
    }

    @Test("Skeletons and their group render, pulsing or still")
    func renders() {
        let group = HStack {
            QeetrixSkeleton(.circle, size: .lg)
            QeetrixSkeleton(lines: 2)
        }
        .qeetrixSkeletonGroup(label: Text("Loading accounts"))
        #expect(ImageRenderer(content: group.frame(width: 300)).cgImage != nil)
        #expect(ImageRenderer(content: Color.gray.frame(width: 10, height: 10).modifier(QeetrixSkeletonPulse.Pulsing())).cgImage != nil)
    }
}
