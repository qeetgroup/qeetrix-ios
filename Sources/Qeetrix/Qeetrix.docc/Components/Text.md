# ``Qeetrix/QeetrixText``

## Overview

Use `QeetrixText` for discrete pieces of copy — titles, section headings, paragraphs, captions —
in the variants of the web's Typography component.

```swift
VStack(alignment: .leading, spacing: QeetrixSpacing.s) {
    QeetrixText("Security", variant: .h2)
    QeetrixText("Sign in with a passkey on every device you trust.", variant: .lead)
    QeetrixText("Last used 2 days ago", variant: .muted)
}
```

Each variant sets the family, size, weight, letter style, line height and colour. Headings are
semibold in the heading letter style; copy is in the body role; `small` is the label role;
`inlineCode` is Fira Code on a sunken chip.

### Accessibility

- h1–h4 are VoiceOver headings, at their level, so the rotor can move between them.
- Every variant scales with Dynamic Type and steps one weight heavier with Bold Text.
- Text wraps rather than truncates. Use `lineLimit(_:)` to clip it, as on any text, and give the
  full value another way when it matters.

### Platform adaptations

- **Breakpoint.** The web sets h1–h3 one step larger from its `sm` breakpoint (640 px). Here that
  breakpoint is the regular horizontal size class, so an iPhone gets the web's mobile sizes and an iPad
  the larger ones.
- **No `as` or `list`.** The web chooses the HTML element with `as` and renders bullet lists. On iOS
  the heading level comes from the variant, and a list is a layout of `QeetrixText` rows.
- **Colour.** The web's `p` inherits the page's text colour; here it sets the primary text colour, so
  a `QeetrixText` looks the same wherever it is placed.

On the web: [Typography on ui.qeet.in](https://ui.qeet.in/docs/components/typography).

## Topics

### Variants

- ``QeetrixTextVariant``
