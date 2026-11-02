#if os(iOS)
    import Qeetrix
    import SwiftUI
    import Testing

    @MainActor
    @Suite("Relative time snapshots")
    struct RelativeTimeSnapshotTests {
        /// A fixed clock, locale and zone, so the text never depends on when or where the test runs.
        static let now = Date(timeIntervalSince1970: 1_792_920_600)  // 2026-10-25T09:30:00Z

        @Test("Seconds to a date past the threshold, the future, the three sizes, tones and Hindi")
        func variants() {
            let now = Self.now
            assertSpecimen(
                VStack(alignment: .leading, spacing: 12) {
                    QeetrixRelativeTime(now.addingTimeInterval(-20), now: now)
                    QeetrixRelativeTime(now.addingTimeInterval(-2 * 60), now: now)
                    QeetrixRelativeTime(now.addingTimeInterval(-26 * 3600), now: now, size: .lg)
                    QeetrixRelativeTime(now.addingTimeInterval(-45 * 86_400), now: now, size: .sm, tone: .subtle)
                    QeetrixRelativeTime(now.addingTimeInterval(3 * 86_400), now: now, weight: .semibold, tone: .brand)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        QeetrixText("Last signed in", tone: .subtle)
                        QeetrixRelativeTime(now.addingTimeInterval(-59 * 60 - 40), now: now, tone: .subtle)
                    }
                    QeetrixRelativeTime(now.addingTimeInterval(-5 * 60), now: now)
                        .environment(\.locale, Locale(identifier: "hi-IN"))
                }
                .environment(\.locale, Locale(identifier: "en-IN"))
                .environment(\.timeZone, TimeZone(identifier: "Asia/Kolkata")!)
            )
        }
    }
#endif
