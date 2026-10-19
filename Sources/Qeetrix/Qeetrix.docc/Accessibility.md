# Accessibility

What Qeetrix does for accessibility automatically, and what your views still need to do.

## Overview

Qeetrix foundations follow WCAG 2.2 AA and Apple's platform conventions.

| Need | Qeetrix provides |
|:--|:--|
| Contrast | Semantic colour pairs meet 4.5:1 for text and 3:1 for boundaries, in both themes |
| Text size | Typography roles scale with Dynamic Type to the accessibility sizes |
| Bold Text | Roles draw one weight heavier |
| Reduce Motion | `.qeetrixAnimation(_:_:value:)` and ``QeetrixMotion/animation(_:_:reduceMotion:)`` stop animating |
| VoiceOver | Icons are hidden unless labelled; elevation backgrounds are hidden |
| Right-to-left | Directional icons mirror |

## Touch targets

Anything tappable needs a hit area of at least 44 × 44 points
(``QeetrixAccessibility/minimumTouchTarget``), even when it is drawn smaller. For example, controls
drawn at ``QeetrixDensity`` heights are 28–36 points. `.qeetrixMinimumTouchTarget()` enlarges the hit
area without changing the drawing:

```swift
Button(action: dismiss) {
    QeetrixIcon(.x, label: Text("Close"))
}
.qeetrixMinimumTouchTarget()
```

## Checking contrast

``QeetrixAccessibility/contrastRatio(_:on:)`` measures two resolved colours the way WCAG defines it,
compositing a translucent foreground first. Qeetrix's own tests use it to re-check the web's contrast
pairs on iOS.

## Your views

- Pair colours by role (`text*` on `surface*`) rather than mixing arbitrary tokens.
- Let text wrap at large sizes. Switch rows to stacks when they don't fit; `ViewThatFits` helps.
- Label meaningful icons and image-only buttons.
- Use leading and trailing, never left and right.
