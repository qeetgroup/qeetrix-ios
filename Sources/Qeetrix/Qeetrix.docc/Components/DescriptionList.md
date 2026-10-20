# ``Qeetrix/QeetrixDescriptionList``

## Overview

The properties of one thing — a plan, a device, a document — as terms and values.

```swift
QeetrixDescriptionList(isDivided: true) {
    QeetrixDescriptionItem("Plan", value: Text("Team"))
    QeetrixDescriptionItem("Created", value: Text(createdAt, style: .date))
    QeetrixDescriptionItem("Status") { QeetrixBadge("Active", variant: .success) }
}
```

- **Layouts.** `horizontal` puts a 192 pt term column beside the values in a regular-width window and
  stacks each term over its value in compact width; `vertical` always stacks; `grid` fills the width
  with term-over-value cells at least 192 pt wide.
- **Divided** draws a `border-subtle` rule between pairs, never above the first.
- **Values** are any view, set in primary `text-sm`; long identifiers wrap instead of overflowing.
- **Density.** Pairs are the density's cell padding apart.

The values are yours: format dates, amounts and identifiers before you pass them, and decide whether a
value is safe to show. The list doesn't copy, log or announce anything you haven't displayed — a copy
action, where you want one, is a button you put beside the item.

In a `List`, use one ``QeetrixDescriptionItem`` per row: the list draws the separators.

### Accessibility

Each item is one element — "Plan, Team" — so the term is read with its value. A value that holds a
control should sit outside the item, where it is reachable on its own.

### Platform differences

The web switches to columns at its `sm` breakpoint (640 px); iOS switches on the horizontal size class,
so an iPad in a narrow split or sheet stacks too.

On the web: [Description List on ui.qeet.in](https://ui.qeet.in/docs/components/description-list).

## Topics

### Items

- ``QeetrixDescriptionItem``
- ``QeetrixDescriptionListLayout``
