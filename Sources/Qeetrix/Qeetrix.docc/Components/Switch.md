# ``Qeetrix/QeetrixSwitch``

## Overview

A setting that applies at once — `@qeetrix/react`'s Switch: a square 32 × 18-point track with a
12-point square thumb (design rules §9).

```swift
VStack(spacing: 0) {
    QeetrixSwitch("Auto-renew", isOn: $autoRenew)
    QeetrixSwitch("Two-step sign-in", isOn: $twoStep, description: Text("A code by SMS at each sign-in."))
}
```

- **Off**: the `color.bg.input` track with a `color.border.strong` edge and the graphite thumb
  (`color.icon.subtle`) on the start side.
- **On**: the Ember track and edge, and the white thumb (`color.icon.on-brand`, in both schemes) on
  the end side. The thumb slides over `motion.duration.normal` with `motion.easing.standard`.
- **Invalid**, in a group with an error: the danger edge, on or off, hovered or not.
- **Disabled**: `color.bg.disabled`, the disabled edge, the `color.icon.disabled` thumb.
- **Row**: the label in `body.md`, 8 points after the switch, and an optional description under it.
  The whole row toggles it.

A setting that waits for a Save step is a ``QeetrixCheckbox``.

### Any toggle, the Qeetrix style

`.toggleStyle(.qeetrixSwitch)` gives any `Toggle` the same look, in a `Form` row too:

```swift
Toggle("Wi-Fi", isOn: $wifi)
    .toggleStyle(.qeetrixSwitch)
```

### Accessibility

VoiceOver reads it as the system's switch. The row is a 44-point target. Under Reduce Motion the thumb
moves without sliding.

### Platform differences

- **Layout.** The switch comes first and the label after it, as on the web — not the trailing switch of
  a system settings row.
- **Rows** are 44 points tall (ADR 0012).

On the web: [Switch on ui.qeet.in](https://ui.qeet.in/components/switch/).
