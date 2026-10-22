#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Accordion snapshots")
    struct AccordionSnapshotTests {
        @Test("Collapsed and expanded, with a description and an icon")
        func items() {
            assertSpecimen(
                QeetrixAccordion {
                    QeetrixAccordionItem(
                        "Billing", description: Text("Invoices and payment method"), icon: .fileText, isExpanded: .constant(true)
                    ) {
                        Text("Invoices are sent on the first of each month.")
                    }
                    QeetrixAccordionItem("Members", icon: .users, isExpanded: .constant(false)) {
                        Text("Twelve people have access.")
                    }
                    DisclosureGroup("Advanced", isExpanded: .constant(false)) { Text("Hidden") }
                }
            )
        }
    }
#endif
