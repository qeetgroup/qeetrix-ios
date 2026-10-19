# ``Qeetrix/QeetrixConfirmationDialog``

## Overview

A choice among actions about one thing, or a last check before a destructive action: the iOS action
sheet. The system anchors it to the view it is attached to — on iOS 27 on iPhone as well as on iPad — so
attach it to the control that opens it.

```swift
@State private var share: QeetrixConfirmationDialog?

QeetrixButton("Share report", variant: .outline) {
    share = QeetrixConfirmationDialog("Share the Q3 summary", actions: [
        QeetrixDialogAction("Copy link") { copyLink() },
        QeetrixDialogAction("Send by email") { sendEmail() },
    ])
}
.qeetrixConfirmationDialog($share)
```

It follows the rules of a ``QeetrixAlertDialog``: the value is the state, every button clears it and
then runs its action once, and a destructive action brings a Cancel with it. The title is always shown.

Use an alert for a decision that must interrupt; this dialog for "which of these?" or "are you sure?"
about something the person just started; a ``QeetrixMenu`` for actions that need no confirmation.

### Accessibility

The system presents it modally, reads its title and message, and lists the actions in order. Cancelling
is always possible: anchored to its control, the dialog shows no Cancel button and a tap outside cancels;
where the system does show one, it is the cancel action.

### Platform differences

The web has no action sheet; it uses an `AlertDialog` or a `DropdownMenu` for the same jobs. The
system draws the dialog.

## Topics

### Actions

- ``QeetrixDialogAction``
