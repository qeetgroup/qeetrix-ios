# ``Qeetrix/QeetrixToast``

## Overview

Brief, non-blocking feedback about an outcome — "Settings saved", "Link copied", "Invoice not sent" —
as `@qeetrix/react`'s toast. The screen stays usable underneath, and the toast leaves by itself.

```swift
@State private var toast: QeetrixToast?

SettingsForm()
    .qeetrixToast($toast)

toast = .success("Settings saved")
toast = QeetrixToast(.info, title: "Conversation archived", action: .init("Undo") { unarchive() })
toast = QeetrixToast(.danger, title: "Couldn't send the invoice", description: "Check the address and try again.")
```

- **Tone**: `info`, `success`, `warning` or `danger`, each with its own sharp 16-point icon
  and its colour on a 3-point status edge on the start side — so status is never colour alone.
- **Look** (toast.css): `color.surface.overlay`, `shadow.overlay` and 4-point corners; the title in
  `title.sm` and one line of description in `body.sm`, `color.text.subtle`; at most one action, a ghost
  `sm` button; then Dismiss, a neutral `sm` icon button. 360 points wide at most, 16 points from the
  edges at the bottom.
- **One at a time.** Setting a toast replaces the one on screen; nothing queues. Setting the same toast
  again keeps it and restarts its timer, without announcing it twice.
- **Timing.** 5 seconds; a `danger` toast stays until it is dismissed. `duration: .zero` keeps any toast
  until it is closed.
- **Leaving.** Dismiss, the action (which dismisses, then runs once), the timer, or setting the binding
  to `nil`. The binding becomes `nil` however it leaves. It comes in over `motion.duration.normal` with
  a fade and a 4-point rise.

For something the person must decide, use a ``QeetrixAlertDialog``. Never put secrets in a toast.

### Accessibility

- VoiceOver announces each new toast once — `danger` ones with high priority.
- While VoiceOver is running, a toast with an action stays until it is used or dismissed, and a toast
  whose time runs out while VoiceOver's focus or a pointer is on it leaves when they move off.

### Platform differences

- **One toast.** The web stacks up to three, 8 points apart; iOS shows one and replaces it (ADR 0014).
- **Placement.** The full width on iPhone, 360 points at the trailing edge on iPad.
- **Swipe and promises.** The web's swipe to dismiss and `promise` toasts have no counterpart here.

On the web: [Toast on ui.qeet.in](https://ui.qeet.in/components/toast/).

## Topics

### Tones

- ``QeetrixToastTone``
