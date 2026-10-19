# Popover

Contextual content anchored to a control, with `qeetrixPopover(isPresented:arrowEdge:compactAdaptation:content:)`.

## Overview

A small panel about the control it points at — help for a setting, the details behind a summary.

```swift
QeetrixIconButton(.info, label: "About roles") { showsRoles = true }
    .qeetrixPopover(isPresented: $showsRoles) {
        Text("Roles").qeetrixTextStyle(.label)
        Text("Admins can invite members and manage billing.")
    }
```

- In a regular-width window (iPad, and iPhones in landscape where they have the room) it is a popover
  with an arrow, 288 pt wide at most, on the popover surface from the `component.popover` tokens.
- In compact width iOS shows it as a sheet at medium height, the native form for contextual content on a
  small screen. Pass `compactAdaptation: .popover` to keep a small popover there too.
- A tap outside or Escape dismisses it, and `isPresented` becomes `false`.

Don't put urgent warnings, destructive confirmations or a whole form in a popover: use a
``QeetrixAlertDialog``, a ``QeetrixConfirmationDialog`` or a sheet.

### Accessibility

The popover is the system's presentation, so VoiceOver moves into it when it appears and reads its
content in order.

### Platform differences

The web popover opens on click and can open on hover; iOS has no hover-to-open, and the web's
`HoverCard` and `Tooltip` have no counterpart here.

On the web: [Popover on ui.qeet.in](https://ui.qeet.in/docs/components/popover).
