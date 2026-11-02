import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Page indicator")
struct PageIndicatorTests {
    @Test("Moving stays inside the pages, from any starting page")
    func moving() {
        #expect(QeetrixPageIndicatorMetrics.page(1, moved: 1, count: 4) == 2)
        #expect(QeetrixPageIndicatorMetrics.page(3, moved: 1, count: 4) == 3)
        #expect(QeetrixPageIndicatorMetrics.page(0, moved: -1, count: 4) == 0)
        #expect(QeetrixPageIndicatorMetrics.page(9, moved: -1, count: 4) == 2)
        #expect(QeetrixPageIndicatorMetrics.page(0, moved: 1, count: 0) == 0)
        #expect(QeetrixPageIndicatorMetrics.clamped(-2, count: 4) == 0)
        #expect(QeetrixPageIndicatorMetrics.clamped(7, count: 4) == 3)
    }

    @Test("8 pt marks 8 pt apart; the current one three marks wide; 16 pt either side")
    func metrics() {
        #expect((QeetrixPageIndicatorMetrics.mark, QeetrixPageIndicatorMetrics.currentWidth) == (8, 24))
        #expect(QeetrixPageIndicatorMetrics.gap == QeetrixSpace.gapSm)
        #expect(QeetrixPageIndicatorMetrics.padding == QeetrixSpace.insetLg)
        // 16 + three marks and their gaps (3 × 16) + the current mark (24) + 16.
        #expect(QeetrixPageIndicatorMetrics.width(count: 4) == 104)
        #expect(QeetrixPageIndicatorMetrics.width(count: 0) == 0)
    }

    @Test("The back and on targets are at least 44 pt wide whenever there is a page to move to")
    func targets() {
        for count in 2...8 {
            let width = QeetrixPageIndicatorMetrics.width(count: count)
            for current in 0..<count {
                let back = QeetrixPageIndicatorMetrics.split(current: current)
                if current > 0 { #expect(back >= 44, "back from \(current) of \(count)") }
                if current < count - 1 { #expect(width - back >= 44, "on from \(current) of \(count)") }
            }
        }
    }

    @Test("Ember for the current page, the 3:1 control border for the rest; the disabled colours when disabled")
    func colours() {
        #expect(QeetrixPageIndicatorMetrics.color(isCurrent: true, isEnabled: true) == .bgBrandBold)
        #expect(QeetrixPageIndicatorMetrics.color(isCurrent: false, isEnabled: true) == .borderStrong)
        #expect(QeetrixPageIndicatorMetrics.color(isCurrent: true, isEnabled: false) == .iconDisabled)
        #expect(QeetrixPageIndicatorMetrics.color(isCurrent: false, isEnabled: false) == .borderDisabled)
    }

    @Test("VoiceOver's value is \"Page 2 of 4\"")
    func value() {
        #expect(QeetrixPageIndicatorStrings.value(page: 2, count: 4, locale: Locale(identifier: "en_US")) == "Page 2 of 4")
    }

    @Test("The drawn marks: 44 pt tall, the current page wide and Ember, the others border.strong")
    func drawn() throws {
        let view = QeetrixPageIndicator(page: .constant(1), count: 4).environment(\.colorScheme, .light)
        let image = try #require(Rendered(view))
        let light = QeetrixTheme.light
        #expect(image.height == 44)
        #expect(image.width == Int(QeetrixPageIndicatorMetrics.width(count: 4)))
        // The first mark at 16–24, the current one at 32–56, the third at 64–72.
        #expect(close(light.resolve(.borderStrong).bytes, image.pixel(20, 22)))
        #expect(close(light.resolve(.bgBrandBold).bytes, image.pixel(44, 22)))
        #expect(close(light.resolve(.borderStrong).bytes, image.pixel(68, 22)))
        #expect(image.pixel(28, 22).a == 0, "the gap between marks")
    }

    @Test("It renders for one page and many, disabled, and draws nothing for none")
    func renders() throws {
        #expect(ImageRenderer(content: QeetrixPageIndicator(page: .constant(0), count: 1)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixPageIndicator(page: .constant(5), count: 8, label: Text("Onboarding"))).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixPageIndicator(page: .constant(2), count: 3).disabled(true)).cgImage != nil)
        let none = ImageRenderer(content: QeetrixPageIndicator(page: .constant(0), count: 0)).cgImage
        #expect(none == nil || none?.width == 0)
    }
}
