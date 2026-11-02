# ``Qeetrix/QeetrixTimePicker``

## Overview

A time of day in a form, with its label, help text and error, opening the system's time wheel. iOS
only: `@qeetrix/react` has no time field yet ("TimeField, only when a screen needs it"), so it is built
as ``QeetrixDatePicker`` is, and as Android's `QeetrixTimeField`.

```swift
QeetrixTimePicker("Reminder", selection: $reminder, minuteStep: 15)
```

- **The field** is the Qeetrix field box showing the time as
  ``QeetrixFormat/time(_:style:locale:timeZone:)`` writes it — "2:30 pm" in India, "14:30" in Britain —
  in tabular figures, with a sharp `clock` icon at its end. The whole box is one button.
- **The popover** opens under the field — a sheet on a phone at the accessibility text sizes, or in
  landscape — with the system's time wheel. "Done" sets the time; "Clear" empties one that isn't
  required.
- **12 or 24 hours** as the person has set the device: both the wheel and the field follow the
  environment's locale, which carries that setting. Setting a locale on the view — `en_US` — fixes it.
- **Minute steps**: `minuteStep` offers the minutes in steps — 15 for quarter hours. It must divide an
  hour (1, 2, 3, 4, 5, 6, 10, 12, 15, 20 or 30); any other step is 1, as UIKit treats it. The time set is
  rounded to the step, so the first time offered — now, from the clock — is on a step too.
- **Values**: the time is set on the day `selection` already has, or today, in the environment's time
  zone, with no seconds.

### What the system draws, and what Qeetrix draws

| Part | Drawn by | Qeetrix's part in it |
|:--|:--|:--|
| The field, its label, help and error | Qeetrix | all of it |
| The popover's frame and arrow | iOS | the `color.surface.overlay` background |
| The time wheel | iOS: `UIDatePicker` in its wheels style | its tint (`color.text.brand`), its locale and time zone; not its font or colours, which iOS sets |
| "Done" and "Clear" | Qeetrix | buttons in the Qeetrix style |

SwiftUI's `DatePicker` has no minute interval, so the wheel is UIKit's `UIDatePicker` with its
`minuteInterval`, inside SwiftUI. On the Mac — a development host for the package's tests, not a
supported platform — there is no `UIDatePicker`: the popover shows SwiftUI's hour-and-minute picker,
which offers every minute, and the time set is rounded to the step.

### Accessibility

- VoiceOver reads the field as a button named by its label, with the time as its value. The wheel's
  VoiceOver, keyboard and Dynamic Type are the system's.
- The field is a 44-point target, and wraps rather than truncating at large text sizes.

### Platform differences

There is no web counterpart. The field and its popover follow ``QeetrixDatePicker``'s, and its strings
the web's ("Choose time" after "Choose date").
