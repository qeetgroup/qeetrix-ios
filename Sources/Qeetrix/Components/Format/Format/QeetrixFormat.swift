import Foundation

/// Locale-aware formatting with the web's rules, as `@qeetrix/react`'s `format` family: numbers,
/// money, percentages, compact numbers, file sizes, durations, dates and times, and relative time.
///
/// ```swift
/// QeetrixFormat.number(1_234_567, locale: Locale(identifier: "en-IN"))              // "12,34,567"
/// QeetrixFormat.currency(124_500, code: "INR", locale: Locale(identifier: "en-IN"))  // "₹1,24,500.00"
/// QeetrixFormat.date("2026-10-25", locale: Locale(identifier: "en-IN"))              // "25 Oct 2026"
/// QeetrixFormat.relativeTime(posted, now: .now, locale: locale)                      // "2 minutes ago"
/// ```
///
/// Each function writes what `@qeetrix/react` writes for the same value and locale — `formatNumber`,
/// `formatCurrency`, `formatDate`, `formatDateTime` and `formatRelativeTime`, and the sizes
/// `FileUpload` shows — on Foundation's format styles and the system's locale data. In a view, pass
/// the environment's `locale` and `timeZone`, which is what the web's `QeetrixProvider` locale is on
/// iOS; the defaults are the person's own settings.
public enum QeetrixFormat {}

/// Which sign a number shows, as `Intl.NumberFormat`'s `signDisplay`.
public enum QeetrixFormatSign: String, CaseIterable, Sendable {
    /// A minus for negative numbers only, the default: "-3", "0", "5".
    case auto
    /// A sign on every number, zero included: "-3", "+0", "+5".
    case always
    /// A sign on every number but zero, for changes: "-3", "0", "+5".
    case exceptZero
    /// No sign: "3", "0", "5".
    case never

    var strategy: NumberFormatStyleConfiguration.SignDisplayStrategy {
        switch self {
        case .auto: .automatic
        case .always: .always(includingZero: true)
        case .exceptZero: .always(includingZero: false)
        case .never: .never
        }
    }

    var currencyStrategy: CurrencyFormatStyleConfiguration.SignDisplayStrategy {
        switch self {
        case .auto: .automatic
        case .always: .always(showZero: true)
        case .exceptZero: .always(showZero: false)
        case .never: .never
        }
    }
}

/// How much of a duration to write, as `Intl.DurationFormat`'s `style`.
public enum QeetrixFormatDurationStyle: String, CaseIterable, Sendable {
    /// Words: "2 hours, 5 minutes, 30 seconds".
    case long
    /// Abbreviations, the default: "2 hr, 5 min, 30 sec".
    case short
    /// The shortest units: "2h 5m 30s".
    case narrow
    /// A clock: "2:05:30".
    case digital
}

// MARK: - Numbers

extension QeetrixFormat {
    /// Halves round away from zero, as `Intl` rounds ("halfExpand"). Foundation's default rounds them
    /// to even, so 2.5 would be "2" where the web writes "3".
    static let rounding = FloatingPointRoundingRule.toNearestOrAwayFromZero

    /// `Intl.NumberFormat`'s default fraction digits: none to three.
    static let numberFractionDigits = 0...3

    /// A number in the locale's digits and grouping, as `formatNumber`: 1234567 → "12,34,567" in
    /// `en-IN`, "1,234,567" in `en-US`.
    ///
    /// Up to three fraction digits unless `fractionDigits` says otherwise, rounded half away from zero.
    public static func number(
        _ value: Double, fractionDigits: ClosedRange<Int>? = nil, sign: QeetrixFormatSign = .auto, locale: Locale = .current
    ) -> String {
        FloatingPointFormatStyle<Double>(locale: locale)
            .precision(.fractionLength(fractionDigits ?? numberFractionDigits))
            .rounded(rule: rounding)
            .sign(strategy: sign.strategy)
            .format(value)
    }

    /// A whole number in the locale's digits and grouping: 1234567 → "12,34,567" in `en-IN`.
    public static func number(
        _ value: Int, fractionDigits: ClosedRange<Int>? = nil, sign: QeetrixFormatSign = .auto, locale: Locale = .current
    ) -> String {
        IntegerFormatStyle<Int>(locale: locale)
            .precision(.fractionLength(fractionDigits ?? 0...0))
            .sign(strategy: sign.strategy)
            .format(value)
    }

    /// An exact decimal in the locale's digits and grouping, with up to three fraction digits unless
    /// `fractionDigits` says otherwise, rounded half away from zero.
    public static func number(
        _ value: Decimal, fractionDigits: ClosedRange<Int>? = nil, sign: QeetrixFormatSign = .auto, locale: Locale = .current
    ) -> String {
        Decimal.FormatStyle(locale: locale)
            .precision(.fractionLength(fractionDigits ?? numberFractionDigits))
            .rounded(rule: rounding)
            .sign(strategy: sign.strategy)
            .format(value)
    }

    /// A fraction as a percentage, as `formatNumber` with `style: "percent"`: 0.4 → "40%", and "40 %"
    /// in `de-DE`. Whole percentages unless `fractionDigits` says otherwise, rounded half away from
    /// zero, so 0.125 is "13%".
    public static func percent(
        _ fraction: Double, fractionDigits: ClosedRange<Int>? = nil, sign: QeetrixFormatSign = .auto, locale: Locale = .current
    ) -> String {
        FloatingPointFormatStyle<Double>.Percent(locale: locale)
            .precision(.fractionLength(fractionDigits ?? 0...0))
            .rounded(rule: rounding)
            .sign(strategy: sign.strategy)
            .format(fraction)
    }

