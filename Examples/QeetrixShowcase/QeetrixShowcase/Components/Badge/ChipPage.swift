import Qeetrix
import SwiftUI

struct ChipPage: View {
    enum Status: String, CaseIterable, Hashable {
        case all = "All", open = "Open", closed = "Closed"
    }

    @State private var unread = false
    @State private var starred = true
    @State private var status = Status.all
    @State private var labels: Set<String> = ["Design"]
    @State private var tags = ["Design", "Research", "Q3"]

    var body: some View {
        ComponentPage(
            title: "Chip",
            summary: "Pills that filter or choose. A selected chip is tinted, edged and checked. The app decides what they filter."
        ) {
            DemoSection("Toggles") {
                FlowLayout {
                    QeetrixChip("Unread", isSelected: $unread)
                    QeetrixChip("Following", isSelected: $starred, icon: .bell)
                    QeetrixChip("Shared", isSelected: .constant(false)).disabled(true)
                }
                QeetrixText("Unread: \(unread ? "on" : "off")", variant: .muted).accessibilityIdentifier("chip-unread")
            }
            DemoSection("One of a set") {
                QeetrixChipGroup("Status", selection: $status, options: Status.allCases.map { QeetrixOption($0.rawValue, value: $0) })
                QeetrixText("Status: \(status.rawValue)", variant: .muted).accessibilityIdentifier("chip-status")
            }
            DemoSection("Several of a set") {
                QeetrixChipGroup(
                    "Labels", selection: $labels,
                    options: ["Design", "Engineering", "Research", "Legal"].map {
                        QeetrixOption($0, value: $0, isDisabled: $0 == "Legal")
                    })
                QeetrixText("Labels: \(labels.sorted().joined(separator: ", "))", variant: .muted).accessibilityIdentifier("chip-labels")
            }
            DemoSection("Removable") {
                FlowLayout {
                    ForEach(tags, id: \.self) { tag in
                        QeetrixChip(tag, icon: .folder) { tags.removeAll { $0 == tag } }
                    }
                }
                QeetrixButton("Reset", variant: .outline, size: .sm) { tags = ["Design", "Research", "Q3"] }
                QeetrixText("Tags: \(tags.count)", variant: .muted).accessibilityIdentifier("chip-tags")
            }
            DemoSection("Sizes") {
                FlowLayout {
                    QeetrixChip("Small", isSelected: .constant(true), size: .sm)
                    QeetrixChip("Medium", isSelected: .constant(true))
                    QeetrixChip("Large", isSelected: .constant(true), size: .lg)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { ChipPage() }
}
