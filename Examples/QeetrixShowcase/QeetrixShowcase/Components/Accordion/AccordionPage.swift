import Qeetrix
import SwiftUI

struct AccordionPage: View {
    private enum Section: String { case tax, numbering, reminders, export }

    @State private var open: Section? = .tax
    @State private var several: Set<Section> = [.tax, .numbering]
    @State private var showsAdvanced = false
    @State private var retries = true

    var body: some View {
        ComponentPage(
            title: "Accordion",
            summary:
                "Stacked sections that show and hide, ruled between. The chevron turns and the content opens by height; nothing moves under Reduce Motion."
        ) {
            DemoSection("One at a time") {
                QeetrixAccordion(expanded: $open) {
                    QeetrixAccordionItem("Tax settings", value: Section.tax) {
                        QeetrixText("GST is added at 18% to every invoice for customers in India.")
                    }
                    QeetrixAccordionItem("Invoice numbering", value: Section.numbering) {
                        QeetrixText("INV-YYYY-NNNN, starting again each financial year.")
                    }
                    QeetrixAccordionItem("Payment reminders", value: Section.reminders) {
                        QeetrixText("Available on the Growth plan.")
                    }
                    .disabled(true)
                }
                QeetrixText("Open: \(open?.rawValue ?? "none")", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("accordion-open")
            }
            DemoSection("Any number") {
                QeetrixAccordion(expanded: $several) {
                    QeetrixAccordionItem("Tax settings", value: Section.tax) { QeetrixText("GST is added at 18%.") }
                    QeetrixAccordionItem("Invoice numbering", value: Section.numbering) { QeetrixText("INV-YYYY-NNNN") }
                    QeetrixAccordionItem("What happens to unpaid invoices at the end of the financial year?", value: Section.export) {
                        QeetrixText("They carry over to the next year, with their original dates.")
                    }
                }
            }
            DemoSection("A single section") {
                QeetrixAccordionItem("Advanced options", isExpanded: $showsAdvanced) {
                    QeetrixSwitch("Retry failed webhooks", isOn: $retries)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { AccordionPage() }
}
