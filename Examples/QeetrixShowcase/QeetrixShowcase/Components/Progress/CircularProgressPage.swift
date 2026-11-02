import Qeetrix
import SwiftUI

struct CircularProgressPage: View {
    @State private var uploaded = 0.4
    // A synthetic 30-second code period, restarted from the page: no real secret is involved.
    @State private var period = CircularProgressPage.period(from: .now)

    var body: some View {
        ComponentPage(
            title: "Circular progress",
            summary: "A value as a ring, on the bar's track. A countdown follows the clock; under Reduce Motion it steps once a second."
        ) {
            DemoSection("Sizes") {
                HStack(spacing: QeetrixSpace.gapLg) {
                    ForEach(QeetrixCircularProgressSize.allCases, id: \.self) { size in
                        QeetrixCircularProgress(value: 0.4, size: size, label: Text("Uploading, \(size.rawValue)"))
                    }
                }
            }
            DemoSection("Tones") {
                HStack(spacing: QeetrixSpace.gapLg) {
                    ForEach(QeetrixCircularProgressTone.allCases, id: \.self) { tone in
                        QeetrixCircularProgress(value: tone == .warning ? 0.15 : 0.65, size: .xl, tone: tone, label: Text(tone.rawValue))
                    }
                }
            }
            DemoSection("A one-time code") {
                TimelineView(.periodic(from: period.lowerBound, by: 1)) { context in
                    let secondsLeft = max(0, Int(period.upperBound.timeIntervalSince(context.date).rounded(.up)))
                    HStack(spacing: QeetrixSpace.gapSm) {
                        QeetrixText("482 913", size: .lg, mono: true)
                        QeetrixCircularProgress(
                            timerInterval: period, size: .lg, tone: secondsLeft <= 5 ? .warning : .brand,
                            label: Text("Time left on this code"), currentValueLabel: Text("\(secondsLeft) seconds left"))
                        QeetrixText("\(secondsLeft) s", size: .sm, tone: .subtle)
                            .monospacedDigit()
                            .accessibilityHidden(true)
                    }
                    .onChange(of: secondsLeft == 0) { _, expired in
                        if expired { period = Self.period(from: period.upperBound) }
                    }
                }
                QeetrixButton("Restart", variant: .ghost, size: .sm) { period = Self.period(from: .now) }
            }
            DemoSection("By value") {
                QeetrixCircularProgress(value: uploaded, size: .xl, label: Text("Uploading invoice.pdf"))
                FlowLayout {
                    QeetrixButton("Advance", variant: .ghost, size: .sm) { uploaded = min(1, uploaded + 0.2) }
                    QeetrixButton("Reset", variant: .ghost, tone: .neutral, size: .sm) { uploaded = 0 }
                }
            }
            DemoSection("The style on a native ProgressView") {
                HStack(spacing: QeetrixSpace.gapLg) {
                    ProgressView("Syncing", value: 0.25).progressViewStyle(.qeetrixCircular(size: .xl, tone: .success))
                    ProgressView("Waiting").progressViewStyle(.qeetrixCircular(size: .xl))
                }
            }
        }
    }

    static func period(from start: Date) -> ClosedRange<Date> {
        start...start.addingTimeInterval(30)
    }
}

#Preview {
    NavigationStack { CircularProgressPage() }
}
