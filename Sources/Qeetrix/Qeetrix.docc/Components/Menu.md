# ``Qeetrix/QeetrixMenu``

## Overview

A menu of actions opened from a Qeetrix button — `@qeetrix/react`'s Menu with its trigger.

```swift
QeetrixMenu("Export", icon: .share2) {
    QeetrixMenuItem("Export as CSV", icon: .copy, description: Text("Opens in a spreadsheet")) { export() }
}

QeetrixMenu(icon: .ellipsis, label: "Actions for Priya Sharma") {
    QeetrixMenuItem("Edit", icon: .pencil) { rename() }
    QeetrixMenuItem("Share", icon: .share2) { shareItem() }
    Divider()
    QeetrixMenuItem("Remove from Acme", icon: .trash, tone: .danger) { confirmDelete() }
}
```

- **The trigger** is a ``QeetrixButton`` — `soft` with a trailing icon, a chevron unless you give one —
  or, icon-only, a neutral ghost ``QeetrixIconButton``, as ui.qeet.in builds them. Variant, tone and
  size are a button's.
- **Items** (``QeetrixMenuItem``): a title, an optional leading 16-point sharp icon, an optional second
  line, and `tone: .danger` for a destructive action. Put destructive items last, after a `Divider`.
  Keep to about seven items per group.

### Accessibility

The list is the system menu, so VoiceOver, the keyboard and Switch Control work with it as with any
menu. An icon-only trigger is named by its label and shows it as a pointer tooltip.

### Platform differences

The list is the system menu (ADR 0014): its surface, font, highlight and keyboard handling are the
system's, so `@qeetrix/react`'s menu surface, its 2-point Ember highlight edge, shortcuts, checkbox and
radio items and submenus with Qeetrix styling don't apply; a destructive item is drawn in the system's
red. Use SwiftUI's `Menu`, `Toggle` and `Picker` inside for nested, checkable or single-choice items.

On the web: [Menu on ui.qeet.in](https://ui.qeet.in/components/menu/).

## Topics

### Items

- ``QeetrixMenuItem``
- ``QeetrixMenuItemTone``
