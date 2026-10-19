# ``Qeetrix/QeetrixAlertDialog``

## Overview

The system alert, for a decision the person must make before going on — deleting something for good,
leaving with unsaved changes — or a notice they must acknowledge. Describe it as a value and present it
by setting it:

```swift
@State private var alert: QeetrixAlertDialog?

QeetrixButton("Delete workspace", variant: .destructive) {
    alert = QeetrixAlertDialog(
        "Delete this workspace?",
        message: Text("Its projects and files are removed for everyone."),
        actions: [QeetrixDialogAction("Delete", role: .destructive) { deleteWorkspace() }])
}
.qeetrixAlertDialog($alert)
```

- The value is the whole state: `nil` is dismissed, and a value is shown with its content.
- Every button sets the value back to `nil`, then runs its action once.
- A destructive action is drawn as destructive. When the actions include one but no cancel, a "Cancel"
  is added, so the safe choice is always there. With no actions, the system shows OK.
- Keep it to two or three actions. For a choice among more, use a ``QeetrixConfirmationDialog``.

An alert interrupts. For an outcome that needs no decision, use a ``QeetrixToast``; for a problem with
what someone typed, show it at the field.

A confirmation records intent; it does not authorise. Whatever the person confirms, the code that performs
the action still checks that it is allowed.

### Accessibility

The system alert is modal for VoiceOver, which reads the title and message when it appears. Keyboard,
Switch Control and Voice Control work with it as with any system alert.

### Platform differences

The web `AlertDialog` is drawn by Qeetrix; on iOS the system draws the alert, in its own font and
material, and only the tint reaches it. The web's inline `Alert` — a status message in the page — is a
different component, not this one.

On the web: [Alert Dialog on ui.qeet.in](https://ui.qeet.in/docs/components/alert-dialog).

## Topics

### Actions

- ``QeetrixDialogAction``
