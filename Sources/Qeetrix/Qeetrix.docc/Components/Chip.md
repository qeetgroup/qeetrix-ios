# ``Qeetrix/QeetrixChip``

## Overview

A pill that filters or chooses.

```swift
QeetrixChip("Unread", isSelected: $showsUnread)

let statuses: [QeetrixOption<Status?>] = [
    QeetrixOption("All", value: nil),
    QeetrixOption("Open", value: .open),
    QeetrixOption("Closed", value: .closed),
]
QeetrixChipGroup("Status", selection: $status, options: statuses)

QeetrixChip("Design", icon: .folder) { labels.remove("Design") }
```

- **Toggle** with `isSelected`: a selected chip is tinted, edged with the brand and checked.
- **Group** with ``QeetrixChipGroup``: one value (radio behaviour) or a `Set` (each chip toggles). Chips
  wrap onto more lines; put the group in a horizontal `ScrollView` for one scrolling row.
- **Removable** with `onRemove`: a choice already made, with a remove button.
- **Sizes** `sm`, `md` (the default) and `lg`: 24, 28 and 32 pt, with a 44 pt touch target around each.

A chip changes your state; your app decides what it filters. A status that doesn't change on a tap is a
``QeetrixBadge``.

### Accessibility

A selectable chip is a button that is reported selected or not; the check mark means selection never
rests on colour alone. A group is named by its label. A remove button is "Remove" with the chip's title
as its value.

### Platform differences

The web's single-choice group moves selection with the arrow keys; iOS gives each chip its own focus
stop, as for radio buttons.

On the web: [Chip on ui.qeet.in](https://ui.qeet.in/docs/components/chip).

## Topics

### Groups and sizes

- ``QeetrixChipGroup``
- ``QeetrixChipSize``
