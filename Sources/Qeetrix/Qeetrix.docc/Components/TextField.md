# ``Qeetrix/QeetrixTextField``

## Overview

A labelled single-line field — the web's `Field` with an `Input` — with an optional description and an
optional error, warning or success message.

```swift
QeetrixTextField(
    "Work email", text: $email,
    prompt: Text("name@company.com"),
    description: Text("We send sign-in links here."),
    message: emailError.map { QeetrixFieldMessage(.error, text: $0) },
    isRequired: true
)
.keyboardType(.emailAddress)
.textContentType(.emailAddress)
```

- **States.** The boundary steps up under a pointer, turns to the focus ring with a 1 pt outline when
  focused, and takes the message's tone. An error keeps its colour when focused.
- **Read-only.** `isReadOnly` shows the value with a dashed boundary, selectable but not editable.
- **Disabled.** `disabled(_:)` shows the sunken surface and fades the field.
- **Height.** The density's control height, as a minimum, so larger text grows the field.

Keyboard type, content type, autocapitalisation, submit label and `onSubmit` apply as they do to any
`TextField`.

### Accessibility

- VoiceOver reads the field by its label — with "Required" for a required field — and its value.
- The description and the message follow as text, in reading order, so they never depend on VoiceOver's
  hints setting.
- When a message appears or changes, VoiceOver announces it.
- A tap on the padding, or just outside a short field, focuses it: the target is at least 44 pt.

### Platform adaptations

- **Text size.** The web uses 16 px text below its `md` breakpoint so iOS Safari does not zoom on
  focus, and 14 px above it. A native field never zooms, but its text stays at 16 pt, the size the web
  shows on a phone.
- **Required.** The web announces the native `required` attribute; here "Required" is part of the
  field's label, because a hint can be switched off.
- **Announcements.** The web's error is a `role="alert"` region and its warning and success are
  `role="status"`. Here each new message is posted as a VoiceOver announcement.

On the web: [Input on ui.qeet.in](https://ui.qeet.in/docs/components/input).

## Topics

### Messages

- ``QeetrixFieldMessage``