    /// An amount of money, as `formatCurrency`: `currency(124_500, code: "INR")` → "₹1,24,500.00" in
    /// `en-IN`.
    ///
    /// - Parameters:
    ///   - amount: The amount, exact.
    ///   - code: The ISO 4217 currency code: "INR", "USD".
    ///   - fractionDigits: The fraction digits to show; by default the currency's own (2 for the
    ///     rupee, 0 for the yen). `0...0` drops the paise from whole amounts: "₹1,24,500".
    ///   - sign: Which sign to show.
    ///   - locale: Whose symbol, grouping and digits to use.
    public static func currency(
        _ amount: Decimal, code: String, fractionDigits: ClosedRange<Int>? = nil, sign: QeetrixFormatSign = .auto,
        locale: Locale = .current
    ) -> String {
        var style = Decimal.FormatStyle.Currency(code: code, locale: locale).rounded(rule: rounding).sign(strategy: sign.currencyStrategy)
        if let fractionDigits { style = style.precision(.fractionLength(fractionDigits)) }
        return style.format(amount)
    }

    /// An amount of money given as a `Double`, written as the `Decimal` form writes it.
    public static func currency(
        _ amount: Double, code: String, fractionDigits: ClosedRange<Int>? = nil, sign: QeetrixFormatSign = .auto,
        locale: Locale = .current
    ) -> String {
        var style = FloatingPointFormatStyle<Double>.Currency(code: code, locale: locale).rounded(rule: rounding)
            .sign(strategy: sign.currencyStrategy)
        if let fractionDigits { style = style.precision(.fractionLength(fractionDigits)) }
        return style.format(amount)
    }

    /// A whole amount of money, written as the `Decimal` form writes it: "₹1,24,500.00".
    public static func currency(
        _ amount: Int, code: String, fractionDigits: ClosedRange<Int>? = nil, sign: QeetrixFormatSign = .auto,
        locale: Locale = .current
    ) -> String {
        currency(Decimal(amount), code: code, fractionDigits: fractionDigits, sign: sign, locale: locale)
    }

    /// A number in the locale's short words, as `formatNumber` with `notation: "compact"`: 1234567 →
    /// "12L" in `en-IN` (lakh), "1.2M" in `en-US`; 12345678 → "1.2Cr" (crore). Two significant digits
    /// below a hundred of the unit, rounded half away from zero.
    public static func compactNumber(_ value: Double, locale: Locale = .current) -> String {
        FloatingPointFormatStyle<Double>(locale: locale).notation(.compactName).rounded(rule: rounding).format(value)
    }

    /// A file size in decimal units, as `@qeetrix/react`'s FileUpload writes it: "512 bytes", "12 kB",
    /// "1.5 MB", "2.5 GB".
    ///
    /// Bytes are written in full; larger sizes take the unit's short name, with one decimal below 10 and
    /// none above. Units are powers of 1,000 — as Files and the web show them — up to gigabytes, so 1.5
    /// TB is "1,500 GB". The web picks the unit before rounding, and so does this: 999,999 bytes is
    /// "1,000 kB".
    public static func fileSize<Bytes: BinaryInteger>(_ bytes: Bytes, locale: Locale = .current) -> String {
        let units: [UnitInformationStorage] = [.bytes, .kilobytes, .megabytes, .gigabytes]
        var value = Double(bytes)
        var unit = 0
        while value >= 1000 && unit < units.count - 1 {
            value /= 1000
            unit += 1
        }
        let fractionDigits = unit > 0 && value < 10 ? 1 : 0
        let style = Measurement<UnitInformationStorage>.FormatStyle(
            width: unit == 0 ? .wide : .abbreviated, locale: locale, usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(0...fractionDigits)).rounded(rule: rounding))
        return style.format(Measurement(value: value, unit: units[unit]))
    }

    /// A length of time in the locale's words, as `Intl.DurationFormat` writes it: "2 hr, 5 min" (short),
    /// "2 hours, 5 minutes" (long), "2h 5m" (narrow) or "2:05:00" (digital).
    ///
    /// `@qeetrix/react` has no duration formatter; this follows the platform API the web would use.
    /// Whole seconds, rounded half away from zero; units that are zero are left out, and a zero
    /// duration is "0 sec". Days are the largest unit, except in `digital`, which counts hours.
    public static func duration(_ duration: Duration, style: QeetrixFormatDurationStyle = .short, locale: Locale = .current) -> String {
        let rounded = Duration.seconds(
            (Double(duration.components.seconds) + Double(duration.components.attoseconds) / 1e18).rounded(rounding))
        let width: Duration.UnitsFormatStyle.UnitWidth
        switch style {
        case .long: width = .wide
        case .short: width = .abbreviated
        case .narrow: width = .narrow
        case .digital:
            return Duration.TimeFormatStyle(pattern: .hourMinuteSecond, locale: locale).format(rounded)
        }
        return Duration.UnitsFormatStyle(allowedUnits: [.days, .hours, .minutes, .seconds], width: width).locale(locale).format(rounded)
    }
}
