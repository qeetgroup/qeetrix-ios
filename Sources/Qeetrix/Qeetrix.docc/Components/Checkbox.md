# ``Qeetrix/QeetrixCheckbox``

## Overview

A choice that is on or off, independently of others: accepting terms, opting into a channel. For a
setting that takes effect immediately, use ``QeetrixSwitch``; for one choice from several, use
``QeetrixRadioGroup``.

```swift
QeetrixCheckbox("Accept the terms", isOn: $accepted, description: Text("You can read them at any time."))
```

### States

- **Checked and unchecked**, carried by the glyph, not only the colour: the brand fill with a white check.
- **Mixed.** A checkbox that stands for a group takes the items it controls; it shows a minus while some
  are on. A tap turns them all on, a second all off — SwiftUI's own mixed-toggle behaviour.

  ```swift
  QeetrixCheckbox("All channels", sources: $channels, isOn: \.isOn)
  ```

- **Disabled** with `disabled(_:)`. In a ``QeetrixFieldSet`` with an error, the boxes take the error
  boundary.

``QeetrixCheckboxToggleStyle`` gives any `Toggle` the checkbox: `.toggleStyle(.qeetrixCheckbox)`.

### Accessibility

It is a native `Toggle`, so VoiceOver reads its label and state — on, off, or the system's mixed state —
with the description as the hint. The whole row is the target, at least 44 pt tall.

### Platform differences

The web checkbox is a 16 px box with a 24 px pointer target; here the box is the same and the row is a
44 pt touch target. iOS has no checkbox role: VoiceOver reads it as a toggle, the platform's on/off
control.

On the web: [Checkbox on ui.qeet.in](https://ui.qeet.in/docs/components/checkbox).

## Topics

### Styling

- ``QeetrixCheckboxToggleStyle``
