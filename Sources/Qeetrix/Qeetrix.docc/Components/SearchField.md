# ``Qeetrix/QeetrixSearchField``

## Overview

A search box for a list — `@qeetrix/react`'s SearchField: the Qeetrix field with a search icon, the
keyboard's search key, and a Clear search button while there is text.

```swift
@State private var query = ""

QeetrixSearchField(text: $query, prompt: Text("e.g. Asha")) { query in
    accounts.search(query)
}
QeetrixSearchField("Find a member", text: $query, description: Text("Name or email."))
```

- **The box** is the Qeetrix field (design rules §8): `color.bg.neutral.subtle`, the 1-point
  `color.border.strong` bottom line, 4-point top corners, `size.control.lg` tall; the sharp 16-point
  `search` icon in `color.icon.subtle` at the start, the text in `body.md`, and 4 points at the end for
  the clear button (search-field.css). Focus draws the 2-point Ember frame inside the box.
- **Searching.** `onSearch` runs when typing pauses for `searchDelay` (300 ms by default), at once on the
  keyboard's search key, and with "" when the field is cleared — so a list searched on a server asks
  once per pause, not per key, and the search key never asks twice. Text you write into the binding
  yourself is not searched. Filter a short local list on every change of the binding instead, if you
  like; `onSearch` is optional.
- **Clearing.** While there is text, "Clear search" — a neutral `sm` ``QeetrixIconButton`` with a sharp
  `x` — empties the field, searches "" and keeps the keyboard. **Escape** on a hardware keyboard clears
  the text first, and only lets the key through once the field is empty, so a sheet around the field
  closes on the second press.
- **Name.** Give a label to show it above the field, or none: the field is then named "Search" for
  VoiceOver and its icon is the visible sign, as in a toolbar. The prompt is an example, never an
  instruction. `description` is help under the field.
- **States.** Read-only (`isReadOnly`) shows the query without the fill or the clear button, selectable;
  disabled (`.disabled(true)`) dims the box and hides the clear button.

### The system search bar

Where search belongs to a whole screen — a list in a `NavigationStack` — the system's search bar is the
native choice. `qeetrixSearchable(text:placement:prompt:searchDelay:onSearch:)` puts it there with the
same search behaviour and the brand tint:

```swift
NavigationStack {
    List(results) { account in
        Text(account.name)
    }
    .navigationTitle("Accounts")
    .qeetrixSearchable(text: $query, prompt: Text("e.g. Asha")) { query in
        results = accounts.matching(query)
    }
    .qeetrixNavigationBar()
}
```

`onSearch` runs when typing pauses, on the search key, and with "" as soon as the text is emptied — by
the bar's clear button, Cancel or the delete key. The caret and Cancel are Ember (`color.text.brand`).

### Accessibility

- VoiceOver reads the field as a search field, by its label or "Search", with its value and its
  description as the hint. The clear button is "Clear search".
- A tap on the padding or the icon focuses the field: the target is at least 44 points tall. At
  larger text sizes the box grows in proportion.
- Search terms can be personal: keep them out of logs and analytics.

### Platform adaptations

- **The system search bar** is drawn by iOS in its own font and fill, with its own placement, scope bar,
  scroll behaviour and Cancel (ADR 0014); Qeetrix gives it the search behaviour and the tint, not the
  field box.
- **Escape in the system bar** does what iOS does with it; the field's clear-first rule is
  ``QeetrixSearchField``'s.
- **Clearing the system bar** searches "" at once whichever way the text was emptied; it can't tell the
  clear button from the delete key.
- **No end adornment.** The web's `endAdornment` (tools before the clear button) has no iOS counterpart
  yet.
- **The keyboard's search key** is the web's Enter; it searches at once and puts the keyboard away.

On the web: [Search field on ui.qeet.in](https://ui.qeet.in/components/search-field/).
