# ``Qeetrix/QeetrixAccordion``

## Overview

Sections whose headers show and hide their content, built from native `DisclosureGroup`s.

```swift
QeetrixAccordion {
    QeetrixAccordionItem("Billing", description: Text("Invoices and payment method"), icon: .fileText) {
        BillingSettings()
    }
    QeetrixAccordionItem("Members", icon: .users) {
        MemberSettings()
    }
}
```

- **The header** is `text-sm` medium with a chevron at the trailing end that turns as it opens; the
  content is primary `text-sm` below it. Items are ruled between, not after the last.
- **Expansion.** Each item keeps its own state unless you pass `isExpanded`. Several can be open at
  once; for one at a time, derive each item's binding from one optional value you own — see the example
  on ``QeetrixAccordion``.
- **Any `DisclosureGroup`** takes the look with `.disclosureGroupStyle(.qeetrix)`, inside an accordion
  or on its own — including in a `List` row, where the list draws the separators.
- **Motion.** The content opens over the accordion's 200 ms, or at once with Reduce Motion on.

### Accessibility

Each header is one button with the heading trait, and "Expanded" or "Collapsed" as its value. The
content is read in order after it.

### Platform differences

The web animates the panel's measured height; iOS fades the content in as the stack grows. The
accordion's tokens resolve at the default density, so the header's padding doesn't follow a compact
density as the web's does.

On the web: [Accordion on ui.qeet.in](https://ui.qeet.in/docs/components/accordion).

## Topics

### Items and style

- ``QeetrixAccordionItem``
- ``QeetrixDisclosureGroupStyle``
