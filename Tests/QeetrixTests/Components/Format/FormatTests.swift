import Foundation
import Testing

@testable import Qeetrix

// `@qeetrix/react` 0.4.0's own format tests (tests/format.server.test.ts, tests/locale.server.test.ts,
// tests/date.server.test.ts and the FileUpload and RelativeTime tests), ported case for case, then the
// options iOS adds. Every call names its locale and time zone: nothing here reads the machine's.

private let enIN = Locale(identifier: "en-IN")
private let enUS = Locale(identifier: "en-US")
private let enGB = Locale(identifier: "en-GB")
private let hiIN = Locale(identifier: "hi-IN")
private let kolkata = TimeZone(identifier: "Asia/Kolkata")!
private let newYork = TimeZone(identifier: "America/New_York")!
private let utc = TimeZone(identifier: "UTC")!

private let second: TimeInterval = 1
private let minute: TimeInterval = 60
private let hour: TimeInterval = 3600
private let day: TimeInterval = 86_400

@Suite("Format: numbers and money")
struct FormatNumberTests {
    @Test("Numbers group the Indian way in en-IN, the Western way in en-US (locale.server.test.ts)")
    func grouping() {
        #expect(QeetrixFormat.number(1_234_567, locale: enIN) == "12,34,567")
        #expect(QeetrixFormat.number(1_234_567, locale: enUS) == "1,234,567")
        #expect(QeetrixFormat.number(123_456, locale: enIN) == "1,23,456")
        #expect(QeetrixFormat.number(12_345_678.9, locale: enIN) == "1,23,45,678.9")
        #expect(QeetrixFormat.number(Decimal(string: "1234567.891")!, locale: enIN) == "12,34,567.891")
    }

    @Test("Money takes the currency's symbol and decimals; whole amounts can drop them (locale.server.test.ts)")
    func currency() {
        #expect(QeetrixFormat.currency(124_500, code: "INR", locale: enIN) == "₹1,24,500.00")
        #expect(QeetrixFormat.currency(124_500, code: "INR", fractionDigits: 0...0, locale: enIN) == "₹1,24,500")
        #expect(QeetrixFormat.currency(Decimal(124_500), code: "INR", locale: enIN) == "₹1,24,500.00")
        #expect(QeetrixFormat.currency(124_500.0, code: "INR", locale: enIN) == "₹1,24,500.00")
        #expect(QeetrixFormat.currency(124_500, code: "INR", locale: enUS) == "₹124,500.00")
        #expect(QeetrixFormat.currency(1234.5, code: "USD", locale: enUS) == "$1,234.50")
        #expect(QeetrixFormat.currency(1234.5, code: "JPY", locale: enUS) == "¥1,235")
        #expect(QeetrixFormat.currency(Decimal(string: "-99.5")!, code: "EUR", locale: Locale(identifier: "de-DE")) == "-99,50\u{A0}€")
    }

    @Test("Like Intl, up to three fraction digits, and halves round away from zero (Foundation rounds them to even)")
    func rounding() {
        #expect(QeetrixFormat.number(1234.5678, locale: enIN) == "1,234.568")
        #expect(QeetrixFormat.number(0.0005, locale: enIN) == "0.001")
        #expect(QeetrixFormat.number(2.5, fractionDigits: 0...0, locale: enIN) == "3")
        #expect(QeetrixFormat.number(-2.5, fractionDigits: 0...0, locale: enIN) == "-3")
        #expect(QeetrixFormat.number(2.345, fractionDigits: 2...2, locale: enIN) == "2.35")
        #expect(QeetrixFormat.number(1.005, fractionDigits: 2...2, locale: enIN) == "1.01")
        #expect(QeetrixFormat.number(5, fractionDigits: 2...2, locale: enIN) == "5.00")
        #expect(QeetrixFormat.currency(Decimal(string: "1234.565")!, code: "INR", locale: enIN) == "₹1,234.57")
        #expect(QeetrixFormat.currency(124_500.5, code: "INR", fractionDigits: 0...0, locale: enIN) == "₹1,24,501")
        #expect(QeetrixFormat.number(-0.0, locale: enIN) == "-0")
        #expect(QeetrixFormat.number(Double.nan, locale: enIN) == "NaN")
        #expect(QeetrixFormat.number(Double.infinity, locale: enIN) == "∞")
    }

