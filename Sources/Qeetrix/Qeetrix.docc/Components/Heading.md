# ``Qeetrix/QeetrixHeading``

## Overview

A section heading — `@qeetrix/react`'s Heading. The `level` sets the outline; the `size` sets the
look, so the outline never bends to a visual choice. `QeetrixHeading("Billing", level: 1)` takes the
level's default look, `heading-lg`; a welcoming page's headline sets a display size:

```swift
QeetrixHeading("Sign in to Qeet", level: 1, size: .displaySm)
```

- **Level** 1–6. Without a size, each level has the web's default look: 1 `heading-lg`, 2 `heading-md`,
  3 `heading-sm`, 4 `title-lg`, 5 `title-md`, 6 `title-sm`.
- **Size**: any display, heading or title role (``QeetrixHeadingSize``). The display sizes headline
  welcoming pages only — sign-in, checkout, onboarding (design rules §17).
- **Tone**: `default`, `subtle` or `inverse`.
- **Truncate** and **align**, as ``QeetrixText``.

Weight 600, in Qeet Sans's Base letter style (`font.geometry.heading`), or Geo
(`font.geometry.display`) for the display sizes.

### Accessibility

VoiceOver reads it as a heading of its level, so the rotor's heading navigation follows the page's
outline. It scales with Dynamic Type along its role's curve.

### Platform differences

On the web the level renders `<h1>`…`<h6>`; on iOS it sets the accessibility heading level.

On the web: [Heading on ui.qeet.in](https://ui.qeet.in/components/heading/).

## Topics

### Styling

- ``QeetrixHeadingSize``
- ``QeetrixHeadingTone``
