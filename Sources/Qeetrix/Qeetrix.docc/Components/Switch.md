# ``Qeetrix/QeetrixSwitch``

## Overview

An on/off control: a label, and the Qeetrix switch at the trailing edge.

```swift
VStack(spacing: 0) {
    QeetrixSwitch("Email notifications", isOn: $email)
    QeetrixSwitch("Weekly digest", isOn: $digest, size: .sm)
}
```

The state never rests on colour alone: the thumb travels to the trailing edge when on, and it is a
light disc on both tracks. ``QeetrixSwitchToggleStyle`` gives any `Toggle` the same switch:

```swift
Toggle("Wi-Fi", isOn: $wifi)
    .toggleStyle(.qeetrixSwitch())
```

### Accessibility

- VoiceOver reads a native switch: the label and "on" or "off".
- The whole row is the target, at least 44 pt tall.
- `disabled(_:)` fades the row and stops it toggling.

### Platform adaptations

- **Layout.** The web places a switch where the form puts it, usually before its label. Here the label
  leads and the switch trails, as iOS lays out a toggle, and in right-to-left layouts both mirror.
- **Target.** The web gives its 32 pt switch a larger pointer target; here the row is the target, as a
  web `<label>` is.

On the web: [Switch on ui.qeet.in](https://ui.qeet.in/docs/components/switch).

## Topics

### Styling

- ``QeetrixSwitchSize``
- ``QeetrixSwitchToggleStyle``
