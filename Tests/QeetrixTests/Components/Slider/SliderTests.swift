import SwiftUI
import Testing

@testable import Qeetrix

private let enIN = Locale(identifier: "en-IN")

@MainActor
@Suite("Slider")
struct SliderTests {
    @Test("Values snap to steps from the minimum, stay inside the bounds, and shed floating-point noise")
    func snapping() {
        let model = QeetrixSliderModel(bounds: 0...100, step: 5)
        #expect(model.snapped(42) == 40)
        #expect(model.snapped(43) == 45)
        #expect(model.snapped(-10) == 0)
        #expect(model.snapped(120) == 100)
        #expect(model.snapped(.nan) == 0)
        let uneven = QeetrixSliderModel(bounds: 0...10, step: 3)
        #expect(uneven.snapped(10) == 9, "the last step under the maximum")
        #expect(QeetrixSliderModel(bounds: 0...1, step: 0.1).snapped(0.3) == 0.3)
        #expect(QeetrixSliderModel(bounds: 10...20, step: 4).snapped(17) == 18)
        #expect(QeetrixSliderModel(bounds: 0...100, step: 0).step == 1, "a step that isn't above zero is 1")
    }

    @Test("Positions: 0 at the minimum, 1 at the maximum; a point along the track lands on a step")
    func positions() {
        let model = QeetrixSliderModel(bounds: 50...150, step: 10)
        #expect(model.fraction(50) == 0 && model.fraction(150) == 1 && model.fraction(100) == 0.5)
        #expect(model.fraction(500) == 1)
        #expect(model.value(atFraction: 0.26) == 80)
        #expect(model.value(atFraction: -1) == 50)
    }

    @Test("Large steps are a tenth of the range on a step (Base UI's 10 of 0–100); VoiceOver takes them past 20 steps")
    func largeSteps() {
        #expect(QeetrixSliderModel(bounds: 0...100, step: 1).largeStep == 10)
        #expect(QeetrixSliderModel(bounds: 0...100_000, step: 500).largeStep == 10_000)
        #expect(QeetrixSliderModel(bounds: 0...100, step: 1, largeStep: 25).largeStep == 25)
        #expect(QeetrixSliderModel(bounds: 0...100, step: 1).accessibilityStep == 10)
        #expect(QeetrixSliderModel(bounds: 0...100, step: 5).accessibilityStep == 5)
    }

    @Test("A range's thumbs never cross; a drag moves the nearest, or between two at one place, the one it goes towards")
    func range() {
        let model = QeetrixSliderModel(bounds: 0...100, step: 1)
        #expect(model.moving(20...60, end: 0, to: 80) == 60...60)
        #expect(model.moving(20...60, end: 1, to: 10) == 20...20)
        #expect(model.moving(20...60, end: 0, to: 30) == 30...60)
        #expect(QeetrixSliderModel.nearest(to: 25, in: [20, 60]) == 0)
        #expect(QeetrixSliderModel.nearest(to: 50, in: [20, 60]) == 1)
        #expect(QeetrixSliderModel.nearest(to: 45, in: [40, 40]) == 1)
        #expect(QeetrixSliderModel.nearest(to: 35, in: [40, 40]) == 0)
        #expect(QeetrixSliderModel.nearest(to: 35, in: [40]) == 0)
    }

    @Test("Keys: arrows a step, left and right mirrored right to left; Page Up and Down a large step; Home and End the ends")
    func keys() {
        let model = QeetrixSliderModel(bounds: 0...100, step: 5)
        #expect(model.target(of: .rightArrow, from: 50, isRightToLeft: false) == 55)
        #expect(model.target(of: .leftArrow, from: 50, isRightToLeft: false) == 45)
        #expect(model.target(of: .rightArrow, from: 50, isRightToLeft: true) == 45)
        #expect(model.target(of: .leftArrow, from: 50, isRightToLeft: true) == 55)
        #expect(model.target(of: .upArrow, from: 50, isRightToLeft: true) == 55)
        #expect(model.target(of: .pageUp, from: 50, isRightToLeft: false) == 60)
        #expect(model.target(of: .pageDown, from: 5, isRightToLeft: false) == 0)
        #expect(model.target(of: .home, from: 50, isRightToLeft: false) == 0)
        #expect(model.target(of: .end, from: 50, isRightToLeft: false) == 100)
        #expect(model.target(of: .tab, from: 50, isRightToLeft: false) == nil)
    }

    @Test("The fill runs from the minimum's side to the thumb, or between two thumbs, mirrored right to left")
    func filled() {
        #expect(QeetrixSliderControl.filled([0.25], isRightToLeft: false) == 0...0.25)
        #expect(QeetrixSliderControl.filled([0.75], isRightToLeft: true) == 0.75...1)
        #expect(QeetrixSliderControl.filled([0.8, 0.3], isRightToLeft: true) == 0.3...0.8)
        #expect(QeetrixSliderControl.trackHeight == 4 && QeetrixSliderControl.thumb == 16 && QeetrixSliderControl.inset == 8)
    }

