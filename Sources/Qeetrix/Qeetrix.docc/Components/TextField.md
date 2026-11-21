# ``Qeetrix/QeetrixTextField``

## Overview

A single-line text field with its label, help text and error — `@qeetrix/react`'s TextField, a Field
around an Input, the default way to build a form row.

```swift
QeetrixTextField(
    "Work email", text: $email,
    prompt: Text("e.g. priya@acme.in"),
    description: Text("We send sign-in links here."),
    error: emailError,
    isRequired: true
)
.keyboardType(.emailAddress)
.textContentType(.emailAddress)
QeetrixTextField("Amount", text: $amount, startAdornment: Text("₹"))
QeetrixTextField("Search", text: $query, icon: .search, isLabelHidden: true)
```

- **The box** (design rules §8): filled with `color.bg.neutral.subtle` (`-hover` under a pointer), a
  1-point `color.border.strong` bottom line, 4-point top corners and a square bottom,
  `size.control.lg` tall, 12 points of inline padding.
- **Text**: the value in `body.md`, `color.text.default`; the prompt in `color.text.subtlest` — an
  example ("e.g. Acme Pvt Ltd"), never an instruction or the label.
- **Adornments**: an optional leading `icon` (sharp, 16 points, `color.icon.subtle`) and text affixes —
  `startAdornment` and `endAdornment`, such as ₹ or ".qeet.in" — in `color.text.subtle`, 8 points from
  the text.
- **States.** Focus: a 2-point Ember frame drawn inside the box replaces the bottom line. Invalid (an
  `error`): a 2-point danger frame. Read-only: no fill, the editable `color.border.strong` line,
  the value selectable. Disabled (`.disabled(true)`): `color.bg.disabled`, a `color.border.disabled` line,
  `color.text.disabled`.

Keyboard type, content type, autocapitalisation, submit label and `onSubmit` apply as they do to any
`TextField`.

### A large field

A sign-up or verification step that asks for one value — a phone number, a name, a date of birth —
uses the large field, `size: .lg`, as `@qeetrix/react`'s Input `size="lg"`:

```swift
QeetrixTextField("Phone number", text: $number, prompt: Text("10-digit mobile number"), startAdornment: Text("+91"), size: .lg)
    .keyboardType(.phonePad)
```

It is 16 points taller than the default (`size.control.lg` + 16: 56 points at the default density, 48
compact, 60 comfortable), as tall as ``QeetrixOTPInput`` at `lg`. The value and its affixes are at
`title.lg`'s size, 20 points, in regular weight with the body letter style and tabular figures; the
prompt stays `body.md`. The box, label, description, error, icon, focus and invalid frames, read-only
and disabled are those of the default size, and it scales with Dynamic Type the same way.

Use it only for that step's one field. A sign-in email or password is the default size, with an `lg`
``QeetrixButton``.

### Accessibility

- VoiceOver reads the field by its label — with "Required" for a required field — its value, its
  description as the hint, and its error with it.
- A tap on the padding, or just outside a short field, focuses it: the target is at least 44 points.

### Platform differences

- **Height.** At the default text size the field is the web's height; larger text scales it in
  proportion.
- **Focus frame.** The web frames a focused field for any focus, as here.
- **Clear and copy tools.** The web's `endAdornment` can hold a control (an IconButton); on iOS the
  adornments are text.

On the web: [Text field on ui.qeet.in](https://ui.qeet.in/components/text-field/).
