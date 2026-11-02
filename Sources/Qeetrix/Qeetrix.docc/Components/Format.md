# ``Qeetrix/QeetrixFormat``

## Overview

Numbers, money, dates and times written the way the web writes them — `@qeetrix/react`'s `format`
family (`formatNumber`, `formatCurrency`, `formatDate`, `formatDateTime`, `formatRelativeTime`), on
Foundation's format styles and the system's locale data. India first: `en-IN` groups in lakhs and
crores and writes the rupee.

```swift
let india = Locale(identifier: "en-IN")
let kolkata = TimeZone(identifier: "Asia/Kolkata")!

QeetrixFormat.number(1_234_567, locale: india)                       // "12,34,567"
QeetrixFormat.currency(124_500, code: "INR", locale: india)          // "₹1,24,500.00"
QeetrixFormat.date("2026-10-25", locale: india)                      // "25 Oct 2026"
QeetrixFormat.dateTime(sentAt, locale: india, timeZone: kolkata)     // "25 Oct 2026, 2:30 pm"
QeetrixFormat.relativeTime(sentAt, now: now, locale: india)          // "2 minutes ago"
```

In a view, pass the environment's locale and time zone — iOS's counterpart of the web's
`QeetrixProvider` locale. Without them, the functions use the person's own settings.

```swift
struct InvoiceTotal: View {
    let total: Decimal
    @Environment(\.locale) private var locale

    var body: some View {
        QeetrixText(QeetrixFormat.currency(total, code: "INR", locale: locale))
            .monospacedDigit()
    }
}
```

For a time that should keep itself current on screen, use ``QeetrixRelativeTime``.

### Numbers and money

- ``number(_:fractionDigits:sign:locale:)-(Double,_,_,_)`` — up to three fraction digits, as `Intl`
  writes a number; ``number(_:fractionDigits:sign:locale:)-(Int,_,_,_)`` and
  ``number(_:fractionDigits:sign:locale:)-(Decimal,_,_,_)`` for whole and exact values.
- ``currency(_:code:fractionDigits:sign:locale:)-(Decimal,_,_,_,_)`` — the currency's own decimals:
  "₹1,24,500.00", "¥1,235"; `fractionDigits: 0...0` drops them: "₹1,24,500".
- ``percent(_:fractionDigits:sign:locale:)`` — a fraction as a whole percentage: 0.4 is "40%".
- ``compactNumber(_:locale:)`` — short words: "12L" and "1.2Cr" in `en-IN`, "1.2M" in `en-US`.
- `sign` is `Intl`'s `signDisplay` (``QeetrixFormatSign``): `.exceptZero` writes a change, "+12%".

Halves round away from zero, as `Intl` rounds: 2.5 is "3" and 0.125 is "13%".

### File sizes and durations

``fileSize(_:locale:)`` writes sizes as `@qeetrix/react`'s FileUpload does: decimal units, bytes in
full, one decimal below 10 — "512 bytes", "12 kB", "1.5 MB".

``duration(_:style:locale:)`` writes a `Duration` in four styles (``QeetrixFormatDurationStyle``):
"2 hours, 5 minutes", "2 hr, 5 min" (the default), "2h 5m" and "2:05:00".

```swift
QeetrixFormat.fileSize(1_500_000, locale: india)                     // "1.5 MB"
QeetrixFormat.duration(.seconds(7_500), style: .long, locale: india) // "2 hours, 5 minutes"
```

### Dates and times

``date(_:style:locale:timeZone:)-(Date,_,_,_)`` and
``dateTime(_:dateStyle:timeStyle:locale:timeZone:)-(Date,_,_,_,_)`` write a moment in a time zone, in
three date lengths (``QeetrixFormatDateStyle``) and two time lengths (``QeetrixFormatTimeStyle``):

| | `short` | `medium` (default) | `long` |
|:--|:--|:--|:--|
| Date, `en-IN` | 25/10/26 | 25 Oct 2026 | 25 October 2026 |
| Date and time, `en-IN` | 25/10/26, 2:30 pm | 25 Oct 2026, 2:30 pm | 25 October 2026 at 2:30 pm |
| Date, `en-US` | 10/25/26 | Oct 25, 2026 | October 25, 2026 |

A calendar date has no zone, so no zone can move it to another day: pass `DateComponents` with a year,
month and day, or an ISO 8601 string, read as the web reads one:

- "2026-10-25" is a calendar date, shown as written;
- "2026-10-25T20:00:00Z" or "…+05:30" (or "+0530") is a moment, shown in `timeZone`;
- "2026-10-25T14:30", with no offset, is a wall-clock time, shown as written;
- anything else — "25/10/2026", "2026-02-31" — is an empty string.

``time(_:style:locale:timeZone:)`` writes the time alone. ``numericDate(_:locale:timeZone:)`` and
``dateRange(_:locale:timeZone:)`` write the all-number form the web's date fields show, in Latin
digits so it can be typed back: "25/10/2026", "01/12/2026 – 31/12/2026".

### Relative time

``relativeTime(_:now:locale:)`` says how long ago or how soon in the largest whole unit: "2 minutes
ago", "in 3 days", "yesterday", "last week". It rounds first and then picks the unit, so 59 minutes 40
seconds is "1 hour ago" and 364 days is "last year". A month is 30 days: four weeks are not yet a
month, five are.

