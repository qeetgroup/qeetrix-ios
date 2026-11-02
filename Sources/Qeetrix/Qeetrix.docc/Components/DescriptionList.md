# ``Qeetrix/QeetrixDescriptionList``

## Overview

Facts about one record, as term and value pairs — `@qeetrix/react`'s DescriptionList: an approval
request's app, place, device and time; a user's email and ID; an audit event's actor and address.

```swift
QeetrixDescriptionList {
    QeetrixDescriptionItem("App", value: "Qeet Pay console")
    QeetrixDescriptionItem("Place", value: "Bengaluru, India")
    QeetrixDescriptionItem("Device", value: "MacBook Pro · Safari")
    QeetrixDescriptionItem("Status") { QeetrixBadge("Pending", tone: .warning) }
    QeetrixDescriptionItem("Phone", value: nil)
}
```

- **Reading.** Terms are `label.sm` in `color.text.subtle`; values `body.md` in `color.text.default`,
  wrapping rather than truncating. A value can be any content — a badge, a link, a copy button — whose
  pieces sit `space.gap.xs` apart and wrap. An empty value (`nil` or `""`) shows "—" in
  `color.text.subtlest`.
- **`rows`** (the default): the term column is 30 % of the row and at least 8 rem, beside the value
  and on its first baseline; rows are at least the density's `size.row` with `space.gap.sm` above and
  below, and a 1-point `color.border.subtle` rule between them. Narrower than 24 rem the term moves
  above its value.
- **`columns`**: terms above values, in at most `columns` columns (1 to 4, default 2) of at least
  8 rem — fewer where there isn't room — `space.gap.lg` between rows and `space.gap.xl` between
  columns.

```swift
QeetrixDescriptionList(layout: .columns, columns: 3) {
    QeetrixDescriptionItem("Actor", value: "priya@acme.in")
    QeetrixDescriptionItem("Event", value: "Signed in")
    QeetrixDescriptionItem("IP address", value: "203.0.113.24")
}
```

### Items

``QeetrixDescriptionItem`` takes a term and a text value, or a term and any content. A `description`
puts a sentence under the value; an `action` puts a control on the fact — a settings row:

```swift
QeetrixDescriptionItem("Display name", value: "Acme", description: Text("Shown in the top bar and in invitations.")) {
    QeetrixButton("Change", variant: .ghost, size: .sm) { editName() }
}
```

In `rows` the action is a third column at the row's end and the row centres on it; narrower than
24 rem it moves under the value, at the start; in `columns` it sits under the value, at the end.

**Values are what you pass.** Format dates, amounts and identifiers first, and never pass a secret: the
list logs, copies and announces nothing.

### Accessibility

- VoiceOver reads each pair as one element — "App, Qeet Pay console" — and the description with it. An
  item's action is its own control, after the pair; a control inside the value (a copy button) is
  offered as an action of the pair.
- An empty value is read as "Not set", or as `emptyLabel`.
- A text value takes its own direction, so an email, a phone number or an amount reads left to right in
  a right-to-left layout, at the layout's start.
- A rem is 16 points at the default text size and grows with Dynamic Type, so at the accessibility
  sizes the term column widens and the rows stack sooner — reflow, never truncation.

### Platform differences

- **The container query** is the width the list is given, as on the web: on an iPhone in portrait —
  compact width — a `rows` list stacks each term above its value; on an iPad or in landscape — regular
  width, or more than 24 rem — the term sits beside it.
- **Semantics.** iOS has no `dl`, `dt` and `dd`: each pair is one accessibility element drawn over the
  term and the value, and the action a second one.
- **In a card** the list keeps the card's padding: `QeetrixCard` has no edge-to-edge body yet, so the
  web's full-width rules stop at the padding.
- **Strings.** The web's `messages.empty` is `emptyLabel`.
- **`divided`** (qeetrix-android before its move to `@qeetrix/react`) is gone there too: `rows` are
  always ruled, `columns` never.

On the web: [Description list on ui.qeet.in](https://ui.qeet.in/components/description-list/).

## Topics

### Items and layout

- ``QeetrixDescriptionItem``
- ``QeetrixDescriptionListLayout``
