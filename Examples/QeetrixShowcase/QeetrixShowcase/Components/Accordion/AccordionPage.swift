import Qeetrix
import SwiftUI

struct AccordionPage: View {
    enum Topic: Hashable { case plan, people, security }

    @State private var open: Topic? = .plan
    @State private var showsAdvanced = false

    var body: some View {
        ComponentPage(
            title: "Accordion",
            summary: "Sections whose headers show and hide their content — native DisclosureGroups in the Qeetrix style."
        ) {
            DemoSection("Several open at once") {
                QeetrixAccordion {
                    QeetrixAccordionItem("Billing", description: Text("Invoices and payment method"), icon: .fileText) {
                        QeetrixText("Invoices are sent on the first of each month.")
                    }
                    QeetrixAccordionItem("Members", icon: .users) {
                        QeetrixText("Twelve people have access.")
                    }
                }
            }
            DemoSection("One at a time") {
                QeetrixAccordion {
                    item("Plan", .plan) { QeetrixText("Team plan, billed monthly.") }
                    item("People", .people) { QeetrixText("Twelve members, two admins.") }
                    item("Security", .security) {
                        DisclosureGroup("Advanced", isExpanded: $showsAdvanced) {
                            QeetrixText("Session length and sign-in rules.")
                        }
                    }
                }
                QeetrixText("Open: \(name(open))", variant: .muted).accessibilityIdentifier("accordion-open")
            }
        }
    }

    /// One item of the one-at-a-time group: open when `open` is its topic.
    private func item(_ title: String, _ topic: Topic, @ViewBuilder content: () -> some View) -> some View {
        QeetrixAccordionItem(title, isExpanded: Binding(get: { open == topic }, set: { open = $0 ? topic : nil }), content: content)
    }

    private func name(_ topic: Topic?) -> String {
        switch topic {
        case .plan: "plan"
        case .people: "people"
        case .security: "security"
        case nil: "none"
        }
    }
}

#Preview {
    NavigationStack { AccordionPage() }
}
