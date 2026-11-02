import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Section header")
struct SectionHeaderTests {
    @Test("sidebar.css: gap.sm, the rule and inset.md above a ruled label; gap.sm alone above the first; 6 pt below")
    func metrics() {
        // gap.sm 8 + the 1 pt rule + inset.md 12.
        #expect(QeetrixSectionHeaderMetrics.topPadding(isRuled: true) == CGFloat(21))
        #expect(QeetrixSectionHeaderMetrics.topPadding(isRuled: false) == 8)
        #expect(QeetrixSectionHeaderMetrics.bottomPadding == 6)
    }

    @Test("A header is its padding round label.caps's 16 pt line")
    func heights() throws {
        let ruled = try #require(Rendered(QeetrixSectionHeader("Security").frame(width: 390)))
        let first = try #require(Rendered(QeetrixSectionHeader("Security", isRuled: false).frame(width: 390)))
        #expect(abs(ruled.height - (21 + 16 + 6)) <= 1)
        #expect(abs(first.height - (8 + 16 + 6)) <= 1)
        #expect(ruled.height - first.height == 13)
    }

    @Test("The rule is color.border.subtle, gap.sm down, edge to edge; the first group has none")
    func rule() throws {
        let ruled = try #require(Rendered(QeetrixSectionHeader("Security").frame(width: 200).environment(\.colorScheme, .light)))
        let subtle = QeetrixTheme.light.resolve(.borderSubtle).bytes
        #expect(close(subtle, ruled.pixel(0, 8)))
        #expect(close(subtle, ruled.pixel(199, 8)))
        #expect(ruled.pixel(100, 7).a == 0 && ruled.pixel(100, 9).a == 0)
        let first = try #require(Rendered(QeetrixSectionHeader("Security", isRuled: false).frame(width: 200)))
        #expect((0..<6).allSatisfy { first.pixel(100, $0).a == 0 })
    }

    @Test("Indic text drops label.caps's tracking, by its letters or the app's language")
    func indic() throws {
        #expect(QeetrixSectionHeaderMetrics.isIndic("सुरक्षा"))
        #expect(QeetrixSectionHeaderMetrics.isIndic("பாதுகாப்பு"))
        #expect(!QeetrixSectionHeaderMetrics.isIndic("Security"))
        #expect(QeetrixSectionHeaderMetrics.isIndic(Locale(identifier: "hi_IN")))
        #expect(QeetrixSectionHeaderMetrics.isIndic(Locale(identifier: "ta")))
        #expect(!QeetrixSectionHeaderMetrics.isIndic(Locale(identifier: "en_IN")))
        #expect(QeetrixSectionHeader("सुरक्षा").isIndicTitle)
        #expect(!QeetrixSectionHeader("Security").isIndicTitle)
        // The same Latin title, tracked and untracked: +0.66 pt a letter is gone.
        func width(_ locale: Locale) throws -> Int {
            let image = try #require(
                Rendered(QeetrixSectionHeader(title: Text(verbatim: "SECURITY"), isRuled: false).fixedSize().environment(\.locale, locale)))
            return image.width
        }
        #expect(try width(Locale(identifier: "en")) - width(Locale(identifier: "hi")) >= 4)
    }

    #if os(macOS)
        @Test("VoiceOver reads the title as written and the description, as one heading; the action is its own")
        func accessibility() {
            let elements = ListsAccessibilityTree.elements(
                of: QeetrixSectionHeader("Signed-in devices", description: Text("Where you're signed in")) {
                    QeetrixButton("Sign out all", variant: .ghost, size: .sm) {}
                })
            #expect(elements.map(\.text) == ["Signed-in devices, Where you're signed in", "Sign out all"], "\(elements)")
            #expect(elements.map(\.role) == ["AXHeading", "AXButton"])
        }
    #endif

    @Test("Headers render with a description and an action, in both schemes")
    func renders() {
        for scheme in [ColorScheme.light, .dark] {
            let header = QeetrixSectionHeader("Signed-in devices", description: Text("Where you're signed in")) {
                QeetrixButton("Sign out all", variant: .ghost, tone: .danger, size: .sm) {}
            }
            #expect(ImageRenderer(content: header.frame(width: 390).environment(\.colorScheme, scheme)).cgImage != nil)
        }
    }
}
