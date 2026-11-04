import Qeetrix
import SwiftUI

struct ProgressPage: View {
    @State private var uploaded = 0.4

    var body: some View {
        ComponentPage(
            title: "Progress",
            summary: "A task advancing, on a 4 pt square track. Without a known total a segment slides; under Reduce Motion it fades."
        ) {
            DemoSection("Determinate") {
                QeetrixProgress("Uploading", value: uploaded, showsValue: true)
                FlowLayout {
                    QeetrixButton("Advance", variant: .ghost, size: .sm) {
                        uploaded = min(1, uploaded + 0.2)
                    }
                    QeetrixButton("Reset", variant: .ghost, tone: .neutral, size: .sm) {
                        uploaded = 0
                    }
                }
            }
            DemoSection("Indeterminate") {
                QeetrixProgress("Preparing export", value: nil)
            }
            DemoSection("How it ended") {
                QeetrixProgress("Import finished", value: 1, tone: .success, showsValue: true)
                QeetrixProgress("Import failed", value: 0.62, tone: .danger, showsValue: true)
            }
            DemoSection("The style on a native ProgressView") {
                ProgressView("Syncing", value: 0.25)
                    .progressViewStyle(.qeetrix(showsValue: true))
            }
        }
    }
}

#Preview {
    NavigationStack { ProgressPage() }
}
