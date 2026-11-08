# ``Qeetrix/QeetrixButton``

## Overview

An action — `@qeetrix/react`'s Button. The label leads; a trailing icon sits in its own zone at the far
end, behind a short rule (design rules §7).

```swift
VStack(alignment: .leading) {
    QeetrixButton("Create invoice") { create() }
    QeetrixButton("Export", icon: .share2, variant: .soft) { export() }
    QeetrixButton("Revoke key", tone: .danger, isLoading: isRevoking) { revoke() }
    QeetrixButton("Cancel", variant: .ghost) { cancel() }
}
```

- **Variant**, the emphasis: `solid` — the Ember primary, the one main action in a region; `soft` —
  warm graphite, the main alternative; `ghost` — no fill and Ember text, for everything else. A region
  has at most one `solid` and one `soft` button.
- **Tone**, the meaning: `brand` (default); `danger` for the confirming action of a destructive flow,
  which replaces the primary rather than sitting beside it; `neutral` for utility actions in toolbars,
  whose ghost look is `color.text.subtle` — a solid or soft neutral button looks like `soft`.
- **Size**, a ``QeetrixControlSize`` from the density: `sm`, `md` (default) or `lg` — 28, 32 or 40
  points at default density. A form's main button is `lg`, the field height.
- **Anatomy.** `label.md` text (`label.sm`'s size at `sm`), 4-point corners. Without an icon the label
  has 14 points either side (10 at `sm`, 16 at `lg`). With one, 12 points after the label (8, 14) a
  1-point rule as tall as the icon, in the label's colour at 55%, starts the zone, and the 16-point
  sharp icon (20 at `lg`) has 10 points either side (8, 12).
- **States.** Hover and press take the fill's `-hover` and `-pressed` tokens, with no scaling or
  movement; the colour change takes `motion.duration.fast`. Disabled is `color.bg.disabled` with
  `color.text.disabled` (a ghost button keeps no fill). Loading puts a spinner in the zone — a button
  without an icon gains the zone — keeps the label and colours, and ignores taps. Keyboard focus is the
  2-point Ember frame inside the edge, with a 1-point `color.surface.default` gap.
- `isFullWidth` stretches it to its container and centres the label on the whole button; an icon
  keeps its zone at the end. Where the label is too long to centre, the leading side gives way
  first, so a full-width button never needs more room than a plain one.

Write labels as verbs ("Create invoice"), and don't disable without saying why nearby.

### Any control, the Qeetrix style

``QeetrixButtonStyle`` gives the same treatment to any SwiftUI control that takes a button style:

```swift
NavigationLink("Billing", value: Route.billing)
    .buttonStyle(.qeetrix(.ghost, size: .sm))
```

### Accessibility

- Every button is a 44 × 44-point touch target, however short it is drawn.
- A loading button reports "Loading" as its value — the web's `aria-busy`.
- Labels scale with Dynamic Type, and the button with them: its height, icon, zone and spinner.

### Platform differences

- **Touch target.** The web's 24–44-point heights are pointer-sized. The drawn size is kept, and the
  hit area extends to 44 points without moving layout.
- **Height.** At the default text size the button is the web's height. Larger text scales it in
  proportion, and a label too long for the width wraps instead of truncating (the web keeps one
  line).
- **Hover.** Under an iPad pointer, buttons take their hover colours; on touch a press shows the
  pressed colours.
- **Focus.** The Ember frame shows when the button has keyboard focus (Full Keyboard Access).
- **Two corrections to the web's CSS**, reported upstream: a solid neutral button keeps the soft look
  when hovered and pressed (button.css lets the solid variant's Ember hover win), and a ghost danger
  button takes the danger tint when pressed (button.css has no pressed rule for it, so the Ember tint
  shows through).

On the web: [Button on ui.qeet.in](https://ui.qeet.in/components/button/).

## Topics

### Styling

- ``QeetrixButtonVariant``
- ``QeetrixButtonTone``
- ``QeetrixControlSize``
- ``QeetrixButtonStyle``

### Related

- ``QeetrixIconButton``
