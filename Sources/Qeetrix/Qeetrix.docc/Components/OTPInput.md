# ``Qeetrix/QeetrixOTPInput``

## Overview

A one-time code, one slot per character — `@qeetrix/react`'s OTPInput.

```swift
QeetrixOTPInput("Verification code", code: $code, size: .lg) { completed in
    verify(completed)
}
QeetrixOTPInput("Recovery code", code: $recovery, length: 10, groups: [5, 5], validationType: .alphanumeric)
```

- **Slots.** Each is the Qeetrix field box with its character centred in tabular figures (`title.md`,
  `title.lg` at `lg`, in the A11y letter style). Like every field it spans its container and the slots
  share the width, shrinking to a 24-point minimum (`size.target.min`), 8 points apart.
- **Size**: `md` — an input's height, for consoles — or `lg`, 16 points taller, for sign-in pages.
- **Groups**: `[3, 3]` splits the slots with an 8 × 2-point `color.border.strong` rule (123 – 456).
- **States.** The focused slot shows the Ember frame; with an error every slot shows the danger frame —
  clear the code after a failed attempt.
- **Behaviour.** Typing moves on, deleting moves back, a paste or SMS AutoFill fills every slot, and
  `onValueComplete` runs once the code is full. `validationType` is `numeric` (the number pad) or
  `alphanumeric`.

Without a label, ``QeetrixOTPInput/init(code:length:groups:size:validationType:error:onValueComplete:)``
draws the slots alone, for a screen whose heading names the code.

### Accessibility

VoiceOver reads one text field named by the label ("One-time code" without one), with the code as its
value.

### Platform differences

The web names each slot "Character 2 of 6"; iOS gives VoiceOver one field for the whole code, which is
how the system's own code entry reads.

On the web: [OTP input on ui.qeet.in](https://ui.qeet.in/components/otp-input/).

## Topics

### Options

- ``QeetrixOTPValidationType``
- ``QeetrixOTPInputSize``
