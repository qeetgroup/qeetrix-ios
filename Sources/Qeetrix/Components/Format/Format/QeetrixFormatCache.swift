import Foundation

/// The date and relative-time formatters the format functions use, made once per locale, zone and
/// layout — making one is the slow part, as on the web, which caches its `Intl` formatters the same
/// way. Formatters are classes and not `Sendable`, so each is made and used under one lock.
final class QeetrixFormatCache: @unchecked Sendable {
    static let shared = QeetrixFormatCache()

    /// A date formatter's identity: what it writes, for whom, and in which zone.
    struct DateKey: Hashable, Sendable {
        let locale: Locale
        let timeZone: TimeZone
        let layout: Layout
    }

    enum Layout: Hashable, Sendable {
        /// `Intl.DateTimeFormat`'s `dateStyle` and `timeStyle`.
        case styles(QeetrixFormatDateStyle?, QeetrixFormatTimeStyle?)
        /// The all-number date in Latin digits (`day: "2-digit", month: "2-digit", year: "numeric"`).
        case numeric
        /// A skeleton of fields, as `Intl.DateTimeFormat`'s field options are.
        case template(String)
    }

    private let lock = NSLock()
    private var dateFormatters: [DateKey: DateFormatter] = [:]
    private var relativeFormatters: [Locale: RelativeDateTimeFormatter] = [:]

    func string(from date: Date, _ key: DateKey) -> String {
        lock.withLock {
            let formatter = dateFormatters[key] ?? Self.makeFormatter(key)
            dateFormatters[key] = formatter
            return formatter.string(from: date)
        }
    }

    /// `Intl.RelativeTimeFormat(locale, { numeric: "auto" }).format(value, unit)`: "yesterday" rather
    /// than "1 day ago", "now" rather than "in 0 seconds".
    func relative(_ value: Int, _ unit: QeetrixFormatRelativeUnit, locale: Locale) -> String {
        lock.withLock {
            let formatter = relativeFormatters[locale] ?? Self.makeRelativeFormatter(locale)
            relativeFormatters[locale] = formatter
            var components = DateComponents()
            components.setValue(value, for: unit.component)
            return formatter.localizedString(from: components)
        }
    }

    /// The web's dates are Gregorian whatever the locale's calendar (`calendar: "gregory"`).
    static func gregorian(_ locale: Locale, timeZone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        calendar.timeZone = timeZone
        return calendar
    }

    static func makeFormatter(_ key: DateKey) -> DateFormatter {
        let formatter = DateFormatter()
        // Latin digits for the all-number date, so what a field shows can be typed back
        // (`numberingSystem: "latn"`).
        let locale = key.layout == .numeric ? gregorianLocale(key.locale, latinDigits: true) : key.locale
        formatter.locale = locale
        formatter.calendar = gregorian(locale, timeZone: key.timeZone)
        formatter.timeZone = key.timeZone
        switch key.layout {
        case .styles(let date, let time):
            formatter.dateStyle = date?.formatterStyle ?? .none
            formatter.timeStyle = time?.formatterStyle ?? .none
            if date == .medium, time != nil, QeetrixFormatParity.joinsMediumDateAndTimeWithComma(key.locale) {
                let both = formatter.dateFormat ?? ""
                formatter.timeStyle = .none
                let datePattern = formatter.dateFormat ?? ""
                formatter.dateStyle = .none
                formatter.timeStyle = time?.formatterStyle ?? .none
                let timePattern = formatter.dateFormat ?? ""
                formatter.dateFormat = datePattern.isEmpty || timePattern.isEmpty ? both : "\(datePattern), \(timePattern)"
            }
        case .numeric:
            formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ddMMyyyy", options: 0, locale: locale)
        case .template(let template):
            formatter.dateFormat = DateFormatter.dateFormat(
                fromTemplate: template, options: 0, locale: gregorianLocale(key.locale, latinDigits: false))
        }
        QeetrixFormatParity.applySpaces(to: formatter)
        QeetrixFormatParity.applySymbols(to: formatter, locale: key.locale)
        return formatter
    }

    static func makeRelativeFormatter(_ locale: Locale) -> RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = locale
        formatter.calendar = gregorian(locale, timeZone: .gmt)
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .full
        return formatter
    }

    /// The locale with the Gregorian calendar, for patterns made from a skeleton, which otherwise follow
    /// the locale's own calendar (an era in `ar-SA`); with Latin digits when asked.
    static func gregorianLocale(_ locale: Locale, latinDigits: Bool) -> Locale {
        var components = Locale.Components(locale: locale)
        components.calendar = .gregorian
        if latinDigits { components.numberingSystem = Locale.NumberingSystem("latn") }
        return Locale(components: components)
    }
}

/// Where Apple's locale data differs from the CLDR data the web's `Intl` uses, in what Qeetrix's own
/// tests share with `@qeetrix/react`'s — so iOS writes what the web writes for the same locale. Each
/// rule checks Apple's value before replacing it, so it does nothing once Apple's data agrees.
///
/// Elsewhere Qeetrix follows the system's data, as every other app on the device does; the format page
/// in the documentation lists the differences known.
enum QeetrixFormatParity {
    /// Apple's English, French and Polish data join a medium date and its time with a word — "25 Oct
    /// 2026 at 2:30 PM", "à", "o" — where CLDR's medium pattern, and so the web, has a comma: "25 Oct
    /// 2026, 2:30 pm". Both use the word for a long date.
    static func joinsMediumDateAndTimeWithComma(_ locale: Locale) -> Bool {
        switch locale.language.languageCode {
        case .english?, .french?, .polish?: true
        case .hindi?: locale.language.script == .latin
        default: false
        }
    }

    /// Apple's times put a no-break space before the day period — "2:30\u{202F}PM" in English (ICU's
    /// data since CLDR 42), "٢:٣٠\u{A0}م" in Arabic; browsers write a plain space, for compatibility,
    /// and so `@qeetrix/react`'s output does: "2:30 pm".
    static func applySpaces(to formatter: DateFormatter) {
        guard let pattern = formatter.dateFormat, pattern.contains(where: { $0 == "\u{202F}" || $0 == "\u{A0}" }) else { return }
        formatter.dateFormat = pattern.replacingOccurrences(of: "\u{202F}", with: " ").replacingOccurrences(of: "\u{A0}", with: " ")
    }

    /// English (India), the web's default locale: Apple writes "AM"/"PM" and "Sep", CLDR — and so the
    /// web — "am"/"pm" and "Sept".
    static func applySymbols(to formatter: DateFormatter, locale: Locale) {
        guard locale.language.languageCode == .english, locale.region == .india else { return }
        if formatter.amSymbol == "AM" { formatter.amSymbol = "am" }
        if formatter.pmSymbol == "PM" { formatter.pmSymbol = "pm" }
        func september(_ months: [String]) -> [String] {
            months.count == 12 && months[8] == "Sep" ? months.enumerated().map { $0.offset == 8 ? "Sept" : $0.element } : months
        }
        formatter.shortMonthSymbols = september(formatter.shortMonthSymbols)
        formatter.shortStandaloneMonthSymbols = september(formatter.shortStandaloneMonthSymbols)
    }
}
