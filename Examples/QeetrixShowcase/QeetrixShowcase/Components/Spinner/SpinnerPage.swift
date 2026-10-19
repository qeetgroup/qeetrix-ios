import Qeetrix
import SwiftUI

struct SpinnerPage: View {
    var body: some View {
        ComponentPage(
            title: "Spinner",
            summary: "An indeterminate busy indicator. It stands still when Reduce Motion is on."
        ) {
            DemoSection("Sizes") {
                HStack(spacing: QeetrixSpacing.l) {
                    ForEach(QeetrixSpinnerSize.allCases, id: \.self) { size in
                        QeetrixSpinner(size: size, label: Text("Loading, \(size.rawValue)"))
                    }
                }
            }
            DemoSection("Default label") {
                QeetrixSpinner()
            }
        }
    }
}

#Preview {
    NavigationStack { SpinnerPage() }
}
