# Motion

Animate with the Qeetrix durations and curves, and stop when the user asks for less motion.

## Overview

``QeetrixDuration`` gives the motion durations:

- ``QeetrixDuration/instant``: 0 ms
- ``QeetrixDuration/fast``: 150 ms
- ``QeetrixDuration/normal``: 200 ms
- ``QeetrixDuration/slow``: 300 ms
- ``QeetrixDuration/deliberate``: 400 ms

``QeetrixEasing`` gives the curves: `standard`, `emphasized`, `enter`, `exit` and `linear`.

Animate a change with `.qeetrixAnimation(_:_:value:)`:

```swift
DisclosurePanel(isExpanded: isExpanded)
    .qeetrixAnimation(.standard, .normal, value: isExpanded)
```

## Reduce Motion

With Reduce Motion on, the web switches every animation to its reduced tokens, which mean no
animation. `.qeetrixAnimation(_:_:value:)` does the same on iOS.

For `withAnimation` and other APIs that take an `Animation`, ask
``QeetrixMotion/animation(_:_:reduceMotion:)``. It returns `nil` when the change should happen without
animation:

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

withAnimation(QeetrixMotion.animation(.enter, .fast, reduceMotion: reduceMotion)) {
    isPresented = true
}
```
