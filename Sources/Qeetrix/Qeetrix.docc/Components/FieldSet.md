# ``Qeetrix/QeetrixFieldSet``

## Overview

Groups related fields or choices under a legend — the web's `FieldSet` with a `FieldLegend` and a
`FieldGroup`. Use it for a section of a form ("Your details"), or for a set of checkboxes or switches
that answer one question ("Notifications"). Don't use it for a single field.

```swift
QeetrixFieldSet("Notifications", description: Text("Choose how we reach you.")) {
    QeetrixCheckbox("Email", isOn: $email)
    QeetrixCheckbox("Push", isOn: $push)
}
```

- The legend is a heading, in the heading face.
- Fields are spaced by the density's field gap (`qeetrixDensity(_:)`). Checkbox, radio and switch rows
  sit flush, because each row is already a 44 pt target.
- A message here is about the group as a whole — "Choose at least one" — and VoiceOver reads it with each
  checkbox in the group. Fields in the set carry their own messages.

### Accessibility

The group is a VoiceOver container named by its legend, and the legend is a heading the rotor can reach.

On the web: [Field on ui.qeet.in](https://ui.qeet.in/docs/components/field).

## See Also

- ``QeetrixField``
- ``QeetrixCheckbox``
- <doc:Forms>
