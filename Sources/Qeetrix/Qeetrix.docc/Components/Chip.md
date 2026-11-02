# ``Qeetrix/QeetrixChip``

## Overview

A tag someone acts on — `@qeetrix/react`'s Chip: a filter that turns on and off, or a choice already
made, with a button that takes it away (design rules §14).

```swift
@State private var unread = false

QeetrixChipFlowLayout {
    QeetrixChip("Unread", isSelected: $unread)
    QeetrixChip("Mentions", isSelected: $mentions, icon: .bell)
    QeetrixChip("Status: Active") { removeStatusFilter() }
}
```

- **Look**: FilterTags' tag — `color.bg.neutral.subtle` with a 1-point `color.border.subtle` edge
  drawn inside it, the controls' 4-point corners, the label in `label.md` and `color.text.default`,
  8 points either side and 4 between its parts.
- **Size**: `sm`, `md` (default) or `lg`, at the controls' heights — 24, 28 or 32 points at compact
  density; 28, 32 or 40 at default; 32, 36 or 44 at comfortable. `sm` sets the label in `label.sm`.
- **Selectable**: the neutral tints' `-hover` and `-pressed` steps under the pointer and a press.
  Chosen, `color.bg.selected` (`-hover` under the pointer) inside a 2-point Ember edge, with a 16-point
  sharp check before the label, so the choice never rests on colour; an `icon` takes the check's place
  and the edge still marks the choice.
- **Removable**: a static label ending in a small neutral icon button (`x`), named "Remove {label}"
  — `removeLabel` names it otherwise. The button takes the pointer, so the chip has no hover of its
  own. Removing the chip, and moving focus to the next, are yours.
- **Disabled**, through `disabled(_:)`: `color.bg.disabled`, the disabled edge and
  `color.text.disabled`; a removable chip's label dims only to `color.text.subtlest`, as it is still
  information, and its button is disabled.
- **Long labels** wrap and the chip grows; nothing is cut.

A status no one can change is a ``QeetrixBadge``; a choice in a form that's submitted, a
``QeetrixCheckbox``; a mode or a view of the same thing, a ``QeetrixSegmentedControl``.

### Groups

``QeetrixChipGroup`` chooses from a set. A `Binding<Value>` chooses one value — the chips are radios,
and choosing one releases the other; a `Binding<Set<Value>>` chooses any number — the web's `multiple`
— each chip a checkbox. Its label names the group for VoiceOver and isn't shown.

```swift
QeetrixChipGroup(
    "Status", selection: $status,
    options: [
        QeetrixOption("All", value: nil),
        QeetrixOption("Open", value: .open),
        QeetrixOption("Closed", value: .closed),
    ],
    size: .sm)
QeetrixChipGroup("Departments", selection: $departments, options: departmentOptions, overflow: .scroll)
```

The chips wrap onto more lines, `space.gap.sm` apart; with `overflow: .scroll` they stay on one line
that scrolls sideways, for a filter bar over a list. ``QeetrixChipFlowLayout`` lays out chips you place
yourself — removable ones — the same way.

### Any toggle, the chip style

`.toggleStyle(.qeetrixChip())` gives any `Toggle` the selectable chip's look:

```swift
Toggle("Starred", isOn: $starred)
    .toggleStyle(.qeetrixChip(icon: .pin))
```

### Accessibility

A selectable chip is read as the system's toggle, named by its label, and VoiceOver says when it turns
on or off; in a one-value group each chip is a button that is selected or not, with its option's
description as the hint. A removable chip is its label — with "Remove {label}" in its actions, so it can
be removed from the label too — then the "Remove {label}" button. Every chip is a 44-point target: on its
own its target extends past its drawn edge without moving layout; in a group or a flow layout each chip
has a slot at least 44 points square, so neighbouring targets never overlap. The label scales with
Dynamic Type and Bold Text, and wraps. Colour changes take `motion.duration.fast`, none under Reduce
Motion. In right-to-left layouts the check leads on the right and the chips flow from the right.

### Platform differences

- **Rows of chips** are at least 44 points tall, so wrapped rows sit 8 points apart or more — 12 at the
  default density's `md` — where the web's are always 8.
- **Keyboard.** The web's one-value group is one Tab stop with arrow keys; on iOS each chip is its own
  focus stop.
- **Options.** A group's chips come from ``QeetrixOption``s, which have no icon; give a chip an icon by
  placing ``QeetrixChip``s yourself in a ``QeetrixChipFlowLayout``.
- **Size** is ``QeetrixControlSize``, the values of the web's `ChipSize`.

On the web: [Chip on ui.qeet.in](https://ui.qeet.in/components/chip/).

## Topics

### Groups

- ``QeetrixChipGroup``
- ``QeetrixChipGroupOverflow``
- ``QeetrixChipFlowLayout``

### Styles

- ``QeetrixChipToggleStyle``
