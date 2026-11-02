import SwiftUI
import Testing

@testable import Qeetrix

// `@qeetrix/react` 0.4.0's relative-time.test.tsx, ported: the same moments against the same "now",
// in an explicit locale and time zone.

@MainActor
@Suite("Relative time")
struct RelativeTimeTests {
    /// relative-time.test.tsx's `NOW`: 2026-10-25T09:30:00Z.
    let now = Date(timeIntervalSince1970: 1_792_920_600)
    let enIN = Locale(identifier: "en-IN")
    let kolkata = TimeZone(identifier: "Asia/Kolkata")!
    let thirtyDays = Duration.seconds(30 * 86_400)

    func minutes(_ count: Double) -> Date { now.addingTimeInterval(-count * 60) }

    func text(_ date: Date, threshold: Duration? = nil, locale: Locale? = nil) -> String {
        QeetrixRelativeTime.text(date, now: now, threshold: threshold ?? thirtyDays, locale: locale ?? enIN, timeZone: kolkata)
    }

    @Test("The relative text, and the full date and time for its hint and tooltip")
    func relativeText() {
        #expect(text(minutes(2)) == "2 minutes ago")
        #expect(QeetrixFormat.dateTime(minutes(2), dateStyle: .long, locale: enIN, timeZone: kolkata).contains("25 October 2026"))
        #expect(QeetrixFormat.dateTime(minutes(2), dateStyle: .long, locale: enIN, timeZone: kolkata) == "25 October 2026 at 2:58 pm")
    }

    @Test("Yesterday, then the date beyond the threshold; a longer threshold keeps the relative text")
    func threshold() {
        #expect(text(minutes(26 * 60)) == "yesterday")
        #expect(text(minutes(45 * 24 * 60)) == "10 Sept 2026")
        // 40 days: a month and a third, which rounds to last month (45 days, a month and a half,
        // rounds up to 2 months ago, as formatRelativeTime rounds).
        #expect(text(minutes(40 * 24 * 60), threshold: .seconds(60 * 86_400)) == "last month")
        #expect(text(minutes(45 * 24 * 60), threshold: .seconds(60 * 86_400)) == "2 months ago")
    }

    @Test("The threshold is a distance either way, and only beyond it is the date shown")
    func thresholdEdges() {
        #expect(text(minutes(30 * 24 * 60)) == "4 weeks ago")
        #expect(text(minutes(30 * 24 * 60 + 1)) == "25 Sept 2026")
        #expect(text(now.addingTimeInterval(2 * 86_400)) == "in 2 days")
        #expect(text(now.addingTimeInterval(31 * 86_400)) == "25 Nov 2026")
    }

    @Test("It speaks the environment's language")
    func hindi() {
        #expect(text(minutes(5), locale: Locale(identifier: "hi-IN")) == "5 मिनट पहले")
    }

    @Test("It refreshes every 15 s within a minute, every minute within an hour, then every 30 minutes")
    func cadence() {
        #expect(QeetrixRelativeTimeSchedule.cadence(age: 0) == 15)
        #expect(QeetrixRelativeTimeSchedule.cadence(age: 59) == 15)
        #expect(QeetrixRelativeTimeSchedule.cadence(age: 60) == 60)
        #expect(QeetrixRelativeTimeSchedule.cadence(age: 3599) == 60)
        #expect(QeetrixRelativeTimeSchedule.cadence(age: 3600) == 1800)
        // A moment 50 s ago: the first refresh comes within 15 s, and from a minute on, every minute.
        let moment = now.addingTimeInterval(-50)
        let entries = Array(QeetrixRelativeTimeSchedule(date: moment).entries(from: now, mode: .normal).prefix(4))
        #expect(entries.map { $0.timeIntervalSince(now) } == [0, 15, 75, 135])
        #expect(text(moment) == "50 seconds ago")
        #expect(QeetrixFormat.relativeTime(moment, now: entries[1], locale: enIN) == "1 minute ago")
    }

    @Test("A schedule for a moment in the future counts its distance the same way")
    func futureCadence() {
        let moment = now.addingTimeInterval(2 * 3600)
        let entries = Array(QeetrixRelativeTimeSchedule(date: moment).entries(from: now, mode: .normal).prefix(3))
        #expect(entries.map { $0.timeIntervalSince(now) } == [0, 1800, 3600])
    }

    @Test("It renders fixed, live and not live, in each size and tone")
    func renders() {
        #expect(ImageRenderer(content: QeetrixRelativeTime(minutes(2), now: now)).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixRelativeTime(minutes(2))).cgImage != nil)
        #expect(ImageRenderer(content: QeetrixRelativeTime(minutes(2), isLive: false)).cgImage != nil)
        for size in QeetrixTextSize.allCases {
            #expect(ImageRenderer(content: QeetrixRelativeTime(minutes(2), now: now, size: size, tone: .subtle)).cgImage != nil)
        }
    }
}