    @Test("Percentages are whole unless asked, and round half away from zero: 0.125 is 13%")
    func percent() {
        #expect(QeetrixFormat.percent(0.4, locale: enIN) == "40%")
        #expect(QeetrixFormat.percent(0.125, locale: enIN) == "13%")
        #expect(QeetrixFormat.percent(0.4567, locale: enIN) == "46%")
        #expect(QeetrixFormat.percent(0.12345, fractionDigits: 0...1, locale: enIN) == "12.3%")
        #expect(QeetrixFormat.percent(1.5, locale: enIN) == "150%")
        #expect(QeetrixFormat.percent(0.4, locale: Locale(identifier: "de-DE")) == "40\u{A0}%")
    }

    @Test("Signs, as signDisplay: auto, always, exceptZero and never")
    func signs() {
        #expect([5, 0, -3].map { QeetrixFormat.number($0, sign: .exceptZero, locale: enIN) } == ["+5", "0", "-3"])
        #expect([5, 0, -3].map { QeetrixFormat.number($0, sign: .always, locale: enIN) } == ["+5", "+0", "-3"])
        #expect([5, 0, -3].map { QeetrixFormat.number($0, sign: .never, locale: enIN) } == ["5", "0", "3"])
        #expect([5, 0, -3].map { QeetrixFormat.number($0, sign: .auto, locale: enIN) } == ["5", "0", "-3"])
        #expect([0.12, 0, -0.03].map { QeetrixFormat.percent($0, sign: .exceptZero, locale: enIN) } == ["+12%", "0%", "-3%"])
        #expect(
            [12, 0, -3].map { QeetrixFormat.currency($0, code: "INR", sign: .exceptZero, locale: enIN) } == ["+₹12.00", "₹0.00", "-₹3.00"])
    }

    @Test("Compact numbers speak lakh and crore in India, two significant digits")
    func compact() {
        #expect(QeetrixFormat.compactNumber(1_234_567, locale: enIN) == "12L")
        #expect(QeetrixFormat.compactNumber(12_345_678, locale: enIN) == "1.2Cr")
        #expect(QeetrixFormat.compactNumber(1_250, locale: enIN) == "1.3K")
        #expect(QeetrixFormat.compactNumber(999, locale: enIN) == "999")
        #expect(QeetrixFormat.compactNumber(1_234_567, locale: enUS) == "1.2M")
        #expect(QeetrixFormat.compactNumber(1_234_567, locale: hiIN) == "12\u{A0}लाख")
    }
}

@Suite("Format: file sizes")
struct FormatFileSizeTests {
    @Test("Sizes in the locale's words, decimal units, bytes in full (file-upload.test.tsx)")
    func sizes() {
        #expect(QeetrixFormat.fileSize(512, locale: enIN) == "512 bytes")
        #expect(QeetrixFormat.fileSize(1_500_000, locale: enIN) == "1.5 MB")
        #expect(QeetrixFormat.fileSize(1_000_000, locale: enIN) == "1 MB")
        #expect(QeetrixFormat.fileSize(12_000, locale: enIN) == "12 kB")
        #expect(QeetrixFormat.fileSize(1, locale: enIN) == "1 byte")
        #expect(QeetrixFormat.fileSize(0, locale: enIN) == "0 bytes")
        #expect(QeetrixFormat.fileSize(2_500_000_000, locale: enIN) == "2.5 GB")
        #expect(QeetrixFormat.fileSize(Int64(1_500), locale: Locale(identifier: "de-DE")) == "1,5 kB")
        #expect(QeetrixFormat.fileSize(UInt(1_500_000), locale: Locale(identifier: "fr-FR")) == "1,5\u{202F}Mo")
    }

    @Test("One decimal below 10, none above; gigabytes at most; the unit chosen before rounding, as the web does")
    func units() {
        #expect(QeetrixFormat.fileSize(9_949, locale: enIN) == "9.9 kB")
        #expect(QeetrixFormat.fileSize(9_950, locale: enIN) == "10 kB")
        #expect(QeetrixFormat.fileSize(1_500_000_000_000, locale: enIN) == "1,500 GB")
        // The web's FileUpload writes 999,999 bytes as "1,000 kB", not "1 MB": iOS matches it.
        #expect(QeetrixFormat.fileSize(999_999, locale: enIN) == "1,000 kB")
    }
}

