# ``Qeetrix/QeetrixBadge``

## Overview

A short, static status or count — one or two words — on a pill: `@qeetrix/react`'s Badge (design rules
§14).

```swift
HStack {
    QeetrixBadge("Draft")
    QeetrixBadge("Paid", tone: .success, icon: .circleCheck)
    QeetrixBadge("Overdue", tone: .danger, variant: .solid)
}
```

- **Tone**: `neutral` (default), `brand`, `info`, `success`, `warning` or `danger`.
- **Variant**: `subtle` (default) — the tone's tint with its text colour — or `solid`, the tone's bold
  fill, for the one status in a view that must stand out. White text on brand, info, success and danger,
  dark text on warning's amber, inverse text on the graphite neutral.
- **Size**: `md` 20 points tall (default) or `sm` 16, for tight rows and beside small text.
- `label.sm` text and an optional leading 12-point sharp icon.

The word carries the meaning; the tone only reinforces it. A badge is not interactive.

### Accessibility

VoiceOver reads it as one piece of static text; its icon is decorative, so the text must say what it
means. It stays on one line and truncates with an ellipsis where it has less room than its text, as at
the largest text sizes.

### Platform differences

None in the look. A count badge needs context for VoiceOver: label its container ("3 pending").

On the web: [Badge on ui.qeet.in](https://ui.qeet.in/components/badge/).

## Topics

### Styling

- ``QeetrixBadgeTone``
- ``QeetrixBadgeVariant``
- ``QeetrixBadgeSize``
