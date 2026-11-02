import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing

// The examples from the navigation and overlay pages of Sources/Qeetrix/Qeetrix.docc — Components/Tabs.md,
// NavigationBars.md, AlertDialog.md, ConfirmationDialog.md, Sheet.md, Popover.md, Menu.md, Toast.md,
// Overlays.md and the system-chrome section of Icons.md — copied verbatim inside views that supply the
// names they use.

private enum Section: Hashable { case overview, activity, archive }
private enum AppTab: Hashable { case home, inbox }

private struct Document: Identifiable {
    let id: Int
    let title: String
}

/// Tabs.md and NavigationBars.md.
private struct NavigationExamples: View {
    @State private var section = Section.overview
    @State private var tab = AppTab.home
    let unreadCount = 3

    var body: some View {
        VStack {
            QeetrixTabs(
                selection: $section,
                tabs: [
                    QeetrixTab("Overview", value: Section.overview),
                    QeetrixTab("Activity", value: Section.activity, icon: .bell, badge: 3),
                    QeetrixTab("Archive", value: Section.archive, isDisabled: true),
                ])
            QeetrixTabs(
                selection: $section,
                tabs: [QeetrixTab("Overview", value: Section.overview), QeetrixTab("Activity", value: Section.activity)],
                variant: .contained)
            switch section {
            case .overview: Text("Overview")
            case .activity: Text("Activity")
            case .archive: EmptyView()
            }
            TabView(selection: $tab) {
                NavigationStack {
                    Text("Home")
                        .navigationTitle("Home")
                        .qeetrixNavigationBar()
                }
                .qeetrixTabItem("Home", icon: .house)
                .tag(AppTab.home)

                NavigationStack {
                    Text("Inbox")
                        .navigationTitle("Inbox")
                        .qeetrixNavigationBar(background: .canvas)
                }
                .qeetrixTabItem("Inbox", icon: .inbox, badge: unreadCount)
                .tag(AppTab.inbox)
            }
            .qeetrixTabBar()
            Button {
                share()
            } label: {
                Label {
                    Text("Share")
                } icon: {
                    Image(qeetrix: .share2)
                }
            }
        }
    }

    func share() {}
}

/// AlertDialog.md, ConfirmationDialog.md, Sheet.md, Popover.md and Menu.md.
private struct OverlayExamples: View {
    @State private var alert: QeetrixAlertDialog?
    @State private var share: QeetrixConfirmationDialog?
    @State private var isEditing = false
    @State private var draft = ""
    @State private var showsRoles = false
    @State private var isRevoking = false
    let hasChanges = false

    var body: some View {
        VStack {
            QeetrixButton("Delete workspace", tone: .danger) {
                alert = QeetrixAlertDialog(
                    "Delete this workspace?",
                    message: Text("Its projects and files are removed for everyone."),
                    actions: [QeetrixDialogAction("Delete", role: .destructive) { deleteWorkspace() }])
            }
            .qeetrixAlertDialog($alert)

            QeetrixButton("Share report", variant: .soft) {
                share = QeetrixConfirmationDialog(
                    "Share the Q3 summary",
                    actions: [
                        QeetrixDialogAction("Copy link") { copyLink() },
                        QeetrixDialogAction("Send by email") { sendEmail() },
                    ])
            }
            .qeetrixConfirmationDialog($share)

            QeetrixIconButton(.info, label: "About roles", tone: .neutral) { showsRoles = true }
                .qeetrixPopover(isPresented: $showsRoles, title: Text("Roles"), description: Text("Who can do what.")) {
                    QeetrixText("Admins can invite members and manage billing.")
                }

            QeetrixMenu("Export", icon: .share2) {
                QeetrixMenuItem("Export as CSV", icon: .copy, description: Text("Opens in a spreadsheet")) { export() }
            }

            QeetrixMenu(icon: .ellipsis, label: "Actions for Priya Sharma") {
                QeetrixMenuItem("Edit", icon: .pencil) { rename() }
                QeetrixMenuItem("Share", icon: .share2) { shareItem() }
                Divider()
                QeetrixMenuItem("Remove from Acme", icon: .trash, tone: .danger) { confirmDelete() }
            }
        }
        .qeetrixSheet(isPresented: $isEditing, isDismissDisabled: hasChanges) {
            QeetrixSheetContent("Edit address", description: Text("Used on every invoice."), isDismissible: !hasChanges, onClose: close) {
                QeetrixTextField("Street", text: $draft)
            } actions: {
                QeetrixButton("Cancel", variant: .ghost, size: .lg) { close() }
                QeetrixButton("Save", size: .lg) { save() }
            }
        }
        .qeetrixSheet(isPresented: $isRevoking) {
            QeetrixSheetContent("Revoke this API key?", intent: .danger, isDismissible: false) {
                QeetrixText("Apps using it stop working at once.")
            } actions: {
                QeetrixButton("Cancel", variant: .ghost, size: .lg) { isRevoking = false }
                QeetrixButton("Revoke key", tone: .danger, size: .lg) { revoke() }
            }
        }
    }

    func deleteWorkspace() {}
    func copyLink() {}
    func sendEmail() {}
    func rename() {}
    func shareItem() {}
    func confirmDelete() {}
    func close() {}
    func save() {}
    func export() {}
    func revoke() {}
}

/// Toast.md.
private struct ToastExample: View {
    @State private var toast: QeetrixToast?

    var body: some View {
        Text("Settings")
            .qeetrixToast($toast)
            .onAppear {
                toast = .success("Settings saved")
                toast = QeetrixToast(.info, title: "Conversation archived", action: .init("Undo") { unarchive() })
                toast = QeetrixToast(.danger, title: "Couldn't send the invoice", description: "Check the address and try again.")
            }
    }

    func unarchive() {}
}

/// Overlays.md.
private struct DocumentRow: View {
    let document: Document
    @State private var confirmDelete: QeetrixConfirmationDialog?
    @Binding var toast: QeetrixToast?

    var body: some View {
        HStack {
            Text(document.title)
            Spacer()
            QeetrixMenu(icon: .ellipsis, label: "Actions for \(document.title)") {
                QeetrixMenuItem("Delete", icon: .trash, tone: .danger) {
                    confirmDelete = QeetrixConfirmationDialog(
                        "Delete \(document.title)?",
                        actions: [
                            QeetrixDialogAction("Delete", role: .destructive) { delete() }
                        ])
                }
            }
            .qeetrixConfirmationDialog($confirmDelete)
        }
    }

    private func delete() {
        // Remove the document, then offer to undo.
        toast = QeetrixToast(.info, title: "\(document.title) deleted", action: .init("Undo") { restore() })
    }

    private func restore() {}
}

@MainActor
@Suite("Navigation and overlay documentation examples")
struct OverlayDocumentationExamplesTests {
    @Test("Every navigation and overlay example compiles against the public API and renders, in both themes")
    func examplesRender() {
        for theme in [QeetrixThemeMode.light, .dark] {
            #expect(ImageRenderer(content: OverlayExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: ToastExample().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            let row = DocumentRow(document: Document(id: 1, title: "Q3 summary"), toast: .constant(nil))
            #expect(ImageRenderer(content: row.frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            // A TabView is hosted by UIKit, which ImageRenderer does not draw; building it is the check.
            _ = NavigationExamples().body
        }
    }
}
