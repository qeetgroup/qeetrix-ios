# ``Qeetrix/QeetrixAlert``

## Overview

A message in the page — above a form, inside a card, at the top of a screen — as `@qeetrix/react`'s
Alert. It stays until the app removes it.

```swift
QeetrixAlert(
    "Push notifications are off", description: "Turn them on to approve sign-ins from this phone.", tone: .warning
) {
    QeetrixButton("Open Settings", size: .sm) { openSettings() }
}
QeetrixAlert("You're offline", description: "Approvals arrive when you reconnect.", onDismiss: { isOfflineShown = false })
QeetrixAlert("This phone isn't linked", description: "Scan the code on qeet.in to link it.", tone: .danger)
```

- **Tone**: `info` (the default), `success`, `warning` or `danger`, each with its own sharp 16-point
  icon — `info`, `circle-check`, `triangle-alert`, `circle-alert` — and its tint, with a 3-point
  status edge in the icon's colour on the start side.
- **Look** (alert.css): `color.bg.<tone>.subtle`, 12 points of padding (8 at the end), no shadow; the
  title in `label.md` at weight 600 and the description in `body.md`, `color.text.subtle`, 2 points
  under it. `icon` replaces the tone's icon — an eye for "viewing as" — and the tone is still read.
- **Actions** go 8 points under the text, 8 points apart, wrapping onto more rows: at most one primary,
  usually `sm` buttons.
- **Dismiss**: `onDismiss` adds a neutral `sm` icon button with an `x` at the end. The app removes the
  alert, and decides whether it comes back.
- **Words.** The title says what happened in a few words; the description, why and what to do. They
  are plain strings, because they are also announced: never put secrets in them.

For feedback about an outcome that leaves by itself, use ``QeetrixToast``; for a decision, a
``QeetrixAlertDialog``. ``QeetrixErrorSummary`` is the danger alert of a form.

### Accessibility

- VoiceOver reads the tone's word before the title — "Warning: Push notifications are off" — then the
  description, as one element; the actions and Dismiss ("Dismiss") follow as buttons. Status is never
  colour alone: each tone has its own icon and its word.
- It never takes focus. An alert that appears after something happens can be announced with
  `announce`: `.polite` waits for VoiceOver to finish what it is saying, `.urgent` interrupts, for an
  error that blocks the task. An alert that is there when the screen opens needs neither.
- Text wraps at every Dynamic Type size; Dismiss has a 44-point touch target. In right-to-left layouts
  the status edge and the icon move to the right.

### Platform differences

- **Announcements.** The web's `role="status"` and `role="alert"` live regions are VoiceOver
  announcements, posted when the alert appears and when its words change.
- **Banners.** The web's `variant="banner"`, a notice across a console under its top bar, has no iOS
  counterpart: an iOS screen puts the alert at its top instead.

On the web: [Alert on ui.qeet.in](https://ui.qeet.in/components/alert/).

## Topics

### Tones and announcements

- ``QeetrixAlertTone``
- ``QeetrixAlertAnnouncement``
