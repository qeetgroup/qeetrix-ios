import Foundation

/// Reads and writes numbers the way a person types them in their locale, with `Decimal` throughout, so a
/// value like 0.1 is exact.
///
/// Foundation formats the value and supplies the locale's decimal separator, grouping separator and minus
/// sign. Reading is stricter than Foundation's lenient parser, which accepts "12abc" as 12, a lone "-" as
/// 0, and — in German, where "." groups — "1234.5" as 1234: here a text is a number only if every
/// character belongs to one, and the in-between states of typing are recognised as such.
enum QeetrixNumberParser {
    enum Reading: Equatable {
        /// Nothing typed.
        case empty
        /// On the way to a number — a minus sign, a trailing decimal separator — and not yet one.
        case partial
        case number(Decimal)
        /// Not a number in this locale.
        case invalid
    }

    /// Reads `text` in `locale`. Digits in any script count (Arabic-Indic, Devanagari, …); the locale's
    /// grouping separators are ignored; one decimal separator is allowed when `allowsFraction`, and a
    /// leading minus when `allowsNegative`.
    static func read(_ text: String, locale: Locale, allowsFraction: Bool, allowsNegative: Bool) -> Reading {
        let symbols = Symbols(locale)
        var negative = false
        var integerDigits = ""
        var fractionDigits = ""
        var sawSeparator = false
        var sawAnything = false

        for character in text where !symbols.isIgnorable(character) {
            if !sawAnything && symbols.isMinus(character) {
                guard allowsNegative else { return .invalid }
                negative = true
                sawAnything = true
                continue
            }
            sawAnything = true
            if let digit = QeetrixOTPCode.decimalDigit(character) {
                if sawSeparator { fractionDigits.append(String(digit)) } else { integerDigits.append(String(digit)) }
            } else if String(character) == symbols.decimal {
                guard allowsFraction, !sawSeparator else { return .invalid }
                sawSeparator = true
            } else if String(character) == symbols.grouping, !sawSeparator {
                continue
            } else {
                return .invalid
            }
        }

        if !sawAnything { return .empty }
        if integerDigits.isEmpty && fractionDigits.isEmpty { return .partial }  // "-", ".", "-."
        if sawSeparator && fractionDigits.isEmpty { return .partial }  // "12."
        let canonical =
            (negative ? "-" : "") + (integerDigits.isEmpty ? "0" : integerDigits) + (fractionDigits.isEmpty ? "" : "." + fractionDigits)
        guard let value = Decimal(string: canonical, locale: Locale(identifier: "en_US_POSIX")) else { return .invalid }
        return .number(value)
    }

    /// The number a partial text already stands for: "12." is 12 while its fraction is typed. A lone "-" or
    /// "." stands for none. Keystrokes can reach the field together, so it may see "12." without ever
    /// seeing "12".
    static func partialValue(_ text: String, locale: Locale, allowsFraction: Bool, allowsNegative: Bool) -> Decimal? {
        let decimal = Symbols(locale).decimal
        guard !decimal.isEmpty, text.hasSuffix(decimal) else { return nil }
        let reading = read(
            String(text.dropLast(decimal.count)), locale: locale, allowsFraction: allowsFraction, allowsNegative: allowsNegative)
        guard case .number(let number) = reading else { return nil }
        return number
    }

    /// `value` for display in `locale`: grouped, with up to `fractionDigits` fraction digits.
    static func format(_ value: Decimal, locale: Locale, fractionDigits: Int) -> String {
        value.formatted(Decimal.FormatStyle(locale: locale).precision(.fractionLength(0...max(0, fractionDigits))).grouping(.automatic))
    }

    /// `value` rounded half away from zero to `fractionDigits` places — in `Decimal`, not binary floating point.
    static func rounded(_ value: Decimal, fractionDigits: Int) -> Decimal {
        var input = value
        var output = Decimal()
        NSDecimalRound(&output, &input, max(0, fractionDigits), .plain)
        return output
    }

    /// `value` brought inside `range`, if there is one.
    static func clamped(_ value: Decimal, to range: ClosedRange<Decimal>?) -> Decimal {
        guard let range else { return value }
        return min(max(value, range.lowerBound), range.upperBound)
    }

    /// One step (negative to decrease) from `value` — from 0 when there is none — kept inside `range`. An
    /// empty field stepped up holds `step`, or the minimum when that is higher.
    static func stepped(_ value: Decimal?, by step: Decimal, range: ClosedRange<Decimal>?) -> Decimal {
        clamped((value ?? 0) + step, to: range)
    }

    /// A whole `Decimal` as an `Int`, held to `Int`'s range.
    static func integer(_ decimal: Decimal) -> Int {
        let whole = rounded(decimal, fractionDigits: 0)
        if whole >= Decimal(Int.max) { return Int.max }
        if whole <= Decimal(Int.min) { return Int.min }
        return Int(truncating: whole as NSDecimalNumber)
    }

    /// The locale's number punctuation, with the bidirectional marks some locales put around a minus sign.
    struct Symbols {
        let decimal: String
        let grouping: String
        let minusSigns: Set<Character>

        init(_ locale: Locale) {
            decimal = locale.decimalSeparator ?? "."
            grouping = locale.groupingSeparator ?? ","
            let formatter = NumberFormatter()
            formatter.locale = locale
            var minus: Set<Character> = ["-", "\u{2212}"]
            for character in formatter.minusSign ?? "" where !Self.isFormatCharacter(character) { minus.insert(character) }
            minusSigns = minus
        }

        func isMinus(_ character: Character) -> Bool { minusSigns.contains(character) }

        /// Spaces (French groups with a narrow no-break space) and invisible direction marks.
        func isIgnorable(_ character: Character) -> Bool {
            Self.isFormatCharacter(character) || (character.isWhitespace && String(character) != grouping)
        }

        static func isFormatCharacter(_ character: Character) -> Bool {
            character.unicodeScalars.allSatisfy { $0.properties.generalCategory == .format }
        }
    }
}
