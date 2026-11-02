import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Accordion")
struct AccordionTests {
    private enum Section: Hashable { case tax, numbering, reminders }

    @Test("One at a time: opening a section replaces the open one; closing it leaves none")
    func single() {
        #expect(QeetrixAccordionExpansion.single(Section?.none, .tax, isExpanded: true) == .tax)
        #expect(QeetrixAccordionExpansion.single(Section.tax, .numbering, isExpanded: true) == .numbering)
        #expect(QeetrixAccordionExpansion.single(Section.tax, .tax, isExpanded: false) == nil)
        // Closing a section that isn't the open one leaves the open one open.
        #expect(QeetrixAccordionExpansion.single(Section.tax, .numbering, isExpanded: false) == .tax)
    }

    @Test("Any number: a section joins or leaves the set")
    func multiple() {
        let open: Set<Section> = [.tax]
        #expect(QeetrixAccordionExpansion.multiple(open, .numbering, isExpanded: true) == [.tax, .numbering])
        #expect(QeetrixAccordionExpansion.multiple(open, .tax, isExpanded: false) == [])
        #expect(QeetrixAccordionExpansion.multiple(open, .tax, isExpanded: true) == [.tax])
    }

    @Test("accordion.css: the trigger is control.lg tall, at least 44 pt; title.sm; the chevron icon.subtle, icon.disabled when disabled")
    func metrics() {
        #expect(QeetrixAccordionMetrics.triggerHeight(.compact) == 44)
        #expect(QeetrixAccordionMetrics.triggerHeight(.default) == 44)
        #expect(QeetrixAccordionMetrics.triggerHeight(.comfortable) == 44)
        #expect(QeetrixAccordionMetrics.titleType == QeetrixTypeSpec(.titleSm))
        #expect(QeetrixAccordionMetrics.chevronColor(isEnabled: true) == .iconSubtle)
        #expect(QeetrixAccordionMetrics.chevronColor(isEnabled: false) == .iconDisabled)
    }

    @Test("A section's binding follows the accordion that owns it")
    func context() {
        var open: Set<Section> = [.tax]
        let binding = Binding(get: { open }, set: { open = $0 })
        let accordion = QeetrixAccordion(expanded: binding) { EmptyView() }
        #expect(accordion.context.isExpanded?(AnyHashable(Section.tax)) == true)
        #expect(accordion.context.isExpanded?(AnyHashable(Section.numbering)) == false)
        accordion.context.setExpanded?(AnyHashable(Section.numbering), true)
        #expect(open == [.tax, .numbering])
        // A value of another type is no section of this accordion.
        #expect(accordion.context.isExpanded?(AnyHashable("tax")) == false)

        var one: Section? = .tax
        let single = QeetrixAccordion(expanded: Binding(get: { one }, set: { one = $0 })) { EmptyView() }
        single.context.setExpanded?(AnyHashable(Section.reminders), true)
        #expect(one == .reminders)
        single.context.setExpanded?(AnyHashable(Section.reminders), false)
        #expect(one == nil)

        let free = QeetrixAccordion { EmptyView() }
        #expect(free.context.isExpanded == nil && free.context.setExpanded == nil)
    }

    @Test("Closed, the content takes no room; open, it shows under the trigger with 16 pt below it")
    func panel() throws {
        func height(_ isExpanded: Bool) throws -> Int {
            let view = QeetrixAccordionItem("Tax settings", isExpanded: .constant(isExpanded)) {
                Color.red.frame(height: 50)
            }
            .frame(width: 320)
            return try #require(Rendered(view)).height
        }
        // Rule, 44 pt trigger, rule below (on its own).
        #expect(try height(false) == 46)
        #expect(try height(true) == 46 + 50 + 16)
    }

    @Test("The rules: border.subtle above each section and below the last")
    func rules() throws {
        let view = QeetrixAccordion(expanded: .constant(Set<Section>())) {
            QeetrixAccordionItem("Tax settings", value: Section.tax) { EmptyView() }
            QeetrixAccordionItem("Invoice numbering", value: Section.numbering) { EmptyView() }
        }
        .frame(width: 320)
        .environment(\.colorScheme, .light)
        let image = try #require(Rendered(view))
        let rule = QeetrixTheme.light.resolve(.borderSubtle).bytes
        // Two items of 1 + 44, then the accordion's own rule.
        #expect(image.height == 91)
        for y in [0, 45, 90] {
            #expect(close(rule, image.pixel(160, y)), "a rule at \(y)")
        }
        #expect(image.pixel(160, 1).a == 0, "the trigger has no fill")
    }

    @Test("Accordions, sections and the style render: open and closed, disabled, in both schemes")
    func renders() {
        for scheme in [ColorScheme.light, .dark] {
            let view = VStack {
                QeetrixAccordion(expanded: .constant(Section?.some(.tax))) {
                    QeetrixAccordionItem("Tax settings", value: Section.tax) { QeetrixText("GST is added at 18%.") }
                    QeetrixAccordionItem("Reminders", value: Section.reminders) { QeetrixText("Off") }.disabled(true)
                }
                QeetrixAccordion {
                    QeetrixAccordionItem("Advanced", isExpanded: .constant(true), headingLevel: 2) { QeetrixText("Retries") }
                }
                DisclosureGroup("Retry policy", isExpanded: .constant(false)) { QeetrixText("Three attempts.") }
                    .disclosureGroupStyle(.qeetrixAccordion())
            }
            .frame(width: 360)
            .environment(\.colorScheme, scheme)
            #expect(ImageRenderer(content: view).cgImage != nil)
        }
    }
}
