# ``Qeetrix/QeetrixCheckbox``

## Overview

A checkbox with its label — `@qeetrix/react`'s Checkbox. It turns one option on or off, or picks
several (design rules §9).

```swift
QeetrixCheckbox("Email me receipts", isOn: $receipts, description: Text("One email per invoice."))
QeetrixCheckbox("All channels", sources: $channels, isOn: \.isOn)
```

- **Box**: 16 points, 2-point corners, a 1-point `color.border.strong` edge on `color.bg.input`
  (`color.border.strong-hover` under a pointer).
- **Checked or mixed**: the Ember fill with a white 12-point sharp tick or dash, stroke 3. A parent
  checkbox over `sources` is mixed when some of them are on.
- **Invalid**, in a group with an error: the danger edge, checked or not, hovered or not.
  **Disabled**: `color.bg.disabled`, the
  disabled edge and mark.
- **Row**: the label in `body.md`, 8 points after the box, and an optional description in `body.sm`
  under it. The whole row toggles it.

Settings that apply at once use ``QeetrixSwitch``; a checkbox is for choices a Save step confirms.

### Any toggle, the Qeetrix style

`.toggleStyle(.qeetrixCheckbox)` gives any `Toggle` the same look.

### Accessibility

VoiceOver reads it as the system's toggle — its label, whether it's on, and its description as the
hint. The row is a 44-point target.

### Platform differences

- **Rows.** The web's row is a 24-point target with rows 4 points apart; iOS rows are 44 points tall
  and flush (ADR 0012).
- **Focus.** The Ember frame 2 points outside the box shows under keyboard focus.

On the web: [Checkbox on ui.qeet.in](https://ui.qeet.in/components/checkbox/).
