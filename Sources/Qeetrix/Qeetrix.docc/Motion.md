# Motion

Animate with the Qeetrix durations, curves and springs, and stop when the user asks for less motion.

## Overview

Qeetrix motion is productive: quick, never decorative, never bouncing or scaling (design rules §18).
``QeetrixDuration`` gives the durations — nothing runs longer than 400 ms:

- ``QeetrixDuration/instant``: 0 ms
- ``QeetrixDuration/fast``: 100 ms — hover, press and colour changes
- ``QeetrixDuration/normal``: 200 ms — a switch thumb, the tab bar, menus and popovers coming in
- ``QeetrixDuration/slow``: 300 ms — dialogs and drawers coming in
- ``QeetrixDuration/slower``: 400 ms

``QeetrixEasing`` gives the curves: ``QeetrixEasing/standard`` for changes in place,
``QeetrixEasing/enter`` for anything arriving, ``QeetrixEasing/exit`` for anything leaving — one step
faster than it came in — ``QeetrixEasing/emphasized`` and ``QeetrixEasing/linear``.

Animate a change with `.qeetrixAnimation(_:_:value:)`:

```swift
DisclosurePanel(isExpanded: isExpanded)
    .qeetrixAnimation(.standard, .normal, value: isExpanded)
```

``QeetrixSpring`` gives the springs for native-style motion — ``QeetrixSpring/snappy`` and
``QeetrixSpring/gentle``, stiffness and damping ratio with a mass of 1 — as SwiftUI animations through
``QeetrixSpring/animation``.

## Reduce Motion

Under Reduce Motion the web sets every duration to ``QeetrixMotion/reducedDuration`` — 0 ms, from
`tokens.css`'s `prefers-reduced-motion` block — so changes happen without animation.
`.qeetrixAnimation(_:_:value:)` does the same on iOS. Waits stay visible: a spinner and an
indeterminate progress bar fade in place instead of moving.

For `withAnimation` and other APIs that take an `Animation`, ask
``QeetrixMotion/animation(_:_:reduceMotion:)``, or ``QeetrixMotion/animation(_:reduceMotion:)`` for a
spring. Each returns `nil` when the change should happen without animation:

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

withAnimation(QeetrixMotion.animation(.enter, .normal, reduceMotion: reduceMotion)) {
    isPresented = true
}
```