### Matching the web

The functions write what `@qeetrix/react` writes for the same value and locale. A test suite checks
2,337 cases in 19 locales against the web's output; `en-IN` and `en-US` match in every one. Where
Foundation's defaults differ from `Intl`'s, Qeetrix sets them to the web's:

- **Rounding**: halves away from zero (`Intl`'s `halfExpand`); Foundation rounds them to even.
- **Fraction digits**: up to three for a number and none for a percentage, as `Intl`; Foundation's
  defaults show every digit.
- **Gregorian, always**, as the web's dates are (`calendar: "gregory"`): no Buddhist or Japanese era.
- **Spaces**: Apple's times put a no-break space before the day period ("2:30 PM" with U+202F, and
  U+00A0 in Arabic); browsers write a plain space, and so does Qeetrix.
- **A medium date and its time** are joined by a comma — "25 Oct 2026, 2:30 pm" — where Apple's
  English, French and Polish data join them with a word ("at", "à", "o"). Both use the word for a
  long date.
- **English (India)**, the web's default: "am"/"pm" and "Sept", as CLDR writes them, where Apple
  writes "AM"/"PM" and "Sep".

Elsewhere Qeetrix follows the system's locale data, as every other app on the device does. These are
the differences from the web known today:

| Locale | iOS | Web |
|:--|:--|:--|
| Bengali, Marathi | Latin digits: "12,34,567" | the script's digits: "১২,৩৪,৫৬৭" |
| Kannada, Malayalam | Indian grouping: "₹1,24,500.00" | Western grouping: "₹124,500.00" |
| Hindi | "अक्तू॰", "दोप॰ 2:30", "आने वाला कल" | "अक्टू॰", "2:30 pm", "कल" |
| English (UK and others outside India) | "10 Sep 2026" | "10 Sept 2026" |
| Tamil, Telugu, Gujarati, Kannada, Arabic | some date patterns and relative-time words | CLDR's |
| Japanese | "¥124,500", "0バイト" | "￥124,500", "0 バイト" |
| English (India), durations | "2 hrs, 5 min" | `Intl.DurationFormat`'s "2 hrs, 5 mins" |

A person's own settings — 24-hour time, a numbering system — apply through the locale, as they do in
every app.

### Platform differences

- **Defaults.** Without a locale or time zone, the functions use the device's: the web defaults to
  `en-IN` and `Asia/Kolkata` so that server and client agree, and asks for the user's zone "where you
  know it" — on iOS it's always known.
- **Typed options.** The web passes `Intl.NumberFormatOptions`; iOS takes `fractionDigits` and `sign`,
  and has a function each for percentages and compact numbers.
- **Added on iOS**: ``time(_:style:locale:timeZone:)``; ``duration(_:style:locale:)`` — the web has
  no duration formatter, so this follows `Intl.DurationFormat`'s styles, splits a `Duration` into
  days, hours, minutes and seconds, and writes nothing as "0 sec" where `Intl` writes an empty string;
  and ``fileSize(_:locale:)``, which is FileUpload's private size formatter on the web.

On the web: `@qeetrix/react/format` — ui.qeet.in has no page for it yet; 06-component-specs.md
describes it under QeetrixProvider, Formatting.

## Topics

### Numbers and money

- ``number(_:fractionDigits:sign:locale:)-(Double,_,_,_)``
- ``number(_:fractionDigits:sign:locale:)-(Int,_,_,_)``
- ``number(_:fractionDigits:sign:locale:)-(Decimal,_,_,_)``
- ``currency(_:code:fractionDigits:sign:locale:)-(Decimal,_,_,_,_)``
- ``currency(_:code:fractionDigits:sign:locale:)-(Double,_,_,_,_)``
- ``currency(_:code:fractionDigits:sign:locale:)-(Int,_,_,_,_)``
- ``percent(_:fractionDigits:sign:locale:)``
- ``compactNumber(_:locale:)``
- ``QeetrixFormatSign``

### Sizes and durations

- ``fileSize(_:locale:)``
- ``duration(_:style:locale:)``
- ``QeetrixFormatDurationStyle``

### Dates and times

- ``date(_:style:locale:timeZone:)-(Date,_,_,_)``
- ``date(_:style:locale:timeZone:)-(String,_,_,_)``
- ``date(_:style:locale:)``
- ``dateTime(_:dateStyle:timeStyle:locale:timeZone:)-(Date,_,_,_,_)``
- ``dateTime(_:dateStyle:timeStyle:locale:timeZone:)-(String,_,_,_,_)``
- ``dateTime(_:dateStyle:timeStyle:locale:)``
- ``time(_:style:locale:timeZone:)``
- ``numericDate(_:locale:timeZone:)``
- ``numericDate(_:locale:)``
- ``dateRange(_:locale:timeZone:)``
- ``dateRange(from:to:locale:)``
- ``QeetrixFormatDateStyle``
- ``QeetrixFormatTimeStyle``

### Relative time

- ``relativeTime(_:now:locale:)``
- ``QeetrixRelativeTime``