@Suite("Format: durations")
struct FormatDurationTests {
    let length = Duration.seconds(2 * 3600 + 5 * 60 + 30)

    @Test("Four styles, as Intl.DurationFormat writes them in en-US")
    func styles() {
        #expect(QeetrixFormat.duration(length, style: .long, locale: enUS) == "2 hours, 5 minutes, 30 seconds")
        #expect(QeetrixFormat.duration(length, locale: enUS) == "2 hr, 5 min, 30 sec")
        #expect(QeetrixFormat.duration(length, style: .narrow, locale: enUS) == "2h 5m 30s")
        #expect(QeetrixFormat.duration(length, style: .digital, locale: enUS) == "2:05:30")
        #expect(QeetrixFormat.duration(.seconds(330), style: .digital, locale: enUS) == "0:05:30")
        #expect(QeetrixFormat.duration(.seconds(45), style: .long, locale: enUS) == "45 seconds")
        #expect(QeetrixFormat.duration(.seconds(3600), style: .long, locale: enUS) == "1 hour")
    }

    @Test("Zero units are left out, whole seconds round half away from zero, and nothing is still a duration")
    func units() {
        #expect(QeetrixFormat.duration(.seconds(5 * 60), style: .long, locale: enUS) == "5 minutes")
        #expect(QeetrixFormat.duration(.milliseconds(29_500), style: .narrow, locale: enUS) == "30s")
        #expect(QeetrixFormat.duration(.milliseconds(29_400), style: .narrow, locale: enUS) == "29s")
        #expect(QeetrixFormat.duration(.zero, style: .long, locale: enUS) == "0 seconds")
        #expect(QeetrixFormat.duration(.seconds(26 * 3600 + 180), style: .digital, locale: enUS) == "26:03:00")
        #expect(QeetrixFormat.duration(.seconds(26 * 3600 + 180), style: .long, locale: enUS) == "1 day, 2 hours, 3 minutes")
    }

    @Test("In the locale's words and digits")
    func locales() {
        #expect(QeetrixFormat.duration(length, style: .long, locale: hiIN) == "2 घंटे, 5 मिनट और 30 सेकंड")
        #expect(QeetrixFormat.duration(length, style: .digital, locale: Locale(identifier: "ar-EG")) == "٢:٠٥:٣٠")
        #expect(QeetrixFormat.duration(length, style: .long, locale: Locale(identifier: "de-DE")) == "2 Stunden, 5 Minuten und 30 Sekunden")
    }
}

@Suite("Format: relative time")
struct FormatRelativeTimeTests {
    /// format.server.test.ts's `now`: 2026-10-25T12:00:00Z.
    let now = Date(timeIntervalSince1970: 1_792_929_600)

    func ago(_ seconds: TimeInterval) -> String {
        QeetrixFormat.relativeTime(now.addingTimeInterval(-seconds), now: now, locale: enIN)
    }

    func ahead(_ seconds: TimeInterval) -> String {
        QeetrixFormat.relativeTime(now.addingTimeInterval(seconds), now: now, locale: enIN)
    }

    @Test("It promotes a value that rounds up to the next unit")
    func promotes() {
        // On the web this was a regression: the unit was chosen before rounding, so these were "60
        // minutes ago" and "12 months ago".
        #expect(ago(59 * minute + 40 * second) == "1 hour ago")
        #expect(ago(364 * day) == "last year")
        #expect(ago(59.6 * second) == "1 minute ago")
        #expect(ago(23 * hour + 40 * minute) == "yesterday")
        #expect(ago(6.6 * day) == "last week")
    }

    @Test("It keeps a value that doesn't reach the next unit in its own")
    func keeps() {
        #expect(ago(59.4 * second) == "59 seconds ago")
        #expect(ago(31 * minute) == "31 minutes ago")
        #expect(ago(59 * minute + 20 * second) == "59 minutes ago")
        #expect(ago(23 * hour) == "23 hours ago")
        #expect(ago(6 * day) == "6 days ago")
        // Four weeks are 28 days, not yet a month (30); five are.
        #expect(ago(31 * day) == "4 weeks ago")
        #expect(ago(32 * day) == "last month")
        #expect(ago(334 * day) == "11 months ago")
        #expect(ago(2 * 365 * day) == "2 years ago")
    }

