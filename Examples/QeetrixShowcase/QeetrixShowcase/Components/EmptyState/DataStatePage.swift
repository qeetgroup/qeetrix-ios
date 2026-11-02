import Qeetrix
import SwiftUI

struct DataStatePage: View {
    enum Phase: String, CaseIterable, Identifiable {
        case loading = "Loading"
        case failed = "Failed"
        case offline = "Offline"
        case empty = "Empty"
        case loaded = "Loaded"

        var id: Self { self }
    }

    struct LoadFailure: Error {}

    @State private var phase = Phase.loading
    @State private var retries = 0

    var body: some View {
        ComponentPage(
            title: "Data state",
            summary: "Loading, then a failure, then empty, then the content, in that order. Loading keeps the failure's height."
        ) {
            DemoSection("State") {
                FlowLayout {
                    ForEach(Phase.allCases) { option in
                        QeetrixButton(option.rawValue, variant: option == phase ? .soft : .ghost, tone: .neutral, size: .sm) {
                            phase = option
                        }
                    }
                }
                QeetrixText("Retries: \(retries)", size: .sm, tone: .subtle).accessibilityIdentifier("data-state-retries")
            }
            DemoSection("Accounts") {
                QeetrixCard(title: Text("Accounts")) {
                    QeetrixDataState(
                        isLoading: phase == .loading, error: phase == .failed || phase == .offline ? LoadFailure() : nil,
                        isEmpty: phase == .empty, failure: phase == .offline ? offline : .standard, onRetry: { retries += 1 }
                    ) {
                        VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) {
                            ForEach(["Priya Sharma · Qeet ID", "Priya Sharma · Qeet Pay"], id: \.self) { account in
                                HStack(spacing: QeetrixSpace.gapMd) {
                                    QeetrixAvatar(name: "Priya Sharma", size: .sm)
                                    QeetrixText(account)
                                }
                            }
                        }
                    } emptyState: {
                        QeetrixEmptyState(
                            "No accounts yet", description: "Add an account to sign in with this phone.", icon: .userPlus, size: .section)
                    }
                }
            }
        }
    }

    var offline: QeetrixDataStateFailure {
        QeetrixDataStateFailure(title: "You're offline", description: "Connect to the internet to see your accounts.", icon: .wifiOff)
    }
}

#Preview {
    NavigationStack { DataStatePage() }
}
