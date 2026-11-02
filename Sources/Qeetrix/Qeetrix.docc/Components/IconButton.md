# ``Qeetrix/QeetrixIconButton``

## Overview

A square, icon-only button — `@qeetrix/react`'s IconButton. Its accessible label is required.

```swift
HStack {
    QeetrixIconButton(.x, label: "Close", tone: .neutral, size: .sm) { dismiss() }
    QeetrixIconButton(.share2, label: "Share", variant: .soft) { share() }
}
```

- **Variant** `ghost` by default, with the same ``QeetrixButtonVariant``s and ``QeetrixButtonTone``s
  as ``QeetrixButton``. Use `tone: .neutral` for utility icons in toolbars and headers, whose icons stay
  neutral (design rules §16).
- **Size**: a square as tall as the control height of its ``QeetrixControlSize``, with a 16-point sharp
  icon (20 at `lg`).
- **States** as ``QeetrixButton``: hover and press tints, disabled, a spinner in place of the icon while
  loading, the Ember focus frame inside the edge.

### Accessibility

- VoiceOver reads the label; the type makes it mandatory.
- With a pointer (iPad), the label shows as a tooltip, as on the web; `tooltip` replaces the text shown.
- A 44 × 44-point touch target, however small it is drawn.

### Platform differences

The icon scales with Dynamic Type, and the button's square with it; at the default size it is the
web's.

The web's tooltip opens on `tooltipSide`; iOS shows `.help(_:)` text where the system places it, and
only with a pointer. On touch there is no tooltip, so the label must be clear from context.

On the web: [Icon button on ui.qeet.in](https://ui.qeet.in/components/icon-button/).
