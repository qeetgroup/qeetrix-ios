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
- **Tone**: `neutral`, or `danger`, which colours the icon `color.icon.danger` for an error.
- **Width**: at most 480 points, centred, with 16 points at the sides. The actions wrap onto more
  rows, centred: one primary at most.
- **Words.** The title says what is missing ("No accounts yet"); the description, why and what to do.
  Never show a raw error, a status code or a server message.

It shows what you give it: whether a list is empty because there is nothing yet, because a filter
excludes everything, or because a load failed is the app's to decide. For the loading, failure and
empty states of one screen together, use ``QeetrixDataState``.

### Accessibility

- With a `level` the title is a heading of that level, for VoiceOver's rotor — set one when this is the
  screen's main message. Without it, the title is text, as on the web. The look is the size's either
  way.
- The icon is decorative and hidden from VoiceOver; the actions are their own buttons.
- The text wraps at every Dynamic Type size and is centred in its line, in right-to-left layouts too.

### Platform differences

None: iOS draws it as the web does. The system's `ContentUnavailableView` is not used, because it
draws the system's type and colours rather than Qeetrix's.

On the web: [Empty state on ui.qeet.in](https://ui.qeet.in/components/empty-state/).

## Topics

### Size and tone

- ``QeetrixEmptyStateSize``
- ``QeetrixEmptyStateTone``
