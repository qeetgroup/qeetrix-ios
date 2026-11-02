# ``Qeetrix/QeetrixSwipeAction``

## Overview

Actions on a list row, revealed by swiping it — Qeet Auth's Remove on an account's row, Approve and
Deny on a sign-in request — and always reachable without swiping: one list of actions feeds the swipe,
the row's VoiceOver actions and its context menu.

```swift
List(accounts) { account in
    QeetrixListItem(account.issuer, description: Text(account.email)) {
        QeetrixAvatar(name: account.issuer, shape: .square, isDecorative: true)
    }
    .qeetrixSwipeActions(actions: [
        QeetrixSwipeAction(
            "Remove", icon: .trash, tone: .danger, confirmation: Text("Remove \(account.issuer) from this phone?"),
            confirmationMessage: Text("You'll need a new QR code to add it again.")
        ) { remove(account) }
    ])
}
.qeetrixListStyle()
```

- **One edge or both.** `qeetrixSwipeActions(edge:allowsFullSwipe:actions:)` puts the actions on the
  trailing edge, or the leading one; `qeetrixSwipeActions(leading:trailing:allowsFullSwipe:)` on both.
  Apply it once per row. The edges follow the reading direction, so in right-to-left layouts the
  leading actions come from the right.
- **A full swipe runs the first action** of its edge — the one at the screen's edge. Pass
  `allowsFullSwipe: false` when a slip shouldn't act.
- **A danger action asks first**, in a ``QeetrixConfirmationDialog`` anchored to the row: the
  question in `confirmation` (the action's title when there's none), `confirmationMessage` under it,
  and the action's title as the destructive button beside Cancel. The action runs once the dialog has
  gone, and only if the person chose it (ADR 0014). A neutral or Ember action runs at once, unless it
  has a `confirmation` too.
- **The tones**, as qeetrix-android's:

| Tone | Fill | For |
|:--|:--|:--|
| `neutral` (default) | `color.bg.neutral.bold` (warm graphite); in dark `color.bg.neutral.subtle-pressed` | archive, mute, snooze |
| `brand` | `color.bg.brand.bold` (Ember) | the row's one constructive action: Approve |
| `danger` | `color.bg.danger.bold` | remove, delete, deny — asked first |

With actions on both edges, put the constructive one at the start and the destructive one at the
end, as Mail does, so a full swipe in either direction does what its colour says.

```swift
QeetrixListItem(request.app, description: Text(request.place)) {
    QeetrixListItemIcon(.lock)
}
.qeetrixSwipeActions(
    leading: [QeetrixSwipeAction("Approve", icon: .check, tone: .brand) { approve(request) }],
    trailing: [
        QeetrixSwipeAction("Deny", icon: .x, tone: .danger, confirmation: Text("Deny the sign-in to \(request.app)?")) {
            deny(request)
        },
        QeetrixSwipeAction("Later", icon: .clock) { snooze(request) },
    ]
)
```

### What the system draws, and what Qeetrix sets

The swipe is the system's `swipeActions(edge:allowsFullSwipe:content:)`, so it is the gesture people
know from Mail and Messages, on the rows of a `List`:

- **iOS draws** each action as a block of its fill beside the row, its icon and title in white in the
  system's font. It chooses what to show from the row's height — the icon on a row of the usual height,
  the icon over the title on a taller one — and lays the actions out, opens and closes them, and
  expands the first across the row on a full swipe.
- **Qeetrix sets** each action's fill — its tone's token, through `tint(_:)` — its icon, a sharp
  20-point Qeetrix icon (`size.icon.md`, as qeetrix-android's), its title, which VoiceOver reads, and
  its order. No swipe button takes the system's destructive role: that would have the list slide the
  row away before the question is answered. The danger action asks instead, and the app removes the
  row once it's confirmed.

`swipeActions` works only on the rows of a `List`. A row in a stack still gets the VoiceOver actions
and the context menu, so the actions stay reachable there too. As with any `swipeActions`, a row with
these actions loses the `Delete` that `onDelete(perform:)` would give it; give it a danger action
instead.

### Without swiping

Swiping is never the only way to an action:

- **VoiceOver** offers every action of both edges as an action of the row: swipe up or down to
  choose, double-tap to run. A danger action asks its question first, as it does from the swipe.
  SwiftUI offers a list row's swipe actions to VoiceOver as well, and lists an action of the same name
  once.
- **The context menu** — touch and hold, a secondary click or Full Keyboard Access — lists the actions
  with their icons: the others in order, then the danger ones after a divider, in the menu's
  destructive red. The row gets its menu from this modifier, so don't add a second `contextMenu` to it.
- **Switch Control** reaches both, through the row's actions and its long press.

### Haptics

The system already taps for the swipe: UIKit's swipe handler has its own feedback for the swipe's
states, and taps as a full swipe reaches the point where letting go runs the first action; the
context menu taps as it opens. Qeetrix adds no haptic of its own to either, so nothing is felt twice.
What the action starts is the app's: when its work finishes, play ``QeetrixFeedback/success`` or
``QeetrixFeedback/error`` through `qeetrixFeedback(_:trigger:)`.

### Accessibility

- Every action has a title, a verb, whether or not iOS shows it on the swipe: it names the VoiceOver
  action, the menu item and the dialog's button.
- A disabled row offers no actions, by swipe, VoiceOver or menu.
- White on each fill is at least 4.5:1 in both schemes: on Ember 4.55:1, on the danger fill 6.04:1, on
  warm graphite 17.7:1 and on dark's neutral fill 11.8:1.
- The icons are drawn by the system as images, which don't mirror: choose icons without a direction.
- The dialog is the system's, modal to VoiceOver; cancelling is always possible.

### Platform differences

- **The system's swipe, not Qeetrix's.** qeetrix-android draws its own: the row slides over an action
  that fills the space it uncovers, a full swipe past 60 % runs it, and it taps as an action is
  revealed and as a swipe passes the point where it runs. On iOS the list's own swipe does all of
  that — its distances, its animation and its haptics — so the gesture is the one iOS users know,
  Reduce Motion and right to left included.
- **Several actions per edge**, where qeetrix-android has one `startAction` and one `endAction`: iOS
  lists show several, Mail's More, Flag and Trash. Keep to three at most.
- **Neutral in dark.** iOS draws every action's icon and title white (`color.text.on-bold`).
  qeetrix-android's neutral, warm graphite with `color.text.inverse`, turns light in dark, where white
  on it would be unreadable (1.1:1) and the design rules allow only `color.text.inverse` on it (§4).
  So in dark the neutral fill is `color.bg.neutral.subtle-pressed`, the darkest neutral fill, which
  white reads on.
- **The danger action always asks**: qeetrix-android asks only when given a `confirmTitle`. iOS asks
  in the system's confirmation dialog, with Cancel, and without a question uses the action's title.
- **The row's menu is built for you**: qeetrix-android leaves it to the app.
- `@qeetrix/react` has no swipe actions: a web table puts a row's actions in a menu.

## Topics

### Tones

- ``QeetrixSwipeActionTone``
