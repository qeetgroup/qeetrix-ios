import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing

// The examples from the screen and navigation pages of Sources/Qeetrix/Qeetrix.docc —
// Components/BottomActionBar.md, FullScreenForm.md, LargeTitle.md, Sidebar.md and SearchField.md — and
// from the doc comments of the symbols they cover, copied verbatim inside views that supply the names
// they use. iOS-only modifiers are guarded so the file also builds on the Mac host.

private struct Invoice {
    let total = "₹1,200"
}

private struct InvoiceSummary: View {
    let invoice: Invoice

    init(_ invoice: Invoice) {
        self.invoice = invoice
    }

    var body: some View {
        Text(invoice.total)
    }
}

private struct Contact: Identifiable, Equatable {
    var id = 1
    var name = ""
    var email = ""
}

private struct Account: Identifiable {
    let id: Int
    let name: String
}

private final class Accounts {
    let all = [Account(id: 1, name: "Asha Rao"), Account(id: 2, name: "Ravi Kumar")]

    func search(_ query: String) {}

    func matching(_ query: String) -> [Account] {
        query.isEmpty ? all : all.filter { $0.name.localizedStandardContains(query) }
    }
}

private enum Destination: Hashable { case accounts, devices, settings, inbox, audit }

private struct Plan {
    let includesAudit = false
}

private struct DestinationView: View {
    let destination: Destination

    init(_ destination: Destination) {
        self.destination = destination
    }

    var body: some View {
        Text(String(describing: destination))
    }
}

/// BottomActionBar.md, and QeetrixScreenAction's doc comment.
private struct BottomActionBarExamples: View {
    let invoice = Invoice()
    let isPaying = false

    var body: some View {
        VStack {
            ScrollView {
                InvoiceSummary(invoice)
            }
            .qeetrixBottomActionBar(
                primary: QeetrixScreenAction("Pay ₹1,200", isLoading: isPaying) { pay() },
                secondary: QeetrixScreenAction("Save for later") { save() })
            Text("Member")
                .qeetrixBottomActionBar(primary: QeetrixScreenAction("Pay ₹1,200", icon: .lock, isLoading: isPaying) { pay() })
                .qeetrixBottomActionBar(primary: QeetrixScreenAction("Remove member", tone: .danger) { remove() })
        }
    }

    func pay() {}
    func save() {}
    func remove() {}
}

/// FullScreenForm.md, and the doc comments of QeetrixFullScreenForm and qeetrixFullScreenForm.
private struct FullScreenFormExamples: View {
    @State private var isAdding = false
    @State private var draft = Contact()
    @State private var editing: Contact?
    let isSaving = false
    let hasChanges = false

    var body: some View {
        VStack {
            Button("New contact") { isAdding = true }
                .qeetrixFullScreenForm(isPresented: $isAdding) {
                    QeetrixFullScreenForm("New contact", confirm: QeetrixScreenAction("Save") { save() }, hasChanges: draft != Contact()) {
                        QeetrixTextField("Name", text: $draft.name)
                        QeetrixTextField("Email", text: $draft.email, prompt: Text("e.g. asha@acme.in"))
                    }
                }
            Text("Contacts")
                .qeetrixFullScreenForm(item: $editing) { contact in
                    QeetrixFullScreenForm(
                        "Edit contact", confirm: QeetrixScreenAction("Save", isLoading: isSaving) { save(contact) }, hasChanges: hasChanges,
                        discardTitle: Text("Discard your edits to \(contact.name)?")
                    ) {
                        QeetrixTextField("Name", text: $draft.name)
                    }
                }
            QeetrixFullScreenForm(
                "Edit contact", confirm: QeetrixScreenAction("Save", isLoading: isSaving) { save() }, hasChanges: hasChanges
            ) {
                QeetrixTextField("Name", text: $draft.name)
                QeetrixTextField("Email", text: $draft.email)
            }
        }
    }

    func save() {}
    func save(_ contact: Contact) {}
}

/// LargeTitle.md, and the doc comment of qeetrixNavigationBar(background:title:).
private struct LargeTitleExamples: View {
    let accounts = [Account(id: 1, name: "Asha Rao")]

