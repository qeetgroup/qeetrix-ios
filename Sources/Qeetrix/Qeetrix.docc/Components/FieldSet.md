# ``Qeetrix/QeetrixFieldset``

## Overview

A section of fields under a heading — "Billing address" — as `@qeetrix/react`'s Fieldset.

```swift
QeetrixFieldset("Billing address", description: Text("Where invoices are sent.")) {
    QeetrixTextField("Street", text: $street)
    QeetrixTextField("City", text: $city)
}
```

- The legend in `title.sm`, `color.text.default` (`color.text.disabled` when disabled), and an optional
  description under it in `body.sm`, `color.text.subtle`.
- The fields stack the density's form gap (``QeetrixDensity/spaceFormGap``) apart; checkbox, radio and
  switch rows sit flush.
- `.disabled(true)` on the fieldset disables every field inside.

A choice question isn't a fieldset: use ``QeetrixRadioGroup``, whose legend looks like every other
field label.

### Accessibility

VoiceOver reads the legend as a heading and names the group by it.

### Platform differences

None in the look.

On the web: [Form and Fieldset on ui.qeet.in](https://ui.qeet.in/components/form/).
