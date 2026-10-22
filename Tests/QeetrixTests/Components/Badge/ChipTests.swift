import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Chip")
struct ChipTests {
    @Test("Sizes: 24, 28, 32 pt tall; text-xs, text-sm, text-sm")
    func sizes() {
        let metrics = QeetrixChipSize.allCases.map(QeetrixChipMetrics.init)
        #expect(metrics.map(\.height) == [24, 28, 32])
        #expect(metrics.map(\.paddingX) == [10, 12, 14])
        #expect(metrics.map(\.type.tokens.size) == [12, 14, 14])
    }

    @Test("Selected: the brand tint and edge, darker when pressed; resting: no fill, the default edge")
    func colors() {
        let selected = QeetrixChipMetrics.colors(isSelected: true, isPressed: false, isHovered: false, colorScheme: .light)
        #expect(selected.background == .surfaceBrandSubtle)
        #expect(selected.border == .borderBrand)
        #expect(
            QeetrixChipMetrics.colors(isSelected: true, isPressed: true, isHovered: false, colorScheme: .light).background
                == .surfaceBrandSubtleActive)
        let resting = QeetrixChipMetrics.colors(isSelected: false, isPressed: false, isHovered: false, colorScheme: .light)
        #expect(resting.background == nil)
        #expect(resting.border == .borderDefault)
        #expect(
            QeetrixChipMetrics.colors(isSelected: false, isPressed: false, isHovered: false, colorScheme: .dark).border == .borderStrong)
        #expect(
            QeetrixChipMetrics.colors(isSelected: false, isPressed: false, isHovered: true, colorScheme: .light).background
                == .surfaceInteractive)
    }

    @Test("A single-choice group replaces the value; a multiple-choice group toggles members")
    func groups() {
        final class Box {
            var one: String = "all"
            var many: Set<String> = ["a"]
        }
        let box = Box()
        let options = ["a", "b"].map { QeetrixOption($0, value: $0) }
        let single = QeetrixChipGroup("Status", selection: Binding(get: { box.one }, set: { box.one = $0 }), options: options)
        single.choose("b")
        #expect(box.one == "b")
        #expect(single.isSelected("b"))
        let multiple = QeetrixChipGroup("Labels", selection: Binding(get: { box.many }, set: { box.many = $0 }), options: options)
        multiple.choose("b")
        #expect(box.many == ["a", "b"])
        multiple.choose("a")
        #expect(box.many == ["b"])
        #expect(!multiple.isSelected("a"))
    }

    @Test("Every kind renders, light and dark; a chip is at its web height")
    func renders() throws {
        for scheme in [ColorScheme.light, .dark] {
            let chips = VStack {
                QeetrixChip("Unread", isSelected: .constant(true))
                QeetrixChip("Unread", isSelected: .constant(false), icon: .mail, size: .sm)
                QeetrixChip("Design", icon: .folder, size: .lg) {}
                QeetrixChipGroup("Status", selection: .constant("a"), options: [QeetrixOption("A", value: "a")]).disabled(true)
            }
            #expect(ImageRenderer(content: chips.environment(\.colorScheme, scheme)).cgImage != nil)
        }
        #expect(try #require(Rendered(QeetrixChip("Unread", isSelected: .constant(false)))).height == 28)
    }

    @Test("Wrapping rows: children keep their size, rows break before an overflow, centring is optional")
    func flow() throws {
        let row = QeetrixFlowLayout(spacing: 8) {
            Color.red.frame(width: 40, height: 10)
            Color.red.frame(width: 40, height: 10)
            Color.red.frame(width: 40, height: 10)
        }
        let rendered = try #require(Rendered(row.frame(width: 100)))
        #expect(rendered.height == 28, "Two rows: 10 + 8 + 10")
        #expect(rendered.pixel(20, 5).r > 200)
        #expect(rendered.pixel(60, 5).r > 200)
        #expect(rendered.pixel(60, 23).a == 0, "The third moved to the second row")
        let centred = QeetrixFlowLayout(spacing: 8, alignment: .center) { Color.red.frame(width: 40, height: 10) }
        let rendered2 = try #require(Rendered(centred.frame(width: 100)))
        #expect(rendered2.pixel(5, 5).a == 0)
        #expect(rendered2.pixel(50, 5).r > 200)
    }
}
