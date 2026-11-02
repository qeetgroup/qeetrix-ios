#if os(iOS)
    import Foundation
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Data state snapshots")
    struct DataStateSnapshotTests {
        @Test("Loading, holding the failure's height; the standard failure with Try again; offline")
        func states() {
            assertSpecimen(
                VStack(spacing: 0) {
                    QeetrixDataState(isLoading: true, onRetry: {}) { Text("Accounts") }
                    QeetrixSeparator()
                    QeetrixDataState(isLoading: false, error: URLError(.badServerResponse), onRetry: {}) { Text("Accounts") }
                    QeetrixSeparator()
                    QeetrixDataState(
                        isLoading: false, error: URLError(.notConnectedToInternet),
                        failure: QeetrixDataStateFailure(
                            title: "You're offline", description: "Connect to the internet to see your accounts.", icon: .wifiOff),
                        onRetry: {}
                    ) { Text("Accounts") }
                }
            )
        }
    }
#endif
