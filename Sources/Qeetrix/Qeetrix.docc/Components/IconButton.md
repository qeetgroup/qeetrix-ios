# ``Qeetrix/QeetrixIconButton``

## Overview

A square button holding one icon. The label is required: it is what VoiceOver reads, and it is never
shown.

```swift
HStack {
    QeetrixIconButton(.x, label: "Close") { dismiss() }
    QeetrixIconButton(.bell, label: "Notifications", variant: .outline, size: .sm) { openInbox() }
}
```

It takes the ``QeetrixButtonVariant`` and ``QeetrixButtonSize`` of ``QeetrixButton``, with `ghost` as
the default variant. The squares are 24, 28 pt, the density's height and 36 pt; the icon is 12 pt at
`xs` and 16 pt otherwise. While loading, the spinner takes the icon's place in the same square, so a
toolbar never reflows.

### Accessibility

- The label names the button; write it as the action ("Close", not "X").
- A 44 × 44 pt touch target at every size.
- A loading icon button reports "Loading" as its value.

### Platform adaptations

The same as ``QeetrixButton``: the 44 pt hit area, hover under a pointer, and the system's focus
indicator.

On the web: [Icon Button on ui.qeet.in](https://ui.qeet.in/docs/components/icon-button).
