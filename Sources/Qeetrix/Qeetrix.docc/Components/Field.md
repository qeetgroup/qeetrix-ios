# ``Qeetrix/QeetrixField``

## Overview

A form row for any control — `@qeetrix/react`'s Field: the label above the control, then help text or
the error that replaces it, 4 points apart (design rules §8).

The Qeetrix inputs already build themselves on a field: give them a label and they lay it out. Use
`QeetrixField` for any other control, such as a native `Stepper` or `DatePicker`:

```swift
QeetrixField("Seats", description: Text("You can add more later.")) {
    Stepper("\(seats) seats", value: $seats, in: 1...25)
}
```

- **Label**: `label.sm` in `color.text.subtle` (`color.text.disabled` when disabled). `isOptional`
  appends "(optional)" in `color.text.subtlest`; fields carry no asterisks, so `isRequired` only tells
  VoiceOver. `isLabelHidden` hides it visually and keeps it for VoiceOver — only for a toolbar search
  with a visible icon.
- **Description**: `body.sm` in `color.text.subtle`; a disabled field's description dims to
  `color.text.subtlest`, not the disabled colour, since it often says why.
- **Error**: replaces the description while it shows — a sharp 16-point `circle-alert` in
  `color.icon.danger`, then the message in `body.sm`, `color.text.danger`. It marks a Qeetrix control
  inside invalid (its 2-point danger frame); `isInvalid` does that without a message.

Validation is yours: the field only presents the error it is given. Word errors as what to do
("Enter a work email").

### Accessibility

For VoiceOver the control carries the field: its name is the label (with "Required"), the description
is its hint, and the error is attached to it as content VoiceOver reads with it, whatever the hints
setting. A new error is announced.

### Platform differences

- **Required.** The web announces the native `required` attribute; here "Required" is part of the
  control's name, because a hint can be switched off.
- **Announcements.** The web links the error with `aria-describedby`; iOS posts a new error as an
  announcement.
- **Help.** The web's ⓘ help popover beside the label (`help`) has no iOS counterpart yet.

On the web: [Input and Field on ui.qeet.in](https://ui.qeet.in/components/input/).
