# ``Qeetrix/QeetrixNumberField``

## Overview

A number, typed or stepped: a quantity, a percentage, a limit. Not for numbers that are identifiers —
phone numbers, codes, card numbers — which are text. Currency entry is a later component.

```swift
QeetrixNumberField("Seats", value: $seats, in: 1...250)
QeetrixNumberField("Discount", value: $discount, in: 0...100, step: Decimal(string: "0.5")!, fractionDigits: 1)
```

- **Values** are `Int?` or `Decimal?` — `Decimal`, so a fractional value is exact. `nil` is an empty field.
- **Typing** keeps its own text: a lone minus sign or a trailing decimal separator is never rejected
  mid-way. The value follows whenever the text is a number inside the range.
- **Committing** — Return, or leaving the field — settles it: a number outside the range is brought to
  its nearest end, a decimal is rounded to `fractionDigits`, text that is not a number goes back to the
  last value, and the value is shown formatted, with grouping.
- **Steppers** change it by `step` and are disabled at the ends of the range.

### Locale and keyboard

The environment's locale decides the decimal separator, grouping and digits (`1.234,5` in German).
Digits in any script are read. The keypad is the number pad, the decimal pad, or — when negatives are
allowed, since neither pad has a minus key — the numbers-and-punctuation keyboard.

### Validation

Out-of-range numbers are corrected on commit, not reported. Report your own rules — "At least 5 seats
for this plan" — with `message`.

### Accessibility

VoiceOver reads a text field named by the label, with the number as its value; the steppers are buttons
named "Decrease" and "Increase".

### Platform differences

The web field also scrubs the value with a pointer drag and steps with the arrow keys; on iOS the
steppers and the keypad do that work.

On the web: [Number Field on ui.qeet.in](https://ui.qeet.in/docs/components/number-field).
