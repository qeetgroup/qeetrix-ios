import Qeetrix
import SwiftUI

struct SpinnerPage: View {
    var body: some View {
        ComponentPage(
            title: "Spinner",
            summary: "An indeterminate wait: a 2 pt ring with a quarter gap. Under Reduce Motion it stops turning and pulses instead."
        ) {
            DemoSection("Sizes") {
                HStack(spacing: QeetrixSpace.gapLg) {
                    ForEach(QeetrixSpinnerSize.allCases, id: \.self) { size in
                        QeetrixSpinner(size: size, label: Text("Loading, \(size.rawValue)"))
                    }
                }
                .foregroundStyle(QeetrixColor.iconDefault)
            }
            DemoSection("Tones") {
                HStack(spacing: QeetrixSpace.gapLg) {
                    QeetrixSpinner(size: .lg, label: Text("Loading invoices"))
                        .foregroundStyle(QeetrixColor.iconSubtle)
                    QeetrixSpinner(size: .lg, tone: .brand, label: Text("Loading, brand"))
                }
            }
            DemoSection("Default label") {
                QeetrixSpinner()
                    .foregroundStyle(QeetrixColor.iconDefault)
            }
        }
    }
}

#Preview {
    NavigationStack { SpinnerPage() }
}
