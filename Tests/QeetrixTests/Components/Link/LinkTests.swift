import Foundation
import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Link")
struct LinkTests {
    @Test("Tones are @qeetrix/react's LinkTone, with link.css's colours at rest and lit")
    func tones() throws {
        #expect(QeetrixLinkTone.allCases.map(\.rawValue) == ["default", "subtle", "inherit"])
        #expect(QeetrixLinkTone.default.color(isLit: false) == .textLink)
        #expect(QeetrixLinkTone.default.color(isLit: true) == .textLinkHover)
        #expect(QeetrixLinkTone.subtle.color(isLit: false) == .textSubtle)
        #expect(QeetrixLinkTone.subtle.color(isLit: true) == .textDefault)
        #expect(QeetrixLinkTone.inherit.color(isLit: false) == nil)
        // The rules, from the pinned stylesheet itself.
        let css = String(decoding: try Repository.data("Upstream/qeetrix-react/css/link.css"), as: UTF8.self)
        #expect(css.contains("color: var(--qx-color-text-link)"))
        #expect(css.contains("color: var(--qx-color-text-link-hover)"))
        #expect(css.contains("text-decoration-thickness: var(--qx-border-width-default)"))
        #expect(css.contains("text-decoration-thickness: var(--qx-border-width-strong)"))
        #expect(css.contains("text-underline-offset: \(Int(QeetrixLinkMetrics.underlineOffset))px"))
        #expect(QeetrixLinkMetrics.underlineThickness(isLit: false) == 1 && QeetrixLinkMetrics.underlineThickness(isLit: true) == 2)
    }

    /// The rows of `image` where most of the width is ink, and the last row with any ink above them.
    private func underline(_ image: Rendered) -> (rows: [Int], letterBottom: Int) {
        func isInk(_ x: Int, _ y: Int) -> Bool { image.pixel(x, y).a > 128 }
        let rows = (0..<image.height).filter { y in (0..<image.width).filter { isInk($0, y) }.count > image.width * 3 / 4 }
        let top = rows.first ?? image.height
        let letterBottom = (0..<top).last { y in (0..<image.width).contains { isInk($0, y) } } ?? -1
        return (rows, letterBottom)
    }

    @Test("The underline is 1 pt, its top 3 pt under the baseline; 2 pt while lit")
    func underlineDrawn() throws {
        guard #available(iOS 18, macOS 15, *) else { return }
        // No descenders: the letters' lowest ink is the baseline.
        let words = Text("Resend code").qeetrixTextStyle(.bodyMd)
        let rest = try #require(Rendered(words.modifier(QeetrixLinkUnderline(thickness: 1)).foregroundStyle(.black)))
        let (rows, letterBottom) = underline(rest)
        #expect(rows.count == 1, "\(rows)")
        #expect((rows.first ?? 0) - (letterBottom + 1) == 3, "the gap between the baseline and the underline: \(rows) \(letterBottom)")
        let lit = try #require(Rendered(words.modifier(QeetrixLinkUnderline(thickness: 2)).foregroundStyle(.black)))
        #expect(underline(lit).rows.count == 2)
    }

    @Test("A link is laid out at its line's height, with a 44 pt target round it, and in the link colour")
    func layout() throws {
        let link = try #require(
            Rendered(QeetrixLink("Resend code") {}.qeetrixTextStyle(.bodyMd).environment(\.colorScheme, .light)))
        #expect(abs(link.height - 20) <= 1, "body.md's 20 pt line, its text frame rounded to the screen's pixels: \(link.height)")
        let ink = (0..<link.height).flatMap { y in (0..<link.width).map { link.pixel($0, y) } }.filter { $0.a > 200 }
        let colour = QeetrixTheme.light.resolve(.textLink).bytes
        #expect(ink.contains { close(colour, $0) })
        #expect(QeetrixHitArea().path(in: CGRect(x: 0, y: 0, width: 80, height: 20)).boundingRect.height == 44)
        // An icon leads, 6 pt before the words, and doesn't make the line taller.
        let icon = try #require(Rendered(QeetrixLink("Resend code", icon: .globe) {}.qeetrixTextStyle(.bodyMd)))
        #expect(icon.height == link.height, "\(icon.height)")
        #expect(icon.width == link.width + Int(QeetrixLinkMetrics.iconSize.points + QeetrixLinkMetrics.iconGap))
    }

    @Test("Inside a sentence: each link run is underlined and takes the tint; the other words are left as they are")
    func sentence() throws {
        var sentence = AttributedString("By continuing you accept the ")
        var terms = AttributedString("Terms of Service")
        terms.link = URL(string: "https://qeet.in/terms")
        terms.swiftUI.foregroundColor = .red
        sentence.append(terms)
        sentence.append(AttributedString("."))
        let linked = sentence.qeetrixLinks()
        let runs = Array(linked.runs)
        #expect(runs.count == 3)
        #expect(runs[1].link?.absoluteString == "https://qeet.in/terms")
        #expect(runs[1].swiftUI.underlineStyle == .single)
        #expect(runs[1].swiftUI.foregroundColor == nil)
        #expect(runs[0].swiftUI.underlineStyle == nil && runs[2].swiftUI.underlineStyle == nil)
        #expect(String(linked.characters) == "By continuing you accept the Terms of Service.")
        #expect(ImageRenderer(content: Text(linked).qeetrixTextStyle(.bodySm).qeetrixLinkTone().frame(width: 300)).cgImage != nil)
        #expect(ImageRenderer(content: Text(linked).qeetrixLinkTone(.inherit)).cgImage != nil)
    }

    #if os(macOS)
        @Test("An action is read as a button, a destination as a link, by its words")
        func accessibility() {
            let view = VStack {
                QeetrixLink("Change number") {}
                QeetrixLink("Privacy Policy", destination: URL(string: "https://qeet.in/privacy")!, tone: .subtle)
            }
            let elements = ListsAccessibilityTree.elements(of: view)
            #expect(elements.map(\.text) == ["Change number", "Privacy Policy"], "\(elements)")
            #expect(elements.map(\.role) == ["AXButton", "AXLink"])
        }
    #endif

    @Test("Links render in each tone, with an icon, disabled, wrapping and right to left")
    func renders() {
        let views: [AnyView] = [
            AnyView(QeetrixLink("Change number") {}),
            AnyView(QeetrixLink("Call me instead", tone: .subtle) {}),
            AnyView(QeetrixLink("Why do you need my SIM?", tone: .inherit) {}.foregroundStyle(QeetrixColor.textDanger)),
            AnyView(QeetrixLink("Read in another language", icon: .globe) {}.disabled(true)),
            AnyView(QeetrixLink("A long link that wraps onto a second line at this width", destination: URL(string: "https://qeet.in")!)),
            AnyView(QeetrixLink("Change number", icon: .arrowLeft) {}.environment(\.layoutDirection, .rightToLeft)),
        ]
        for view in views {
            #expect(ImageRenderer(content: view.qeetrixTextStyle(.bodySm).frame(width: 160)).cgImage != nil)
        }
    }
}
