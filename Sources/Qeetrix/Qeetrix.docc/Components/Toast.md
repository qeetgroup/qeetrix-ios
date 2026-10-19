# ``Qeetrix/QeetrixToast``

## Overview

Brief, non-blocking feedback about an outcome — "Settings saved", "Link copied", "Report not sent". The
screen stays usable underneath, and the toast leaves by itself.

```swift
@State private var toast: QeetrixToast?

SettingsForm()
    .qeetrixToast($toast)

toast = .success("Settings saved")
toast = QeetrixToast(.info, title: "Conversation archived", action: .init("Undo") { unarchive() })
```

- **Types.** `info`, `success`, `warning` and `error`, each with its status icon, title colour and
  accent on the inline-start edge.
- **One at a time.** Setting a toast replaces the one on screen; nothing queues. Setting the same toast
  again keeps it and restarts its timer, without announcing it twice.
- **Timing.** 5 s, or 10 s for warnings, errors and toasts with an action; `duration: .zero` keeps it
  until it is closed.
- **Leaving.** Close, the action (which dismisses, then runs once), the timer, or setting the binding to
  `nil`. The binding becomes `nil` however it leaves.
- **Placement.** At the bottom, above the safe area: full width on iPhone, 384 pt at the trailing edge
  on iPad.

Put `qeetrixToast(_:)` on the screen whose outcome it reports. There is no app-wide toast service: each
host shows its own.

A toast is not for errors the person must fix — show those at the field or in a
``QeetrixFormErrorSummary`` — or for decisions, which need a ``QeetrixAlertDialog``.

> Important: Never put secrets in a toast — passwords, one-time codes, tokens, keys. Its text is
> announced aloud and may be on screen in public.

### Accessibility

VoiceOver announces each new toast once, errors with high priority. While VoiceOver is running a toast
with an action stays until it is used or closed, so the time limit never takes the action away. A
toast whose time runs out while VoiceOver's focus or a pointer is on it leaves when they move off.

### Platform differences

The web mounts one `Toaster` and calls `toast()` from anywhere; it stacks several toasts. On iOS the
host is a view modifier with a binding, and one toast shows at a time, because a stack covers a phone's
content and every toast in it would be announced. There is no separate snackbar: a toast with an action
is the snackbar.

On the web: [Toast on ui.qeet.in](https://ui.qeet.in/docs/components/toast).

## Topics

### Describing a toast

- ``QeetrixToastType``
- ``QeetrixToast/Action``
