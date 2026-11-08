import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Bottom action bar")
struct BottomActionBarTests {
    private let pay = QeetrixScreenAction("Pay ₹1,200") {}
    private let save = QeetrixScreenAction("Save for later") {}

    @Test("A screen action is brand, enabled and idle by default; its place decides its variant")
    func action() {
        #expect(pay.tone == .brand && !pay.isLoading && !pay.isDisabled && pay.icon == nil)
        let remove = QeetrixScreenAction("Remove member", icon: .trash, tone: .danger, isLoading: true, isDisabled: true) {}
        #expect(remove.tone == .danger && remove.isLoading && remove.isDisabled && remove.icon == .trash)
        var ran = 0
        QeetrixScreenAction(title: Text("Pay")) { ran += 1 }.action()
        #expect(ran == 1)
    }

    @Test("The page gutter, 12 pt above and below, 8 pt between buttons")
    func metrics() {
        #expect(QeetrixBottomActionBarMetrics.gutter(isCompact: true) == QeetrixSpace.insetLg)
        #expect(QeetrixBottomActionBarMetrics.gutter(isCompact: false) == QeetrixSpace.layoutMd)
        #expect(QeetrixBottomActionBarMetrics.verticalPadding == 12)
        #expect(QeetrixBottomActionBarMetrics.gap == 8)
    }

    @Test("Content is under the bar while it continues past the bar's top edge")
    func contentUnderBar() {
        // A 600 pt viewport whose bottom 80 pt are the bar.
        func under(_ height: CGFloat, offset: CGFloat) -> Bool {
            QeetrixBottomActionBarMetrics.isContentUnderBar(contentHeight: height, offset: offset, viewportHeight: 600, bottomInset: 80)
        }
        #expect(!under(400, offset: 0), "Short content ends above the bar")
        #expect(!under(520, offset: 0), "Content that ends exactly at the bar's edge")
        #expect(!under(520.4, offset: 0), "Half a point of slack")
        #expect(under(1_200, offset: 0), "Long content, at the top")
        #expect(under(1_200, offset: 500))
        #expect(!under(1_200, offset: 680), "Scrolled to the end, clear of the bar")
        #expect(under(700, offset: -40), "A top inset scrolls the content down")
    }

    @Test("The bar is surface.default, with the 1 pt border.default rule only while content is under it")
    func rule() throws {
        func render(_ rule: Bool) throws -> Rendered {
            let bar = QeetrixBottomActionBar(primary: pay, secondary: nil, showsRule: rule)
                .frame(width: 390)
                .environment(\.colorScheme, .light)
                .environment(\.horizontalSizeClass, .compact)
            return try #require(Rendered(bar))
        }
        let surface = QeetrixTheme.light.resolve(.surfaceDefault).bytes
        let ruled = try render(true)
        #expect(close(QeetrixTheme.light.resolve(.borderDefault).bytes, ruled.pixel(4, 0)))
        #expect(close(surface, ruled.pixel(4, 2)))
        let plain = try render(false)
        #expect(close(surface, plain.pixel(4, 0)))
        // 12 + the lg button (40 at the default density) + 12.
        #expect(plain.height == 64)
    }

    @Test("Compact: one action spans the bar")
    func fullWidth() throws {
        let bar = QeetrixBottomActionBar(primary: pay, secondary: nil, showsRule: false)
            .frame(width: 390)
            .environment(\.colorScheme, .light)
            .environment(\.horizontalSizeClass, .compact)
        let image = try #require(Rendered(bar))
        let brand = QeetrixTheme.light.resolve(.bgBrandBold).bytes
        #expect(close(brand, image.pixel(18, 32)), "From the 16 pt gutter")
        #expect(close(brand, image.pixel(371, 32)), "To the other gutter")
    }

    @Test("Compact: two short actions side by side, the secondary first, at equal widths")
    func sideBySide() throws {
        let bar = QeetrixBottomActionBar(
            primary: QeetrixScreenAction("Pay") {}, secondary: QeetrixScreenAction("Later") {}, showsRule: false
        )
        .frame(width: 390)
        .environment(\.colorScheme, .light)
        .environment(\.horizontalSizeClass, .compact)
        let image = try #require(Rendered(bar))
        #expect(image.height == 64, "One row")
        #expect(close(QeetrixTheme.light.resolve(.bgNeutralBold).bytes, image.pixel(30, 32)), "The soft secondary at the start")
        #expect(close(QeetrixTheme.light.resolve(.bgBrandBold).bytes, image.pixel(360, 32)), "The solid primary at the end")
        // (358 − 8) / 2 = 175 each: the primary starts at 16 + 175 + 8.
        #expect(close(QeetrixTheme.light.resolve(.bgBrandBold).bytes, image.pixel(200, 32)))
        #expect(close(QeetrixTheme.light.resolve(.surfaceDefault).bytes, image.pixel(195, 32)), "The 8 pt gap")
    }