    var body: some View {
        VStack {
            NavigationStack {
                List(accounts) { account in
                    Text(account.name)
                }
                .navigationTitle("Accounts")
                #if os(iOS)
                    .navigationBarTitleDisplayMode(.large)
                #endif
                .qeetrixNavigationBar(title: .qeetrix)
            }
            NavigationStack {
                InvoiceList()
                    .navigationTitle("Invoices")
                    .qeetrixNavigationBar(background: .canvas, title: .qeetrix)
            }
        }
    }
}

private struct InvoiceList: View {
    var body: some View {
        Text("Invoices")
    }
}

/// Sidebar.md, and the doc comments of QeetrixNavigationItem, QeetrixSidebar and QeetrixNavigationScaffold.
private struct SidebarExamples: View {
    @State private var destination = Destination.accounts
    let unread = 3
    let plan = Plan()
    let items = [
        QeetrixNavigationItem("Accounts", value: Destination.accounts, icon: .keyRound),
        QeetrixNavigationItem("Settings", value: Destination.settings, icon: .settings),
    ]

    var body: some View {
        VStack {
            QeetrixNavigationScaffold(
                "Qeet Auth", selection: $destination,
                items: [
                    QeetrixNavigationItem("Accounts", value: Destination.accounts, icon: .keyRound),
                    QeetrixNavigationItem("Devices", value: Destination.devices, icon: .smartphone, badge: 2),
                    QeetrixNavigationItem("Settings", value: Destination.settings, icon: .settings),
                ]
            ) { destination in
                NavigationStack {
                    DestinationView(destination)
                }
            }
            NavigationSplitView {
                QeetrixSidebar("Qeet Auth", selection: $destination, items: items)
            } detail: {
                DestinationView(destination)
            }
            NavigationSplitView {
                QeetrixSidebar(
                    "Qeet Auth", selection: $destination,
                    items: [
                        QeetrixNavigationItem("Accounts", value: Destination.accounts, icon: .keyRound),
                        QeetrixNavigationItem("Devices", value: Destination.devices, icon: .smartphone, badge: 2),
                        QeetrixNavigationItem("Settings", value: Destination.settings, icon: .settings),
                    ])
            } detail: {
                DestinationView(destination)
            }
            let more = [
                QeetrixNavigationItem("Inbox", value: Destination.inbox, icon: .inbox, badge: unread),
                QeetrixNavigationItem("Audit log", value: Destination.audit, icon: .fileText, isDisabled: !plan.includesAudit),
            ]
            QeetrixSidebar("More", selection: $destination, items: more)
        }
    }
}

/// SearchField.md, and the doc comments of QeetrixSearchField and qeetrixSearchable.
private struct SearchFieldExamples: View {
    @State private var query = ""
    @State private var results: [Account] = []
    let accounts = Accounts()

    var body: some View {
        VStack {
            QeetrixSearchField(text: $query, prompt: Text("e.g. Asha")) { query in
                accounts.search(query)
            }
            QeetrixSearchField("Find a member", text: $query, description: Text("Name or email."))
            NavigationStack {
                List(results) { account in
                    Text(account.name)
                }
                .navigationTitle("Accounts")
                .qeetrixSearchable(text: $query, prompt: Text("e.g. Asha")) { query in
                    results = accounts.matching(query)
                }
                .qeetrixNavigationBar()
            }
        }
    }
}

@MainActor
@Suite("Screens documentation examples")
struct ScreensDocumentationExamplesTests {
    @Test("Every screen and navigation example compiles against the public API and renders, in both themes")
    func examplesRender() {
        for theme in [QeetrixThemeMode.light, .dark] {
            #expect(ImageRenderer(content: BottomActionBarExamples().frame(width: 390, height: 800).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: FullScreenFormExamples().frame(width: 390, height: 800).qeetrixThemeMode(theme)).cgImage != nil)
            // Navigation stacks, split views and tab bars are hosted by UIKit, which ImageRenderer does not
            // draw; building them is the check.
            _ = LargeTitleExamples().body
            _ = SidebarExamples().body
            _ = SearchFieldExamples().body
        }
    }
}
