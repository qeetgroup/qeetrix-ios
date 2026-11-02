# ``Qeetrix/QeetrixRadioGroup``

## Overview

Pick one of a set — `@qeetrix/react`'s RadioGroup: the question as the legend, then a radio per option
(design rules §9).

```swift
QeetrixRadioGroup(
    "Billing cycle", selection: $cycle,
    options: [
        QeetrixOption("Monthly", value: Plan.monthly),
        QeetrixOption("Yearly", value: Plan.yearly, description: Text("Two months free")),
    ])
QeetrixRadioGroup(
    "Billing cycle", selection: $cycle,
    options: [QeetrixOption("Monthly", value: Plan.monthly), QeetrixOption("Yearly", value: Plan.yearly)],
    orientation: .horizontal)
```

- **Legend** in the field-label style, so every form row's label looks the same; the description or
  error under the options, as for a field.
- **Radio**: a 16-point circle with a 1-point `color.border.strong` edge on `color.bg.input`; selected,
  the edge becomes a 5-point Ember ring around the centre.
- **Orientation**: `vertical` (default) or `horizontal` for short options, 16 points apart, wrapping.
- **States**: with an error every radio takes the danger edge, and the chosen one a danger ring; a
  disabled option is dimmed.

### Accessibility

VoiceOver reads each option as a button that is selected or not, with its description as the hint, and
the group's error with each.

### Platform differences

- **Rows** are 44-point targets, flush (ADR 0012); the web's are 24 points, 4 apart.
- **Keyboard.** The web moves the selection with the arrow keys; iOS moves focus between the options.

On the web: [Radio on ui.qeet.in](https://ui.qeet.in/components/radio/).

## Topics

### Options

- ``QeetrixOption``
- ``QeetrixChoiceOrientation``
