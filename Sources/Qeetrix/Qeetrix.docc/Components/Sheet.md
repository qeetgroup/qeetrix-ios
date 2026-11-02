# ``Qeetrix/QeetrixSheetContent``

## Overview

A focused task over the current screen — a form, filters, details — presented with
`qeetrixSheet(isPresented:detents:isDismissDisabled:onDismiss:content:)` or its `item:` form, and laid
out with this view. On iOS the sheet stands in for both `@qeetrix/react`'s Drawer and its Dialog
(ADR 0014).

```swift
.qeetrixSheet(isPresented: $isEditing, isDismissDisabled: hasChanges) {
    QeetrixSheetContent("Edit address", description: Text("Used on every invoice."), isDismissible: !hasChanges, onClose: close) {
        QeetrixTextField("Street", text: $draft)
    } actions: {
        QeetrixButton("Cancel", variant: .ghost, size: .lg) { close() }
        QeetrixButton("Save", size: .lg) { save() }
    }
}
```

- **The surface**: `color.surface.overlay` with 4-point corners, from the bottom on iPhone and as a
  form sheet on iPad.
- **The layout** (drawer.css): a header with the title (`title.md`), an optional description (`body.md`,
  `color.text.subtle`) and Close at its end; the body, which scrolls; and a footer with the actions,
  end-aligned, tertiary first. 24 points of padding (`space.inset.xl`, 16 above and below the actions)
  and 1-point `color.border.subtle` rules under the header and above the footer, which stay put while
  the body scrolls.
- **Intent.** Where the sheet is the web's Dialog — a decision that interrupts — give it an `intent`:
  the Dialog's 3-point line across its top, Ember for a standard dialog (`.standard`), red for a
  destructive one (`.danger`), amber for a warning (`.warning`):

  ```swift
  .qeetrixSheet(isPresented: $isRevoking) {
      QeetrixSheetContent("Revoke this API key?", intent: .danger, isDismissible: false) {
          QeetrixText("Apps using it stop working at once.")
      } actions: {
          QeetrixButton("Cancel", variant: .ghost, size: .lg) { isRevoking = false }
          QeetrixButton("Revoke key", tone: .danger, size: .lg) { revoke() }
      }
  }
  ```
- **Dismissal.** A swipe down, Close, or your own buttons dismiss it, and `isPresented` (or `item`)
  becomes `false` (or `nil`). Close — a neutral ghost icon button named "Close" — calls `onClose`, or
  dismisses the sheet. With `isDismissible: false` there's no Close: pair it with the sheet's
  `isDismissDisabled`, as for an unsaved form, the web's `dismissible={false}`.

### Accessibility

The sheet is modal: VoiceOver moves into it and reads the title as a heading. Close is named "Close".

### Platform differences

- **Presentation** is the system sheet: detents, the swipe, the keyboard and the grab handle are the
  system's. The web's drawer slides in from the side and its dialog is centred; iOS presents both as a
  sheet. A centred, non-sheet dialog is deferred until a product needs one (ADR 0014).
- **Shadow.** The system draws the sheet's own edge; the web's `shadow.modal` isn't repeated.

On the web: [Drawer](https://ui.qeet.in/components/drawer/) and
[Dialog](https://ui.qeet.in/components/dialog/) on ui.qeet.in.

## Topics

### Intent

- ``QeetrixDialogIntent``
