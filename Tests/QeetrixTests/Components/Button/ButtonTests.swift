import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Button")
struct ButtonTests {
    @Test("Variants, tones and sizes are @qeetrix/react's")
    func names() {
        #expect(QeetrixButtonVariant.allCases.map(\.rawValue) == ["solid", "soft", "ghost"])
        #expect(QeetrixButtonTone.allCases.map(\.rawValue) == ["brand", "danger", "neutral"])
    }

    @Test("Heights come from the density: size.control.sm, md, lg")
    func heights() {
        for density in QeetrixDensity.allCases {
            for size in QeetrixControlSize.allCases {
                #expect(QeetrixButtonMetrics(size: size, density: density).height == density.controlHeight(size))
            }
        }
    }

    @Test("button.css: padding 10/14/16, gap 8/12/14, zone 8/10/12, rule 14/16/20 and the icon 16/16/20")
    func metrics() {
        func row(_ size: QeetrixControlSize) -> [CGFloat] {
            let metrics = QeetrixButtonMetrics(size: size, density: .default)
            return [metrics.padding, metrics.gap, metrics.zonePadding, metrics.ruleHeight, metrics.iconSize.points]
        }
        #expect(row(.sm) == [10, 8, 8, 14, 16])
        #expect(row(.md) == [14, 12, 10, 16, 16])
        #expect(row(.lg) == [16, 14, 12, 20, 20])
        #expect(QeetrixButtonStyle.iconSize(for: .lg).points == 20)
        #expect(QeetrixButtonMetrics(size: .sm, density: .default).spinnerSize == .md)
        #expect(QeetrixButtonMetrics(size: .lg, density: .default).spinnerSize == .lg)
        #expect(QeetrixButtonLabel.ruleOpacity == 0.55)
    }

    @Test("Text: label.md at 500; sm takes label.sm's size at the same weight")
    func type() {
        let md = QeetrixButtonMetrics(size: .md, density: .default).type
        #expect(md == QeetrixTypeSpec(.labelMd))
        let sm = QeetrixButtonMetrics(size: .sm, density: .default).type
        #expect(sm.tokens.size == QeetrixTextRole.labelSm.tokens.size)
        #expect(sm.tokens.lineHeight == QeetrixTextRole.labelSm.tokens.lineHeight)
        #expect(sm.tokens.weight == .medium)
    }

    typealias Expected = (background: QeetrixColor?, foreground: QeetrixColor)

    /// button.css, state by state. A solid neutral button stays the soft look when hovered and pressed, as
    /// QeetrixButtonStyle.swift records, and a ghost danger button hovers in the danger tint and presses in
    /// its pressed tint, never the brand's.
    static let table: [(QeetrixButtonVariant, QeetrixButtonTone, [QeetrixButtonState: Expected])] = [
        (
            .solid, .brand,
            [
                .resting: (.bgBrandBold, .textOnBrand), .hovered: (.bgBrandBoldHover, .textOnBrand),
                .pressed: (.bgBrandBoldPressed, .textOnBrand),
            ]
        ),
        (
            .soft, .brand,
            [
                .resting: (.bgNeutralBold, .textInverse), .hovered: (.bgNeutralBoldHover, .textInverse),
                .pressed: (.bgNeutralBoldPressed, .textInverse),
            ]
        ),
        (
            .solid, .neutral,
            [
                .resting: (.bgNeutralBold, .textInverse), .hovered: (.bgNeutralBoldHover, .textInverse),
                .pressed: (.bgNeutralBoldPressed, .textInverse),
            ]
        ),
        (
            .soft, .neutral,
            [
                .resting: (.bgNeutralBold, .textInverse), .hovered: (.bgNeutralBoldHover, .textInverse),
                .pressed: (.bgNeutralBoldPressed, .textInverse),
            ]
        ),
        (
            .solid, .danger,
            [
                .resting: (.bgDangerBold, .textOnBold), .hovered: (.bgDangerBoldHover, .textOnBold),
                .pressed: (.bgDangerBoldPressed, .textOnBold),
            ]
        ),
        (
            .soft, .danger,
            [
                .resting: (.bgDangerBold, .textOnBold), .hovered: (.bgDangerBoldHover, .textOnBold),
                .pressed: (.bgDangerBoldPressed, .textOnBold),
            ]
        ),
        (
            .ghost, .brand,
            [.resting: (nil, .textBrand), .hovered: (.bgBrandSubtle, .textBrand), .pressed: (.bgBrandSubtlePressed, .textBrand)]
        ),
        (
            .ghost, .danger,
            [.resting: (nil, .textDanger), .hovered: (.bgDangerSubtle, .textDanger), .pressed: (.bgDangerSubtlePressed, .textDanger)]
        ),
        (
            .ghost, .neutral,
            [.resting: (nil, .textSubtle), .hovered: (.bgNeutralSubtle, .textDefault), .pressed: (.bgNeutralSubtlePressed, .textDefault)]
        ),
    ]

