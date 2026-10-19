# ``Qeetrix/QeetrixBadge``

## Overview

A small label for a count, a status or a category.

```swift
HStack {
    QeetrixBadge("New")
    QeetrixBadge("Beta", variant: .brand)
    QeetrixBadge("Paid", variant: .success, icon: .circleCheck)
}
```

- `default` is the one solid Qeet fill. It is the loudest thing a badge can be: use it sparingly.
- `brand`, `info`, `success`, `warning` and `destructive` are quiet tints with a hairline from the
  badge's own tokens, so the shape holds on a white card.
- `secondary`, `outline` and `muted` are graphite, for metadata that should not compete.

### Accessibility

VoiceOver reads a badge as one piece of text. Its icon is decorative, so the text alone must say what
the badge means.

### Platform adaptations

A badge stays on one line, as on the web. At the largest text sizes, where a long badge cannot fit the
screen, it truncates instead of running off it — keep badge text short.

On the web: [Badge on ui.qeet.in](https://ui.qeet.in/docs/components/badge).

## Topics

### Variants

- ``QeetrixBadgeVariant``
