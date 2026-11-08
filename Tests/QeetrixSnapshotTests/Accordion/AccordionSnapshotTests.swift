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

        @Test("A summary under the title, closed and open, and with a long title and summary")
        func summaries() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 24) {
                    QeetrixAccordionItem("Advanced", description: Text("6 digits · every 30 seconds · SHA-1"), isExpanded: .constant(false))
                    {
                        QeetrixText("Change these only if the service's setup page asks you to.")
                    }
                    QeetrixAccordion(expanded: .constant(Optional(1))) {
                        QeetrixAccordionItem("Advanced", description: Text("6 digits · every 30 seconds · SHA-1"), value: 1) {
                            QeetrixText("Change these only if the service's setup page asks you to.")
                        }
                        QeetrixAccordionItem(
                            "When the app locks itself after you leave it", description: Text("After 1 minute in the background"), value: 2
                        ) {
                            QeetrixText("Immediately, after 1 minute, or after 5 minutes.")
                        }
                    }
                }
            )
        }
    }
#endif