    @Test("Every variant and tone in every state takes its button.css colours")
    func colours() {
        #expect(Self.table.count == QeetrixButtonVariant.allCases.count * QeetrixButtonTone.allCases.count)
        for (variant, tone, states) in Self.table {
            for (state, expected) in states {
                let colors = QeetrixButtonColors.colors(variant, tone, state)
                #expect(colors.background == expected.background, "\(variant) \(tone) \(state)")
                #expect(colors.foreground == expected.foreground, "\(variant) \(tone) \(state)")
            }
        }
    }

    @Test("button.css has the rules the table follows: neutral hover and press, and ghost danger's press tint")
    func cssRules() throws {
        let css = String(decoding: try Repository.data("Upstream/qeetrix-react/css/button.css"), as: UTF8.self)
        func rule(_ selector: String) -> String? {
            css.range(of: selector + " {").map { String(css[$0.upperBound...].prefix { $0 != "}" }) }
        }
        // A solid or soft neutral button hovers and presses in graphite.
        let neutral = #".qx-button[data-tone="neutral"]:not([data-variant="ghost"])"#
        #expect(rule(neutral + ":hover:not([data-disabled])")?.contains("--qx-color-bg-neutral-bold-hover") == true)
        #expect(rule(neutral + ":active:not([data-disabled])")?.contains("--qx-color-bg-neutral-bold-pressed") == true)
        // A ghost danger button hovers in the danger tint and presses in the danger's pressed tint.
        let danger = #".qx-button[data-tone="danger"][data-variant="ghost"]"#
        #expect(rule(danger + ":hover:not([data-disabled])")?.contains("--qx-color-bg-danger-subtle)") == true)
        #expect(rule(danger + ":active:not([data-disabled])")?.contains("--qx-button-danger-pressed") == true)
        #expect(rule(danger)?.contains("--qx-color-bg-danger-subtle-pressed") == true)
    }

    @Test("Full width: the label is centred on the whole button, with or without an icon, at every size and right to left")
    func fullWidthCentresTheLabel() throws {
        var offsets: [String] = []
        for direction in [LayoutDirection.leftToRight, .rightToLeft] {
            for size in QeetrixControlSize.allCases {
                for icon in [nil, QeetrixIconName.arrowRight] {
                    let view = QeetrixButton("Continue", icon: icon, size: size, isFullWidth: true) {}
                        .frame(width: 300)
                        .environment(\.colorScheme, .light)
                        .environment(\.layoutDirection, direction)
                    let image = try #require(Rendered(view))
                    // The label's ink: the white letters on the Ember fill, away from the zone at the trailing end.
                    let columns = direction == .leftToRight ? 0..<230 : 70..<300
                    let ink = columns.filter { x in (0..<image.height).contains { image.pixel(x, $0).g > 180 } }
                    let first = try #require(ink.first), last = try #require(ink.last)
                    let offset = Double(first + last + 1) / 2 - 150
                    if abs(offset) > 1 { offsets.append("\(direction) \(size) \(icon == nil ? "plain" : "icon"): \(offset)") }
                }
            }
        }
        #expect(offsets.isEmpty, "\(offsets)")
    }

    @Test("Full width keeps a plain button's ideal width; where it's tight the leading side gives way first")
    func fullWidthIdealWidth() throws {
        let plain = QeetrixButton("Type the key instead", icon: .keyboard) {}
        let full = QeetrixButton("Type the key instead", icon: .keyboard, isFullWidth: true) {}
        let ideal = try #require(ImageRenderer(content: plain.fixedSize()).cgImage?.width)
        #expect(ImageRenderer(content: full.fixedSize()).cgImage?.width == ideal)
        // Exactly the plain button's width: the label keeps the leading padding, as a plain one does.
        let view = full.frame(width: CGFloat(ideal)).environment(\.colorScheme, .light)
        let image = try #require(Rendered(view))
        let ink = (0..<image.width).filter { x in (0..<image.height).contains { image.pixel(x, $0).g > 180 } }
        let first = try #require(ink.first)
        #expect(abs(first - Int(QeetrixButtonMetrics(size: .md, density: .default).padding)) <= 2, "label starts at \(first)")
    }

