# ``Qeetrix/QeetrixSheetContent``

## Overview

A focused task over the current screen — a form, filters, details — presented with
`qeetrixSheet(isPresented:detents:isDismissDisabled:onDismiss:content:)` or its `item:` form, and laid
out with this view.

```swift
.qeetrixSheet(isPresented: $isEditing, isDismissDisabled: hasChanges) {
    QeetrixSheetContent("Edit profile", description: Text("Your team sees these details."), onClose: close) {
        QeetrixTextField("Display name", text: $draft)
    } actions: {
        QeetrixButton("Cancel", variant: .outline) { close() }
        QeetrixButton("Save") { save() }
    }
}
```

- **The surface.** On iPhone the sheet rises from the bottom to its detents, with a grab handle when
  there is more than one: the web's `Drawer`. On iPad it is the centred form sheet: the web's `Dialog`.
  The background and corner come from the `component.dialog` tokens.
- **The layout.** The title is a heading, with an optional description and a Close button. The content
  scrolls when it is taller than the sheet. The actions are placed as ``QeetrixFormActions`` places them,
  and stay above the keyboard.
- **Dismissal.** A swipe down, a tap outside on iPad, Close, or your own buttons dismiss the sheet, and
  `isPresented` (or `item`) becomes `false` (or `nil`). `isDismissDisabled` refuses the swipe and the tap
  outside — while a form has unsaved changes, say. `onClose` replaces Close's dismissal, so you can ask
  first. `onDismiss` runs once afterwards, however the sheet was dismissed.

### Accessibility

The sheet is modal for VoiceOver. The title is a heading and Close a labelled button, both at the top,
so the sheet's purpose and the way out come first.

### Platform differences

The web has four modal surfaces (`Dialog`, `AlertDialog`, `Drawer` and `Sheet`); iOS has the sheet and
the alert. A centred dialog on iPhone is not provided: there the bottom sheet is the platform's modal
for a task. The web's side `Sheet` has no iPhone equivalent; on iPad a sheet or a split view takes its
place.

On the web: [Dialog](https://ui.qeet.in/docs/components/dialog) and
[Drawer](https://ui.qeet.in/docs/components/drawer) on ui.qeet.in.
