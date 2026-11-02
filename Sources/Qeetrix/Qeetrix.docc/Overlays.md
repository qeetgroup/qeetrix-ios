# Choosing an overlay

Which overlay fits — alert, confirmation dialog, sheet, popover, menu or toast — and how each one's state
stays yours.

## Overview

Each overlay answers a different need. Pick by what the person must do with it:

| The person must… | Use | `@qeetrix/react` | Blocks the screen |
|:--|:--|:--|:--|
| decide before going on, or acknowledge something serious | ``QeetrixAlertDialog`` | Dialog, `intent` danger or warning | Yes |
| choose among actions about one thing, or confirm a destructive one | ``QeetrixConfirmationDialog`` | Dialog or Menu | Yes |
| complete a focused task: a form, filters, details | a sheet, with ``QeetrixSheetContent`` | Drawer, Dialog | Yes |
| see more about a control, briefly | a popover, `qeetrixPopover(isPresented:title:description:arrowEdge:compactAdaptation:content:)` | Popover | Until tapped away |
| pick an action from a list | ``QeetrixMenu`` | Menu | Until tapped away |
| notice an outcome, perhaps undo it | ``QeetrixToast`` | Toast | No |

On iOS each is the system's presentation (ADR 0014): the system draws alerts, action sheets and menus
in its own font and material, and presents sheets and popovers, with their gestures, keyboard handling
and VoiceOver focus. Qeetrix draws what goes inside sheets and popovers, and the toast.

Errors in what someone typed are none of these: show them at the field, and in a
``QeetrixErrorSummary`` when the form is submitted.

## The state is yours

Every overlay is presented from a binding your view owns — an optional value or a `Bool` — and Qeetrix
sets it back when the overlay leaves, however it leaves. There is no presentation manager to call and no
global state:

```swift
struct DocumentRow: View {
    let document: Document
    @State private var confirmDelete: QeetrixConfirmationDialog?
    @Binding var toast: QeetrixToast?

    var body: some View {
        HStack {
            Text(document.title)
            Spacer()
            QeetrixMenu(icon: .ellipsis, label: "Actions for \(document.title)") {
                QeetrixMenuItem("Delete", icon: .trash, tone: .danger) {
                    confirmDelete = QeetrixConfirmationDialog(
                        "Delete \(document.title)?",
                        actions: [
                            QeetrixDialogAction("Delete", role: .destructive) { delete() }
                        ])
                }
            }
            .qeetrixConfirmationDialog($confirmDelete)
        }
    }

    private func delete() {
        // Remove the document, then offer to undo.
        toast = QeetrixToast(.info, title: "\(document.title) deleted", action: .init("Undo") { restore() })
    }
}
```

Each overlay hands over to the next by setting its binding. A dialog's action runs after the dialog's
binding is cleared, so the action sees the dialog gone when it sets the next one — a toast, say.

## Guarding work in progress

A sheet with unsaved changes should not vanish on a stray swipe. Pass `isDismissDisabled: true` to the
sheet and `isDismissible: false` to its ``QeetrixSheetContent``, which then has no close button, so
only its own actions close it — the web's `dismissible={false}`. Or keep the close button and give it
an `onClose` that asks before it sets the sheet's binding to `false`, with a
``QeetrixConfirmationDialog`` whose destructive action is "Discard changes" and whose cancel action is
"Keep editing".

## Confirming is not authorising

A dialog records what the person meant. It does not make the action allowed: the code that performs it —
usually a server — still checks permission, and handles the action failing.

## See Also

- <doc:NavigationBars>
- <doc:Forms>
