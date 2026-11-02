# ``Qeetrix/QeetrixSpinner``

## Overview

An indeterminate wait — `@qeetrix/react`'s Spinner: a 2-point ring with a quarter gap, turning once
every 800 ms (2 × `motion.duration.slower`, `motion.easing.linear`).

```swift
HStack {
    QeetrixSpinner()
    QeetrixSpinner(size: .lg, tone: .brand, label: Text("Loading invoices"))
}
```

- **Size**: `sm` 14, `md` 16 (default), `lg` 20 or `xl` 24 points.
- **Tone**: `neutral` (default), the surrounding foreground colour as the web's `currentColor`; or
  `brand`, `color.icon.brand`.

Inside a button use ``QeetrixButton``'s `isLoading` instead, which puts the spinner in its icon zone and
reports the busy state on the button itself.

### Accessibility

- VoiceOver reads its label — "Loading" unless you give one. Name what is loading when the screen has
  more than one spinner. `isDecorative` hides it where something else reports the wait.
- Under Reduce Motion it stops turning, closes the ring and pulses its opacity every 1.6 seconds, so the
  wait stays visible.

### Platform differences

None in the look.

On the web: [Spinner on ui.qeet.in](https://ui.qeet.in/components/spinner/).

## Topics

### Styling

- ``QeetrixSpinnerSize``
- ``QeetrixSpinnerTone``
