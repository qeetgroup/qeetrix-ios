# ``Qeetrix/QeetrixListItem``

## Overview

A row of a collection — a file, a member, a setting — in a native `List` or on its own. It presents;
your `List`, `ForEach`, `NavigationLink` and `Button` do the rest.

```swift
List {
    Section {
        ForEach(files) { file in
            NavigationLink(value: file) {
                QeetrixListItem(file.name, description: Text(file.owner), metadata: Text(file.size), icon: .fileText) {
                    QeetrixBadge(file.status, variant: .secondary)
                }
            }
            .qeetrixListRow()
            .swipeActions { Button("Delete", role: .destructive) { delete(file) } }
        }
    } header: {
        QeetrixSectionHeader("Files", description: Text("Shared with your team."))
    }
}
```

- **Slots.** A title, and optionally a description, metadata at the end of the title line, a leading
  view (``QeetrixListItemIcon``, ``QeetrixAvatar``) and a trailing view (a ``QeetrixBadge``, a value, a
  ``QeetrixMenu``). The unlabelled closure is the trailing view; name `leading:`.
- **In a `List`.** A row that is the list item sets its own insets and surface. A row wrapped in a
  `NavigationLink` or a `Button` gets them from `qeetrixListRow()` on the link or button —
  a list reads row settings from the row's outermost view. The separator lines up under the title, and a
  link's chevron keeps its margin.
- **On its own.** In a card or a sheet, stack rows in a `VStack(spacing: 0)` with ``QeetrixSeparator``
  between them, and give buttons ``QeetrixListItemButtonStyle`` for the pressed and hovered surface.
- **Selection** is a value you keep: pass `isSelected`, and the row takes the brand tint, a 2 pt brand
  edge and the selected trait.
- **Density.** The row is the density's row height, and never under 44 pt; its vertical padding is the
  density's cell padding.
- **Large text.** At the accessibility sizes the trailing view moves below the text.

A setting that is a switch is a ``QeetrixSwitch`` row, not a list item with a switch in it: the switch
row is the label and the control in one target.

### Accessibility

The title, description and metadata are one element, read in that order; the leading icon is decorative.
A row wrapped in a link or a button is one button, with the selected trait when it is selected. Controls
in the trailing view stay separately reachable — so don't put a button inside a row that is itself a
button: use swipe actions, a context menu, or a menu beside the row.

### Platform differences

The web has no list-row component: a web table or listbox does this job. This is the iOS row that every
collection screen is built from, made of the web's type and colour tokens — the notification row's
composition and the table's selected-row colours.

## Topics

### Rows

- ``QeetrixListItemIcon``
- ``QeetrixListItemButtonStyle``
- ``QeetrixSectionHeader``
