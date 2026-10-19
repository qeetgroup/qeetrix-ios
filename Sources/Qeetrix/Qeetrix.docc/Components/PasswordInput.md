# ``Qeetrix/QeetrixPasswordInput``

## Overview

A password field with a reveal toggle, built on the system's `SecureField`.

```swift
QeetrixPasswordInput("Password", text: $password, purpose: .current, isRequired: true)
    .submitLabel(.go)
    .onSubmit(signIn)
```

Use `purpose: .current` to sign in and `.new` to sign up or reset a password. For a numeric PIN or a
code sent to the person, use ``QeetrixOTPInput``.

### Secure entry and AutoFill

- It is a native `SecureField`, so the system's secure entry applies: the text is masked, cannot be
  copied, and is hidden from screen recordings.
- `purpose` sets the content type Password AutoFill reads: the saved password to sign in, a strong
  suggested password and the offer to save it when creating one. AutoFill is never switched off.
- Autocapitalisation and autocorrection are off, so a password is never sent to a spelling service.
- The component keeps no copy of the password: it lives in your binding only. It never logs, stores or
  describes it. Strength meters and password rules are the app's.

### The reveal toggle

The toggle after the field shows the password as plain text and hides it again. It is named for what it
will do — "Show password", "Hide password" — and keeps the keyboard and the text where they were. It is
disabled with the field; `showsToggle: false` leaves it out.

### Accessibility

VoiceOver reads a secure text field named by the label, and never its contents; revealed, it reads a
plain text field, as the person chose. The toggle is a 44 pt target.

### Platform differences

The web re-masks a revealed password when its form submits, to keep it out of browser form history. iOS
has no form history, so the password stays as the person left it.

On the web: [Password Input on ui.qeet.in](https://ui.qeet.in/docs/components/password-input).

## Topics

### Purpose

- ``QeetrixPasswordPurpose``
