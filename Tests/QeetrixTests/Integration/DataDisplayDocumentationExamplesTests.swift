import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing

// The examples from the Phase 5 pages of Sources/Qeetrix/Qeetrix.docc — Components/ListItem.md,
// DescriptionList.md, Accordion.md, EmptyState.md, DataState.md, Skeleton.md, Chip.md, Timeline.md,
// Collections.md and Searching.md — copied verbatim inside views that supply the names they use.

private struct File: Identifiable, Hashable {
    let id: Int
    let name: String
    let owner: String
    let size: String
    let status: String
}

private struct Member: Identifiable {
    let id: Int
    let name: String
    let email: String
    let role: String
}

private struct Document: Identifiable {
    enum Status: Hashable { case open, closed }
    let id: Int
    let title: String
    let status: Status
}

private enum Status: Hashable { case open, closed }

/// ListItem.md.
private struct ListItemExample: View {
    let files = [File(id: 1, name: "Q3 summary", owner: "Asha Rao", size: "2 MB", status: "Shared")]

    var body: some View {
        List {
            Section {
                ForEach(files) { file in
                    NavigationLink(value: file) {
                        QeetrixListItem(file.name, description: Text(file.owner), metadata: Text(file.size), icon: .fileText) {
                            QeetrixBadge(file.status, variant: .secondary)
                        }
                    }
                    .qeetrixListRow()
                    .swipeActions { Button("Delete", role: .destructive) { delete(file) } }
                }
            } header: {
                QeetrixSectionHeader("Files", description: Text("Shared with your team."))
            }
        }
    }

    func delete(_ file: File) {}
}

/// DescriptionList.md, Accordion.md, EmptyState.md, Skeleton.md, Chip.md and Timeline.md.
private struct ComponentExamples: View {
    @State private var showsUnread = false
    @State private var status: Status? = nil
    @State private var labels: Set<String> = ["Design"]
    let createdAt = Date(timeIntervalSince1970: 0)

    var body: some View {
        VStack {
            QeetrixDescriptionList(isDivided: true) {
                QeetrixDescriptionItem("Plan", value: Text("Team"))
                QeetrixDescriptionItem("Created", value: Text(createdAt, style: .date))
                QeetrixDescriptionItem("Status") { QeetrixBadge("Active", variant: .success) }
            }
            QeetrixAccordion {
                QeetrixAccordionItem("Billing", description: Text("Invoices and payment method"), icon: .fileText) {
                    Text("Billing settings")
                }
                QeetrixAccordionItem("Members", icon: .users) {
                    Text("Member settings")
                }
            }
            QeetrixEmptyState(
                "No invoices yet", description: Text("Invoices appear here once you bill a customer."),
                variant: .firstUse, icon: .fileText
            ) {
                QeetrixButton("Create invoice") { createInvoice() }
            }
            HStack(spacing: 12) {
                QeetrixSkeleton(.circle).frame(width: 40, height: 40)
                QeetrixSkeletonText(lines: 2, role: .label)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Loading members"))
            QeetrixChip("Unread", isSelected: $showsUnread)
            let statuses: [QeetrixOption<Status?>] = [
                QeetrixOption("All", value: nil),
                QeetrixOption("Open", value: .open),
                QeetrixOption("Closed", value: .closed),
            ]
            QeetrixChipGroup("Status", selection: $status, options: statuses)
            QeetrixChip("Design", icon: .folder) { labels.remove("Design") }
            QeetrixTimeline {
                QeetrixTimelineItem("Invoice paid", time: Text("09:41"), tone: .success, icon: .check)
                QeetrixTimelineItem("Reminder sent", time: Text("Yesterday"), tone: .info)
                QeetrixTimelineItem("Synced", emphasis: .minor)
            }
        }
    }

    func createInvoice() {}
}

/// DataState.md.
private struct DataStateExample: View {
    @MainActor final class Model {
        var isLoading = false
        var failed = true
        var members: [Member] = []
        func reload() {}
    }

    let model = Model()

    var body: some View {
        QeetrixDataState(
            isLoading: model.isLoading, isEmpty: model.members.isEmpty,
            failure: model.failed ? QeetrixDataFailure("Couldn't load members.") { model.reload() } : nil
        ) {
            MemberList(members: model.members)
        } empty: {
            QeetrixEmptyState("No members yet", description: Text("Invite people to this workspace."))
        }
    }
}

private struct MemberList: View {
    let members: [Member]
    var body: some View { Text("\(members.count) members") }
}

/// Collections.md.
private struct Members: View {
    let members: [Member]
    @State private var selected: Member.ID?

    var body: some View {
        List {
            Section {
                ForEach(members) { member in
                    Button {
                        selected = member.id
                    } label: {
                        QeetrixListItem(member.name, description: Text(member.email), isSelected: selected == member.id) {
                            QeetrixBadge(member.role, variant: .secondary)
                        } leading: {
                            QeetrixAvatar(name: member.name)
                        }
                    }
                    .qeetrixListRow()
                }
            } header: {
                QeetrixSectionHeader("Members")
            }
        }
        .scrollContentBackground(.hidden)
        .background(QeetrixColor.surfaceCanvas)
    }
}

/// Searching.md.
private struct Documents: View {
    let documents: [Document]
    @State private var query = ""
    @State private var status: Document.Status? = nil
    let statusOptions = [QeetrixOption("All", value: Document.Status?.none), QeetrixOption("Open", value: Document.Status.open)]

    private var results: [Document] {
        documents.filter { ($0.status == status || status == nil) && (query.isEmpty || $0.title.localizedCaseInsensitiveContains(query)) }
    }

    var body: some View {
        List {
            QeetrixChipGroup("Status", selection: $status, options: statusOptions)
            if results.isEmpty {
                QeetrixEmptyState("No results", description: Text("Nothing matches your search."), variant: .noResults, size: .sm) {
                    QeetrixButton("Clear search", variant: .outline, size: .sm) {
                        query = ""; status = nil
                    }
                }
            }
            ForEach(results) { document in QeetrixListItem(document.title, icon: .fileText) }
        }
        #if os(iOS)
            .searchable(text: $query, prompt: Text("Search documents"))
        #endif
    }
}

@MainActor
@Suite("Phase 5 documentation examples")
struct DataDisplayDocumentationExamplesTests {
    @Test("Every Phase 5 example compiles against the public API and renders, in both themes")
    func examplesRender() {
        for theme in [QeetrixThemeMode.light, .dark] {
            #expect(ImageRenderer(content: ComponentExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: DataStateExample().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            // Lists are hosted by UIKit, which ImageRenderer does not draw; building them is the check.
            _ = ListItemExample().body
            _ = Members(members: [Member(id: 1, name: "Asha Rao", email: "asha@example.com", role: "Owner")]).body
            _ = Documents(documents: [Document(id: 1, title: "Roadmap", status: .open)]).body
        }
    }
}
