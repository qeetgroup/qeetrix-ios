#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Stat snapshots")
    struct StatSnapshotTests {
        /// A ruled strip at a phone's width (one stat to a row), every tone, a change up and down with its
        /// trend, money, text, and loading.
        @Test("A group with changes, trends and tones; text, money and loading")
        func states() {
            assertSpecimen(
                VStack(alignment: .leading, spacing: 24) {
                    QeetrixStatGroup {
                        QeetrixStat(
                            "Active users", value: 1_240_512, change: .percent(0.032), note: Text("this week"),
                            trend: [42, 44, 41, 47, 52, 51, 58])
                        QeetrixStat(
                            "Failed payments", value: 42, change: .number(6, isIncreaseGood: false), note: Text("since yesterday"),
                            trend: [30, 34, 33, 36, 42])
                        QeetrixStat("Collected", value: .currency(1_842_600, code: "INR"), change: .number(0), note: Text("no change"))
                        QeetrixStat("Disputes", value: 3, note: Text("2 need a reply"), tone: .warning)
                    }
                    .environment(\.locale, Locale(identifier: "en_IN"))
                    QeetrixStat(
                        "Latency", value: .text(Text(verbatim: "42 ms")), change: .number(-8, isIncreaseGood: false), note: Text("p95"))
                    QeetrixStat("Uptime", value: .percent(0.999, fractionDigits: 1...1), trend: [1, 1, 1])
                    QeetrixStat("Revenue", value: 0, isLoading: true)
                }
            )
        }
    }
#endif
