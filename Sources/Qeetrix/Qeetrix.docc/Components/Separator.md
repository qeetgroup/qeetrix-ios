# ``Qeetrix/QeetrixSeparator``

## Overview

A 1 pt rule between groups of content. `default` divides sections, groups and toolbars; `muted` divides
items inside a section, such as rows of a list.

```swift
VStack(alignment: .leading, spacing: QeetrixSpacing.m) {
    QeetrixText("Profile", variant: .h3)
    QeetrixSeparator()
    QeetrixText("Your name and photo are visible to your team.")
}
```

A vertical separator fills the height its container proposes; inside an `HStack`, give the stack a
height or let its content set one.

### Accessibility

A separator never carries meaning on its own: grouping comes from spacing and headings. Both variants
are below 3:1 by design.

### Platform adaptations

The web separator has `role="separator"`. VoiceOver has no separator trait, so the rule is hidden from
VoiceOver, like the system's own list separators.

On the web: [Separator on ui.qeet.in](https://ui.qeet.in/docs/components/separator).

## Topics

### Variants

- ``QeetrixSeparatorVariant``