    @Test("It rounds the future like the past; halves round away from now both ways")
    func future() {
        #expect(ahead(59 * minute + 40 * second) == "in 1 hour")
        #expect(ahead(364 * day) == "next year")
        #expect(ago(1.5 * hour) == "2 hours ago")
        #expect(ahead(1.5 * hour) == "in 2 hours")
    }

    @Test("Less than half a second either way is now; it speaks Hindi")
    func nowAndHindi() {
        #expect(ago(0.4) == "now")
        #expect(ahead(0.4) == "now")
        // ICU's Hindi takes the oblique form ("1 घंटे पहले"); older data had "घंटा".
        let hindi = QeetrixFormat.relativeTime(now.addingTimeInterval(-(59 * minute + 40 * second)), now: now, locale: hiIN)
        #expect(["1 घंटे पहले", "1 घंटा पहले"].contains(hindi), "\(hindi)")
    }

    @Test("Minutes, yesterday and days ahead, in English and Hindi (locale.server.test.ts)")
    func words() {
        #expect(ago(2 * minute) == "2 minutes ago")
        #expect(ago(day) == "yesterday")
        #expect(ahead(3 * day) == "in 3 days")
        #expect(QeetrixFormat.relativeTime(now.addingTimeInterval(-2 * minute), now: now, locale: hiIN) == "2 मिनट पहले")
    }

    @Test("Each unit holds until the next: 60 s, 60 min, 24 h, 7 days, 30 days, 12 months")
    func units() {
        #expect(QeetrixFormatRelativeUnit.allCases.map(\.seconds) == [1, 60, 3600, 86_400, 604_800, 2_592_000, 31_536_000])
        #expect(QeetrixFormatRelativeUnit.allCases.map(\.next) == [60, 60, 24, 7, 30.0 / 7, 12, .infinity])
    }
}

@Suite("Format: dates and times")
struct FormatDateTests {
    @Test("A calendar date in India's style, in three lengths, and the US's")
    func styles() {
        #expect(QeetrixFormat.date("2026-10-25", locale: enIN) == "25 Oct 2026")
        #expect(QeetrixFormat.date("2026-10-25", style: .short, locale: enIN) == "25/10/26")
        #expect(QeetrixFormat.date("2026-10-25", style: .long, locale: enIN) == "25 October 2026")
        #expect(QeetrixFormat.date("2026-10-25", locale: enUS) == "Oct 25, 2026")
        #expect(QeetrixFormat.date(DateComponents(year: 2026, month: 10, day: 25), locale: enIN) == "25 Oct 2026")
        // CLDR's English (India) abbreviates September "Sept"; Apple's data says "Sep".
        #expect(QeetrixFormat.date("2026-09-10", locale: enIN) == "10 Sept 2026")
    }

    @Test("It speaks Hindi")
    func hindi() {
        let medium = QeetrixFormat.date("2026-10-25", locale: hiIN)
        let long = QeetrixFormat.date("2026-10-25", style: .long, locale: hiIN)
        // The web's test takes either spelling of October, "अक्टू॰" (CLDR's) or "अक्तू॰" (Apple's).
        #expect(["25 अक्टू॰ 2026", "25 अक्तू॰ 2026"].contains(medium), "\(medium)")
        #expect(["25 अक्टूबर 2026", "25 अक्तूबर 2026"].contains(long), "\(long)")
    }

    @Test("A calendar date never moves to another day, whatever the time zone")
    func calendarDatesStayPut() {
        for zone in ["Pacific/Kiritimati", "Pacific/Pago_Pago", "UTC"] {
            #expect(QeetrixFormat.date("2026-01-01", locale: enIN, timeZone: TimeZone(identifier: zone)!) == "1 Jan 2026", "\(zone)")
        }
    }

    @Test("A moment's date is in the zone given: 20:00 UTC on the 25th is 01:30 on the 26th in India")
    func moments() {
        let evening = Date(timeIntervalSince1970: 1_792_958_400)  // 2026-10-25T20:00:00Z
        #expect(QeetrixFormat.date(evening, locale: enIN, timeZone: kolkata) == "26 Oct 2026")
        #expect(QeetrixFormat.date(evening, locale: enIN, timeZone: utc) == "25 Oct 2026")
        #expect(QeetrixFormat.date("2026-10-25T20:00:00Z", locale: enIN, timeZone: kolkata) == "26 Oct 2026")
        #expect(QeetrixFormat.date("2026-10-25T20:00:00-05:00", locale: enIN, timeZone: kolkata) == "26 Oct 2026")
    }

