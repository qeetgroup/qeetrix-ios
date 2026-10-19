# ``Qeetrix/QeetrixButton``

## Overview

The Qeet action control. Use one `default` (primary) button per screen; the other variants are
quieter.

```swift
VStack(alignment: .leading) {
    QeetrixButton("Save changes", isLoading: isSaving, loadingLabel: "Saving") { save() }
    QeetrixButton("Search", leadingIcon: .search, variant: .outline) { search() }
    QeetrixButton("Delete", variant: .destructive, size: .sm) { delete() }
}
```

- **Variants.** `default` (the Qeet-orange primary), `outline`, `secondary`, `ghost`, `destructive`
  (quiet at rest, solid on press) and `link`.
- **Sizes.** `xs` 24 pt, `sm` 28 pt, `default` the density's control height (28, 32 or 36 pt) and
  `lg` 36 pt.
- **States.** Pressed walks one step along the variant's colours and settles its shadow. Disabled
  fades — except the primary button, which turns neutral, since an unavailable action carries no brand
  emphasis. Loading keeps the colours, shows a spinner in the leading slot and ignores taps.

### Any control, the Qeetrix style

``QeetrixButtonStyle`` gives the same treatment to any SwiftUI control that takes a button style:

```swift
NavigationLink("Billing", value: Route.billing)
    .buttonStyle(.qeetrix(.outline, size: .sm))
```

### Accessibility

- Every button is a 44 × 44 pt touch target, however short it is drawn.
- A loading button reports "Loading" as its value, or reads its loading label as its name.
- Labels scale with Dynamic Type and wrap rather than truncate.

### Platform adaptations

- **Touch target.** The web's 24–36 pt heights are pointer-sized. The drawn size is kept, and the hit
  area extends to 44 pt without moving layout, as the web Switch does with its pointer target.
- **Height.** The web height is fixed; here it is a minimum, so larger text grows the button.
- **Hover.** Under an iPad pointer, buttons take their hover colours as on the web; on touch a press
  shows the pressed colours, and a link underlines.
- **Focus.** iOS draws its own focus indicator for Full Keyboard Access, so the web's focus ring is
  not repeated.
- **Busy.** The web marks a loading button `aria-busy`. VoiceOver has no busy trait, so the button's
  value says "Loading".

On the web: [Button on ui.qeet.in](https://ui.qeet.in/docs/components/button).

## Topics

### Styling

- ``QeetrixButtonVariant``
- ``QeetrixButtonSize``
- ``QeetrixButtonStyle``

### Related

- ``QeetrixIconButton``
