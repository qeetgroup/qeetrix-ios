# ``Qeetrix/QeetrixSeparator``

## Overview

A 1-point line between groups of content — `@qeetrix/react`'s Separator.

```swift
VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) {
    QeetrixHeading("Profile", level: 3)
    QeetrixSeparator()
    QeetrixText("Your name and photo are visible to your team.")
}
```

- **Orientation**: horizontal (default), or vertical, which stretches to its row.
- **Tone**: `subtle` (`color.border.subtle`, default), `default` or `strong`.
- `border.width.default` thick.

### Accessibility

Decorative by default — hidden from VoiceOver, the web's `decorative` — since spacing and headings
already group the content. Pass `isDecorative: false` where the boundary itself carries meaning.

### Platform differences

None in the look. A vertical separator — `QeetrixSeparator(.vertical)` — needs its row to have a
height, so give an `HStack` a fixed vertical size.

On the web: [Separator on ui.qeet.in](https://ui.qeet.in/components/separator/).

## Topics

### Styling

- ``QeetrixSeparatorTone``
