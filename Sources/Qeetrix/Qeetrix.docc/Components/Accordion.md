# ``Qeetrix/QeetrixAccordion``

## Overview

Stacked sections that show and hide, ruled like every surface — `@qeetrix/react`'s Accordion.

```swift
@State private var open: Section? = .tax

QeetrixAccordion(expanded: $open) {
    QeetrixAccordionItem("Tax settings", value: Section.tax) {
        QeetrixText("GST is added at 18%.")
    }
    QeetrixAccordionItem("Invoice numbering", value: Section.numbering) {
        QeetrixText("INV-YYYY-NNNN")
    }
}
```

- **Rules**: a 1-point `color.border.subtle` rule above each section and below the last.
- **Trigger**: full width, at least `size.control.lg` tall — and at least 44 points — with the title in
  `title.sm` and `color.text.default`, then 12 points on a 16-point sharp `chevron-down` in
  `color.icon.subtle` that turns half a turn when open.
- **Summary**: a section's optional `description` — today's choice while it's closed, "6 digits · every
  30 seconds · SHA-1" — sits under the title in `body.sm`, `color.text.subtle`, 4 points inside the
  trigger above and below, and stops short of the chevron, which stays on the title's first line.

  ```swift
  QeetrixAccordionItem("Advanced", description: Text("6 digits · every 30 seconds · SHA-1"), isExpanded: $showsAdvanced) {
      CodeSettings()
  }
  ```
- **Content**: set in `body.md` and `color.text.default`, with 16 points below it. It opens and closes
  by height over `motion.duration.normal` with `motion.easing.standard`, as the chevron turns.
- **Disabled**, through `disabled(_:)` on a section or the whole accordion: the title in
  `color.text.disabled`, the chevron in `color.icon.disabled`, and it can't be toggled.

### Which sections are open

The app owns it. A `Binding<Value?>` opens one section at a time — opening one closes the other, and
`nil` closes all; a `Binding<Set<Value>>` opens any number, the web's `multiple`. Sections are found by
their values, so inserting, removing or reordering them keeps each one's state.

```swift
@State private var open: Set<Section> = [.tax]

QeetrixAccordion(expanded: $open) {
    QeetrixAccordionItem("Tax settings", value: Section.tax) { QeetrixText("GST is added at 18%.") }
    QeetrixAccordionItem("Reminders", value: Section.reminders) { QeetrixText("Off") }
        .disabled(true)
}
```

### A single section

A ``QeetrixAccordionItem`` with its own `isExpanded` binding is one collapsible section — for "Show
more" or advanced options — ruled above and below when it stands alone. In a ``QeetrixAccordion``
without a binding, each section brings its own.

```swift
QeetrixAccordionItem("Advanced options", isExpanded: $showsAdvanced) {
    QeetrixSwitch("Retry failed webhooks", isOn: $retries)
}
```

Any `DisclosureGroup` takes the same look with ``QeetrixAccordionDisclosureGroupStyle``:

```swift
DisclosureGroup("Retry policy", isExpanded: $showsRetries) {
    QeetrixText("Three attempts, a minute apart.")
}
.disclosureGroupStyle(.qeetrixAccordion())
```

### Accessibility

VoiceOver reads each trigger as a heading of `headingLevel` (3 by default, as on the web) and a button:
its title, then its summary, with the value "Expanded" or "Collapsed"; a closed section's content is
hidden from it. Triggers are
44-point rows and their titles wrap at large text sizes. Under Reduce Motion the content opens and the
chevron turns at once. Keyboard focus is the Ember frame inside the trigger. In right-to-left layouts
the chevron sits on the left.

### Platform differences

- **Built on `DisclosureGroup`**, the system's disclosure control, styled.
- **Triggers** are at least 44 points tall where the web's are `size.control.lg`: triggers stack flush,
  so a target extended past the drawn row would overlap the next one.
- **Closed content** stays laid out at no height, hidden from VoiceOver and touch, as the web keeps a
  closed panel in the page. The web's find in page has no counterpart.
- **Collapsible.** The web's Collapsible renders a trigger of your own; on iOS a single section is an
  accordion item with its own binding.

On the web: [Accordion on ui.qeet.in](https://ui.qeet.in/components/accordion/).

## Topics

### Sections

- ``QeetrixAccordionItem``
- ``QeetrixAccordionDisclosureGroupStyle``
