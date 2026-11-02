# ``Qeetrix/QeetrixCopyButton``

## Overview

Copies text to the clipboard — `@qeetrix/react`'s CopyButton: a user ID, an invite link, an API key.
For a value shown with its Copy button use ``QeetrixCopyField``; for a one-time code, ``QeetrixOTPCode``.

```swift
@State private var toast: QeetrixToast?

ClientDetails(client: client)
    .qeetrixToast($toast)

QeetrixCopyButton(value: client.id, label: Text("Copy client ID"), toast: $toast)
QeetrixCopyButton("Copy link", value: inviteLink, variant: .soft, toast: $toast)
```

- **Look**: an icon button — ghost, neutral and `md` by default — with the sharp `copy` icon, or with a
  title a ``QeetrixButton`` with the icon in its trailing zone. Every ``QeetrixButtonVariant``,
  ``QeetrixButtonTone`` and size works.
- **After a copy** the icon is a `check`, in `color.icon.success` on a ghost button, for `resetAfter`
  (2 seconds), and the tooltip says "Copied". Tapping again copies again and restarts the time.
- **Failure is never silent.** If the value can't be read, the icon is a `circle-alert` (in
  `color.icon.danger` on a ghost button), "Couldn't copy" is announced, and the error haptic plays.
- **Confirmation**: a light haptic and, with the binding the screen's `qeetrixToast(_:)` hosts, a "Copied"
  toast. Without a toast binding, VoiceOver announces "Copied".

### Secrets

`isSensitive` is for one-time codes, API keys and recovery codes. The clipboard entry stays on this
device — it is never offered to the universal clipboard, so Handoff doesn't carry it to the person's
other devices — and the system removes it **60 seconds** after the copy if nothing has replaced it. The
toast says so: "Clears from the clipboard after 1 minute".

Sixty seconds is long enough to switch apps and paste, which people do within seconds, and covers a
30-second one-time code's own window plus the one step of clock drift servers usually accept (RFC 6238
§5.2), and all of a 60-second code's. It is short enough that a secret isn't still there for whatever
is pasted next.

A value that has to be fetched — a fresh token, a key revealed on demand — is read when the button is
tapped. If it throws, nothing is copied and the button shows the failure:

```swift
QeetrixCopyButton(label: Text("Copy API key"), isSensitive: true, toast: $toast) {
    try await keys.reveal(key.id)
}
```

The text is never logged or announced. Never put the value itself in a toast.

### Accessibility

- An icon-only button is named by `label` — what it copies, "Copy user ID" — or "Copy". A titled one is
  named by its title. After a copy its value is "Copied" (or "Couldn't copy") until it resets.
- The touch target is at least 44 points, extended without moving layout. Focus stays on the button
  after a copy.
- The icon scales with Dynamic Type and the title wraps rather than truncates. Colour isn't the only
  sign: the icon changes shape.

### Platform differences

- **Toast and haptics.** The web announces "Copied" in a polite live region; iOS adds a light haptic, and
  a toast when the screen hosts one (ADR 0014: no global toast service, so the screen passes its
  binding).
- **Local only and expiring.** `isSensitive` has no web counterpart: a browser can't keep an entry off
  other devices or make it expire. It is `UIPasteboard`'s `localOnly` and `expirationDate`.
- **When it fails.** The web fails without clipboard access outside a secure context; an iOS app always
  has the pasteboard, so only a value that throws fails.
- **No `onCopyError` or `messages`.** Handle the error inside the closure. The strings come from the
  package's localisations.
- **Tooltip.** The web's tooltip opens on hover and stays open while "Copied" shows; on iOS it is the
  pointer tooltip (`help`), shown on iPad with a pointer.

On the web: [Copy button on ui.qeet.in](https://ui.qeet.in/components/copy-button/).
