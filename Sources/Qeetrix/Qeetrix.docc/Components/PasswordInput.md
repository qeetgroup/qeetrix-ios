# ``Qeetrix/QeetrixPasswordInput``

## Overview

A password or secret with its label, help text and error, and a Show password toggle at its end —
`@qeetrix/react`'s PasswordInput in a Field.

```swift
QeetrixPasswordInput("Password", text: $password, isRequired: true)
    .submitLabel(.go)
    .onSubmit(signIn)
QeetrixPasswordInput("Client secret", text: $secret, autoComplete: .off)
```

- **The box** is the Qeetrix field, with the toggle — a neutral `sm` ``QeetrixIconButton``, eye ↔
  eye-off — 4 points from its end.
- **Hidden by default**: people may not be alone. Pass `isVisible` to own the state.
- **AutoFill**: `autoComplete` is `currentPassword` (default, to sign in), `newPassword` (to create
  one) or `off` (a secret that isn't the user's password, such as an API key).
- Spelling, capitals and correction are off. Paste and password managers work, and there is no length
  cap (WCAG 3.3.8).

### Accessibility

- The toggle is named "Show password" and read as selected while the password shows; using it announces
  "Password shown" or "Password hidden". The keyboard stays with the field.
- The field is marked privacy-sensitive.

### Platform differences

- **Caps Lock.** The web warns "Caps Lock is on" while typing; iOS has no reliable way to read Caps Lock
  from a text field, so there is no warning.
- **Hide on submit.** The web hides the password again when its form is submitted; on iOS a form is
  yours, so set `isVisible` to `false` when you submit.

On the web: [Password input on ui.qeet.in](https://ui.qeet.in/components/password-input/).

## Topics

### Options

- ``QeetrixPasswordAutoComplete``
