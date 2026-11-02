import Qeetrix
import SwiftUI

/// The format functions in the device's locale, then side by side in the locales Qeet ships first.
struct FormatPage: View {
    @Environment(\.locale) private var locale
    @Environment(\.timeZone) private var timeZone
    @State private var amount: Decimal = 124_500

    private let moment = Date(timeIntervalSince1970: 1_792_918_800)  // 2026-10-25T09:00:00Z
    private let locales = ["en-IN", "en-US", "hi-IN", "ta-IN", "de-DE", "ar-EG"]

    var body: some View {
        ComponentPage(
            title: "Format",
            summary:
                "Numbers, money, sizes, durations, dates and relative time, written as the web writes them: en-IN groups in lakhs and writes ₹."
        ) {
            DemoSection("Your locale and time zone") {
                sample("Number", QeetrixFormat.number(1_234_567.891, locale: locale))
                sample("Money", QeetrixFormat.currency(amount, code: "INR", locale: locale))
                sample("Whole rupees", QeetrixFormat.currency(amount, code: "INR", fractionDigits: 0...0, locale: locale))
                sample("Percentage", QeetrixFormat.percent(0.125, locale: locale))
                sample("Change", QeetrixFormat.percent(0.042, fractionDigits: 0...1, sign: .exceptZero, locale: locale))
                sample("Compact", QeetrixFormat.compactNumber(12_345_678, locale: locale))
                sample("File size", QeetrixFormat.fileSize(1_500_000, locale: locale))
                sample("Duration", QeetrixFormat.duration(.seconds(7_530), locale: locale))
                sample("Date", QeetrixFormat.date(moment, locale: locale, timeZone: timeZone))
                sample("Date and time", QeetrixFormat.dateTime(moment, locale: locale, timeZone: timeZone))
                sample("All numbers", QeetrixFormat.numericDate(moment, locale: locale, timeZone: timeZone))
                QeetrixButton("Add ₹1,00,000", variant: .ghost, size: .sm) { amount += 100_000 }
            }
            ForEach(locales, id: \.self) { identifier in
                let other = Locale(identifier: identifier)
                DemoSection(identifier) {
                    sample("Number", QeetrixFormat.number(1_234_567, locale: other))
                    sample("Money", QeetrixFormat.currency(124_500, code: "INR", locale: other))
                    sample("Compact", QeetrixFormat.compactNumber(12_345_678, locale: other))
                    sample("Date", QeetrixFormat.date("2026-10-25", style: .long, locale: other))
                    sample("Date and time", QeetrixFormat.dateTime("2026-10-25T09:00:00Z", locale: other, timeZone: Self.kolkata))
                    sample("Relative", QeetrixFormat.relativeTime(moment.addingTimeInterval(-2 * 60), now: moment, locale: other))
                }
                .environment(\.locale, other)
            }
        }
    }

    private static let kolkata = TimeZone(identifier: "Asia/Kolkata")!

    /// A name and its formatted value, side by side when they fit; the value in tabular figures.
    private func sample(_ name: String, _ value: String) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: QeetrixSpace.gapMd) {
                QeetrixText(name, tone: .subtle)
                Spacer(minLength: QeetrixSpace.gapMd)
                QeetrixText(value).monospacedDigit()
            }
            VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                QeetrixText(name, tone: .subtle)
                QeetrixText(value).monospacedDigit()
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack { FormatPage() }
}
