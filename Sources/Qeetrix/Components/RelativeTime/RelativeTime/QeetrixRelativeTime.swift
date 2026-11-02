import SwiftUI

/// When something happened, as people say it — `@qeetrix/react`'s RelativeTime: "2 minutes ago",
/// "yesterday", then the date once it's further away than `threshold` ("10 Sept 2026").
///
/// ```swift
/// QeetrixRelativeTime(invoice.sentAt)
/// QeetrixRelativeTime(device.lastSeen, size: .sm, tone: .subtle)
/// ```
///
/// It keeps itself current while it's on screen, as the web's does: every 15 seconds within a minute
/// of the moment, every minute within an hour, then every 30 minutes. The text is
/// ``QeetrixFormat/relativeTime(_:now:locale:)``'s, in the environment's locale, set as ``QeetrixText``
/// sets body text, with tabular figures. VoiceOver reads it, with the full date and time — "25
/// October 2026 at 2:30 pm", in the environment's time zone — as its hint; a pointer shows them as a
/// tooltip, as the web's title does.
public struct QeetrixRelativeTime: View {
    let date: Date
    let threshold: Duration
    let now: Date?
    let isLive: Bool
    let size: QeetrixTextSize
    let weight: QeetrixTextWeight
    let tone: QeetrixTextTone?
    @Environment(\.locale) private var locale
    @Environment(\.timeZone) private var timeZone
    /// The clock of a view that isn't live: the moment it first appeared.
    @State private var appeared = Date()

    /// - Parameters:
    ///   - date: The moment.
    ///   - threshold: Beyond this distance, either way, the date is shown instead. Default 30 days.
    ///   - now: A fixed "now", for previews, tests and screenshots; it also stops the updates.
    ///   - isLive: Whether to keep the text current while it's on screen. Default `true`.
    ///   - size: The body size, as ``QeetrixText``'s.
    ///   - weight: The weight, as ``QeetrixText``'s.
    ///   - tone: The colour, as ``QeetrixText``'s; `nil` keeps the surrounding colour.
    public init(
        _ date: Date, threshold: Duration = .seconds(30 * 86_400), now: Date? = nil, isLive: Bool = true, size: QeetrixTextSize = .md,
        weight: QeetrixTextWeight = .regular, tone: QeetrixTextTone? = nil
    ) {
        self.date = date
        self.threshold = threshold
        self.now = now
        self.isLive = isLive
        self.size = size
        self.weight = weight
        self.tone = tone
    }

    public var body: some View {
        if let now {
            label(at: now)
        } else if isLive {
            TimelineView(QeetrixRelativeTimeSchedule(date: date)) { context in
                label(at: context.date)
            }
        } else {
            label(at: appeared)
        }
    }

    private func label(at now: Date) -> some View {
        let full = QeetrixFormat.dateTime(date, dateStyle: .long, timeStyle: .short, locale: locale, timeZone: timeZone)
        return QeetrixText(
            Text(verbatim: Self.text(date, now: now, threshold: threshold, locale: locale, timeZone: timeZone)), size: size, weight: weight,
            tone: tone
        )
        // relative-time.css: `.qx-relative-time { font-variant-numeric: tabular-nums }`.
        .monospacedDigit()
        .help(Text(verbatim: full))
        .accessibilityHint(Text(verbatim: full))
    }

    /// What it shows at `now`: the relative time, or past the threshold the date with its month
    /// abbreviated (`day: "numeric", month: "short", year: "numeric"`).
    static func text(_ date: Date, now: Date, threshold: Duration, locale: Locale, timeZone: TimeZone) -> String {
        abs(now.timeIntervalSince(date)) > threshold.qeetrixRelativeTimeSeconds
            ? QeetrixFormat.abbreviatedDate(date, locale: locale, timeZone: timeZone)
            : QeetrixFormat.relativeTime(date, now: now, locale: locale)
    }
}

/// The web's refresh cadence, by the age of the moment: every 15 s within a minute, every minute
/// within an hour, then every 30 minutes.
struct QeetrixRelativeTimeSchedule: TimelineSchedule {
    let date: Date

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> Entries {
        Entries(date: date, upcoming: startDate)
    }

    static func cadence(age: TimeInterval) -> TimeInterval {
        age < 60 ? 15 : age < 3600 ? 60 : 1800
    }

    struct Entries: Sequence, IteratorProtocol {
        let date: Date
        var upcoming: Date

        mutating func next() -> Date? {
            let entry = upcoming
            upcoming = entry.addingTimeInterval(QeetrixRelativeTimeSchedule.cadence(age: abs(entry.timeIntervalSince(date))))
            return entry
        }
    }
}

extension Duration {
    /// The duration in seconds, fractions included.
    var qeetrixRelativeTimeSeconds: TimeInterval {
        TimeInterval(components.seconds) + TimeInterval(components.attoseconds) / 1e18
    }
}
