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

### At the end of a row

A row that lays out its own title and note ends with the switch alone, as `@qeetrix/react`'s Switch with
an `aria-label`. ``QeetrixSwitch/init(isOn:accessibilityLabel:)`` draws only the track, and VoiceOver
reads the label:

```swift
HStack(spacing: QeetrixSpace.gapMd) {
    VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
        Text("Unlock with Face ID")
            .qeetrixTextStyle(.bodyMd)
        Text("Asks for your face before it shows a code.")
            .qeetrixTextStyle(.bodySm)
            .foregroundStyle(QeetrixColor.textSubtle)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    QeetrixSwitch(isOn: $faceID, accessibilityLabel: Text("Unlock with Face ID"))
}
```

The switch is laid out at the track's 32 × 18 points and doesn't stretch. Its 44-point target spills
round the track without moving the layout, so the row keeps the web's height and the text keeps its
width. A list row whose whole row toggles the switch is ``QeetrixListItem`` with `isOn`.

### Any toggle, the Qeetrix style

`.toggleStyle(.qeetrixSwitch)` gives any `Toggle` the same look, in a `Form` row too:

```swift
Toggle("Wi-Fi", isOn: $wifi)
    .toggleStyle(.qeetrixSwitch)
```

The style can't read `.labelsHidden()` on iOS 17, so it always draws the label. For a switch without a
visible label, use ``QeetrixSwitch/init(isOn:accessibilityLabel:)``.

### Accessibility

VoiceOver reads it as the system's switch. The row is a 44-point target, and so is the area round a
bare switch. Under Reduce Motion the thumb moves without sliding.

### Platform differences

- **Layout.** The switch comes first and the label after it, as on the web — not the trailing switch of
  a system settings row.
- **Rows** are 44 points tall (ADR 0012).

On the web: [Switch on ui.qeet.in](https://ui.qeet.in/components/switch/).