    @Test("Compact: two long actions stack, the primary on top")
    func stacked() throws {
        let bar = QeetrixBottomActionBar(
            primary: QeetrixScreenAction("Pay ₹1,20,000 now with UPI") {},
            secondary: QeetrixScreenAction("Save this invoice for later") {},
            showsRule: false
        )
        .frame(width: 390)
        .environment(\.colorScheme, .light)
        .environment(\.horizontalSizeClass, .compact)
        let image = try #require(Rendered(bar))
        #expect(image.height == 12 + 40 + 8 + 40 + 12)
        // Past the labels, in each button's fill.
        #expect(close(QeetrixTheme.light.resolve(.bgBrandBold).bytes, image.pixel(368, 30)), "The primary on top")
        #expect(close(QeetrixTheme.light.resolve(.bgNeutralBold).bytes, image.pixel(368, 80)))
    }

    @Test("Regular: the actions keep their widths, at the end")
    func regular() throws {
        let bar = QeetrixBottomActionBar(primary: pay, secondary: save, showsRule: false)
            .frame(width: 800)
            .environment(\.colorScheme, .light)
            .environment(\.horizontalSizeClass, .regular)
        let image = try #require(Rendered(bar))
        #expect(image.height == 64)
        #expect(close(QeetrixTheme.light.resolve(.surfaceDefault).bytes, image.pixel(100, 32)), "Nothing at the start")
        #expect(close(QeetrixTheme.light.resolve(.bgBrandBold).bytes, image.pixel(800 - 32 - 4, 32)), "The primary at the 32 pt gutter")
    }

    @Test("Compact: a ghost tertiary under the primary, both spanning the bar; or the tertiary alone")
    func tertiary() throws {
        let surface = QeetrixTheme.light.resolve(.surfaceDefault).bytes
        let brand = QeetrixTheme.light.resolve(.bgBrandBold).bytes
        func render(_ primary: QeetrixScreenAction?) throws -> Rendered {
            let bar = QeetrixBottomActionBar(
                primary: primary, secondary: nil, tertiary: QeetrixScreenAction("Not now", tone: .neutral) {}, showsRule: false
            )
            .frame(width: 390)
            .environment(\.colorScheme, .light)
            .environment(\.horizontalSizeClass, .compact)
            return try #require(Rendered(bar))
        }
        let both = try render(QeetrixScreenAction("Continue") {})
        #expect(both.height == 12 + 40 + 8 + 40 + 12, "Stacked")
        #expect(close(brand, both.pixel(18, 32)) && close(brand, both.pixel(371, 32)), "The solid primary on top, across the bar")
        #expect(close(surface, both.pixel(18, 80)) && close(surface, both.pixel(371, 80)), "The ghost under it has no fill")
        #expect((16..<374).contains { !close(surface, both.pixel($0, 80)) }, "Its label is drawn")
        let alone = try render(nil)
        #expect(alone.height == 12 + 40 + 12, "A quiet Done on its own")
        #expect((16..<374).contains { !close(surface, alone.pixel($0, 32)) })
        #expect(!(16..<374).contains { close(brand, alone.pixel($0, 32)) }, "No solid action")
    }

    @Test("Regular: the primary and the tertiary stacked at the end, at the wider one's width")
    func regularTertiary() throws {
        let brand = QeetrixTheme.light.resolve(.bgBrandBold).bytes
        func leadingBrand(_ tertiary: QeetrixScreenAction?) throws -> Int? {
            let continueAction = QeetrixScreenAction("Continue") {}
            let bar = QeetrixBottomActionBar(primary: continueAction, secondary: nil, tertiary: tertiary, showsRule: false)
                .frame(width: 800)
                .environment(\.colorScheme, .light)
                .environment(\.horizontalSizeClass, .regular)
            let image = try #require(Rendered(bar))
            #expect(close(brand, image.pixel(800 - 32 - 4, 32)), "At the 32 pt gutter")
            return (0..<800).first { close(brand, image.pixel($0, 32)) }
        }
        let alone = try #require(try leadingBrand(nil))
        let over = try #require(try leadingBrand(QeetrixScreenAction("Type the code instead") {}))
        #expect(over < alone - 20, "The primary takes the longer tertiary's width")
        #expect(over > 400, "Not the whole bar")
    }

    @Test("The modifier attaches to a scroll view and renders, light and dark")
    func attaches() {
        for scheme in [ColorScheme.light, .dark] {
            let screen = ScrollView { Text("Invoice") }
                .qeetrixBottomActionBar(primary: pay, secondary: save)
                .frame(width: 390, height: 600)
                .environment(\.colorScheme, scheme)
            #expect(ImageRenderer(content: screen).cgImage != nil)
            let danger = Text("Member")
                .qeetrixBottomActionBar(primary: QeetrixScreenAction("Remove member", tone: .danger, isLoading: true) {})
                .frame(width: 390, height: 300)
                .environment(\.colorScheme, scheme)
            #expect(ImageRenderer(content: danger).cgImage != nil)
            let quiet = Text("Linked")
                .qeetrixBottomActionBar(tertiary: QeetrixScreenAction("Done", tone: .neutral) {})
                .frame(width: 390, height: 300)
                .environment(\.colorScheme, scheme)
            #expect(ImageRenderer(content: quiet).cgImage != nil)
        }
    }
}
