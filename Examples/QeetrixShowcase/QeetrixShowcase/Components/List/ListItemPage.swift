import Qeetrix
import SwiftUI

struct ListItemPage: View {
    @State private var faceID = true
    @State private var notifications = false
    @State private var selected: Set<String> = ["Ada Lovelace"]
    @State private var languageTaps = 0
    @State private var signOuts = 0
    let people = ["Ada Lovelace", "Grace Hopper", "Priya Sharma"]
    let inviteURL = URL(string: "https://id.qeet.in/invite")!

    var body: some View {
        ComponentPage(
            title: "List item",
            summary:
                "A row of a collection: a title, a description and a value, a leading icon or avatar, and a chevron or switch at the end."
        ) {
            DemoSection("Rows that do something") {
                VStack(spacing: 0) {
                    QeetrixListItem("Priya Sharma", description: Text(verbatim: "priya@acme.in"), value: ListItemDemoRoute.account) {
                        QeetrixAvatar(name: "Priya Sharma", isDecorative: true)
                    }
                    QeetrixSeparator()
                    QeetrixListItem("Face ID", description: Text("Unlock Qeet Auth with your face"), isOn: $faceID) {
                        QeetrixListItemIcon(.scanLine)
                    }
                    QeetrixSeparator()
                    QeetrixListItem("Notifications", isOn: $notifications) { QeetrixListItemIcon(.bell) }
                    QeetrixSeparator()
                    QeetrixListItem("Language", metadata: Text("English"), accessory: .chevron) { languageTaps += 1 }
                    QeetrixSeparator()
                    QeetrixListItem("Sign out", role: .destructive) {
                        signOuts += 1
                    } leading: {
                        QeetrixListItemIcon(.x)
                    }
                }
                QeetrixText("Language opened \(languageTaps) times, signed out \(signOuts) times", size: .sm, tone: .subtle)
                    .accessibilityIdentifier("list-item-taps")
            }
            DemoSection("Rows that show something") {
                VStack(spacing: 0) {
                    QeetrixListItem("Storage", description: Text("Used this month"), metadata: Text("2.4 GB")) {
                        QeetrixListItemIcon(.database)
                    } trailing: {
                        QeetrixBadge("Pro", tone: .brand)
                    }
                    QeetrixSeparator()
                    QeetrixListItem("Last backup", metadata: Text("10:42")) { QeetrixListItemIcon(.cloudUpload) }
                    QeetrixSeparator()
                    QeetrixListItem("Syncing", description: Text("3 of 12 accounts")) {
                        QeetrixListItemIcon(.refreshCw)
                    } trailing: {
                        QeetrixSpinner(size: .sm)
                    }
                }
            }
            DemoSection("Selection") {
                VStack(spacing: 0) {
                    ForEach(people, id: \.self) { name in
                        let isSelected = selected.contains(name)
                        QeetrixListItem(name, isSelected: isSelected) {
                            if isSelected { selected.remove(name) } else { selected.insert(name) }
                        } leading: {
                            QeetrixAvatar(name: name, isDecorative: true)
                        } trailing: {
                            if isSelected { QeetrixIcon(.check, size: .sm, shape: .sharp).foregroundStyle(QeetrixColor.iconBrand) }
                        }
                        QeetrixSeparator()
                    }
                }
            }
            DemoSection("Disabled") {
                QeetrixListItem("Managed by Acme", description: Text("Your organisation sets this"), isOn: .constant(true)) {
                    QeetrixListItemIcon(.lock)
                }
                .disabled(true)
            }
            DemoSection("Any button as a row") {
                ShareLink(item: inviteURL) {
                    QeetrixListItem("Invite a teammate") { QeetrixListItemIcon(.userPlus) }
                }
                .buttonStyle(.qeetrixListItem())
            }
            DemoSection("In a List") {
                List {
                    Section {
                        QeetrixListItem("Priya Sharma", description: Text(verbatim: "priya@acme.in"), value: ListItemDemoRoute.account) {
                            QeetrixAvatar(name: "Priya Sharma", isDecorative: true)
                        }
                        QeetrixListItem("Kaveri Foods", description: Text(verbatim: "admin@kaveri.in"), value: ListItemDemoRoute.account) {
                            QeetrixAvatar(name: "Kaveri Foods", shape: .square, isDecorative: true)
                        }
                    } header: {
                        QeetrixSectionHeader("Accounts", isRuled: false)
                    }
                    .listSectionSeparator(.hidden)
                    Section {
                        QeetrixListItem("Face ID", isOn: $faceID) { QeetrixListItemIcon(.scanLine) }
                        QeetrixListItem("Language", metadata: Text("English"), accessory: .chevron) { languageTaps += 1 }
                        QeetrixListItem("Sign out", role: .destructive) { signOuts += 1 }
                    } header: {
                        QeetrixSectionHeader("Security")
                    }
                    .listSectionSeparator(.hidden)
                }
                .qeetrixListStyle()
                .frame(height: 420)
            }
        }
        .navigationDestination(for: ListItemDemoRoute.self) { _ in
            ListItemDemoAccount()
        }
    }
}

private enum ListItemDemoRoute: Hashable {
    case account
}

/// Where the account rows lead.
private struct ListItemDemoAccount: View {
    var body: some View {
        ScrollView {
            QeetrixDescriptionList {
                QeetrixDescriptionItem("Name", value: "Priya Sharma")
                QeetrixDescriptionItem("Email", value: "priya@acme.in")
                QeetrixDescriptionItem("Added", value: "30 Oct 2026")
            }
            .padding(QeetrixSpace.insetLg)
        }
        .background(QeetrixColor.surfaceCanvas)
        .navigationTitle("Account")
        .accessibilityIdentifier("list-item-account")
    }
}

#Preview {
    NavigationStack { ListItemPage() }
}

#Preview("Large text, dark") {
    NavigationStack { ListItemPage() }
        .environment(\.dynamicTypeSize, .accessibility3)
        .preferredColorScheme(.dark)
}