    @Test("Always Gregorian, even where the locale's own calendar differs")
    func gregorian() {
        let thai = QeetrixFormat.date("2026-10-25", style: .long, locale: Locale(identifier: "th-TH"))
        #expect(thai.contains("2026") && !thai.contains("2569"), "\(thai)")
        let japanese = QeetrixFormat.date("2026-10-25", style: .long, locale: Locale(identifier: "ja-JP@calendar=japanese"))
        #expect(japanese.contains("2026") && !japanese.contains("令和"), "\(japanese)")
    }

    @Test("Anything that isn't a date is an empty string")
    func invalid() {
        for value in ["", "25/10/2026", "2026-02-31", "2026-10-25T25:00", "soon", "२०२६-१०-२५"] {
            #expect(QeetrixFormat.date(value, locale: enIN, timeZone: kolkata) == "", "\(value)")
        }
        #expect(QeetrixFormat.date(DateComponents(year: 2026, month: 2, day: 31), locale: enIN) == "")
        #expect(QeetrixFormat.date(DateComponents(year: 2026, month: 13, day: 1), locale: enIN) == "")
        #expect(QeetrixFormat.date(DateComponents(month: 10, day: 25), locale: enIN) == "")
    }

    let moment = "2026-10-25T09:00:00Z"

    @Test("A moment with a short time, in the zone given")
    func dateTime() {
        #expect(QeetrixFormat.dateTime(moment, locale: enIN, timeZone: kolkata) == "25 Oct 2026, 2:30 pm")
        #expect(
            QeetrixFormat.dateTime(Date(timeIntervalSince1970: 1_792_918_800), locale: enIN, timeZone: kolkata) == "25 Oct 2026, 2:30 pm")
        #expect(QeetrixFormat.dateTime(moment, locale: enIN, timeZone: utc) == "25 Oct 2026, 9:00 am")
        #expect(
            QeetrixFormat.dateTime(moment, dateStyle: .short, timeStyle: .medium, locale: enIN, timeZone: kolkata) == "25/10/26, 2:30:00 pm"
        )
        #expect(QeetrixFormat.dateTime(moment, dateStyle: .long, locale: enIN, timeZone: kolkata) == "25 October 2026 at 2:30 pm")
        #expect(QeetrixFormat.dateTime(moment, locale: enUS, timeZone: kolkata) == "Oct 25, 2026, 2:30 PM")
        #expect(QeetrixFormat.dateTime(moment, locale: enGB, timeZone: kolkata) == "25 Oct 2026, 14:30")
    }

    @Test("Offsets with or without a colon, and fractions of a second")
    func offsets() {
        #expect(QeetrixFormat.dateTime("2026-10-25T14:30:00+05:30", locale: enIN, timeZone: kolkata) == "25 Oct 2026, 2:30 pm")
        #expect(QeetrixFormat.dateTime("2026-10-25T14:30:00+0530", locale: enIN, timeZone: kolkata) == "25 Oct 2026, 2:30 pm")
        #expect(QeetrixFormat.dateTime("2026-10-25T09:00:00.123456Z", locale: enIN, timeZone: kolkata) == "25 Oct 2026, 2:30 pm")
        #expect(QeetrixFormat.dateTime("2026-10-25t09:00:00z", locale: enIN, timeZone: kolkata) == "25 Oct 2026, 2:30 pm")
        #expect(QeetrixFormat.dateTime(" 2026-10-25T09:00Z ", locale: enIN, timeZone: kolkata) == "25 Oct 2026, 2:30 pm")
    }

    @Test("A date-time without an offset shows as written; a calendar date without a time")
    func plainDateTimes() {
        #expect(QeetrixFormat.dateTime("2026-10-25T14:30", locale: enIN, timeZone: newYork) == "25 Oct 2026, 2:30 pm")
        #expect(QeetrixFormat.dateTime("2026-10-25", locale: enIN, timeZone: kolkata) == "25 Oct 2026")
        #expect(
            QeetrixFormat.dateTime(DateComponents(year: 2026, month: 10, day: 25, hour: 14, minute: 30), locale: enIN)
                == "25 Oct 2026, 2:30 pm")
        #expect(QeetrixFormat.dateTime(DateComponents(year: 2026, month: 10, day: 25), locale: enIN) == "25 Oct 2026")
    }

    @Test("It speaks Hindi")
    func dateTimeHindi() {
        let text = QeetrixFormat.dateTime(moment, locale: hiIN, timeZone: kolkata)
        // The web's test reads /^25 अक्[टत]ू॰ 2026, .*2:30/: either October, and the time after a comma.
        #expect(["25 अक्टू॰ 2026, ", "25 अक्तू॰ 2026, "].contains { text.hasPrefix($0) } && text.contains("2:30"), "\(text)")
    }

    @Test("Anything that isn't a date and time is an empty string")
    func invalidDateTimes() {
        #expect(QeetrixFormat.dateTime("2026-10-25T14:60", locale: enIN, timeZone: kolkata) == "")
        #expect(QeetrixFormat.dateTime("2026-10-25T14:30+25:00", locale: enIN, timeZone: kolkata) == "")
        #expect(QeetrixFormat.dateTime("2026-10-25T14:30:60Z", locale: enIN, timeZone: kolkata) == "")
        #expect(QeetrixFormat.dateTime(DateComponents(year: 2026, month: 10, day: 25, hour: 24), locale: enIN) == "")
    }

    @Test("A time alone: short and with seconds, 12- or 24-hour by locale, with a plain space before am or pm")
    func time() {
        let moment = Date(timeIntervalSince1970: 1_792_918_845)  // 2026-10-25T09:00:45Z
        #expect(QeetrixFormat.time(moment, locale: enIN, timeZone: kolkata) == "2:30 pm")
        #expect(QeetrixFormat.time(moment, style: .medium, locale: enIN, timeZone: kolkata) == "2:30:45 pm")
        #expect(QeetrixFormat.time(moment, locale: enUS, timeZone: kolkata) == "2:30 PM")
        #expect(QeetrixFormat.time(moment, locale: enGB, timeZone: kolkata) == "14:30")
        #expect(!QeetrixFormat.time(moment, locale: enUS, timeZone: kolkata).contains("\u{202F}"))
    }
}

