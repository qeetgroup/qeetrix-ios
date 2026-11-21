# ``Qeetrix/QeetrixRadioGroup``

## Overview

Pick one of a set — `@qeetrix/react`'s RadioGroup: the question as the legend, then a radio per option
(design rules §9).

```swift
QeetrixRadioGroup(
    "Billing cycle", selection: $cycle,
    options: [
        QeetrixOption("Monthly", value: Plan.monthly),
        QeetrixOption("Yearly", value: Plan.yearly, description: Text("Two months free")),
    ])
QeetrixRadioGroup(
    "Billing cycle", selection: $cycle,
    options: [QeetrixOption("Monthly", value: Plan.monthly), QeetrixOption("Yearly", value: Plan.yearly)],
    orientation: .horizontal)
```

- **Legend** in the field-label style, so every form row's label looks the same; the description or
  error under the options, as for a field.
- **Radio**: a 16-point circle with a 1-point `color.border.strong` edge on `color.bg.input`; selected,
  the edge becomes a 5-point Ember ring around the centre.
- **Orientation**: `vertical` (default) or `horizontal` for short options, 16 points apart, wrapping.
- **Icon**: an option with an `icon` draws it before the title, 16 points in `color.icon.subtle`.
- **States**: with an error every radio takes the danger edge, and the chosen one a danger ring; a
  disabled option is dimmed.

### Tiles

`variant: .tile` draws each option as a box, for choices that need explaining — field.css
`[data-variant="tile"]`, as `@qeetrix/react`'s `<RadioGroup variant="tile">`:

```swift
QeetrixRadioGroup(
    "Who can see your photo", selection: $photo,
    options: [
        QeetrixOption("Everyone", value: Audience.everyone, description: Text("Anyone with your number"), icon: .users),
        QeetrixOption("My contacts", value: Audience.contacts, icon: .contactRound),
    ],
    variant: .tile)
QeetrixRadioGroup("Language", selection: $language, options: languages, variant: .tile, columns: 2)
```

- **Box**: 12 points in (`space.inset.md`) on `color.surface.default`, with a 1-point
  `color.border.subtle` edge inside it and `radius.control` corners. Chosen, `color.bg.selected` with a
  2-point `color.border.brand` edge. Under a pointer or a held touch, `color.bg.neutral.subtle`, never
  over the chosen fill. Disabled, `color.bg.disabled` with the disabled edge.
- **Inside**, 12 points apart: the icon, 20 points in a 36-point `color.bg.neutral.subtle` box (white
  with a brand icon once chosen); the title in `body.md` at `title.sm`'s weight, the description in
  `body.sm` under it; and the radio at the end, on the title's first line. A tile with an icon is at
  least 60 points tall, and every tile at least 44.
- **Columns**: up to `columns` equal columns share the width, 8 points apart (`space.gap.sm`), and the
  rows are 8 points apart; every tile in a row is as tall as the tallest. One column by default. Where a
  tile would be narrower than 128 points — 192 once any option has an icon or a description, the web's
  8rem and 12rem — there are fewer columns, as many as fit.
- The title is any `Text`, such as a language in its own script.

### Accessibility

VoiceOver reads each option as a button that is selected or not, with its description as the hint, and
the group's error with each — a row and a tile alike. Choosing another tile plays the selection
feedback, as a row does.

### Platform differences

- **Rows** are 44-point targets, flush (ADR 0012); the web's are 24 points, 4 apart.
- **Keyboard.** The web moves the selection with the arrow keys; iOS moves focus between the options.

On the web: [Radio on ui.qeet.in](https://ui.qeet.in/components/radio/).

## Topics

### Options

- ``QeetrixOption``
- ``QeetrixChoiceOrientation``
- ``QeetrixChoiceVariant``
