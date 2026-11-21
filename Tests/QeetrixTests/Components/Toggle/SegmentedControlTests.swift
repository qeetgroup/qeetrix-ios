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

    private enum Audience: Hashable { case everyone, contacts, nobody }

    private func audience(_ chosen: Audience, width: CGFloat, labels: [String] = ["Everyone", "My contacts", "Nobody"]) -> some View {
        QeetrixSegmentedControl(
            "Who sees it", selection: .constant(chosen),
            options: zip(labels, [Audience.everyone, .contacts, .nobody]).map { QeetrixOption($0.0, value: $0.1) }, isFullWidth: true
        )
        .frame(width: width)
        .environment(\.colorScheme, .light)
    }

    @Test("Full width: three equal segments across 300 pt, whatever their labels, the rules between them")
    func fullWidthShares() throws {
        let graphite = QeetrixTheme.light.resolve(.bgNeutralBold).bytes
        // 300 − 2 × 1 pt edge − 2 × 1 pt rule = 296: three shares of 98.7 pt, from x = 1, 100.7 and 200.3.
        let middle = try #require(Rendered(audience(.contacts, width: 300)))
        #expect(middle.width == 300 && middle.height == 32)
        #expect(close(graphite, middle.pixel(103, 16)) && close(graphite, middle.pixel(197, 16)), "the middle share is chosen")
        #expect(middle.pixel(97, 16).a == 0 && middle.pixel(203, 16).a == 0, "its neighbours are clear")
        // A short label's segment is as wide as a long one's.
        let short = try #require(Rendered(audience(.everyone, width: 300, labels: ["All", "Everyone in my contacts", "No"])))
        #expect(close(graphite, short.pixel(96, 16)))
        #expect(short.pixel(104, 16).a == 0)
        // Right to left, the first share is on the right.
        let mirrored = try #require(Rendered(audience(.everyone, width: 300).environment(\.layoutDirection, .rightToLeft)))
        #expect(close(graphite, mirrored.pixel(296, 16)) && mirrored.pixel(4, 16).a == 0)
    }

    @Test("Full width: a share too narrow truncates its label on one line; the control keeps control.md's height")
    func fullWidthTruncates() throws {
        let narrow = try #require(Rendered(audience(.everyone, width: 180, labels: ["Everyone", "Only my contacts", "Nobody at all"])))
        #expect(narrow.width == 180 && narrow.height == 32)
        // Without full width, the same labels at the same width wrap instead.
        let wrapping = QeetrixSegmentedControl(
            "Who sees it", selection: .constant(Audience.everyone),
            options: [
                QeetrixOption("Everyone", value: Audience.everyone), QeetrixOption("Only my contacts", value: .contacts),
                QeetrixOption("Nobody at all", value: .nobody),
            ]
        )
        .frame(width: 180)
        #expect(try #require(Rendered(wrapping.fixedSize(horizontal: false, vertical: true))).height > 32)
    }

    @Test("Full width keeps the sizes' heights and the densities'")
    func fullWidthSizes() throws {
        for size in QeetrixControlSize.allCases {
            for density in QeetrixDensity.allCases {
                let view = QeetrixSegmentedControl(
                    "Theme", selection: .constant(Scheme.dark), options: options, size: size, isFullWidth: true
                )
                .frame(width: 320)
                .qeetrixDensity(density)
                let image = try #require(Rendered(view))
                #expect(CGFloat(image.height) == density.controlHeight(size), "\(size) \(density)")
            }
        }
    }
}
