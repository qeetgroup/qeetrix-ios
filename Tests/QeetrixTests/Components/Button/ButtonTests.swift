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

    /// button.css, state by state. Two cells deliberately differ from the CSS, as QeetrixButtonStyle.swift
    /// records: a solid neutral button stays the soft look when hovered and pressed (the CSS lets the
    /// solid variant's Ember hover win), and a ghost danger button keeps the danger tint when pressed (the
    /// CSS shows the ghost's Ember press tint).
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
            [.resting: (nil, .textDanger), .hovered: (.bgDangerSubtle, .textDanger), .pressed: (.bgDangerSubtle, .textDanger)]
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
        // A solid or soft neutral button hovers and presses in graphite (QTRX-157).
        let neutral = #".qx-button[data-tone="neutral"]:not([data-variant="ghost"])"#
        #expect(rule(neutral + ":hover:not([data-disabled])")?.contains("--qx-color-bg-neutral-bold-hover") == true)
        #expect(rule(neutral + ":active:not([data-disabled])")?.contains("--qx-color-bg-neutral-bold-pressed") == true)
        // A pressed ghost danger button keeps the danger tint (QTRX-158).
        let danger = #".qx-button[data-tone="danger"][data-variant="ghost"]:is(:hover, :active):not([data-disabled])"#
        #expect(rule(danger)?.contains("--qx-color-bg-danger-subtle") == true)
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
