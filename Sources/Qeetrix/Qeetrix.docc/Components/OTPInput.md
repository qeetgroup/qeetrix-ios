# ``Qeetrix/QeetrixOTPInput``

## Overview

A one-time code — from a text message, an email or an authenticator app — drawn as a row of cells.

```swift
QeetrixOTPInput("Verification code", code: $code, groupSize: 3) { completed in
    verify(completed)
}
```

One native text field holds the code; the cells only draw it. So the system's one-time-code AutoFill
(from Messages and Mail), paste, the edit menu and VoiceOver all work on the code as one value — there are
no separate per-cell fields to break them.

- **Length and characters.** Six digits by default, as on the web. `length` sets another count;
  `characters: .alphanumeric` accepts letters as well, for services that send them. Characters outside
  the set are dropped, digits from other scripts are entered as 0–9, and leading zeros are kept — the
  code is a `String`.
- **Paste.** A whole code pasted or autofilled into a part-filled field replaces it; nothing past
  `length` is accepted.
- **Completion.** `onComplete` runs once each time the code becomes complete. Nothing is submitted
  automatically: call your own submit from it if you want that.
- **Clearing.** Set the binding to `""`.
- **Groups.** `groupSize: 3` shows a six-digit code as 123 – 456; the divider is decorative.

### Accessibility

VoiceOver reads one text field, named by the label — "One-time code" without one — with the code as its
value, not a row of cells. With a message, the cells' boundaries take its colour and the message is
attached to the field.

### Platform differences

- A code reads left to right in every script, so the cells keep that order in right-to-left layouts, as
  on the web.
- The web code is digits only; `.alphanumeric` is an iOS addition.
- The web moves focus from cell to cell; on iOS the single field has one caret, and the active cell is
  drawn with the focus boundary.

Generating, checking and storing codes are the app's. The component never logs or describes the code.

On the web: [OTP Input on ui.qeet.in](https://ui.qeet.in/docs/components/otp-input).

## Topics

### Characters

- ``QeetrixOTPCharacters``
