import Qeetrix
import SwiftUI

struct ProgressPage: View {
    @State private var uploaded = 0.4

    var body: some View {
        ComponentPage(
            title: "Progress",
            summary: "Task progress. A bar without a known total sweeps; under Reduce Motion it is a still hatch."
        ) {
            DemoSection("Determinate") {
                QeetrixProgress("Uploading", value: uploaded)
                FlowLayout {
                    QeetrixButton("Advance", variant: .outline, size: .sm) {
                        uploaded = min(1, uploaded + 0.2)
                    }
                    QeetrixButton("Reset", variant: .ghost, size: .sm) {
                        uploaded = 0
                    }
                }
            }
            DemoSection("Indeterminate") {
                QeetrixProgress("Preparing export", value: nil)
            }
            DemoSection("Sizes") {
                ForEach(QeetrixProgressSize.allCases, id: \.self) { size in
                    QeetrixProgress("Size \(size.rawValue)", value: 0.6, size: size, showsValue: false)
                }
            }
            DemoSection("The style on a native ProgressView") {
                ProgressView("Syncing", value: 0.25)
                    .progressViewStyle(.qeetrix(size: .sm))
            }
        }
    }
}

#Preview {
    NavigationStack { ProgressPage() }
}
