import Qeetrix
import SwiftUI

struct ChipPage: View {
    private enum Status: String, CaseIterable { case all, open, pending, closed }

    @State private var unread = false
    @State private var mentions = true
    @State private var starred = false
    @State private var status = Status.all
    @State private var departments: Set<String> = ["Engineering"]
    @State private var filters = ["Status: Active", "Team: Finance", "Plan: Growth"]

    private let departmentNames = ["Engineering", "Finance", "Design", "Sales", "Support", "Legal", "People", "Operations"]

    var body: some View {
        ComponentPage(
            title: "Chip",
            summary:
                "An interactive tag: a filter that turns on and off, chosen with the selected tint, a 2 pt Ember edge and a check, or a choice already made with a button that removes it."
        ) {
            DemoSection("Selectable") {
                QeetrixChipFlowLayout {
                    QeetrixChip("Unread", isSelected: $unread)
                    QeetrixChip("Mentions", isSelected: $mentions, icon: .bell)
                    Toggle("Starred", isOn: $starred).toggleStyle(.qeetrixChip(icon: .pin))
                    QeetrixChip("Archived", isSelected: .constant(false)).disabled(true)
                    QeetrixChip("Pinned", isSelected: .constant(true)).disabled(true)
                }
                QeetrixText("Unread \(unread ? "on" : "off"), mentions \(mentions ? "on" : "off")", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("chip-state")
            }
            DemoSection("One value") {
                QeetrixChipGroup(
                    "Status", selection: $status,
                    options: Status.allCases.map { QeetrixOption($0.rawValue.capitalized, value: $0, isDisabled: $0 == .closed) },
                    size: .sm)
                QeetrixText("Status: \(status.rawValue)", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("chip-status")
            }
            DemoSection("Several, wrapping") {
                QeetrixChipGroup("Departments", selection: $departments, options: departmentNames.map { QeetrixOption($0, value: $0) })
            }
            DemoSection("Several, scrolling sideways") {
                QeetrixChipGroup(
                    "Departments", selection: $departments, options: departmentNames.map { QeetrixOption($0, value: $0) },
                    overflow: .scroll)
            }
            DemoSection("Removable") {
                QeetrixChipFlowLayout {
                    ForEach(filters, id: \.self) { filter in
                        QeetrixChip(filter) { filters.removeAll { $0 == filter } }
                    }
                    QeetrixChip("Region: South", icon: .mapPin) {}.disabled(true)
                }
                if filters.isEmpty {
                    QeetrixButton("Reset filters", variant: .ghost, size: .sm) {
                        filters = ["Status: Active", "Team: Finance", "Plan: Growth"]
                    }
                }
            }
            DemoSection("Sizes") {
                QeetrixChipFlowLayout {
                    ForEach(QeetrixControlSize.allCases, id: \.self) { size in
                        QeetrixChip(size.rawValue, isSelected: .constant(true), size: size)
                    }
                }
            }
            DemoSection("A long label wraps") {
                QeetrixChip("Invoices overdue by more than thirty days, across every customer", isSelected: .constant(false))
            }
        }
    }
}

#Preview {
    NavigationStack { ChipPage() }
}
