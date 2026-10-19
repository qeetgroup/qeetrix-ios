# ``Qeetrix/QeetrixCard``

## Overview

A surface that groups related content: an optional header, the content, and an optional footer band.

```swift
QeetrixCard {
    QeetrixCardHeader("Team plan", description: "Billed monthly") {
        QeetrixBadge("Current", variant: .brand)
    }
    QeetrixText("Up to 25 members, with audit logs and single sign-on.")
} footer: {
    QeetrixButton("Upgrade") {}
}
```

- **Variants.** `default` is the resting card: a boundary and the faintest shadow. `outline` drops the
  shadow for dense layouts and repeated tiles. `elevated` stands one step forward; use it for the one
  surface on a screen that should.
- **Sizes.** `default` has 16 pt padding and gaps, `sm` 12 pt.
- **Selection.** `isSelected` paints a 2 pt brand boundary without moving anything.
- **Nesting.** A card inside a card keeps its boundary and drops its shadow.

### A card that is the control

For a card that is itself tappable, give a `Button` (or a `NavigationLink`) the card style:

```swift
Button {
    choose(plan)
} label: {
    QeetrixCardHeader("Team plan", description: "Billed monthly")
}
.buttonStyle(.qeetrixCard(isSelected: plan == chosen))
```

Put only the card's content in the label — never other controls.

### Accessibility

- A static card is not an element of its own; VoiceOver reads its contents in order. Card titles are
  headings, so the rotor can move between cards.
- `isSelected` on a static card is visual only: carry the state in the control that owns it. On the
  card button style VoiceOver reads the button as selected.

### Platform adaptations

- **Press feedback.** The web lifts an interactive card under the pointer and does nothing more on
  press. Touch has no hover, so here a press shows the hover boundary; under an iPad pointer the card
  lifts as on the web.
- **Edge-to-edge media.** The web clips an image placed first or last to the card's corners. Here the
  content is one padded region; put full-bleed media in the content with negative padding if needed.

On the web: [Card on ui.qeet.in](https://ui.qeet.in/docs/components/card).

## Topics

### Parts

- ``QeetrixCardHeader``

### Styling

- ``QeetrixCardVariant``
- ``QeetrixCardSize``
- ``QeetrixCardButtonStyle``
