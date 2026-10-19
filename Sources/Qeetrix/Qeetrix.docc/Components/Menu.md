# ``Qeetrix/QeetrixMenu``

## Overview

A Qeetrix button that opens the system menu of actions: "More actions" on a row, a sort or export menu
in a toolbar.

```swift
QeetrixMenu(icon: .ellipsis, label: "More actions") {
    QeetrixMenuItem("Rename", icon: .pencil) { rename() }
    QeetrixMenuItem("Share", icon: .share2) { share() }
    Divider()
    QeetrixMenuItem("Delete", icon: .trash, role: .destructive) { confirmDelete() }
}
```

- The trigger is a ``QeetrixButton`` — any variant and size — with a title and a chevron, or an icon
  with a label.
- ``QeetrixMenuItem`` gives an item a Qeetrix icon and a role; `.destructive` draws it red. Disable an
  item with `disabled(_:)`: it stays visible, dimmed, and can't be chosen.
- `Divider`, `Section` and `Picker` work inside the menu as they always do, and the same items work in a
  `contextMenu`.
- A destructive item that can't be undone should open a ``QeetrixConfirmationDialog`` rather than act at
  once.

### Accessibility

The trigger is a button named by its title or label; the menu is the system's, so VoiceOver,
keyboard navigation and Dynamic Type work as everywhere on iOS.

### Platform differences

The menu surface is drawn by iOS in its own font and material: the web's `component.menu` tokens don't
apply. The web's checkbox items are a `Toggle`, and radio items a `Picker`, inside the menu.

On the web: [Dropdown Menu on ui.qeet.in](https://ui.qeet.in/docs/components/dropdown-menu).

## Topics

### Items

- ``QeetrixMenuItem``