    @Test("A button with an icon keeps its height at the foot of a taller stack")
    func iconButtonDoesNotStretch() throws {
        let view = VStack(spacing: 0) {
            Color.clear.frame(maxHeight: .infinity)
            QeetrixButton("Type the key instead", icon: .keyboard, variant: .soft, size: .lg, isFullWidth: true) {}
        }
        .frame(width: 300, height: 400)
        .environment(\.colorScheme, .light)
        let image = try #require(Rendered(view))
        let fill = QeetrixTheme.light.resolve(.bgNeutralBold).bytes
        let rows = (0..<image.height).filter { close(fill, image.pixel(4, $0)) }.count
        #expect(abs(rows - Int(QeetrixDensity.default.sizeControlLg)) <= 1, "\(rows) pt of button in a 400 pt stack")
    }

    @Test("Disabled: bg.disabled and text.disabled, ghosts stay transparent; no opacity fade")
    func disabled() {
        for variant in QeetrixButtonVariant.allCases {
            for tone in QeetrixButtonTone.allCases {
                let colors = QeetrixButtonColors.colors(variant, tone, .disabled)
                #expect(colors.foreground == .textDisabled)
                #expect(colors.background == (variant == .ghost ? nil : .bgDisabled), "\(variant) \(tone)")
            }
        }
    }

    @Test("Busy is not unavailable: a loading button keeps its resting colours, even when disabled")
    func loading() {
        #expect(QeetrixButtonStyleBody.state(isEnabled: true, isPressed: true, isHovered: true, isLoading: true) == .resting)
        #expect(QeetrixButtonStyleBody.state(isEnabled: false, isPressed: false, isHovered: false, isLoading: true) == .resting)
        #expect(QeetrixButtonStyleBody.state(isEnabled: false, isPressed: true, isHovered: false, isLoading: false) == .disabled)
        #expect(QeetrixButtonStyleBody.state(isEnabled: true, isPressed: true, isHovered: true, isLoading: false) == .pressed)
        #expect(QeetrixButtonStyleBody.state(isEnabled: true, isPressed: false, isHovered: true, isLoading: false) == .hovered)
    }

    @Test("A button with an icon gains the zone and is wider; loading gives one without an icon the same zone")
    func zone() throws {
        let plain = try #require(Rendered(QeetrixButton("Save") {}))
        let icon = try #require(Rendered(QeetrixButton("Save", icon: .send) {}))
        let loading = try #require(Rendered(QeetrixButton("Save", isLoading: true) {}))
        // Zone: 10 + 16 + 10 = 36, minus the 14 pt end padding it replaces, plus the 12 pt gap.
        #expect(icon.width - plain.width == 36 - 14 + 12)
        #expect(loading.width == icon.width)
        #expect(plain.height == 32 && icon.height == 32)
    }

