import Qeetrix
import SwiftUI

struct DataStatePage: View {
    enum Phase: String, CaseIterable, Hashable {
        case loading = "Loading", failed = "Failed", empty = "Empty", content = "Content"
    }

    @State private var phase = Phase.loading
    @State private var retries = 0

    var body: some View {
        ComponentPage(
            title: "Data state",
            summary:
                "The loading, failure and empty branches of one surface, so none is forgotten. The app owns the state; nothing is fetched here."
        ) {
            DemoSection("Branch") {
                QeetrixTabs(selection: $phase, tabs: Phase.allCases.map { QeetrixTab($0.rawValue, value: $0) })
                QeetrixCard {
                    QeetrixDataState(
                        isLoading: phase == .loading, isEmpty: phase == .empty,
                        failure: phase == .failed
                            ? QeetrixDataFailure("Couldn't load members.") {
                                retries += 1
                                phase = .content
                            } : nil
                    ) {
                        VStack(spacing: 0) {
                            ForEach(["Asha Rao", "Ravi Kumar", "Meera Iyer"], id: \.self) { name in
                                QeetrixListItem(name) {
                                } leading: {
                                    QeetrixAvatar(name: name, size: .sm)
                                }
                            }
                        }
                        .accessibilityIdentifier("data-content")
                    } loading: {
                        QeetrixDataLoadingRows(rows: 3)
                    } empty: {
                        QeetrixEmptyState("No members yet", description: Text("Invite people to this workspace."), size: .sm)
                    }
                }
                QeetrixText("Retries: \(retries)", variant: .muted).accessibilityIdentifier("data-retries")
            }
        }
    }
}

#Preview {
    NavigationStack { DataStatePage() }
}
