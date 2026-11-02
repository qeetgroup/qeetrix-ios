# ``Qeetrix/QeetrixAlertDialog``

## Overview

A decision the person must make before going on — deleting something for good, leaving with unsaved
changes — or a notice they must acknowledge: `@qeetrix/react`'s Dialog with a `danger` or `warning`
`intent` (an alert dialog), presented as the system alert. Describe it as a value and present it by
setting it:

```swift
@State private var alert: QeetrixAlertDialog?

QeetrixButton("Delete workspace", tone: .danger) {
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
- Title it with the question ("Delete this workspace?") and name the action on its button ("Delete",
  not "OK"). Keep it to two or three actions; for a choice among more, use a
  ``QeetrixConfirmationDialog``.

An alert interrupts. For an outcome that needs no decision, use a ``QeetrixToast``; for a problem with
what someone typed, show it at the field. A confirmation records intent; it does not authorise: the code
that performs the action still checks that it is allowed.

### Accessibility

The system alert is modal for VoiceOver, which reads the title and message when it appears. Keyboard,
Switch Control and Voice Control work with it as with any system alert.

### Platform differences

The web's Dialog is drawn by Qeetrix — `color.surface.overlay`, `shadow.modal`, a 3-point intent line on
top, red for destructive and amber for a warning, the actions end-aligned with Cancel first and initial
focus on it. On iOS the system draws the alert (ADR 0014), in its own font and material, places its
buttons and their focus, and only the tint reaches it. For a dialog with fields or longer content, use a
sheet with an `intent` (``QeetrixSheetContent``).

On the web: [Dialog on ui.qeet.in](https://ui.qeet.in/components/dialog/).

## Topics

### Actions

- ``QeetrixDialogAction``
