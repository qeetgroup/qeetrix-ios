# ``Qeetrix/QeetrixDateRangePicker``

## Overview

A range of dates in a form, with its label, help text and error — `@qeetrix/react`'s DateRangePicker
in a Field, opening Qeetrix's range calendar.

```swift
QeetrixDateRangePicker("Billing period", selection: $period, presets: [.thisMonth, .lastMonth, .last30Days])
```

- **The field** is the Qeetrix field box showing both ends in the locale's all-number form, joined by
  an en dash, as the web writes them — "01/12/2026 – 31/12/2026" — through
  ``QeetrixFormat/dateRange(_:locale:timeZone:)``, in tabular figures, with a sharp `calendar` icon at
  its end. It wraps rather than truncating at large text sizes.
- **The popover** opens under the field, as ``QeetrixDatePicker``'s does, with a
  ``QeetrixRangeCalendar``: the first day chosen starts the range, the second ends it and closes the
  popover. Escape first undoes a half-chosen range.
- **Presets** (``QeetrixDateRangePreset``) list ranges to choose in one step under the calendar, behind
  a 1-point `color.border.subtle` rule: "Today", "Last 7 days", "Last 30 days", "Last 90 days", "This
  month", "Last month", or your own. Each is cut to `min` and `max`; one wholly outside them, or that
  would start or end on a disabled day, is dimmed. Choosing one sets the range and closes the popover.
- **Values**: the range runs from the moment its first day starts to the moment its last day starts,
  in the environment's time zone. To test whether a moment falls on one of its days, compare it with
  the start of the day after the last.

```swift
QeetrixDateRangePicker(
    "Stay", selection: $stay, min: .now,
    presets: [QeetrixDateRangePreset("Next weekend") { nextWeekend() }])
```

### What the system draws, and what Qeetrix draws

iOS has no range picker, so everything inside the popover is Qeetrix's: the calendar, as the web's
RangeCalendar (range-calendar.css), the presets and "Clear". iOS draws the popover's frame and arrow,
on Qeetrix's `color.surface.overlay`.

### Accessibility

- VoiceOver reads the field as a button named by its label, with the range in words — "1 December 2026
  to 31 December 2026" — as its value.
- In the calendar every day of the range is selected, and each step is announced: "Starts Monday, 12
  October 2026. Now choose the end date.", then "… to …". The presets are a group, "Quick ranges".
- The presets are 44-point rows, two to a row and one at the accessibility text sizes.

### Platform differences

- **Nothing to type**, as ``QeetrixDatePicker``: the web's field reads six typed numbers.
- **Presets under the calendar** at every width, two to a row: the web puts them beside the calendar
  from 600 pixels, which would widen the popover past its field.
- **44-point rows** for the presets, where the web's are `size.control.md` high, 2 pixels apart: targets
  stacked that close would overlap (ADR 0012).
- **"Clear"** empties the field, where the web deletes its text; there is no `startName` or `endName`.

On the web: [Date range picker on ui.qeet.in](https://ui.qeet.in/components/date-range-picker/).

## Topics

### Presets

- ``QeetrixDateRangePreset``
