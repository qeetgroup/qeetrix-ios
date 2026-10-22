# ``Qeetrix/QeetrixEmptyState``

## Overview

What a surface shows when there is nothing to show — an empty collection, no results, no permission, a
failed load, a first use.

```swift
QeetrixEmptyState("No invoices yet", description: Text("Invoices appear here once you bill a customer."),
                  variant: .firstUse, icon: .fileText) {
    QeetrixButton("Create invoice") { createInvoice() }
}
```

- **Variants** say why: `default`, `firstUse` (the only brand-tinted one), `noResults` (search-x),
  `noPermission` (lock) and `error` (triangle-alert, the destructive tint on the tile only).
- **Sizes.** `sm` for a section or a side panel, `default` for a collection, `lg` for a whole screen.
- **Actions** are buttons you pass, centred, wrapping when they don't fit.

It renders what you give it. Your app decides why a surface is empty, what the words are and what an
action does. Never put a raw error, a status code or a stack trace in the description.

Use ``QeetrixDataState`` to keep the loading, failure and empty branches of one surface together.

### Accessibility

The tile is decorative. The title is a heading, then the description and the actions are read in order.

### Platform differences

SwiftUI's `ContentUnavailableView` shows the system's large symbol in the system font; this view draws
the Qeetrix contract — the tinted tile, the tone per variant, the sizes and Qeet Sans — so an empty state
looks the same in a list, a card and a screen.

On the web: [Empty State on ui.qeet.in](https://ui.qeet.in/docs/components/empty-state).

## Topics

### Options

- ``QeetrixEmptyStateVariant``
- ``QeetrixEmptyStateSize``