@Suite("Format: all-number dates and ranges")
struct FormatNumericDateTests {
    @Test("Each locale's order, in its numbers (date.server.test.ts)")
    func order() {
        #expect(QeetrixFormat.numericDate(DateComponents(year: 2026, month: 10, day: 25), locale: enIN) == "25/10/2026")
        #expect(QeetrixFormat.numericDate(DateComponents(year: 2026, month: 10, day: 25), locale: enUS) == "10/25/2026")
        #expect(QeetrixFormat.numericDate(DateComponents(year: 2026, month: 2, day: 31), locale: enIN) == "")
        #expect(QeetrixFormat.numericDate(DateComponents(year: 2026, month: 10, day: 25, hour: 23), locale: enIN) == "25/10/2026")
        #expect(QeetrixFormat.numericDate(Date(timeIntervalSince1970: 1_792_958_400), locale: enIN, timeZone: kolkata) == "26/10/2026")
    }

    @Test("Gregorian, with Latin digits, so every locale's dates can be typed back")
    func latin() {
        let date = DateComponents(year: 2026, month: 10, day: 25)
        #expect(QeetrixFormat.numericDate(date, locale: Locale(identifier: "th-TH")) == "25/10/2026")
        #expect(QeetrixFormat.numericDate(date, locale: Locale(identifier: "fa")) == "2026/10/25")
        let arabic = QeetrixFormat.numericDate(date, locale: Locale(identifier: "ar-EG"))
        #expect(arabic.wholeMatch(of: #/25[^0-9]+10[^0-9]+2026/#) != nil, "\(arabic)")
        #expect(QeetrixFormat.numericDate(date, locale: Locale(identifier: "ar-SA")) == "25\u{200F}/10\u{200F}/2026")
    }

