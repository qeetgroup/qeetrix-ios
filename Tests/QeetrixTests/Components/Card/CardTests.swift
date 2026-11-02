import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Card")
struct CardTests {
    @Test("Variants and tones are @qeetrix/react's")
    func names() {
        #expect(QeetrixCardVariant.allCases.map(\.rawValue) == ["default", "subdued"])
        #expect(QeetrixCardTone.allCases.map(\.rawValue) == ["neutral", "danger"])
    }

    @Test("Raised, ruled and flat: surface.raised inside a 1 pt border.default, no shadow beyond the edge")
    func surface() throws {
        let card = QeetrixCard { Color.clear.frame(height: 20) }
            .frame(width: 100)
            .padding(10)
            .background(Color.white)
            .environment(\.colorScheme, .light)
        let image = try #require(Rendered(card))
        #expect(close(QeetrixTheme.light.resolve(.surfaceRaised).bytes, image.pixel(50, 25)))
        #expect(close(QeetrixTheme.light.resolve(.borderDefault).bytes, image.pixel(50, 10)), "The 1 pt edge")
        #expect(image.pixel(50, image.height - 3).r == 255, "No shadow under the card")
    }

    @Test("Subdued is the sunken tone; danger draws the danger edge")
    func variants() throws {
        func pixel(_ card: some View, _ x: Int, _ y: Int) throws -> (r: Int, g: Int, b: Int, a: Int) {
            try #require(Rendered(card.frame(width: 100).environment(\.colorScheme, .light))).pixel(x, y)
        }
        #expect(
            close(
                QeetrixTheme.light.resolve(.surfaceSunken).bytes,
                try pixel(QeetrixCard(variant: .subdued) { Color.clear.frame(height: 20) }, 50, 20)))
        #expect(
            close(
                QeetrixTheme.light.resolve(.borderDanger).bytes,
                try pixel(QeetrixCard(tone: .danger) { Color.clear.frame(height: 20) }, 50, 0)))
    }

    @Test("A titled card has a ruled header: 16 pt padding and a 1 pt line below")
    func header() throws {
        let titled = try #require(Rendered(QeetrixCard(title: Text("Plan")) { Color.clear.frame(height: 10) }.frame(width: 200)))
        let untitled = try #require(Rendered(QeetrixCard { Color.clear.frame(height: 10) }.frame(width: 200)))
        // The header adds its padding, the title's line (title.sm, 16 × 1.5) and the rule.
        // title.sm's line is 24 pt (CSS half-leading, QeetrixTextStyleModifier).
        #expect(abs(titled.height - untitled.height - (16 + 24 + 16 + 1)) <= 1)
        #expect(titled.height - untitled.height > 16 + 16 + 1, "Padding both sides, the title and the rule")
    }

    @Test("A header-only card ends at its header: no body and no rule under it (QTRX-174)")
    func headerOnly() throws {
        let headerOnly = try #require(Rendered(QeetrixCard(title: Text("Plan")) {}.frame(width: 200)))
        // The header's padding and the title's 24 pt line, inside the 1 pt card edge: no 32 pt body, no rule.
        #expect(abs(headerOnly.height - (16 + 24 + 16)) <= 1)
        // With a footer, the footer's own rule is the only one between them.
        let withFooter = try #require(
            Rendered(
                QeetrixCard(title: Text("Plan")) {
                } footer: {
                    Color.clear.frame(width: 10, height: 10)
                }.frame(width: 200)))
        #expect(abs(withFooter.height - (16 + 24 + 16) - (1 + 16 + 10 + 16)) <= 1)
        // A body whose content renders nothing takes no room either.
        let nothing = try #require(Rendered(QeetrixCard(title: Text("Plan")) { if false { Text("x") } }.frame(width: 200)))
        if #available(iOS 18, macOS 15, *) { #expect(nothing.height == headerOnly.height) }
    }

    @Test("Footer actions sit at the end, wrapping when they don't fit")
    func footer() throws {
        let view = QeetrixCardFooterLayout(spacing: 8) {
            Color.blue.frame(width: 30, height: 20)
            Color.red.frame(width: 30, height: 20)
        }
        .frame(width: 100)
        let rendered = try #require(Rendered(view))
        #expect(rendered.height == 20)
        #expect(rendered.pixel(10, 10).a == 0, "Space at the start")
        #expect(rendered.pixel(95, 10).r > 200, "The last action at the end")
        let wrapped = try #require(
            Rendered(
                QeetrixCardFooterLayout(spacing: 8) {
                    Color.blue.frame(width: 60, height: 20)
                    Color.red.frame(width: 60, height: 20)
                }.frame(width: 100)))
        #expect(wrapped.height == 48)
    }

    @Test("Cards render with every part, and as a button style, selected or not")
    func renders() {
        let full = QeetrixCard(title: Text("Team plan"), description: Text("Billed monthly"), tone: .danger) {
            Text("Body")
        } actions: {
            QeetrixButton("View all", variant: .ghost, size: .sm) {}
        } footer: {
            QeetrixButton("Upgrade", size: .lg) {}
        }
        #expect(ImageRenderer(content: full.frame(width: 300)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixCard("Plan", description: "Monthly") { Text("Body") }.frame(width: 300)).cgImage != nil)
        #expect(
            ImageRenderer(
                content: QeetrixCard {
                    Text("Body")
                } footer: {
                    Text("Footer")
                }.frame(width: 300)
            ).cgImage != nil)
        #expect(
            ImageRenderer(
                content: QeetrixCard {
                    Text("Body")
                } actions: {
                    Text("Action")
                }.frame(width: 300)
            ).cgImage != nil)
        #expect(ImageRenderer(content: Button("Open") {}.buttonStyle(.qeetrixCard(isSelected: true)).frame(width: 300)).cgImage != nil)
        #expect(ImageRenderer(content: Button("Open") {}.buttonStyle(.qeetrixCard(.subdued)).frame(width: 300)).cgImage != nil)
    }

    @Test("A selected card is the selected tint inside a 2 pt Ember edge")
    func selected() throws {
        let image = try #require(
            Rendered(
                Button {
                } label: {
                    Color.clear.frame(width: 60, height: 20)
                }
                .buttonStyle(.qeetrixCard(isSelected: true)).environment(\.colorScheme, .light)))
        #expect(close(QeetrixTheme.light.resolve(.borderBrand).bytes, image.pixel(image.width / 2, 1)))
        #expect(close(QeetrixTheme.light.resolve(.bgSelected).bytes, image.pixel(image.width / 2, image.height / 2)))
    }
}
