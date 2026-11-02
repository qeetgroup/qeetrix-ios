# ``Qeetrix/QeetrixCard``

## Overview

Related content on a screen — `@qeetrix/react`'s Card: a raised, ruled surface with 4-point corners
and no shadow (design rules §12).

```swift
QeetrixCard(title: Text("Team plan"), description: Text("Billed monthly")) {
    QeetrixText("Up to 25 members, with audit logs and SSO.")
} footer: {
    QeetrixButton("Upgrade", size: .lg) { upgrade() }
}
QeetrixCard(title: Text("Delete workspace"), tone: .danger) {
    QeetrixText("Removes every project and file, for everyone.")
} actions: {
    QeetrixButton("Delete", tone: .danger, size: .sm) {}
}
```

- **Anatomy.** `color.surface.raised` inside a 1-point `color.border.default` edge. An optional ruled
  header holds the title (`title.sm`), a line under it (`body.sm`, `color.text.subtle`) and actions at
  the end; the body (`body.md`) and an optional ruled footer, its actions end-aligned and wrapping, all
  take 16 points of padding (`space.inset.lg`), so the footer's actions line up with fields above.
- **Variant**: `default` (raised) or `subdued` (`color.surface.sunken`, for a secondary panel — still
  ruled, still no shadow).
- **Tone**: `neutral` or `danger`, a "danger zone" of settings that delete or can't be undone: the
  border and the title in the danger colour; the rules inside stay neutral, and the title's words
  carry the meaning.

### A card that is the control

``QeetrixCardButtonStyle`` makes a whole card a button, with the selection look of the web's choice
tiles: a neutral tint when pressed or hovered and, when selected, `color.bg.selected` inside a 2-point
Ember edge.

```swift
Button {
    choose(plan)
} label: {
    VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
        QeetrixHeading("Team plan", level: 3, size: .titleSm)
        QeetrixText("Billed monthly", size: .sm, tone: .subtle)
    }
}
.buttonStyle(.qeetrixCard(isSelected: plan == chosen))
```

Put only the card's content in its label — a title and short copy, never other controls.

### Accessibility

- A titled card's title is a heading of `headingLevel` (2 by default): the page sets the outline, not
  the look.
- A selected card button is read as selected.

### Platform differences

- **Selectable cards** are iOS only: `@qeetrix/react` 0.4.0 has no whole-card target yet (its spec
  names a future SelectionCard). The look follows the web's choice tiles.
- **Tables** run edge to edge in a web card's body; iOS has no Qeetrix table yet.

On the web: [Card on ui.qeet.in](https://ui.qeet.in/components/card/).

## Topics

### Styling

- ``QeetrixCardVariant``
- ``QeetrixCardTone``
- ``QeetrixCardButtonStyle``
