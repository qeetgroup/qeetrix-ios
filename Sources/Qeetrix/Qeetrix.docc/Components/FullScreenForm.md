# ``Qeetrix/QeetrixFullScreenForm``

## Overview

A modal screen for creating or editing something with more than a few fields — `@qeetrix/react`'s
Dialog at `size="fullscreen"` with the bar of Material's full-screen dialog — presented with
`qeetrixFullScreenForm(isPresented:onDismiss:content:)` or its `item:` form. A dialog and a bottom
sheet suit short content; this is for the form that needs the screen.

```swift
@State private var isAdding = false
@State private var draft = Contact()

Button("New contact") { isAdding = true }
    .qeetrixFullScreenForm(isPresented: $isAdding) {
        QeetrixFullScreenForm("New contact", confirm: QeetrixScreenAction("Save") { save() }, hasChanges: draft != Contact()) {
            QeetrixTextField("Name", text: $draft.name)
            QeetrixTextField("Email", text: $draft.email, prompt: Text("e.g. asha@acme.in"))
        }
    }
```

- **Presentation.** On a phone, and at any compact width, it covers the screen; on a tablet it is a
  form sheet. `isPresented` (or `item`) is yours and becomes `false` (or `nil`) however the form closes.
- **The bar.** The Dialog's 3-point Ember intent line across the top, then a bar the app chrome's height
  (`size.control.lg` + 16 points) with Close — a neutral ghost ``QeetrixIconButton`` named "Close" — at
  the start, the title (`title.md`, a heading) and the confirming action, a solid ``QeetrixButton``, at
  the end; a 1-point `color.border.subtle` rule under it. A title that doesn't fit on the bar's line
  takes its own line under the buttons, and wraps.
- **The fields** scroll beneath the bar on `color.surface.overlay`, `space.form.gap` apart, on the
  phone's 16-point gutter or the Dialog's 24 points in a form sheet.
- **Confirming.** The action runs as given: validate, save, then set `isPresented` to `false` once it
  has worked, so a form with errors stays open to show them. Use `isLoading` while saving and
  `isDisabled` (with a reason nearby) when there's nothing to save.
- **Unsaved changes.** Pass `hasChanges`. Without changes Close dismisses the form; with them it asks
  first, in a ``QeetrixConfirmationDialog`` — "Discard your changes?", with "Discard changes" and "Keep
  editing" — and a swipe can't dismiss the form sheet. `discardTitle` replaces the question
  ("Discard this invoice?"); `onClose` replaces what Close does, for a form that keeps drafts instead.

```swift
.qeetrixFullScreenForm(item: $editing) { contact in
    QeetrixFullScreenForm(
        "Edit contact", confirm: QeetrixScreenAction("Save", isLoading: isSaving) { save(contact) }, hasChanges: hasChanges,
        discardTitle: Text("Discard your edits to \(contact.name)?")
    ) {
        QeetrixTextField("Name", text: $draft.name)
    }
}
```

### Accessibility

- The form is modal: VoiceOver moves into it and reads the title as a heading. Close is named "Close".
- Escape on a hardware keyboard, and VoiceOver's escape gesture (a two-finger Z), are Close: they ask
  first when there are changes.
- The fields scroll above the keyboard and a focused field is kept in view; dragging the fields down
  puts the keyboard away. At large text sizes the bar grows and the title moves onto its own line.

### Platform adaptations

- **Material's bar, the web's surface.** The web's fullscreen Dialog keeps its actions in a footer; on a
  phone the confirming action sits in the bar, as in Material's full-screen dialog and iOS's own
  create and edit sheets, where the keyboard can't cover it.
- **Presentation** is the system's: a full-screen cover at compact width, which no swipe dismisses, and
  a sheet at regular width, sized for a form by `presentationSizing(.form)` from iOS 18 — on iOS 17 the
  system's default sheet size. If the width class changes while the form is open (an iPad entering
  Split View), it moves to the other presentation, so keep the draft in your state.
- **The swipe on a form sheet** is refused while there are changes; SwiftUI doesn't report the attempt,
  so it can't ask first, as Close does (ADR 0014).
- **The confirmation** is the system's confirmation dialog, drawn by iOS: an action sheet on a phone, a
  popover from Close on a tablet.

On the web: [Dialog on ui.qeet.in](https://ui.qeet.in/components/dialog/).