    @Test("Ranges join two all-number dates with an en dash")
    func ranges() {
        let december = (DateComponents(year: 2026, month: 12, day: 1), DateComponents(year: 2026, month: 12, day: 31))
        #expect(QeetrixFormat.dateRange(from: december.0, to: december.1, locale: enIN) == "01/12/2026 – 31/12/2026")
        #expect(QeetrixFormat.dateRange(from: december.0, to: DateComponents(year: 2026, month: 2, day: 31), locale: enIN) == "")
        let start = Date(timeIntervalSince1970: 1_796_083_200)  // 2026-12-01T00:00:00Z
        let end = Date(timeIntervalSince1970: 1_798_675_200)  // 2026-12-31T00:00:00Z
        #expect(QeetrixFormat.dateRange(start...end, locale: enUS, timeZone: utc) == "12/01/2026 – 12/31/2026")
    }
}

@Suite("Format: reading ISO 8601")
struct FormatMomentTests {
    @Test("A date is a calendar date, a date-time with a zone a moment, one without a wall time")
    func kinds() {
        #expect(QeetrixFormatMoment(iso8601: "2026-10-25") == .plainDate(Date(timeIntervalSince1970: 1_792_886_400)))
        #expect(QeetrixFormatMoment(iso8601: "2026-10-25T14:30") == .plainDateTime(Date(timeIntervalSince1970: 1_792_938_600)))
        #expect(QeetrixFormatMoment(iso8601: "2026-10-25T14:30:00+05:30") == .instant(Date(timeIntervalSince1970: 1_792_918_800)))
        // Milliseconds, as the web keeps them: the fraction's first three digits.
        guard case .instant(let fraction) = QeetrixFormatMoment(iso8601: "2026-10-25T09:00:00.1239Z") else {
            Issue.record("not a moment")
            return
        }
        #expect(abs(fraction.timeIntervalSince1970 - 1_792_918_800.123) < 1e-6)
    }

    @Test("ASCII digits only, as JavaScript's \\d; impossible dates, times and offsets are nothing")
    func strict() {
        for value in [
            "2026-10-٢٥", "2026-1-25", "2026-10-25T9:00", "2026-10-25 09:00", "2026-10-25T09:00+5:30", "2028-02-30", "2027-02-29",
        ] {
            #expect(QeetrixFormatMoment(iso8601: value) == nil, "\(value)")
        }
        #expect(QeetrixFormatMoment(iso8601: "2028-02-29") != nil)
    }
}

@Suite("Format: Apple's locale data where it differs from the web's")
struct FormatParityRuleTests {
    @Test("English, French and Polish join a medium date and its time with a comma, as CLDR does")
    func mediumJoin() {
        #expect(QeetrixFormatParity.joinsMediumDateAndTimeWithComma(enIN))
        #expect(QeetrixFormatParity.joinsMediumDateAndTimeWithComma(Locale(identifier: "fr-FR")))
        #expect(QeetrixFormatParity.joinsMediumDateAndTimeWithComma(Locale(identifier: "pl-PL")))
        #expect(QeetrixFormatParity.joinsMediumDateAndTimeWithComma(Locale(identifier: "hi-Latn-IN")))
        #expect(!QeetrixFormatParity.joinsMediumDateAndTimeWithComma(hiIN))
        #expect(!QeetrixFormatParity.joinsMediumDateAndTimeWithComma(Locale(identifier: "de-DE")))
        let moment = "2026-10-25T09:00:00Z"
        #expect(QeetrixFormat.dateTime(moment, locale: Locale(identifier: "fr-FR"), timeZone: kolkata) == "25 oct. 2026, 14:30")
        #expect(QeetrixFormat.dateTime(moment, locale: Locale(identifier: "pl-PL"), timeZone: kolkata) == "25 paź 2026, 14:30")
    }

    @Test("English (India) takes CLDR's am, pm and Sept; other English locales keep Apple's")
    func indianEnglish() {
        let moment = Date(timeIntervalSince1970: 1_789_020_000)  // 2026-09-10T06:00:00Z
        #expect(QeetrixFormat.dateTime(moment, locale: enIN, timeZone: kolkata) == "10 Sept 2026, 11:30 am")
        #expect(QeetrixFormat.dateTime(moment, locale: enUS, timeZone: kolkata) == "Sep 10, 2026, 11:30 AM")
        #expect(QeetrixFormat.date(moment, locale: enGB, timeZone: kolkata) == "10 Sep 2026")
    }
}
