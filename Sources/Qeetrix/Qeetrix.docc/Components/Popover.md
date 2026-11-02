# Popover

Contextual content anchored to a control — `@qeetrix/react`'s Popover — with
`qeetrixPopover(isPresented:title:description:arrowEdge:compactAdaptation:content:)`.

## Overview

A small panel about the control it points at — help for a setting, the details behind a summary.

```swift
QeetrixIconButton(.info, label: "About roles", tone: .neutral) { showsRoles = true }
    .qeetrixPopover(isPresented: $showsRoles, title: Text("Roles"), description: Text("Who can do what.")) {
        QeetrixText("Admins can invite members and manage billing.")
    }
```

- **Look** (popover.css): `color.surface.overlay`, 16 points of padding (`space.inset.lg`) and 12 points
  between its parts, at most 360 points wide; an optional title (`title.sm`) and description (`body.md`,
  `color.text.subtle`, 4 points under it). The title names it.
- On iPad and on any iPhone in landscape (compact height) it is the system popover. In a portrait
  iPhone (compact width) iOS shows it as a sheet at medium height, the native form for contextual
  content on a small screen; pass `compactAdaptation: .popover` to keep a small popover there too.
- A tap outside or Escape dismisses it, and `isPresented` becomes `false`.

Don't put urgent warnings, destructive confirmations or a whole form in a popover: use a
``QeetrixAlertDialog``, a ``QeetrixConfirmationDialog`` or a sheet.

### Accessibility

The popover is the system's presentation, so VoiceOver moves into it when it appears and reads its
title, then its content.

### Platform differences

- **Frame and arrow.** The system draws the popover's frame, shadow and arrow (ADR 0014). The web's
  popover has a 1-point `color.border.subtle` edge, `shadow.overlay` and no arrow.
- **Opening.** The web popover opens on click; iOS has no hover-to-open, and the web's Tooltip has no
  counterpart beyond an icon button's pointer tooltip.

On the web: [Popover on ui.qeet.in](https://ui.qeet.in/components/popover/).
