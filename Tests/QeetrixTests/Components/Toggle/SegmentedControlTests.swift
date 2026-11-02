import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Segmented control")
struct SegmentedControlTests {
    private enum Scheme: Hashable { case light, dark, system }

    private let options = [
        QeetrixOption("Light", value: Scheme.light),
        QeetrixOption("Dark", value: Scheme.dark),
        QeetrixOption("System", value: Scheme.system),
    ]

    @Test("toggle.css: segments inside the 1 pt edge, 12 pt inline padding (8 at sm, 16 at lg), label.md (label.sm at sm)")
    func metrics() {
        for density in QeetrixDensity.allCases {
            for size in QeetrixControlSize.allCases {
                #expect(QeetrixSegmentedControlMetrics(size: size, density: density).height == density.controlHeight(size) - 2)
            }
        }
        #expect(QeetrixControlSize.allCases.map { QeetrixSegmentedControlMetrics(size: $0, density: .default).padding } == [8, 12, 16])
        #expect(QeetrixSegmentedControlMetrics(size: .md, density: .default).type == QeetrixTypeSpec(.labelMd))
        let small = QeetrixSegmentedControlMetrics(size: .sm, density: .default).type
        #expect(small.tokens.size == QeetrixTextRole.labelSm.tokens.size && small.tokens.weight == .medium)
    }

    @Test("Off: clear with text.subtle; hover (and a held touch): the neutral tint with text.default; chosen: graphite, inverse text")
    func colours() {
        #expect(QeetrixSegmentColors.colors(isSelected: false, state: .resting) == QeetrixSegmentColors(fill: nil, text: .textSubtle))
        for state in [QeetrixButtonState.hovered, .pressed] {
            let colors = QeetrixSegmentColors.colors(isSelected: false, state: state)
            #expect(colors == QeetrixSegmentColors(fill: .bgNeutralSubtle, text: .textDefault))
        }
        for state in [QeetrixButtonState.resting, .hovered, .pressed] {
            let colors = QeetrixSegmentColors.colors(isSelected: true, state: state)
            #expect(colors == QeetrixSegmentColors(fill: .bgNeutralBold, text: .textInverse))
        }
        // `[data-disabled]` changes only the text.
        #expect(QeetrixSegmentColors.colors(isSelected: false, state: .disabled) == QeetrixSegmentColors(fill: nil, text: .textDisabled))
        #expect(QeetrixSegmentColors.colors(isSelected: true, state: .disabled).fill == .bgNeutralBold)
    }

    @Test("A disabled chosen segment's text still shows on graphite (at least 3:1), in both schemes")
    func disabledChosenContrast() {
        for theme in [QeetrixTheme.light, .dark] {
            let ratio = QeetrixAccessibility.contrastRatio(theme.resolve(.textDisabled), on: theme.resolve(.bgNeutralBold))
            #expect(ratio >= 3, "\(theme.colorScheme): \(ratio)")
        }
    }

    @Test("The fill takes the group's corners, inside its edge, on the outer side only")
    func positions() {
        #expect(
            [0, 1, 2].map { QeetrixSegmentPosition(index: $0, count: 3) } == [QeetrixSegmentPosition.first, .middle, .last])
        #expect(QeetrixSegmentPosition(index: 0, count: 1) == .only)
        let first = QeetrixSegmentPosition.first.shape
        #expect(first.cornerRadii.topLeading == 3 && first.cornerRadii.bottomLeading == 3 && first.cornerRadii.topTrailing == 0)
        let last = QeetrixSegmentPosition.last.shape
        #expect(last.cornerRadii.topTrailing == 3 && last.cornerRadii.bottomTrailing == 3 && last.cornerRadii.topLeading == 0)
        #expect(QeetrixSegmentPosition.middle.shape.cornerRadii == RectangleCornerRadii())
    }

    @Test("The drawn control: control.md tall, a border.strong edge, the chosen segment graphite")
    func drawn() throws {
        let view = QeetrixSegmentedControl("Theme", selection: .constant(Scheme.light), options: options)
            .fixedSize()
            .environment(\.colorScheme, .light)
        let image = try #require(Rendered(view))
        let light = QeetrixTheme.light
        #expect(image.height == 32)
        #expect(close(light.resolve(.borderStrong).bytes, image.pixel(image.width / 2, 0)))
        #expect(close(light.resolve(.bgNeutralBold).bytes, image.pixel(6, image.height / 2)))
        #expect(image.pixel(image.width - 6, image.height / 2).a == 0, "an unchosen segment is clear")
    }

    @Test("Sizes, densities and both schemes render; a long label wraps at a narrow width")
    func renders() throws {
        for scheme in [ColorScheme.light, .dark] {
            for size in QeetrixControlSize.allCases {
                let view = QeetrixSegmentedControl("Theme", selection: .constant(Scheme.dark), options: options, size: size)
                    .environment(\.colorScheme, scheme)
                #expect(ImageRenderer(content: view).cgImage != nil)
            }
        }
        let narrow = QeetrixSegmentedControl(
            "Period", selection: .constant(1),
            options: [QeetrixOption("Last seven days", value: 1), QeetrixOption("Last thirty days", value: 2)]
        )
        .frame(width: 160)
        let image = try #require(Rendered(narrow.fixedSize(horizontal: false, vertical: true)))
        #expect(image.height > 32)
        let disabled = QeetrixSegmentedControl("Theme", selection: .constant(Scheme.light), options: options).disabled(true)
        #expect(ImageRenderer(content: disabled).cgImage != nil)
    }
}
