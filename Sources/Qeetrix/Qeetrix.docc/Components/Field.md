# ``Qeetrix/QeetrixField``

## Overview

The field every Qeetrix input is built on: a label, the control, a description and a validation
message, with the web `Field`'s 6 pt rhythm.

Use it to give any control — a native `Picker`, `Stepper`, `DatePicker` or your own — the same label,
description and message as the Qeetrix inputs. Don't wrap a Qeetrix input in it: ``QeetrixTextField``,
``QeetrixPasswordInput``, ``QeetrixSelect`` and the others take a label and lay out their own field.

```swift
QeetrixField("Seats", description: Text("You can add more later."), isRequired: true) {
    Stepper("\(seats) seats", value: $seats, in: 1...25)
}
```

### States and validation

- **Required and optional.** `isRequired` adds an asterisk to the label; `isOptional` adds "(optional)"
  instead — the better convention when most fields of a form are required.
- **Messages.** A ``QeetrixFieldMessage`` — error, warning or success — appears under the control with
  its icon, and colours a Qeetrix control's boundary. The label is never repainted: the message says what
  is wrong. Messages are the app's; the field validates nothing.
- **Disabled.** `disabled(_:)` dims the label with the control.

Colours, type and spacing come from the theme and follow light, dark and Increased Contrast like every
other component.

### Accessibility

The control carries the field for VoiceOver, so the relationship never rests on position:

- its name is the label, with "Required" for a required field;
- the description is its hint;
- the message is attached as content VoiceOver reads with it, whatever the hints setting;
- a new or changed message is announced.

The description and message also follow as text in reading order, as on the web. A Qeetrix control
applies all of this itself; a native control inside the field is named by the label.

### Platform differences

The web associates label, description and message by element ids (`aria-labelledby`,
`aria-describedby`, `aria-errormessage`). iOS has no such references, so the field passes them to the
control through the environment and the control carries them.

On the web: [Field on ui.qeet.in](https://ui.qeet.in/docs/components/field).

## See Also

- ``QeetrixFieldMessage``
- ``QeetrixFieldSet``
- <doc:Forms>
