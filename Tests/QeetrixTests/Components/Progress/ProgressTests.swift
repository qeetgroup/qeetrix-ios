import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Progress")
struct ProgressTests {
    @Test("Track thicknesses: 4, 8, 12")
    func sizes() {
        #expect(QeetrixProgressSize.allCases.map(\.trackHeight) == [4, 8, 12])
    }

    @Test("The value is a whole percentage, formatted for the locale")
    func percent() {
        #expect(QeetrixProgressBody.percent(0.4, locale: Locale(identifier: "en_US")) == "40%")
        #expect(QeetrixProgressBody.percent(0.666, locale: Locale(identifier: "en_US")) == "67%")
        let french = QeetrixProgressBody.percent(0.4, locale: Locale(identifier: "fr_FR"))
        #expect(french.hasPrefix("40") && french.hasSuffix("%") && french != "40%")
    }

    @Test("The hatch draws 4 pt bands every 8 pt across the whole track")
    func hatch() {
        let rect = CGRect(x: 0, y: 0, width: 80, height: 8)
        let path = QeetrixProgressHatch().path(in: rect)
        #expect(!path.isEmpty)
        #expect(path.boundingRect.minX <= rect.minX && path.boundingRect.maxX >= rect.maxX)
        // Bands and gaps are equal (4 pt each along the bands' normal), so half of any line is covered…
        let samples = stride(from: 0.0, to: 80.0, by: 0.125).map { CGPoint(x: $0, y: 4) }
        let covered = Double(samples.filter { path.contains($0) }.count) / Double(samples.count)
        #expect(abs(covered - 0.5) < 0.03)
        // …and the pattern repeats every 8 pt along the normal: 8√2 pt along a horizontal line.
        let period = 8 * 2.squareRoot()
        for x in stride(from: 0.0, to: 60.0, by: 1.0) {
            #expect(path.contains(CGPoint(x: x, y: 4)) == path.contains(CGPoint(x: x + period, y: 4)))
        }
    }

    @Test("Bars render determinate, indeterminate and through the style")
    func renders() {
        #expect(ImageRenderer(content: QeetrixProgress("Uploading", value: 0.4).frame(width: 200)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixProgress(label: nil, value: nil).frame(width: 200)).cgImage != nil)
        #expect(ImageRenderer(content: ProgressView(value: 2, total: 4).progressViewStyle(.qeetrix()).frame(width: 200)).cgImage != nil)
    }
}

@Suite("Progress sweep")
struct ProgressSweepTests {
    @Test("The segment is 40% wide, travels from just off the start to just off the end, and never leaves the track")
    func segment() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 8)
        #expect(QeetrixProgressSegment(phase: 0).path(in: rect).isEmpty, "Starts just off the start")
        #expect(QeetrixProgressSegment(phase: 1).path(in: rect).isEmpty, "Ends just off the end")
        let middle = QeetrixProgressSegment(phase: 0.5).path(in: rect).boundingRect
        #expect(abs(middle.width - 40) < 1e-9)
        #expect(abs(middle.midX - 50) < 1e-9)
        // Entering and leaving, it is cut to the track: its path, and so its frame, stays inside.
        for phase in stride(from: 0.0, through: 1.0, by: 0.05) {
            let bounds = QeetrixProgressSegment(phase: phase).path(in: rect).boundingRect
            #expect(bounds.isNull || rect.contains(bounds))
        }
        #expect(abs(QeetrixProgressSegment(phase: 0.1).path(in: rect).boundingRect.width - 14) < 1e-9)
    }
}
