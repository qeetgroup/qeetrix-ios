import Foundation
import Qeetrix  // public API only, as a reader of the documentation would write it
import SwiftUI
import Testing

// The examples from the feedback and status pages of Sources/Qeetrix/Qeetrix.docc — Components/Alert.md,
// EmptyState.md, DataState.md, Skeleton.md, Timeline.md and Steps.md — and from their types' doc
// comments, copied verbatim inside views that supply the names they use.

private struct Account: Identifiable {
    let id: String
}

/// A stand-in for the app's icon.
private struct AppIconImage: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 14).fill(.orange).frame(width: 64, height: 64)
    }
}

private struct AccountList: View {
    let accounts: [Account]

    var body: some View {
        ForEach(accounts) { Text($0.id) }
    }
}

private struct ApprovalList: View {
    var body: some View {
        Text("Approvals")
    }
}

private struct AccountsModel {
    var isLoading = false
    var error: (any Error)? = nil
    var accounts: [Account] = []

    func reload() {}
}

/// Alert.md and QeetrixAlert's doc comment.
private struct AlertExamples: View {
    @State private var isOfflineShown = true

    var body: some View {
        VStack {
            QeetrixAlert(
                "Push notifications are off", description: "Turn them on to approve sign-ins from this phone.", tone: .warning
            ) {
                QeetrixButton("Open Settings", size: .sm) { openSettings() }
            }
            QeetrixAlert("You're offline", description: "Approvals arrive when you reconnect.", onDismiss: { isOfflineShown = false })
            QeetrixAlert("This phone isn't linked", description: "Scan the code on qeet.in to link it.", tone: .danger)
            QeetrixAlert("Push notifications are off", description: "Turn them on to approve sign-ins from this phone.", tone: .warning) {
                QeetrixButton("Open Settings", size: .sm) { openSettings() }
            }
        }
    }

    func openSettings() {}
}

/// EmptyState.md, DataState.md and their types' doc comments.
private struct EmptyStateExamples: View {
    let model = AccountsModel()
    let loadError: (any Error)? = URLError(.notConnectedToInternet)
    let isOffline = true

    var body: some View {
        VStack {
            QeetrixEmptyState("No accounts yet", description: "Add an account to sign in with this phone.", icon: .userPlus, level: 2) {
                QeetrixButton("Add account", icon: .plus) { addAccount() }
            } footer: {
                Text("Or scan the code on qeet.in")
            }
            QeetrixEmptyState(
                "No pending approvals", description: "Sign-in requests from your accounts appear here.", icon: .inbox, size: .section)
            QeetrixEmptyState("No accounts yet", description: "Add an account to sign in with this phone.", icon: .userPlus) {
                QeetrixButton("Add account", icon: .plus) { addAccount() }
            }
            QeetrixEmptyState("No pending approvals", description: "Sign-in requests appear here.", icon: .inbox, size: .section)
            // Outcome and lock screens.
            QeetrixEmptyState(title: Text("Qeet ID is locked"), description: Text("Unlock to see your codes."), image: AppIconImage()) {
                QeetrixButton("Unlock", icon: .lockOpen) { unlock() }
            }
            .centredInHeight()
            QeetrixEmptyState("Sign-in approved", description: "You're signed in on your Mac.", icon: .circleCheck, tone: .success)
            QeetrixDataState(isLoading: model.isLoading, error: model.error, isEmpty: model.accounts.isEmpty, onRetry: model.reload) {
                AccountList(accounts: model.accounts)
            } emptyState: {
                QeetrixEmptyState("No accounts yet", description: "Add an account to sign in with this phone.", icon: .userPlus)
            }
            offlineExample
        }
    }

    @ViewBuilder var offlineExample: some View {
        let offline = QeetrixDataStateFailure(
            title: "You're offline", description: "Connect to the internet to see your approvals.", icon: .wifiOff)

        QeetrixDataState(isLoading: false, error: loadError, failure: isOffline ? offline : .standard, onRetry: reload) {
            ApprovalList()
        }
        let _ = QeetrixDataStateFailure(
            title: "You're offline", description: "Connect to the internet to see your accounts.", icon: .wifiOff)
    }

    func addAccount() {}
    func unlock() {}
    func reload() {}
}

/// Skeleton.md and QeetrixSkeleton's doc comment.
private struct SkeletonExamples: View {
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: QeetrixSpace.gapLg) {
                ForEach(0..<3, id: \.self) { _ in
                    HStack(spacing: QeetrixSpace.gapMd) {
                        QeetrixSkeleton(.circle, size: .lg)
                        QeetrixSkeleton(lines: 2)
                    }
                }
            }
            .qeetrixSkeletonGroup(label: Text("Loading accounts"))
            HStack(spacing: QeetrixSpace.gapMd) {
                QeetrixSkeleton(.circle, size: .lg)
                QeetrixSkeleton(lines: 2)
            }
            .qeetrixSkeletonGroup()
        }
    }
}

/// Timeline.md and QeetrixTimeline's doc comment.
private struct TimelineExamples: View {
    var body: some View {
        VStack {
            QeetrixTimeline {
                QeetrixTimelineGroup("Today") {
                    QeetrixTimelineItem(
                        "Signed in with a passkey", description: "Bengaluru · Safari on iPhone", time: Text("2 min ago"), icon: .keyRound)
                    QeetrixTimelineItem(
                        "Sign-in refused", description: "Unknown device", time: Text("1 h ago"), icon: .circleX, tone: .danger)
                }
                QeetrixTimelineGroup("Yesterday") {
                    QeetrixTimelineItem("Phone linked", time: Text("18:02"), icon: .smartphone, tone: .success)
                }
            }
            QeetrixTimeline(variant: .compact) {
                QeetrixTimelineItem("Approved on iPhone", time: Text("2 min ago"), tone: .success)
                QeetrixTimelineItem("Approval requested", time: Text("3 min ago"))
            }
        }
    }
}

/// Steps.md and QeetrixSteps' doc comment.
private struct StepsExamples: View {
    @State private var current = 1
    let setup = [QeetrixStep("Account"), QeetrixStep("Verify phone"), QeetrixStep("Passkey"), QeetrixStep("Done")]

    var body: some View {
        VStack {
            QeetrixSteps([QeetrixStep("Account"), QeetrixStep("Phone"), QeetrixStep("Passkey")], current: 1)
            QeetrixSteps(
                [
                    QeetrixStep("Connect the directory", description: "Okta, over SAML"),
                    QeetrixStep("Map attributes", description: "Email and name"),
                    QeetrixStep("Test a sign-in", status: .failed),
                    QeetrixStep("Go live"),
                ],
                current: 2, orientation: .vertical)
            QeetrixSteps(setup, current: current) { index in current = index }
            QeetrixSteps(
                [QeetrixStep("Account"), QeetrixStep("Verify phone"), QeetrixStep("Passkey"), QeetrixStep("Done")],
                current: 1)
        }
    }
}

@Suite("Feedback documentation examples")
struct FeedbackDocumentationExamplesTests {
    @Test("Every feedback and status example compiles against the public API and renders, in both themes")
    @MainActor
    func examplesRender() {
        for theme in [QeetrixThemeMode.light, .dark] {
            #expect(ImageRenderer(content: AlertExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: EmptyStateExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: SkeletonExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: TimelineExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
            #expect(ImageRenderer(content: StepsExamples().frame(width: 390).qeetrixThemeMode(theme)).cgImage != nil)
        }
    }
}
