# ``Qeetrix/QeetrixOTPCode``

## Overview

A one-time code to read or paste elsewhere, with the time it has left — the authenticator's code, beside
``QeetrixOTPInput``, which takes one. Qeet Auth's main screen is a list of them.

```swift
QeetrixOTPCode(account.code, periodStart: step.start, label: Text(verbatim: "Acme, priya@acme.in"), size: .md, toast: $toast)
QeetrixOTPCode(recovery.code, validity: recovery.window, isHidden: true, toast: $toast)
```

- **The code** is in Fira Code at weight 500 with tabular figures, at `title.lg`'s size (`md`, for a
  list) or `heading.md`'s (`lg`, the default, for one code on its own screen). It is grouped to read
  back — 123 456, and 1234 5678 for eight digits — `space.gap.md` apart, and reads left to right in
  every language.
- **The time left** is a ``QeetrixCircularProgress`` emptying over the period (20 points beside an `md`
  code, 24 beside an `lg` one) and the seconds beside it, `label.md` in `color.text.subtle`. In the last
  5 seconds the ring takes the `warning` tone and the seconds `color.text.warning`.
- **Tap to copy.** The code goes on the clipboard on this device only, never the universal clipboard,
  and the system removes it after 60 seconds (see ``QeetrixCopyButton``). A light haptic confirms it;
  with the screen's toast binding, so does a "Copied" toast that says when it leaves the clipboard.
  While pressed the code takes the neutral ghost button's tint.
- **Hidden until tapped.** With `isHidden` the code shows as dots in `color.text.subtle`. The first tap
  shows it, the next copies it, and the next code starts hidden again.
- **Six and eight digits; 30 and 60 seconds.** `period` is 30 seconds by default.

### The app's action instead of the copy

Where a tap on a code means something else, give `action` and `actionHint`: a tap runs the action with
the code instead of copying it — no clipboard, no toast, no haptic. In an AutoFill credential provider,
the picker fills the code the system asked for:

```swift
QeetrixOTPCode(account.code, periodStart: step.start, label: Text(account.name), size: .md,
               actionHint: Text("Fills the code")) { code in fill(code) }
```

The code looks the same: the groups, the ring, the seconds and the warning tone. With `isHidden` the
first tap still shows the code, and the next runs the action. Any confirmation is the app's to give.

### Qeetrix doesn't compute the code

Qeetrix only shows a code. The app generates it — TOTP, RFC 6238, from the secret it keeps in the
Keychain — and passes it with its period window: `validity`, a `ClosedRange<Date>`, or `periodStart` and
`period`. When the window ends the app gives the next code; until then an expired code shows 0 seconds
and an empty ring. A view that redraws each second does both:

```swift
TimelineView(.periodic(from: .now, by: 1)) { context in
    let step = account.step(at: context.date)
    QeetrixOTPCode(account.code(for: step), periodStart: step.start, period: account.period, label: Text(account.name))
}
```

The code is marked `privacySensitive()` and is never logged, announced as an event or put in a toast.

### Accessibility

- VoiceOver reads one button: the `label` (whose code it is), the digits one by one, then the time left —
  "Acme, priya@acme.in, 4 8 2 9 1 3, 12 seconds left" — with "Copies the code" as its hint, or the
  `actionHint` given with an action. Hidden, it reads "Code hidden" and "Shows the code". The time left
  updates while VoiceOver is on the code.
- The touch target is at least 44 points, extended without moving layout. With Full Keyboard Access the
  focus frame is drawn round the code.
- The code scales with Dynamic Type. Where it doesn't fit, the time moves under the code, then the groups
  under each other: it never truncates. Bold Text steps the weight up.
- Under Reduce Motion the ring steps once a second instead of moving smoothly.
- The warning tone is never the only sign: the seconds count down beside the ring.

### Platform differences

- **No web counterpart.** `@qeetrix/react` has no OTP code; this follows qeetrix-android's
  `QeetrixOTPCode`, OTP input's tabular code type and the circular progress's countdown.
- **The clipboard.** Local only and expiring, which a browser can't do; Android marks the entry
  sensitive instead.
- **Toast and haptic.** iOS confirms the copy with a light haptic and the screen's toast, where Android
  13 and later show the system's own clipboard confirmation.

## Topics

### Options

- ``QeetrixOTPCodeSize``
