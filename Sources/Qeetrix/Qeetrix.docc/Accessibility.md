# Accessibility

What Qeetrix does for accessibility automatically, and what your views still need to do.

## Overview

Qeetrix follows WCAG 2.2 AA, the accessibility guarantees of `@qeetrix/react` (design rules §20) and
Apple's platform conventions.

| Need | Qeetrix provides |
|:--|:--|
| Contrast | The colour pairs the tokens are designed for meet 4.5:1 for text and 3:1 for icons, field lines, control borders and the focus frame, in both schemes |
| Text size | Typography roles scale with Dynamic Type to the accessibility sizes |
| Bold Text | Roles draw one weight heavier |
| Reduce Motion | `.qeetrixAnimation(_:_:value:)` and ``QeetrixMotion/animation(_:_:reduceMotion:)`` stop animating; spinners and progress bars fade instead of moving |
| Keyboard focus | The 2-point Ember focus frame, never removed |
| No colour alone | Status always has a word or an icon: badges carry text, toasts and errors their own icon per tone |
| VoiceOver | Components carry their names, values, states and hints; decorative icons and shadows are hidden |
| Right-to-left | Layouts use leading and trailing; directional icons mirror |

## Touch targets

Anything tappable needs a hit area of at least 44 × 44 points
(``QeetrixAccessibility/minimumTouchTarget``), even when it is drawn smaller. Qeetrix components keep
the web's drawn sizes — controls are 24–44 points tall, depending on size and density — and extend
their hit area to 44 points without moving layout; checkbox, radio and switch rows are 44 points tall.
`.qeetrixMinimumTouchTarget()` does the same for your own views:

```swift
Button(action: dismiss) {
    QeetrixIcon(.x, label: Text("Close"))
}
.qeetrixMinimumTouchTarget()
```

## Checking contrast

``QeetrixAccessibility/contrastRatio(_:on:)`` measures two resolved colours the way WCAG defines it,
compositing a translucent foreground first. Qeetrix's own tests use it to re-check `@qeetrix/tokens`'
contrast pairs on the converted iOS values.

## Your views

- Pair colours by role (`text*` on `surface*` and `bg*`) rather than mixing arbitrary tokens. `textDisabled`
  is only for text inside a disabled control; quieter text that must still be read is `textSubtle`.
- Let text wrap at large sizes. Switch rows to stacks when they don't fit; `ViewThatFits` helps.
- Label meaningful icons and icon-only buttons.
- Use leading and trailing, never left and right.
