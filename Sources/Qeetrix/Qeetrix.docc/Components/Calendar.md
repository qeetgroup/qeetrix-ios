# ``Qeetrix/QeetrixCalendar``

## Overview

A month of days to choose one from — `@qeetrix/react`'s Calendar, drawn by Qeetrix.

```swift
QeetrixCalendar(selection: $deliveryDay, min: .now, isDateDisabled: { isHoliday($0) })
```

For one date in a form, use ``QeetrixDatePicker``: it opens the system's calendar, and this one only
when days are ruled out. Use `QeetrixCalendar` inline, where a page shows a month to choose from.

- **The header** (calendar.css): the month and year in `label.md` at `title.sm`'s weight, between
  neutral ghost previous and next buttons, whose chevrons point outwards in either reading direction.
- **The days**: the weekdays from the locale's first day — Sunday in India and the US, Monday in most of
  Europe — in `label.sm`, `color.text.subtle`, then six weeks, so the height never jumps; days of other
  months are blank. Each day is a `size.control.md` square with 4-point corners in `body.md` with
  tabular figures, in the middle of a cell at least 44 points square.
- **The look**: today has a 1-point `color.border.brand` outline; the chosen day is filled
  `color.bg.brand.bold` in `color.text.on-brand`, which takes over the outline; a pointer or a press
  tints a day `color.overlay.hover` or `color.overlay.pressed`; disabled days are `color.text.disabled`
  and take no tint. Changes take `motion.duration.fast`, not at all under Reduce Motion.
- **Limits**: days before `min` and after `max`, and those `isDateDisabled` rules out, can't be chosen,
  and the arrows stop at `min` and `max`. The calendar opens on the chosen day, or today, kept inside
  them.
- **Years and months**: the title opens the years, a decade a page with the year either side muted
  (2019–2030 for the 2020s); choosing a year shows its months, and choosing a month its days, keeping
  the day number. Years and months wholly outside the limits are disabled.
- **States**: `isReadOnly` shows the date and lets the months be browsed, but no day can be chosen;
  disabled, everything is grey and the month stays put.
- **Values**: a date is the day it falls on in the environment's time zone, and a chosen day is written
  as the moment it starts there. Names follow the environment's locale, always in the Gregorian
  calendar. Choosing a day plays ``QeetrixFeedback/selection``.
- **Its own size**: as wide as its days, 308 points at the default text size — narrower where its
  container is, never wider.

### Accessibility

- VoiceOver reads each day in full — "Today, Sunday, 25 October 2026" — as a button, the chosen one
  selected, disabled ones dimmed; the weekday names are hidden, since every day says its own. The
  title is a heading and a button, "October 2026, choose year"; the arrows are "Previous month" and
  "Next month" (a year, or ten years, in the other views). A new month is announced. Opening the years,
  a year's months or a month's days moves VoiceOver to the year, month or day they open on, as the web
  moves focus; in a picker, VoiceOver starts on the chosen day, or today.
- VoiceOver's escape gesture goes back from the years or months to the days; from the days it
  dismisses what the calendar is in — a picker's popover, a sheet, a pushed screen — as it does
  anywhere.
- With a hardware keyboard the grid takes focus: the arrows move by a day and a week (left and right
  mirrored in right-to-left layouts), Home and End to the week's ends, Page Up and Page Down by a month
  — with Shift, a year — and Return or Space choose. In the years and months, the arrows move by one and
  by a row of three. Escape goes back to the days. The day under the keyboard has the 2-point
  `color.border.focus` frame inside it.
- Every day's cell is a 44-point target, and the targets tile without overlapping. Text grows with
  Dynamic Type; at the largest sizes a day's number shrinks to fit its column rather than truncating.

### Platform differences

- **44-point cells.** The web's days are 32 pixels in 34-pixel rows; on iOS they sit in 44-point
  cells, so the calendar is 308 points wide and its rows 44 points apart, and the targets don't overlap
  (ADR 0012). The days stay `size.control.md` squares, centred, where the web stretches them across a
  wide picker.
- **Day numbers in the locale's digits**, as the title is; the web writes them as plain numbers.
- **No `defaultMonth`**: it opens on the chosen day or today.
- **The system's calendar** — `DatePicker` in its graphical style — is the native control for one date,
  and ``QeetrixDatePicker`` uses it; this calendar is for what it can't do.

On the web: [Calendar on ui.qeet.in](https://ui.qeet.in/components/calendar/).
