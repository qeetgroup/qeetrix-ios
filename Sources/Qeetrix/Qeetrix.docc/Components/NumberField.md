# ``Qeetrix/QeetrixNumberField``

## Overview

A number, typed or stepped, with its label, help text and error — `@qeetrix/react`'s NumberField in a
Field.

```swift
QeetrixNumberField("Seats", value: $seats, in: 1...250)
QeetrixNumberField(
    "Discount", value: $discount, in: 0...100, step: Decimal(string: "0.5")!, fractionDigits: 1, endAdornment: Text("%"))
QeetrixNumberField("Amount", value: $amount, startAdornment: Text("₹"), showsSteppers: false)
```

- **The box** is the Qeetrix field, the value in tabular figures, units as affixes in
  `color.text.subtle`.
- **Steppers**: unless `showsSteppers` is false — for amounts nobody steps through — the − and + at its
  end: square `size.control.sm` buttons 2 points apart behind a `color.border.default` hairline, the
  `color.overlay.hover` and `color.overlay.pressed` tints, disabled at the ends of the range.
- **Values**: `Int?` or `Decimal?` — `Decimal` so a fractional value is exact; `nil` is empty.
- **Typing** keeps its own text, so a lone minus or a trailing separator is never rewritten mid-edit.
  Committing (Return, or leaving the field) brings a number into the range, rounds it to
  `fractionDigits` and formats it for the locale. Report your own rules with `error`.

### Accessibility

The steppers are named "Decrease" and "Increase". The field is read by its label, with its value.

### Platform differences

- **Keypad.** The number pad, the decimal pad, or — when negatives are allowed, since neither pad has a
  minus key — the numbers-and-punctuation keyboard.
- **Arrow keys.** The web steps with the arrow keys and Page Up/Down; iOS steps with the buttons.
- **Formats.** The web's `format` takes `Intl.NumberFormatOptions` (currency, percent); iOS formats
  plain numbers for the environment's locale.

On the web: [Number field on ui.qeet.in](https://ui.qeet.in/components/number-field/).