    @Test("An icon of the app's own gets the zone a named icon gets: the same pixels, at every size, full width and right to left")
    func customIcon() throws {
        func same(_ one: some View, _ other: some View) throws -> Bool {
            let first = try #require(Rendered(one.environment(\.colorScheme, .light)))
            let second = try #require(Rendered(other.environment(\.colorScheme, .light)))
            guard first.width == second.width, first.height == second.height else { return false }
            for y in 0..<first.height {
                for x in 0..<first.width where first.pixel(x, y) != second.pixel(x, y) { return false }
            }
            return true
        }
        for size in QeetrixControlSize.allCases {
            let iconSize = QeetrixButtonStyle.iconSize(for: size)
            for variant in QeetrixButtonVariant.allCases {
                let named = QeetrixButton("Export", icon: .share2, variant: variant, size: size) {}
                let custom = QeetrixButton("Export", variant: variant, size: size) {
                } icon: {
                    QeetrixIcon(.share2, size: iconSize, shape: .sharp)
                }
                #expect(try same(named, custom), "\(size) \(variant)")
            }
            let fullNamed = QeetrixButton("Continue", icon: .arrowRight, size: size, isFullWidth: true) {}.frame(width: 300)
            let fullCustom = QeetrixButton("Continue", size: size, isFullWidth: true) {
            } icon: {
                QeetrixIcon(.arrowRight, size: iconSize, shape: .sharp)
            }
            #expect(try same(fullNamed, fullCustom.frame(width: 300)), "full width \(size)")
            #expect(
                try same(
                    fullNamed.environment(\.layoutDirection, .rightToLeft),
                    fullCustom.frame(width: 300).environment(\.layoutDirection, .rightToLeft)), "right to left \(size)")
            // Icon buttons: the drawing centred in the square, as a named icon is.
            let iconNamed = QeetrixIconButton(.x, label: "Close", variant: .soft, size: size) {}
            let iconCustom = QeetrixIconButton(label: "Close", variant: .soft, size: size) {
            } icon: {
                QeetrixIcon(.x, size: iconSize, shape: .sharp)
            }
            #expect(try same(iconNamed, iconCustom), "icon button \(size)")
        }
    }

    @Test("A turned icon keeps its drawing in the zone: the x turned 45° reads as a plus")
    func customIconTurned() throws {
        let button = QeetrixButton("Hang up", tone: .danger) {
        } icon: {
            QeetrixIcon(.x, size: .sm).rotationEffect(.degrees(45))
        }
        let image = try #require(Rendered(button.environment(\.colorScheme, .light)))
        // The 16 pt icon box ends 10 pt (the zone padding) from the trailing edge.
        let centre = (x: image.width - 10 - 8, y: image.height / 2)
        func isLight(_ x: Int, _ y: Int) -> Bool { image.pixel(x, y).g > 150 }
        let vertical = (-6...6).filter { dy in (-1...1).contains { isLight(centre.x + $0, centre.y + dy) } }.count
        let horizontal = (-6...6).filter { dx in (-1...1).contains { isLight(centre.x + dx, centre.y + $0) } }.count
        #expect(vertical >= 9 && horizontal >= 9, "vertical \(vertical), horizontal \(horizontal)")
        #expect(!isLight(centre.x - 5, centre.y - 5) && !isLight(centre.x + 5, centre.y + 5), "no diagonal left")
    }

    @Test("While loading, the spinner takes a custom icon's place, as it takes a named one's")
    func customIconLoading() throws {
        let named = try #require(Rendered(QeetrixButton("Hang up", icon: .x, size: .lg, isLoading: true) {}))
        let custom = try #require(
            Rendered(
                QeetrixButton("Hang up", size: .lg, isLoading: true) {
                } icon: {
                    QeetrixIcon(.x, size: .md).rotationEffect(.degrees(135))
                }))
        #expect((custom.width, custom.height) == (named.width, named.height))
        let iconNamed = try #require(Rendered(QeetrixIconButton(.x, label: "Hang up", isLoading: true) {}))
        let iconCustom = try #require(
            Rendered(
                QeetrixIconButton(label: "Hang up", isLoading: true) {
                } icon: {
                    QeetrixIcon(.x, size: .sm)
                }))
        #expect((iconCustom.width, iconCustom.height) == (iconNamed.width, iconNamed.height))
    }

    @Test("A solid button fills with Ember, corners 4 pt")
    func rendersEmber() throws {
        let image = try #require(Rendered(QeetrixButton("Save") {}.environment(\.colorScheme, .light)))
        #expect(close(QeetrixTheme.light.resolve(.bgBrandBold).bytes, image.pixel(2, image.height / 2)))
        #expect(image.pixel(0, 0).a < 128, "Rounded corner")
    }

    @Test("Icon buttons are square at the control height, 16 pt icons (20 at lg), ghost by default")
    func iconButton() throws {
        for size in QeetrixControlSize.allCases {
            let image = try #require(Rendered(QeetrixIconButton(.x, label: "Close", size: size) {}))
            #expect(image.width == image.height)
            #expect(CGFloat(image.width) == QeetrixDensity.default.controlHeight(size))
        }
        let ghost = try #require(Rendered(QeetrixIconButton(.x, label: "Close") {}))
        #expect(ghost.pixel(1, 1).a == 0, "No fill at rest")
    }

    @Test("Buttons render in every variant, tone and size, loading or not, full width or not")
    func renders() {
        for variant in QeetrixButtonVariant.allCases {
            for tone in QeetrixButtonTone.allCases {
                #expect(ImageRenderer(content: QeetrixButton("Save", icon: .send, variant: variant, tone: tone) {}).cgImage != nil)
                #expect(ImageRenderer(content: QeetrixButton("Save", variant: variant, tone: tone, isLoading: true) {}).cgImage != nil)
                #expect(ImageRenderer(content: QeetrixIconButton(.x, label: "Close", variant: variant, tone: tone) {}).cgImage != nil)
            }
        }
        let full = ImageRenderer(content: QeetrixButton("Continue", icon: .send, size: .lg, isFullWidth: true) {}.frame(width: 300))
        #expect(full.cgImage?.width == 300)
        #expect(ImageRenderer(content: Button("Billing") {}.buttonStyle(.qeetrix(.ghost, size: .sm))).cgImage != nil)
    }
}
