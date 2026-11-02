import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing

// The examples from Sources/Qeetrix/Qeetrix.docc/Components — ListItem.md, SectionHeader.md,
// DescriptionList.md and CheckList.md — copied verbatim inside views that supply the names they use.
// If the API changes in a way that breaks an example, this file stops compiling, and the page must be
// updated with it. The one difference from the pages: each `List` is given a height, which a list in a
// screen gets from the screen.

private enum Route: Hashable { case account }

private struct Device: Identifiable {
    let id: Int
    let name: String
    let lastSeen: String
}

/// ListItem.md.
private struct ListItemExamples: View {
    @State private var faceID = true
    @State private var showLanguages = false
    let inviteURL = URL(string: "https://id.qeet.in/invite")!

    var body: some View {
        VStack {
            List {
                Section {
                    QeetrixListItem("Priya Sharma", description: Text(verbatim: "priya@acme.in"), value: Route.account) {
                        QeetrixAvatar(name: "Priya Sharma", isDecorative: true)
                    }
                } header: {
                    QeetrixSectionHeader("Accounts", isRuled: false)
                }
                .listSectionSeparator(.hidden)
                Section {
                    QeetrixListItem("Face ID", description: Text("Unlock Qeet Auth with your face"), isOn: $faceID) {
                        QeetrixListItemIcon(.scanLine)
                    }
                    QeetrixListItem("Language", metadata: Text("English"), accessory: .chevron) { showLanguages = true }
                    QeetrixListItem("Sign out", role: .destructive) { signOut() }
                } header: {
                    QeetrixSectionHeader("Security")
                }
                .listSectionSeparator(.hidden)
            }
            .qeetrixListStyle()
            .frame(height: 400)
            ShareLink(item: inviteURL) {
                QeetrixListItem("Invite a teammate") { QeetrixListItemIcon(.userPlus) }
            }
            .buttonStyle(.qeetrixListItem())
        }
    }

    func signOut() {}
}

/// SectionHeader.md.
private struct SectionHeaderExamples: View {
    @State private var faceID = false
    let devices = [Device(id: 1, name: "iPhone 17", lastSeen: "Now"), Device(id: 2, name: "MacBook Pro", lastSeen: "Yesterday")]

    var body: some View {
        VStack {
            List {
                Section {
                    QeetrixListItem("Face ID", isOn: $faceID)
                } header: {
                    QeetrixSectionHeader("Security", isRuled: false)
                }
                .listSectionSeparator(.hidden)
                Section {
                    ForEach(devices) { device in
                        QeetrixListItem(device.name, description: Text(device.lastSeen))
                    }
                } header: {
                    QeetrixSectionHeader("Signed-in devices", description: Text("Where your account is in use.")) {
                        QeetrixButton("Sign out all", variant: .ghost, tone: .danger, size: .sm) { signOutAll() }
                    }
                }
                .listSectionSeparator(.hidden)
            }
            .qeetrixListStyle()
            .frame(height: 400)
            VStack(spacing: 0) {
                QeetrixSectionHeader("Recovery codes", isRuled: false)
                QeetrixListItem("Download codes", accessory: .chevron) { download() }
            }
        }
    }

    func signOutAll() {}
    func download() {}
}

/// DescriptionList.md.
private struct DescriptionListExamples: View {
    var body: some View {
        VStack {
            QeetrixDescriptionList {
                QeetrixDescriptionItem("App", value: "Qeet Pay console")
                QeetrixDescriptionItem("Place", value: "Bengaluru, India")
                QeetrixDescriptionItem("Device", value: "MacBook Pro · Safari")
                QeetrixDescriptionItem("Status") { QeetrixBadge("Pending", tone: .warning) }
                QeetrixDescriptionItem("Phone", value: nil)
            }
            QeetrixDescriptionList(layout: .columns, columns: 3) {
                QeetrixDescriptionItem("Actor", value: "priya@acme.in")
                QeetrixDescriptionItem("Event", value: "Signed in")
                QeetrixDescriptionItem("IP address", value: "203.0.113.24")
            }
            QeetrixDescriptionItem("Display name", value: "Acme", description: Text("Shown in the top bar and in invitations.")) {
                QeetrixButton("Change", variant: .ghost, size: .sm) { editName() }
            }
        }
    }

    func editName() {}
}

/// CheckList.md.
private struct CheckListExamples: View {
    let password = "correct horse"
    let hasNumberOrSymbol = false
    let isReused = false

    var body: some View {
        VStack {
            QeetrixCheckList {
                QeetrixCheckItem("At least 12 characters", status: password.count >= 12 ? .passed : .pending)
                QeetrixCheckItem("A number or a symbol", status: hasNumberOrSymbol ? .passed : .pending)
                QeetrixCheckItem("Not a password you've used before", status: isReused ? .failed : .passed)
            }
            QeetrixCheckList {
                QeetrixCheckItem("The certificate is in date", detail: Text("Until 23 Aug 2030"), status: .passed)
                QeetrixCheckItem("The metadata URL answers", status: .running)
            } footer: {
                Text("Started just now")
                QeetrixButton("Run again", variant: .ghost, size: .sm) { runChecks() }
            }
        }
    }

    func runChecks() {}
}

@MainActor
@Suite("List documentation examples")
struct ListsDocumentationExamplesTests {
    @Test("Every list example compiles against the public API and renders, in both themes")
    func examplesRender() {
        for theme in [QeetrixThemeMode.light, .dark] {
            #expect(ImageRenderer(content: ListItemExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: SectionHeaderExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: DescriptionListExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: CheckListExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
        }
    }
}
