import Qeetrix
import SwiftUI

/// Swipe actions and pull to refresh on a list of rows: Qeet Auth's pending approvals and accounts.
struct SwipeActionsAndRefreshPage: View {
    @State private var isFirstLoad = true
    @State private var approvals = SwipeDemoApproval.samples
    @State private var accounts = SwipeDemoAccount.samples
    @State private var failsNextRefresh = false
    @State private var lastAction = "None yet"
    @State private var toast: QeetrixToast?

    var body: some View {
        // The first load is the data state's spinner; every later one is the pull, with the rows showing.
        QeetrixDataState(isLoading: isFirstLoad) {
            List {
                Section {
                    if approvals.isEmpty {
                        QeetrixListItem("No pending approvals", description: Text("Pull the list down to check for new ones.")) {
                            QeetrixListItemIcon(.inbox)
                        }
                    }
                    ForEach(approvals) { approval in
                        QeetrixListItem(approval.app, description: Text(approval.detail)) {
                            QeetrixListItemIcon(approval.icon)
                        }
                        .qeetrixSwipeActions(
                            leading: [
                                QeetrixSwipeAction("Approve", icon: .check, tone: .brand) { decide(approval, "Approved") }
                            ],
                            trailing: [
                                QeetrixSwipeAction(
                                    "Deny", icon: .x, tone: .danger, confirmation: Text("Deny the sign-in to \(approval.app)?"),
                                    confirmationMessage: Text("Whoever is signing in is stopped.")
                                ) { decide(approval, "Denied") },
                                QeetrixSwipeAction("Later", icon: .clock) { lastAction = "Later: \(approval.app)" },
                            ])
                    }
                } header: {
                    QeetrixSectionHeader(
                        "Pending approvals",
                        description: Text("Swipe right to approve, left to deny or decide later, or touch and hold. Pull down to refresh."),
                        isRuled: false)
                }
                .listSectionSeparator(.hidden)

                Section {
                    ForEach(accounts) { account in
                        QeetrixListItem(account.issuer, description: Text(account.email)) {
                            QeetrixAvatar(name: account.issuer, shape: .square, isDecorative: true)
                        }
                        .qeetrixSwipeActions(actions: [
                            QeetrixSwipeAction(
                                "Remove", icon: .trash, tone: .danger, confirmation: Text("Remove \(account.issuer) from this phone?"),
                                confirmationMessage: Text("You'll need a new QR code to add it again.")
                            ) {
                                accounts.removeAll { $0.id == account.id }
                                lastAction = "Removed: \(account.issuer)"
                            }
                        ])
                    }
                } header: {
                    QeetrixSectionHeader("Accounts")
                }
                .listSectionSeparator(.hidden)

                Section {
                    QeetrixListItem("Fail the next refresh", isOn: $failsNextRefresh) { QeetrixListItemIcon(.wifiOff) }
                    QeetrixListItem("Last action", description: Text(lastAction))
                        .accessibilityIdentifier("swipe-result")
                } header: {
                    QeetrixSectionHeader("Try it")
                }
                .listSectionSeparator(.hidden)
            }
            .qeetrixListStyle()
            .qeetrixRefreshable { await refresh() }
        }
        .background(QeetrixColor.surfaceCanvas)
        .qeetrixToast($toast)
        .navigationTitle("Swipe actions and refresh")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard isFirstLoad else { return }
            try? await Task.sleep(for: .milliseconds(600))
            isFirstLoad = false
        }
    }

    private func decide(_ approval: SwipeDemoApproval, _ decision: String) {
        approvals.removeAll { $0.id == approval.id }
        lastAction = "\(decision): \(approval.app)"
    }

    /// A second's wait, then the samples are back — or, once, the refresh fails, shown in a toast.
    private func refresh() async -> QeetrixRefreshResult {
        try? await Task.sleep(for: .seconds(1))
        if failsNextRefresh {
            failsNextRefresh = false
            lastAction = "Refresh failed"
            toast = .danger("Couldn't refresh your approvals")
            return .failed
        }
        let hadAll = approvals.count == SwipeDemoApproval.samples.count && accounts.count == SwipeDemoAccount.samples.count
        approvals = SwipeDemoApproval.samples
        accounts = SwipeDemoAccount.samples
        lastAction = "Refreshed"
        return hadAll ? .updated : .updated("New requests arrived")
    }
}

/// A sign-in waiting for the person's decision.
private struct SwipeDemoApproval: Identifiable {
    let id: String
    let app: String
    let detail: String
    let icon: QeetrixIconName

    static let samples = [
        SwipeDemoApproval(id: "pay", app: "Qeet Pay console", detail: "Bengaluru · MacBook Pro · Safari", icon: .lock),
        SwipeDemoApproval(id: "people", app: "Qeet People", detail: "Pune · iPhone 17", icon: .smartphone),
        SwipeDemoApproval(id: "logs", app: "Qeet Logs", detail: "Hyderabad · Windows · Edge", icon: .server),
    ]
}

/// An account on this phone.
private struct SwipeDemoAccount: Identifiable {
    let id: String
    let issuer: String
    let email: String

    static let samples = [
        SwipeDemoAccount(id: "acme", issuer: "Acme", email: "priya@acme.in"),
        SwipeDemoAccount(id: "kaveri", issuer: "Kaveri Foods", email: "admin@kaveri.in"),
    ]
}

#Preview {
    NavigationStack { SwipeActionsAndRefreshPage() }
}

#Preview("Large text, dark") {
    NavigationStack { SwipeActionsAndRefreshPage() }
        .environment(\.dynamicTypeSize, .accessibility3)
        .preferredColorScheme(.dark)
}

#Preview("Right to left") {
    NavigationStack { SwipeActionsAndRefreshPage() }
        .environment(\.layoutDirection, .rightToLeft)
}
