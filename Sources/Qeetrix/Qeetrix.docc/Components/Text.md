# ``Qeetrix/QeetrixText``

## Overview

Running text, labels and inline code, on the body typography roles — `@qeetrix/react`'s Text.

```swift
VStack(alignment: .leading, spacing: QeetrixSpace.gapSm) {
    QeetrixHeading("Security", level: 2)
    QeetrixText("Sign in with a passkey on every device you trust.", size: .lg, tone: .subtle)
    QeetrixText("Last used 2 days ago", size: .sm, tone: .subtle)
    QeetrixText("INV-2026-0042", mono: true)
}
```

- **Size**: `sm` (`body.sm`, 12/16), `md` (`body.md`, 14/20, default) or `lg` (`body.lg`, 16/24).
- **Weight**: `regular` (400, default), `medium` (500) or `semibold` (600).
- **Tone**: a text colour from ``QeetrixTextTone``; `nil` keeps the surrounding colour. `disabled` is
  only for text inside an inactive control; quieter text that must still be read is `subtle`.
- **Mono**: Fira Code at the same size, for code, IDs and keys.
- **Truncate**: a number of lines, ending with an ellipsis; without it, text wraps freely.
- **Align**: `start`, `center` or `end`, following the layout direction.

Qeet Sans in its A11y letter style (`font.geometry.body`). For section titles use ``QeetrixHeading``.

### Accessibility

Text scales with Dynamic Type along the body roles' curves and draws one weight heavier under Bold
Text. VoiceOver reads it as static text.

### Platform differences

The web's Text renders any element (`render`); on iOS it is a view around SwiftUI `Text`, so it composes
with `Text` modifiers rather than taking an element.

On the web: [Text on ui.qeet.in](https://ui.qeet.in/components/text/).

## Topics

### Styling

- ``QeetrixTextSize``
- ``QeetrixTextWeight``
- ``QeetrixTextTone``
- ``QeetrixTextAlign``
