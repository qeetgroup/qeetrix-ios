# ``Qeetrix/QeetrixDatePicker``

## Overview

A date in a form, with its label, help text and error — `@qeetrix/react`'s DatePicker in a Field,
opening the system's calendar where it can.

```swift
QeetrixDatePicker("Joining date", selection: $joiningDate, min: .now)
QeetrixDatePicker("Delivery", selection: $delivery, min: .now, isDateDisabled: { Calendar.current.isDateInWeekend($0) })
```

- **The field** is the Qeetrix field box (design rules §8) showing the date in the locale's all-number
  form, as the web's field writes it — "25/10/2026" in India, "10/25/2026" in the US — through
  ``QeetrixFormat/numericDate(_:locale:timeZone:)``, in tabular figures, with a 16-point sharp
  `calendar` icon at its end where the web has its calendar button. The whole box is one button.
- **The popover** opens under the field, as wide as the field and never narrower than a month, on
  `color.surface.overlay`. On a phone at the accessibility text sizes, and in a phone's landscape, where
  a popover wouldn't fit, it is a sheet that scrolls.
- **Limits**: `min` and `max` keep the date to a span of days; `isDateDisabled` rules out more, such as
  weekends or holidays.
- **States**: the field's invalid, read-only and disabled looks. "Clear" empties a date that isn't
  required.
- **Values**: a date is the day it falls on in the environment's time zone, and a chosen day is written
  as the moment it starts there. Validation is the app's: report a date your rules don't allow with
  `error`.

### What the system draws, and what Qeetrix draws

| Part | Drawn by | Qeetrix's part in it |
|:--|:--|:--|
| The field, its label, help and error | Qeetrix | all of it |
| The popover's frame and arrow | iOS | the `color.surface.overlay` background |
| The calendar, without `isDateDisabled` | iOS: `DatePicker` in its graphical style | its tint (`color.text.brand`), its locale, the Gregorian calendar and the week's first day; not its font, which iOS sets |
| The calendar, with `isDateDisabled` | Qeetrix: ``QeetrixCalendar`` | all of it |
| "Done" and "Clear" | Qeetrix | buttons in the Qeetrix style |

The system's calendar comes first (ADR 0014): its month and year wheel, VoiceOver, keyboard and
Dynamic Type are what iOS users know. It can't rule out single days, so with `isDateDisabled` the field
opens Qeetrix's calendar, which can — the web's Calendar, with the same look as
``QeetrixDateRangePicker``'s.

### Accessibility

- VoiceOver reads the field as a button named by its label, with the date in words — "25 October 2026"
  — as its value; the description is its hint and the error is read with it.
- In the system's calendar, VoiceOver, the keyboard and Dynamic Type are the system's. In Qeetrix's,
  each day is read in full — "Today, Sunday, 25 October 2026" — the chosen one selected, ruled-out days
  dimmed; see ``QeetrixCalendar``.
- The field is a 44-point target; its text wraps rather than truncating at large text sizes. In
  right-to-left layouts the icon is at the left.

### Platform differences

- **Nothing to type.** The web's field takes a typed date in the locale's order and checks it; on iOS
  the field opens the calendar, and the system's month and year wheel — or Qeetrix's years view —
  reaches a distant date. The web's typed-date errors ("Enter a date like 31/12/2026") have no iOS
  counterpart; the app reports its own with `error`.
- **"Done".** The system's calendar moves its date as its month and year wheel turns, so it can't set
  the date as soon as it changes: "Done" sets it. Qeetrix's calendar sets a day as soon as it is chosen
  and closes, as the web's does.
- **"Clear"** empties the field, where the web deletes its text.
- **No `name`**: there is no form submission to carry the ISO date.
- Android shows the date in words ("25 Oct 2026"); iOS shows what the web shows.

On the web: [Date picker on ui.qeet.in](https://ui.qeet.in/components/date-picker/).
