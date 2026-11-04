import Qeetrix
import SwiftUI

struct CheckListPage: View {
    // Demonstration only: the page shows the rules a password meets, never the password.
    @State private var password = ""
    @State private var connection: [QeetrixCheckStatus] = [.pending, .pending, .pending]
    @State private var lastRun: String?

    var body: some View {
        ComponentPage(
            title: "Check list",
            summary: "Rules that tick as they're met, each with its result in words as well as its icon."
        ) {
            DemoSection("A new password's rules") {
                QeetrixPasswordInput("New password", text: $password, autoComplete: .newPassword)
                QeetrixCheckList {
                    QeetrixCheckItem("At least 12 characters", status: password.count >= 12 ? .passed : .pending)
                    QeetrixCheckItem("A number or a symbol", status: password.contains { !$0.isLetter } ? .passed : .pending)
                    QeetrixCheckItem("Not \"password\"", status: password.lowercased().contains("password") ? .failed : .passed)
                }
            }
            DemoSection("A connection test") {
                QeetrixCheckList {
                    QeetrixCheckItem("The certificate is in date", detail: Text("Until 23 Aug 2030"), status: connection[0])
                    QeetrixCheckItem("The metadata URL answers", status: connection[1])
                    QeetrixCheckItem("The signing key matches", detail: Text("Checked against the metadata"), status: connection[2])
                } footer: {
                    Text(lastRun ?? "Not run yet")
                    QeetrixButton("Run checks", variant: .ghost, size: .sm) { run() }
                }
            }
            DemoSection("Every status") {
                QeetrixCheckList {
                    ForEach(QeetrixCheckStatus.allCases, id: \.self) { status in
                        QeetrixCheckItem(status.rawValue.capitalized, status: status)
                    }
                }
            }
        }
    }

    private func run() {
        connection = [.running, .running, .running]
        lastRun = "Running…"
        Task {
            try? await Task.sleep(for: .seconds(1))
            connection = [.passed, .passed, .failed]
            lastRun = "Ran just now"
        }
    }
}

#Preview {
    NavigationStack { CheckListPage() }
}
