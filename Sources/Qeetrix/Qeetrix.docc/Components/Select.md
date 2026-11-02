# ``Qeetrix/QeetrixSelect``

## Overview

Pick one option from a short list, up to about 15, with its label, help text and error —
`@qeetrix/react`'s Select in a Field.

```swift
QeetrixSelect("Country", selection: $country, options: countries, placeholder: Text("Choose a country"))
```

- **The trigger** looks like a field (design rules §8): the filled box with its bottom line, the value
  in `body.md` or the placeholder in `color.text.subtlest`, and a trailing 16-point sharp chevron in
  `color.icon.default`.
- **Size**: `lg` (default) is the field height; `md` and `sm` give a toolbar's height beside buttons of
  the same size, `sm` with `body.sm`.
- **States**: the field's invalid, read-only and disabled looks.

### Accessibility

VoiceOver reads the trigger as a pop-up button named by the label, with the chosen option as its value.

### Platform differences

The list is the system menu (ADR 0012): its surface, font and highlight are the system's, the chosen
option carries the system checkmark, and disabled options are dimmed. The web's popup — a menu surface
with an Ember check and a 2-point Ember edge on the highlighted option — and multiple selection have no
iOS counterpart.

On the web: [Select on ui.qeet.in](https://ui.qeet.in/components/select/).

## Topics

### Options

- ``QeetrixOption``