    @Test("Values and bounds are written by QeetrixFormat: numbers, percentages of a fraction, money")
    func format() {
        #expect(QeetrixSliderFormat.number.string(25_000, locale: enIN) == "25,000")
        #expect(QeetrixSliderFormat.number(fractionDigits: 1...1).string(2, locale: enIN) == "2.0")
        #expect(QeetrixSliderFormat.percent.string(0.4, locale: enIN) == "40%")
        #expect(QeetrixSliderFormat.currency("INR", fractionDigits: 0...0).string(125_000, locale: enIN) == "₹1,25,000")
    }

    @Test("A range's thumbs are named after the label, as the web fills {label}")
    func names() {
        #expect(
            QeetrixSliderStrings.filling("%@, minimum", with: Text(verbatim: "Budget")) == Text(verbatim: "") + Text(verbatim: "Budget")
                + Text(verbatim: ", minimum"))
        #expect(String(localized: "qeetrix.slider.minimum-of", defaultValue: "%@, minimum", bundle: .module) == "%@, minimum")
        #expect(String(localized: "qeetrix.slider.maximum-of", defaultValue: "%@, maximum", bundle: .module) == "%@, maximum")
        #expect(QeetrixSliderStrings.filling("no slot", with: Text(verbatim: "Budget")) == Text(verbatim: "no slot"))
    }

    @Test("Ember holds 3:1 on every surface; the track, border.default, is a rule below 3:1 — the fill and thumb carry the control")
    func contrast() {
        for theme in [QeetrixTheme.light, .dark] {
            for surface in [QeetrixColor.surfaceCanvas, .surfaceDefault, .surfaceRaised, .surfaceOverlay] {
                let fill = ContrastTests.Pair(foreground: .bgBrandBold, background: [surface], minimum: 3)
                #expect(ContrastTests.ratio(fill, theme) >= 3, "\(theme.colorScheme): \(fill)")
                let track = ContrastTests.Pair(foreground: .borderDefault, background: [surface], minimum: 3)
                #expect(ContrastTests.ratio(track, theme) < 3, "\(theme.colorScheme): \(track) — reported upstream")
            }
        }
    }

    #if os(macOS)
        @Test("Each thumb is the system's slider for VoiceOver, named by the label — a range's after it; the header is hidden")
        func accessibilityTree() {
            let view = VStack {
                QeetrixSlider("Discount", value: .constant(20), in: 0...50, step: 5, showsValue: true, description: Text("Up to half."))
                QeetrixSlider("Budget", range: .constant(10_000...40_000), in: 0...100_000, step: 500, showsBounds: true)
            }
            let elements = ListsAccessibilityTree.elements(of: view)
            #expect(elements.map(\.role) == ["AXSlider", "AXStaticText", "AXSlider", "AXSlider"])
            #expect(elements.map(\.text) == ["Discount", "Up to half.", "Budget, minimum", "Budget, maximum"])
        }
    #endif

    @Test("It renders one value and a range, with the value and bounds, an error, disabled and right to left")
    func renders() {
        let views: [AnyView] = [
            AnyView(QeetrixSlider("Discount", value: .constant(20), in: 0...50, step: 5, showsValue: true)),
            AnyView(QeetrixSlider("Budget", range: .constant(10_000...40_000), in: 0...100_000, step: 500, showsBounds: true)),
            AnyView(QeetrixSlider("Threshold", value: .constant(0.4), in: 0...1, step: 0.05, format: .percent, error: "Too low")),
            AnyView(QeetrixSlider("Discount", value: .constant(20)).disabled(true)),
            AnyView(QeetrixSlider("Budget", range: .constant(20...60), showsValue: true).environment(\.layoutDirection, .rightToLeft)),
        ]
        for view in views {
            #expect(ImageRenderer(content: view.frame(width: 390)).cgImage != nil)
        }
    }

    @Test("The drawn slider: the Ember fill up to the thumb, the track after it, mirrored right to left")
    func drawn() throws {
        for direction in [LayoutDirection.leftToRight, .rightToLeft] {
            let view = QeetrixSliderControl(
                values: [50], model: QeetrixSliderModel(bounds: 0...100, step: 1), names: [Text(verbatim: "Discount")], spoken: ["50"],
                set: { _, _ in }, onEditingChanged: { _ in }
            )
            .frame(width: 216)
            .environment(\.colorScheme, .light)
            .environment(\.layoutDirection, direction)
            let image = try #require(Rendered(view))
            let middle = image.height / 2
            let brand = QeetrixTheme.light.resolve(.bgBrandBold).bytes
            let track = QeetrixTheme.light.resolve(.borderDefault).bytes
            // 8 pt in from each end, 200 pt of track: the thumb at 108; the fill on the minimum's side.
            let filledSide = direction == .leftToRight ? 30 : 186
            let trackSide = direction == .leftToRight ? 186 : 30
            #expect(close(brand, image.pixel(filledSide, middle)), "\(direction)")
            #expect(close(track, image.pixel(trackSide, middle)), "\(direction)")
            #expect(close(brand, image.pixel(108, middle)), "the thumb")
        }
    }
}
