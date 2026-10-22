import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Accordion")
struct AccordionTests {
    @Test("Tokens from component.accordion")
    func tokens() {
        #expect(QeetrixAccordionTokens.duration == QeetrixDuration(seconds: 0.2))
        #expect(QeetrixAccordionTokens.triggerPaddingBlock == 16)
        #expect(QeetrixAccordionTokens.divider == QeetrixComponentColor(.borderDefault))
        #expect(QeetrixAccordionMetrics.triggerType.tokens.weight == .medium)
        #expect(QeetrixAccordionMetrics.contentType.tokens.size == 14)
    }

    @Test("Expanded shows the content; collapsed hides it; the header is a touch target tall")
    func expansion() throws {
        func accordion(_ expanded: Bool) -> some View {
            QeetrixAccordion {
                QeetrixAccordionItem("Billing", description: Text("Invoices"), icon: .fileText, isExpanded: .constant(expanded)) {
                    Color.blue.frame(height: 100)
                }
            }
            .frame(width: 320)
        }
        let collapsed = try #require(Rendered(accordion(false)))
        let expanded = try #require(Rendered(accordion(true)))
        #expect(collapsed.height >= 44)
        #expect(expanded.height >= collapsed.height + 100)
    }

    @Test("Any DisclosureGroup takes the style, and items rule between themselves")
    func style() throws {
        let rule = QeetrixColor.borderDefault.color(for: .light).resolve(in: EnvironmentValues()).bytes
        let accordion = QeetrixAccordion {
            DisclosureGroup("One") { Text("A") }
            DisclosureGroup("Two") { Text("B") }
        }
        .frame(width: 200)
        .environment(\.colorScheme, .light)
        let rendered = try #require(Rendered(accordion))
        let rows = (0..<rendered.height).filter { close(rule, rendered.pixel(100, $0), tolerance: 6) && rendered.pixel(100, $0).a > 0 }
        #expect(rows.count == 1, "One rule between two items; none after the last")
        #expect(ImageRenderer(content: DisclosureGroup("Advanced") { Text("A") }.disclosureGroupStyle(.qeetrix)).cgImage != nil)
    }
}
