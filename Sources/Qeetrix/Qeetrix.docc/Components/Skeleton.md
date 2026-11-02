# ``Qeetrix/QeetrixSkeleton``

## Overview

A placeholder shaped like the content that is loading, as `@qeetrix/react`'s Skeleton — the account
list and the approvals while they load.

```swift
VStack(alignment: .leading, spacing: QeetrixSpace.gapLg) {
    ForEach(0..<3, id: \.self) { _ in
        HStack(spacing: QeetrixSpace.gapMd) {
            QeetrixSkeleton(.circle, size: .lg)
            QeetrixSkeleton(lines: 2)
        }
    }
}
.qeetrixSkeletonGroup(label: Text("Loading accounts"))
```

- **Variant**: `text` (the default), a line of `body.md` — 20 points tall — with 2-point corners;
  `block`, a card, image or chart, 64 points tall with `radius.surface` corners; `circle`, an avatar,
  of ``QeetrixSkeletonSize`` — the avatar's 24, 32, 40 and 48 points.
- **Lines**: ``QeetrixSkeleton/init(lines:role:)`` draws a paragraph: bars as tall as the role's text
  and centred in its lines, the last of several 60% wide. It takes the lines' height exactly, so the
  text that replaces it moves nothing below.
- **Size**: `text` and `block` take the width they are offered — narrow them with `frame(width:)` —
  and `height` replaces their default height.
- **Look**: `color.bg.neutral.subtle-pressed`, its opacity pulsing to 45% and back, 1.6 seconds each
  way (4 × `motion.duration.slower`, `motion.easing.standard`).

### Accessibility

- A skeleton is hidden from VoiceOver. Put `qeetrixSkeletonGroup(label:)` on the view that holds the
  skeletons: VoiceOver then finds one element there, "Loading" (or your label), instead of nothing or
  every placeholder — as the web marks the region `aria-busy` and announces the wait.
- Under Reduce Motion the pulse stops and the skeleton stands still at full opacity.
- Lines grow with Dynamic Type, as the text they stand in for will; in right-to-left layouts the short
  last line starts at the right.

### Platform differences

The system's `redacted(reason: .placeholder)` draws the real views' text as bars in its colour. It
isn't used: it doesn't take Qeetrix's tint or pulse, and VoiceOver still reads the placeholder text.

On the web: [Skeleton on ui.qeet.in](https://ui.qeet.in/components/skeleton/).

## Topics

### Shapes

- ``QeetrixSkeletonVariant``
- ``QeetrixSkeletonSize``
