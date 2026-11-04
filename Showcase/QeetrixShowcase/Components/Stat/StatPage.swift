import Qeetrix
import SwiftUI

struct StatPage: View {
    @State private var isLoading = true

    var body: some View {
        ComponentPage(
            title: "Stat",
            summary: "Key numbers in a ruled strip: a label, the value in tabular figures, a change up or down and a small trend."
        ) {
            DemoSection("A strip") {
                QeetrixStatGroup {
                    QeetrixStat(
                        "Active users", value: 1_240_512, change: .percent(0.032), note: Text("this week"),
                        trend: [42, 44, 41, 47, 52, 51, 58])
                    QeetrixStat(
                        "Failed payments", value: 42, change: .number(6, isIncreaseGood: false), note: Text("since yesterday"),
                        trend: [30, 34, 33, 36, 42])
                    QeetrixStat("Collected", value: .currency(1_842_600, code: "INR"), note: Text("18 invoices"))
                    QeetrixStat("Disputes", value: 3, note: Text("2 need a reply"), tone: .warning)
                }
                .environment(\.locale, Locale(identifier: "en_IN"))
                .background(QeetrixColor.surfaceRaised)
            }
            DemoSection("Values") {
                QeetrixStat("Latency", value: .text(Text(verbatim: "42 ms")), change: .number(-8, isIncreaseGood: false), note: Text("p95"))
                QeetrixStat("Uptime", value: .percent(0.999, fractionDigits: 1...1), trend: [1, 1, 1])
            }
            DemoSection("Loading") {
                QeetrixStatGroup {
                    QeetrixStat("Revenue", value: .currency(1_842_600, code: "INR"), change: .percent(0.12), isLoading: isLoading)
                    QeetrixStat("Invoices", value: 128, note: Text("this month"), isLoading: isLoading)
                }
                QeetrixSwitch("Loading", isOn: $isLoading)
            }
        }
    }
}

#Preview {
    NavigationStack { StatPage() }
}
