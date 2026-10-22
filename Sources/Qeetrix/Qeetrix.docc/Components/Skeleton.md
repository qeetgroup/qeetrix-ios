# ``Qeetrix/QeetrixSkeleton``

## Overview

Placeholders in the shape of content that is loading.

```swift
HStack(spacing: 12) {
    QeetrixSkeleton(.circle).frame(width: 40, height: 40)
    QeetrixSkeletonText(lines: 2, role: .label)
}
.accessibilityElement(children: .ignore)
.accessibilityLabel(Text("Loading members"))
```

- **Shapes.** `rectangle` (the control corner), `circle` and `capsule`; size them with `frame`.
- **Text.** ``QeetrixSkeletonText`` draws lines the height of a typography role's text, the last one
  shorter, growing with Dynamic Type.
- **Colour.** A translucent tint of the foreground, the same weight on every surface in both themes.
- **Motion.** A highlight sweeps across every 1.6 s; with Reduce Motion on it stands still.

### Accessibility

Placeholders are hidden from VoiceOver. Label the region they fill as loading — as above, or with
``QeetrixDataState``, which does it for you — so VoiceOver finds one "Loading" element rather than none.

### Performance

Each placeholder animates its own sweep. A screen of placeholders is cheap; for a long list, show a
screenful of skeleton rows rather than one per expected item.

On the web: [Skeleton on ui.qeet.in](https://ui.qeet.in/docs/components/skeleton).

## Topics

### Shapes

- ``QeetrixSkeletonShape``
- ``QeetrixSkeletonText``
