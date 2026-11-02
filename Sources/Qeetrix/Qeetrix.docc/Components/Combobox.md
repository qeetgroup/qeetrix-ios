# ``Qeetrix/QeetrixCombobox``

## Overview

Pick from a long list — dozens to thousands of options — by searching it: `@qeetrix/react`'s
Combobox on a phone. Where ``QeetrixSelect``'s menu suits up to about 15 options, the combobox opens
a sheet with a search field, the options in groups, the current choice marked, and "No matches" when
nothing fits.

```swift
@State private var country: String? = nil

let countries: [QeetrixComboboxItem<String?>] = [
    QeetrixComboboxItem("India", value: "IN"),
    QeetrixComboboxItem("Germany", value: "DE", description: "Deutschland"),
    QeetrixComboboxItem("United Arab Emirates", value: "AE"),
]

QeetrixCombobox(
    "Country", selection: $country, items: countries, placeholder: Text("e.g. India"),
    searchPrompt: Text("e.g. Germany"))
```

- **The trigger** is the Select's (design rules §8): the filled field with its 1-point
  `color.border.strong` bottom line, the choice in `body.md` or the placeholder in
  `color.text.subtlest`, and a trailing 16-point sharp chevron in `color.icon.default`. While its sheet
  is open it shows the 2-point Ember frame, as the web's field does while its list is open. Invalid,
  read-only and disabled are the field's looks; read-only and disabled don't open.
- **The sheet** has a ruled header — the field's label in `title.md`, Close (a neutral `sm` ghost icon
  button) and a ``QeetrixSearchField`` — then the options as ``QeetrixListItem`` rows ruled in
  `color.border.subtle`. A chosen option has a sharp 16-point `check` in `color.icon.brand` at its end;
  a disabled one is dimmed and can't be chosen; an option's `description` is its second line. The sheet
  opens scrolled to the first choice.
- **Groups.** Give `groups:` instead of `items:` and each group is headed by a
  ``QeetrixSectionHeader``, which stays pinned while its rows scroll. Groups with nothing that matches
  are left out.

### Choosing

- **One choice** — `selection: Binding<Value>` — sets the value and closes the sheet. "Nothing chosen"
  is a value no option has, such as `nil`, and shows the placeholder. To offer "none" as a choice, give
  it an option of its own.
- **Several** — `selection: Binding<Set<Value>>` — adds or removes an option with each tap; the sheet
  stays open, and **Done** (a ghost `sm` button in place of Close) closes it. The trigger shows the
  option's label while one is chosen, and "3 selected" from two (`combobox.selected`).

```swift
@State private var languages: Set<String> = ["en"]

let groups = [
    QeetrixComboboxGroup("Indian languages", items: [
        QeetrixComboboxItem("Hindi", value: "hi", description: "हिन्दी"),
        QeetrixComboboxItem("Tamil", value: "ta", description: "தமிழ்"),
    ]),
    QeetrixComboboxGroup("Other languages", items: [
        QeetrixComboboxItem("English", value: "en"),
        QeetrixComboboxItem("German", value: "de", description: "Deutsch"),
    ]),
]

QeetrixCombobox("Languages you speak", selection: $languages, groups: groups, isOptional: true)
```

### Searching

An option matches when its label contains what's typed, ignoring case, accents and full- or half-width
forms, as the environment's `locale` compares letters — so "sao" finds "São Paulo", and in Turkish
"istanbul" finds "İstanbul". Letters are compared as typed, so a Hindi search matches while a conjunct
is still being written ("हिन" finds "हिन्दी"). Only the label is searched, as on the web: put what
people will type in it.

For a directory too large to send whole, search on a server: `onSearch` runs once typing pauses
(`searchDelay`, 300 ms by default) and with "" as soon as the search is cleared. Pass the results as the
options — they're shown as given, unfiltered — and `isLoading` while they're on the way: "Searching…"
with a small spinner heads the list, and "No matches" waits until the results say so. A chosen option
keeps its label in the trigger when new results leave it out.

```swift
QeetrixCombobox(
    "Owner", selection: $ownerID, items: results, placeholder: Text("e.g. Priya Sharma"),
    isLoading: isSearching
) { query in
    search(query)
}
```

`messages` replaces the built-in words: "No matches", "Searching…", "3 selected" and "Done".

### Accessibility

- VoiceOver reads the trigger as a button named by the label (with "Required"), the choice — or the
  placeholder — as its value, and the description as its hint; with several chosen the value is the
  count, then their labels: "3 selected, India, Germany and Japan". The error is read with it.
- In the sheet the title is a heading; each option is a button read with its description, and a
  chosen one is selected. Group labels are headings, for the rotor. "No matches" and "Searching…" are
  announced when they appear, as the web's live regions are.
- Every row is at least 44 points tall; the trigger's target is at least 44 points.
- Text wraps at every size in the sheet; at the accessibility sizes a chosen option's check moves under
  its text, with the row's other trailing content. The trigger keeps one line, as the Select's does.
- Right to left, the layout mirrors; the chevron points down either way.

### Platform differences

- **A sheet, not a popup** (ADR 0014). On a phone the web's list under the field would sit behind the
  keyboard, so typing happens in a search field at the top of a system sheet, which swipes closed and
  becomes a form sheet on iPad. The sheet is presented by state the combobox owns, or by
  `isPresented`, which it sets back however the sheet closes.
- **The trigger is the Select's**, not a text field: the field doesn't take typing itself.
- **Several choices are counted, not pills.** The web shows each choice as a removable pill inside the
  field; a phone's field has no room for them, so the trigger counts them and the sheet is where they
  are added and removed. There is no Backspace-to-remove.
- **No Clear button in the field.** A single choice is changed in the sheet; give "none" an option if
  it can be undone.
- **Rows are list rows**, `label.md` at 44 points, where the web's options are `body.md` in a 32-pixel
  menu, chosen at weight 500; there is no highlight bar, because a touch has no hover.
- **Not yet:** a custom `filter`, the leading `icon` and `allowCustom` ("Use “…”").

On the web: [Combobox on ui.qeet.in](https://ui.qeet.in/components/combobox).

## Topics

### Options

- ``QeetrixComboboxItem``
- ``QeetrixComboboxGroup``
- ``QeetrixComboboxMessages``
