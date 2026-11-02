# ``Qeetrix/QeetrixRangeCalendar``

## Overview

A month of days to choose a range from — `@qeetrix/react`'s RangeCalendar, drawn by Qeetrix, because
iOS has no system range calendar.

```swift
QeetrixRangeCalendar(selection: $stay, min: .now)
```

For a range in a form, use ``QeetrixDateRangePicker``, which opens this calendar from a field.

- **Choosing**: the first day chosen is one end. Until the second is chosen, a pointer or the keyboard
  previews the range — only to days that can end it — in place of the old one. A day before the first
  swaps them, and the same day twice is a one-day range. `selection` is set once both ends are chosen.
- **The look** (range-calendar.css): a band of `color.bg.brand.subtle` a day high, across the gutters,
  under the range; its two ends filled `color.bg.brand.bold`, with the band reaching into them from
  the middle; days between keep `color.text.default` and today's outline, and take
  `color.bg.brand.subtle-hover` under a pointer. Disabled days can't be an end; inside a range they stay
  grey. Disabled, the band and today's outline go grey too.
- **Values**: from the moment the first day starts to the moment the last day starts, in the
  environment's time zone.
- Everything else is ``QeetrixCalendar``'s: the header, the years and months, the limits, the keys and
  the sizes.

### Accessibility

- Every day in the range is selected for VoiceOver, and each step is announced: "Starts Monday, 12
  October 2026. Now choose the end date.", then "Monday, 12 October 2026 to Friday, 16 October 2026".
- Escape — or VoiceOver's escape gesture — undoes a half-chosen range and does nothing more, so a picker
  around it stays open; the next one closes the picker.
- The keys, the 44-point cells and Dynamic Type are ``QeetrixCalendar``'s. In right-to-left layouts the
  range runs from right to left.

### Platform differences

- The web previews the range under the mouse and under keyboard focus; iOS does under an iPad's pointer
  and the keyboard. With touch or VoiceOver, the first day shows alone until the second is chosen.
- The cells are ``QeetrixCalendar``'s 44-point ones, so the band has room above and below it.

On the web: [Range calendar on ui.qeet.in](https://ui.qeet.in/components/range-calendar/).
