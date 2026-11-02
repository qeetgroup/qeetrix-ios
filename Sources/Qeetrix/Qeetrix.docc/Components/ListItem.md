# ``Qeetrix/QeetrixListItem``

## Overview

A row of a collection — an account, a setting, a device, a file — with a title and, optionally, a
description, a value, a leading avatar or icon, trailing content and an accessory. Qeet Auth's account
list and its settings are lists of them.

```swift
List {
    Section {
        QeetrixListItem("Priya Sharma", description: Text(verbatim: "priya@acme.in"), value: Route.account) {
            QeetrixAvatar(name: "Priya Sharma", isDecorative: true)
        }
    } header: {
        QeetrixSectionHeader("Accounts", isRuled: false)
    }
    .listSectionSeparator(.hidden)
    Section {
        QeetrixListItem("Face ID", description: Text("Unlock Qeet Auth with your face"), isOn: $faceID) {
            QeetrixListItemIcon(.scanLine)
        }
        QeetrixListItem("Language", metadata: Text("English"), accessory: .chevron) { showLanguages = true }
        QeetrixListItem("Sign out", role: .destructive) { signOut() }
    } header: {
        QeetrixSectionHeader("Security")
    }
    .listSectionSeparator(.hidden)
}
.qeetrixListStyle()
```

- **Anatomy**, from the Table's rows (design rules §15): at least the density's `size.row` and 44 points
  tall — 44 in the compact and default densities, 48 in the comfortable one — with `space.gap.xs` above
  and below the content, the page gutter (`space.inset.lg`) at the sides and `space.gap.md` between its
  parts. The title is `label.md` in `color.text.default`; the description `body.sm` in
  `color.text.subtle` under it; the value (`metadata`) `body.sm`, tabular figures, at the end of the
  title's line, on its baseline and at most half the width.
- **Leading**: a ``QeetrixListItemIcon`` — a 32-point tile, a `md` avatar's size, drawn as the
  Timeline's marker: `color.bg.neutral.subtle`, a 1-point `color.border.subtle` edge, 4-point corners
  and a 16-point sharp icon in `color.icon.subtle` — or a ``QeetrixAvatar``.
- **Trailing**: a badge, a short text, a spinner. Then the accessory: the sharp `chevron-right` in
  `color.icon.subtle` (menu.css's submenu chevron), or, for a setting, the Qeetrix switch.

### What a row does

The initialiser decides:

| Initialiser | The row is | At its end |
|:--|:--|:--|
| `QeetrixListItem(_:description:metadata:accessory:isSelected:leading:trailing:)` | content only | `accessory` |
| `…(_:…:role:action:leading:trailing:)` | a `Button`; `role: .destructive` draws the title in `color.text.danger` and the icon tile's icon in `color.icon.danger` | `accessory` — `.chevron` when the action opens a screen |
| `…(_:…:value:leading:trailing:)` | a `NavigationLink` that presents `value` | the chevron |
| `…(_:…:isOn:leading:trailing:)` | a setting: the whole row toggles it | the Qeetrix switch |

| State | Look |
|:--|:--|
| Pressed / under the pointer | `color.bg.neutral.subtle-hover` / `color.bg.neutral.subtle` (§15's neutral tint) |
| Selected (`isSelected`) | `color.bg.selected` (`-hover` while pressed), read as selected. The Ember tint means "chosen for an action", not the current item (§11). So that it isn't colour alone, mark it too: a sharp `check` in `trailing`, as iOS marks a chosen option |
| Keyboard focus | The 2-point Ember frame inside the row (§10, table rows) |
| Disabled (`disabled(_:)`) | `color.text.disabled` title, `color.text.subtlest` description, `color.icon.disabled` icons; it ignores taps |

### Any button as a row

``QeetrixListItemButtonStyle`` gives the row's look to any `Button`, `NavigationLink`, `ShareLink` or
`Menu` whose label is a ``QeetrixListItem``:

```swift
ShareLink(item: inviteURL) {
    QeetrixListItem("Invite a teammate") { QeetrixListItemIcon(.userPlus) }
}
.buttonStyle(.qeetrixListItem())
```

### In a list, in a stack

- **In a `List`** the row sets its own insets, sits on `color.surface.raised`, and tints the list's
  separators `color.border.subtle`, edge to edge as a table's rules are. `qeetrixListStyle()` makes the
  list plain — square and ruled — on the page's `color.surface.canvas`. A ``QeetrixSectionHeader``
  draws the rule between groups, so hide the list's own section separators with
  `listSectionSeparator(.hidden)` on each section.
- **In a stack**, put a ``QeetrixSeparator`` between rows.
- **Show people's data verbatim.** `Text("priya@acme.in")` is read as Markdown, so iOS turns an email
  address or a web address in it into a link: drawn in the tint, read by VoiceOver as a link, and
  tappable inside the row. Pass a name, email or phone number as `Text(verbatim:)`.
- **The list's behaviours are the list's.** Swipe actions (``QeetrixSwipeAction``, applied with
  `qeetrixSwipeActions(edge:allowsFullSwipe:actions:)`), pull to refresh (<doc:PullToRefresh>),
  `onDelete`, `onMove` and selection in edit mode are applied to the row or the list; the row adds none
  of them and takes none away.

### Accessibility

- VoiceOver reads a row as one element: the title, the description, the value, then any text in
  `leading` and `trailing`. Give a leading avatar `isDecorative: true` when the title names the person,
  so it isn't read twice. A button or link row is a button; a selected row is selected; a setting is
  read as the system's switch, with its state.
- A control in `trailing` becomes part of the row: its name is read with the row's and VoiceOver offers
  it as the row's action. Prefer ``QeetrixSwipeAction``s, which also reach VoiceOver and the row's
  context menu, applied to the row from outside.
- Every row is at least 44 points tall and its whole width is the target.
- Text wraps, never truncates. From the accessibility sizes the trailing content moves below the text
  and the value below the description; the icon tile grows with its icon.
- The chevron mirrors in right-to-left layouts: `@qeetrix/icons` marks it `preserve`, so the row
  decides, as react's menu does.

### Platform differences

- **iOS's own row.** `@qeetrix/react` has no list row — a web screen uses a Table where a phone uses a
  list — so the row follows qeetrix-android's `QeetrixListItem`, in Swift idiom: `onClick` is `action`,
  `selected` `isSelected`, `enabled` the environment's `disabled(_:)`, `onLongClick` a `contextMenu`
  applied from outside, and navigation a `NavigationLink` value. The accessory, the switch row and the
  destructive role are iOS's additions, for Qeet Auth's settings.
- **System first** (ADR 0014). In a `List` the row is the list's own cell, so swipe actions, pull to
  refresh and edit mode are the system's. The row hides the list's disclosure indicator on its own
  link, because it draws the Qeetrix chevron.
- **The switch is at the end** of a setting's row, as in iOS's settings, where ``QeetrixSwitch`` puts
  the control first (design rules §9).
- **44 points**, not Android's 48 dp, as the minimum.
- **A selection inside a `List`** is drawn by the row (`isSelected`); the row's surface replaces the
  list's own selection highlight.

## Topics

### Parts

- ``QeetrixListItemIcon``
- ``QeetrixListItemAccessory``

### Styling

- ``QeetrixListItemButtonStyle``
