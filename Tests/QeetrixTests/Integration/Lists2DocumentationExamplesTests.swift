import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing

// The examples from Sources/Qeetrix/Qeetrix.docc/Components — SwipeActions.md and PullToRefresh.md —
// copied verbatim inside views that supply the names they use. If the API changes in a way that breaks
// an example, this file stops compiling, and the page must be updated with it. The one difference from
// the pages: each `List` is given a height, which a list in a screen gets from the screen.

private struct Lists2Account: Identifiable {
    let id: Int
    let issuer: String
    let email: String
}

private struct Lists2Request {
    let app: String
    let place: String
}

private struct Lists2Approval: Identifiable {
    let id: Int
    let app: String
    let place: String
}

/// A model whose reload can't fail.
@MainActor
private final class Lists2PlainModel {
    func reload() async {}
}

/// A model whose reload says how many requests arrived, or throws.
@MainActor
private final class Lists2CountingModel {
    func reload() async throws -> Int { 0 }
}

/// A model behind a data state.
@MainActor
private final class Lists2DataModel {
    var approvals: [Lists2Approval] = []
    var isLoading = false
    var loadError: (any Error)?
    func retry() {}
    func reload() async {}
}

/// SwipeActions.md.
private struct SwipeActionsExamples: View {
    let accounts = [Lists2Account(id: 1, issuer: "Acme", email: "priya@acme.in")]
    let request = Lists2Request(app: "Qeet Pay console", place: "Bengaluru")

    var body: some View {
        VStack {
            List(accounts) { account in
                QeetrixListItem(account.issuer, description: Text(account.email)) {
                    QeetrixAvatar(name: account.issuer, shape: .square, isDecorative: true)
                }
                .qeetrixSwipeActions(actions: [
                    QeetrixSwipeAction(
                        "Remove", icon: .trash, tone: .danger, confirmation: Text("Remove \(account.issuer) from this phone?"),
                        confirmationMessage: Text("You'll need a new QR code to add it again.")
                    ) { remove(account) }
                ])
            }
            .qeetrixListStyle()
            .frame(height: 120)
            QeetrixListItem(request.app, description: Text(request.place)) {
                QeetrixListItemIcon(.lock)
            }
            .qeetrixSwipeActions(
                leading: [QeetrixSwipeAction("Approve", icon: .check, tone: .brand) { approve(request) }],
                trailing: [
                    QeetrixSwipeAction("Deny", icon: .x, tone: .danger, confirmation: Text("Deny the sign-in to \(request.app)?")) {
                        deny(request)
                    },
                    QeetrixSwipeAction("Later", icon: .clock) { snooze(request) },
                ]
            )
        }
    }

    func remove(_ account: Lists2Account) {}
    func approve(_ request: Lists2Request) {}
    func deny(_ request: Lists2Request) {}
    func snooze(_ request: Lists2Request) {}
}

/// PullToRefresh.md: the plain form, and the form that can fail.
private struct PullToRefreshExamples: View {
    let approvals = [Lists2Approval(id: 1, app: "Qeet Pay console", place: "Bengaluru")]
    let model = Lists2PlainModel()
    let counting = Lists2CountingModel()
    @State private var toast: QeetrixToast?

    var body: some View {
        VStack {
            List(approvals) { approval in
                QeetrixListItem(approval.app, description: Text(approval.place)) {
                    QeetrixListItemIcon(.lock)
                }
            }
            .qeetrixListStyle()
            .qeetrixRefreshable { await model.reload() }
            .frame(height: 120)
            failing
        }
    }

    /// The second example, whose `model` reloads with a count.
    private var failing: some View {
        let model = counting
        return List(approvals) { approval in
            QeetrixListItem(approval.app, description: Text(approval.place))
        }
        .qeetrixListStyle()
        .qeetrixRefreshable {
            do {
                let added = try await model.reload()
                return added == 0 ? .updated : .updated("\(added) new requests")
            } catch {
                toast = .danger("Couldn't refresh your approvals")
                return .failed
            }
        }
        .qeetrixToast($toast)
        .frame(height: 120)
    }
}

/// PullToRefresh.md: with a data state.
private struct PullToRefreshDataStateExamples: View {
    let model = Lists2DataModel()

    var body: some View {
        QeetrixDataState(
            isLoading: model.approvals.isEmpty && model.isLoading, error: model.loadError, isEmpty: model.approvals.isEmpty,
            onRetry: model.retry
        ) {
            List(model.approvals) { approval in
                QeetrixListItem(approval.app, description: Text(approval.place))
            }
            .qeetrixListStyle()
            .qeetrixRefreshable { await model.reload() }
        } emptyState: {
            QeetrixEmptyState("No pending approvals", description: "Sign-in requests to approve appear here.", icon: .inbox)
        }
    }
}

@MainActor
@Suite("Swipe actions and pull to refresh documentation examples")
struct Lists2DocumentationExamplesTests {
    @Test("Every swipe and refresh example compiles against the public API and renders, in both themes")
    func examplesRender() {
        for theme in [QeetrixThemeMode.light, .dark] {
            #expect(ImageRenderer(content: SwipeActionsExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: PullToRefreshExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: PullToRefreshDataStateExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
        }
    }
}
