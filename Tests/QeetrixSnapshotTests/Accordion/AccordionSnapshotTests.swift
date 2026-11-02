#if os(iOS)
    import SwiftUI
    import Testing

    @testable import Qeetrix

    @MainActor
    @Suite("Accordion snapshots")
    struct AccordionSnapshotTests {
        @Test("Open and closed sections, a disabled one, a long title, and a section on its own")
        func variants() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 24) {
                    QeetrixAccordion(expanded: .constant(Optional(1))) {
                        QeetrixAccordionItem("Tax settings", value: 1) {
                            QeetrixText("GST is added at 18% to every invoice for customers in India.")
                        }
                        QeetrixAccordionItem("Invoice numbering", value: 2) { QeetrixText("INV-YYYY-NNNN") }
                        QeetrixAccordionItem("Payment reminders", value: 3) { QeetrixText("Off") }.disabled(true)
                        QeetrixAccordionItem("What happens to unpaid invoices at the end of the financial year?", value: 4) {
                            QeetrixText("They carry over.")
                        }
                    }
                    QeetrixAccordionItem("Advanced options", isExpanded: .constant(false)) {
                        QeetrixText("Retry failed webhooks")
                    }
                }
            )
        }
    }
#endif
