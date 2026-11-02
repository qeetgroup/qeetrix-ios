# ``Qeetrix/QeetrixCheckList``

## Overview

Rules that tick as they're met — a new password's rules, a setup's steps, a connection test's checks —
each with its result in words as well as its icon: `@qeetrix/react`'s CheckList.

```swift
QeetrixCheckList {
    QeetrixCheckItem("At least 12 characters", status: password.count >= 12 ? .passed : .pending)
    QeetrixCheckItem("A number or a symbol", status: hasNumberOrSymbol ? .passed : .pending)
    QeetrixCheckItem("Not a password you've used before", status: isReused ? .failed : .passed)
}
```

- **The sheet**: `color.surface.raised` inside a 1-point `color.border.default` edge with 4-point
  corners (`radius.surface`); items ruled in `color.border.subtle`.
- **An item** (``QeetrixCheckItem``): its status icon, its title (`label.md`) and an optional detail
  under it (`body.sm`, `color.text.subtle`, wrapping), and its status in words at the end
  (`label.sm`) — at least 3 rem tall, `space.inset.sm` above and below and `space.inset.md` at the
  sides, `space.gap.md` between the parts.
- **Statuses** (``QeetrixCheckStatus``):

| Status | Icon | Words |
|:--|:--|:--|
| `passed` | sharp `circle-check`, `color.icon.success` | "Passed", `color.text.success` |
| `failed` | sharp `circle-x`, `color.icon.danger` | "Failed", `color.text.danger` |
| `pending` | sharp `circle-dashed`, `color.icon.subtle` | "Not run", `color.text.subtle` |
| `running` | a small spinner, `color.icon.subtle` | "Running", `color.text.subtle` |

A footer — when the checks ran, a button to run them again — sits under its own rule in `body.sm`,
`color.text.subtle`, its parts at the two ends, wrapping:

```swift
QeetrixCheckList {
    QeetrixCheckItem("The certificate is in date", detail: Text("Until 23 Aug 2030"), status: .passed)
    QeetrixCheckItem("The metadata URL answers", status: .running)
} footer: {
    Text("Started just now")
    QeetrixButton("Run again", variant: .ghost, size: .sm) { runChecks() }
}
```

The app decides each status; the list checks nothing itself. `statusLabel` replaces the built-in words
for one item.

### Accessibility

- VoiceOver reads each check as one element, with its status: "At least 12 characters, Passed". The
  status is in words as well as the icon and its colour, so it is never colour alone.
- When a status changes — a rule met as the person types, a check finishing — VoiceOver announces the
  title and the new status at low priority, after what it is saying.
- The title is a plain string, localised on creation, because it is also announced.
- From the accessibility sizes the status moves under the title; the icons and the spinner grow with
  the text. Under Reduce Motion the spinner stops turning and pulses.

### Platform differences

- **Announcements.** The web marks the list `aria-live="polite"`, so a screen reader reads the changed
  words; iOS has no live regions, so each item announces its title and new status itself, at low
  priority — queued behind other speech.
- **Strings.** The web's `messages` is `statusLabel`, for the item's current status.
- **The spinner** is ``QeetrixSpinner`` at `sm`, decorative, as the web's.

On the web: `@qeetrix/react`'s experimental CheckList (`@qeetrix/react/experimental`); ui.qeet.in has
no page for it yet.

## Topics

### Items

- ``QeetrixCheckItem``
- ``QeetrixCheckStatus``
