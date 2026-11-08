# ``Qeetrix/QeetrixEmptyState``

## Overview

The message where content would be — nothing yet, no results, or an error — as `@qeetrix/react`'s
EmptyState.

```swift
QeetrixEmptyState("No accounts yet", description: "Add an account to sign in with this phone.", icon: .userPlus, level: 2) {
    QeetrixButton("Add account", icon: .plus) { addAccount() }
} footer: {
    Text("Or scan the code on qeet.in")
}
QeetrixEmptyState(
    "No pending approvals", description: "Sign-in requests from your accounts appear here.", icon: .inbox, size: .section)
```

- **Parts**: an optional sharp 24-point icon (`color.icon.subtle`), the title, a description in
  `body.md`, `color.text.subtle`, the actions, and a footer in `body.sm`, `color.text.subtle`. They are
  8 points apart, centred; the icon has 4 points more under it, and the actions 8 points more above
  them.
- **Size**: `page` (the default) for a whole screen — the title in `title.md`, 48 points above and
  below — or `section` inside a card or list — `title.sm`, 24 points.
- **Tone**: `neutral`, or `danger`, which colours the icon `color.icon.danger` for an error. An outcome
  screen takes `success` (`color.icon.success`: "Sign-in approved") or `warning` (`color.icon.warning`:
  "Approve on your other phone"); the title says the outcome, so the colour is never the only sign.
- **Width**: at most 480 points, centred, with 16 points at the sides. The actions wrap onto more
  rows, centred: one primary at most.
- **Words.** The title says what is missing ("No accounts yet"); the description, why and what to do.
  Never show a raw error, a status code or a server message.

### Outcome and lock screens

An outcome or lock screen can lead with the app's own image in place of the icon — the app's icon on a
Locked screen — drawn at the size the app gives it, decorative and hidden from VoiceOver.
`centredInHeight()` puts the column in the middle of the height it is offered rather than at the top; in
a scroll view, which offers no height, give it the screen's height as its minimum.

```swift
QeetrixEmptyState(title: Text("Qeet ID is locked"), description: Text("Unlock to see your codes."), image: AppIconImage()) {
    QeetrixButton("Unlock", icon: .lockOpen) { unlock() }
}
.centredInHeight()
QeetrixEmptyState("Sign-in approved", description: "You're signed in on your Mac.", icon: .circleCheck, tone: .success)
```

It shows what you give it: whether a list is empty because there is nothing yet, because a filter
excludes everything, or because a load failed is the app's to decide. For the loading, failure and
empty states of one screen together, use ``QeetrixDataState``.

### Accessibility

- With a `level` the title is a heading of that level, for VoiceOver's rotor — set one when this is the
  screen's main message. Without it, the title is text, as on the web. The look is the size's either
  way.
- The icon, or the image in its place, is decorative and hidden from VoiceOver; the actions are their
  own buttons.
- The text wraps at every Dynamic Type size and is centred in its line, in right-to-left layouts too.

### Platform differences

iOS draws it as the web does, with two additions for native outcome screens, as on Android: the
`success` and `warning` tones, and an image in place of the icon. The system's `ContentUnavailableView` is not used, because it
draws the system's type and colours rather than Qeetrix's.

On the web: [Empty state on ui.qeet.in](https://ui.qeet.in/components/empty-state/).

## Topics

### Size and tone

- ``QeetrixEmptyStateSize``
- ``QeetrixEmptyStateTone``
