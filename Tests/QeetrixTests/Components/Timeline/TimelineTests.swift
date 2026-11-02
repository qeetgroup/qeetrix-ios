import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Timeline")
struct TimelineTests {
    @Test("Variants and tones are @qeetrix/react's; each tone colours the marker, danger the title too")
    func names() {
        #expect(QeetrixTimelineVariant.allCases.map(\.rawValue) == ["default", "compact"])
        #expect(QeetrixTimelineTone.allCases.map(\.rawValue) == ["neutral", "brand", "info", "success", "warning", "danger"])
        #expect(
            QeetrixTimelineTone.allCases.map { $0.markerColor(.default) } == [
                .iconSubtle, .iconBrand, .iconInfo, .iconSuccess, .iconWarning, .iconDanger,
            ])
        #expect(QeetrixTimelineTone.neutral.markerColor(.compact) == .borderStrong, "A neutral dot is border.strong")
        #expect(QeetrixTimelineTone.allCases.filter { $0.titleColor == .textDanger } == [.danger])
    }

    @Test("The marker is component.timeline.marker-size, restated from @qeetrix/tokens")
    func markerToken() throws {
        let tokens = try #require(Repository.json("Upstream/qeetrix-tokens/dtcg/tokens/component.tokens.json") as? [String: Any])
        let timeline = try #require((tokens["component"] as? [String: Any])?["timeline"] as? [String: Any])
        let size = try #require((timeline["marker-size"] as? [String: Any])?["$value"])
        #expect(Repository.points(size) == Double(QeetrixTimelineMetrics.markerSize))
        #expect(QeetrixTimelineMetrics.markerSize == 28)
        #expect(QeetrixTimelineMetrics.dot == 6)
        #expect(QeetrixTimelineMetrics.titleType.tokens.weight == QeetrixTextRole.labelMd.tokens.weight)
    }

    @Test("Gaps: 16 pt after an event (compact 8), 12 pt between groups, none after a group before an event")
    func gaps() {
        #expect(QeetrixTimelineMetrics.gap(after: .item, before: .item, variant: .default) == 16)
        #expect(QeetrixTimelineMetrics.gap(after: .item, before: .group, variant: .default) == 16)
        #expect(QeetrixTimelineMetrics.gap(after: .item, before: .item, variant: .compact) == 8)
        #expect(QeetrixTimelineMetrics.gap(after: .group, before: .group, variant: .default) == 12)
        #expect(QeetrixTimelineMetrics.gap(after: .group, before: .item, variant: .default) == 0)
    }

    @Test("The line runs from 4 pt under a marker to 4 pt above the next event")
    func lineGeometry() {
        let line = QeetrixTimelineMetrics.line(
            from: CGRect(x: 0, y: 0, width: 28, height: 28), to: CGRect(x: 0, y: 44, width: 300, height: 28))
        #expect(line.top == 32 && line.height == 8)
        #expect(
            QeetrixTimelineMetrics.line(from: CGRect(x: 0, y: 0, width: 28, height: 28), to: CGRect(x: 0, y: 20, width: 300, height: 28))
                .height == 0)
    }

    @Test("Two events: 28 pt each, 16 pt apart, joined by a 1 pt line at the marker's centre, mirrored in right to left")
    func joined() throws {
        func timeline(_ direction: LayoutDirection) throws -> Rendered {
            let view = QeetrixTimeline {
                QeetrixTimelineItem("Signed in", icon: .keyRound)
                QeetrixTimelineItem("Signed out", icon: .lock)
            }
            return try #require(
                Rendered(
                    view.frame(width: 300).background(Color.white).environment(\.colorScheme, .light).environment(
                        \.layoutDirection, direction)))
        }
        let line = QeetrixTheme.light.resolve(.borderSubtle).bytes
        let ltr = try timeline(.leftToRight)
        #expect(ltr.height == 28 + 16 + 28)
        // The marker spans 0–28; its centre column is 13.5–14.5, so pixel 13 or 14 carries the line.
        #expect(close(line, ltr.pixel(13, 36), tolerance: 40) || close(line, ltr.pixel(14, 36), tolerance: 40))
        #expect(ltr.pixel(13, 30).r == 255 && ltr.pixel(13, 42).r == 255, "4 pt clear of each marker")
        let rtl = try timeline(.rightToLeft)
        #expect(close(line, rtl.pixel(286, 36), tolerance: 40) || close(line, rtl.pixel(285, 36), tolerance: 40))
    }

    @Test("No line after the last event, between groups, or in the compact look")
    func unjoined() throws {
        let grouped = QeetrixTimeline {
            QeetrixTimelineGroup("Today") { QeetrixTimelineItem("Signed in", icon: .keyRound) }
            QeetrixTimelineGroup("Yesterday") { QeetrixTimelineItem("Signed out", icon: .lock) }
        }
        let image = try #require(Rendered(grouped.frame(width: 300).background(Color.white).environment(\.colorScheme, .light)))
        // label.caps' 16 pt line and 8 pt, the 28 pt event, 12 pt, then the next group.
        #expect(abs(image.height - ((16 + 8 + 28) * 2 + 12)) <= 1)
        // Clear from under the first marker to the next group's label.
        #expect((16 + 8 + 28 + 4..<16 + 8 + 28 + 12).allSatisfy { image.pixel(13, $0).r == 255 && image.pixel(14, $0).r == 255 })
        let compact = QeetrixTimeline(variant: .compact) {
            QeetrixTimelineItem("Approved")
            QeetrixTimelineItem("Requested")
        }
        let dots = try #require(Rendered(compact.frame(width: 300).background(Color.white)))
        // Two 20 pt title lines, 8 pt apart; the dots are 6 pt and centred on them.
        #expect(abs(dots.height - (20 + 8 + 20)) <= 2, "A point per text block on iOS")
        #expect(dots.pixel(3, 24).r == 255, "No line between the dots")
    }

    @Test("First lines share the marker's centre; a line taller than the marker moves the marker down to it")
    func offsets() throws {
        let normal = QeetrixTimelineMetrics.offsets(marker: 28, titleLine: 20, timeLine: 16)
        #expect(normal.marker == 0 && normal.text == 4 && normal.time == 6)
        let large = QeetrixTimelineMetrics.offsets(marker: 56, titleLine: 76, timeLine: 50)
        #expect(large.marker == 10 && large.text == 0 && large.time == 13)
        let dot = QeetrixTimelineMetrics.offsets(marker: 6, titleLine: 20, timeLine: 16)
        #expect(dot.marker == 7 && dot.text == 0 && dot.time == 2, "The dot: .5lh - 3px")
        #expect(try #require(Rendered(QeetrixTimelineItem("Signed in", icon: .keyRound).frame(width: 300))).height == 28)
    }

    @Test("Titles from a key, a string or Text, with a description and a time")
    func renders() {
        let timeline = QeetrixTimeline {
            QeetrixTimelineItem("Signed in", description: "Bengaluru", time: Text("2 min ago"), icon: .keyRound, tone: .success)
            QeetrixTimelineItem(String("Refused"), description: "Unknown device", time: Text("1 h ago"), tone: .danger)
            QeetrixTimelineItem(title: Text("Linked"), description: Text("iPhone"))
        }
        #expect(ImageRenderer(content: timeline.frame(width: 390)).cgImage != nil)
        #expect(ImageRenderer(content: timeline.frame(width: 390).environment(\.dynamicTypeSize, .accessibility3)).cgImage != nil)
    }
}
