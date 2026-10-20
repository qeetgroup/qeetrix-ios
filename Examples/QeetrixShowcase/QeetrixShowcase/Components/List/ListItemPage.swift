import Qeetrix
import SwiftUI

/// Rows in a native `List`, with sections, navigation, selection, swipe actions and a context menu.
struct ListItemPage: View {
    @State private var documents = ShowcaseDocument.samples
    @State private var selected: Int? = 1
    @State private var notifications = true
    @State private var lastAction = "none"
    @State private var toast: QeetrixToast?

    var body: some View {
        List {
            Section {
                QeetrixListItem("Q3 summary")
                QeetrixListItem(
                    "Design review", description: Text("Edited by Ravi Kumar"), metadata: Text(verbatim: "860 KB"), icon: .fileText)
                QeetrixListItem("Asha Rao", description: Text(verbatim: "asha@example.com")) {
                    QeetrixBadge("Owner", variant: .brand)
                } leading: {
                    QeetrixAvatar(name: "Asha Rao")
                }
                QeetrixListItem("Archived workspace", description: Text("Read-only"), icon: .folder).disabled(true)
            } header: {
                QeetrixSectionHeader("Rows", description: Text("Title, description, metadata, leading and trailing views."))
            }

            Section {
                ForEach(documents) { document in
                    NavigationLink {
                        DocumentDetail(document: document)
                    } label: {
                        QeetrixListItem(
                            document.title, description: Text(document.owner), metadata: Text(verbatim: document.size), icon: .fileText
                        ) {
                            QeetrixBadge(document.status.rawValue, variant: document.status == .active ? .success : .secondary)
                        }
                    }
                    .qeetrixListRow()
                    .swipeActions {
                        Button(role: .destructive) {
                            remove(document)
                        } label: {
                            Label {
                                Text("Delete")
                            } icon: {
                                Image(qeetrix: .trash)
                            }
                        }
                    }
                    .contextMenu {
                        QeetrixMenuItem("Rename", icon: .pencil) { lastAction = "rename \(document.title)" }
                        QeetrixMenuItem("Delete", icon: .trash, role: .destructive) { remove(document) }
                    }
                }
            } header: {
                QeetrixSectionHeader("Documents", description: Text("Swipe or touch and hold a row for actions.")) {
                    QeetrixButton("Reset", variant: .link, size: .sm) { documents = ShowcaseDocument.samples }
                }
            }

            Section {
                ForEach(ShowcaseDocument.samples.prefix(3)) { document in
                    Button {
                        selected = document.id
                    } label: {
                        QeetrixListItem(
                            document.title, description: Text(document.owner), icon: .fileText, isSelected: selected == document.id)
                    }
                    .foregroundStyle(QeetrixColor.textPrimary)
                    .qeetrixListRow()
                }
            } header: {
                QeetrixSectionHeader("Selection", description: Text("The app owns which row is selected."))
            }

            Section {
                QeetrixListItem("Roadmap", description: Text("Meera Iyer"), icon: .fileText) {
                    QeetrixMenu(icon: .ellipsis, label: Text("Actions for Roadmap")) {
                        QeetrixMenuItem("Rename", icon: .pencil) { lastAction = "rename Roadmap" }
                        QeetrixMenuItem("Share", icon: .share2) { lastAction = "share Roadmap" }
                    }
                }
                QeetrixSwitch("Email notifications", isOn: $notifications)
                    .padding(.leading, QeetrixSpacing.l)  // the row's trailing inset is the rest
                    .qeetrixListRow()
                QeetrixListItem("Last action", description: Text(lastAction)).accessibilityIdentifier("list-last-action")
            } header: {
                QeetrixSectionHeader("Controls", description: Text("A menu beside the row; a switch is its own row."))
            }
        }
        .scrollContentBackground(.hidden)
        .background(QeetrixColor.surfaceCanvas)
        .navigationTitle("List item")
        .navigationBarTitleDisplayMode(.inline)
        .qeetrixToast($toast)
    }

    private func remove(_ document: ShowcaseDocument) {
        guard let index = documents.firstIndex(of: document) else { return }
        documents.remove(at: index)
        lastAction = "delete \(document.title)"
        toast = QeetrixToast(
            .info, title: "\(document.title) deleted",
            action: .init("Undo") {
                documents.insert(document, at: min(index, documents.count))
            })
    }
}

/// A pushed detail: the document's properties and history.
struct DocumentDetail: View {
    let document: ShowcaseDocument

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QeetrixSpacing.xl) {
                QeetrixDescriptionList(isDivided: true) {
                    QeetrixDescriptionItem("Title", value: Text(verbatim: document.title))
                    QeetrixDescriptionItem("Owner", value: Text(verbatim: document.owner))
                    QeetrixDescriptionItem("Size", value: Text(verbatim: document.size))
                    QeetrixDescriptionItem("Status") {
                        QeetrixBadge(document.status.rawValue, variant: document.status == .active ? .success : .secondary)
                    }
                }
                QeetrixCard {
                    QeetrixListItem("Owner", description: Text(verbatim: document.owner), icon: .users) {
                        QeetrixBadge("Editor", variant: .secondary).accessibilityIdentifier("detail-owner-badge")
                    }
                    .accessibilityIdentifier("detail-owner-row")
                }
                QeetrixSectionHeader("History")
                QeetrixTimeline {
                    QeetrixTimelineItem("Shared with the team", time: Text(verbatim: "Today, 09:41"), tone: .brand, icon: .users)
                    QeetrixTimelineItem("Edited", time: Text(verbatim: "Yesterday"), description: Text(verbatim: document.owner))
                    QeetrixTimelineItem("Created", time: Text(verbatim: "12 Oct"))
                }
            }
            .padding(QeetrixSpacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(QeetrixColor.surfaceCanvas)
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("document-detail")
    }
}

#Preview {
    NavigationStack { ListItemPage() }
}
