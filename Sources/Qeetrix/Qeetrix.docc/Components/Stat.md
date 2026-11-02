# ``Qeetrix/QeetrixStat``

## Overview

One key number with its label and a note — `@qeetrix/react`'s Stat — and the ruled strip that holds
several, ``QeetrixStatGroup``: a dashboard's KPIs, a page header's summary.

```swift
QeetrixStatGroup {
    QeetrixStat("Active users", value: 1_240_512, change: .percent(0.032), note: Text("this week"), trend: weeklyUsers)
    QeetrixStat("Collected", value: .currency(1_842_600, code: "INR"), note: Text("18 invoices"))
    QeetrixStat("Disputes", value: 3, note: Text("2 need a reply"), tone: .warning)
}
```

- **The parts** (stat.css): the label in `label.sm`, `color.text.subtle`; the value in `heading.sm`
  with tabular figures, 4 points under it; the note in `body.sm`, 2 points under the value; 12 × 16
  points inside the cell.
- **The value** (``QeetrixStatValue``) is written by ``QeetrixFormat`` in the environment's locale: a
  number — "12,40,512" in India — money, whole amounts without a fraction as the web writes them
  ("₹18,42,600"), a percentage, or `Text` as given for a value with its unit.
- **The note** is `color.text.subtlest`, or its tone's colour (``QeetrixStatTone``): `positive` in
  `color.text.success`, `negative` in `color.text.danger`, `warning` in `color.text.warning`.
- **A change** (``QeetrixStatChange``) starts the note: a 14-point sharp arrow up or down and the
  amount, without its sign — "↑ 3.2% this week". It gives the note its tone: an increase is positive
  and a decrease negative, the other way round with `isIncreaseGood: false` (errors, churn), and no
  change neutral; `tone` overrides it.
- **The trend** draws recent values, oldest first, as the web's 88 × 28-point line beside the number —
  under it, where the number wouldn't fit beside it:
  `color.icon.subtle` at `icon.stroke.thin` over the same colour at 10%, its last point the one
  `color.border.brand` mark, "now". It needs two values; a constant series draws flat. It's
  decorative: say what matters about it in the note.
- **Loading**: skeletons stand on the value's and the note's lines at those lines' heights — 5 and 10
  em wide — so nothing moves when the number arrives; the trend waits.

```swift
QeetrixStat("Failed payments", value: 42, change: .number(6, isIncreaseGood: false), note: Text("since yesterday"))
QeetrixStat("Latency", value: .text(Text("42 ms")), note: Text("p95"))
QeetrixStat("Revenue", value: 0, isLoading: true)
```

### The group

``QeetrixStatGroup`` sets stats side by side in equal cells at least 200 points wide, with 1-point
`color.border.default` rules between them; a strip W points wide has W ÷ 200 columns, as many as it has
stats at most, and a row's cells share their height. Where the cells wrap — on a phone, one stat to a
row — each row starts and ends on the gutter with no rule at its start, and a rule runs above it across
the whole strip, past a short last row.

### Accessibility

- VoiceOver reads a stat as one element: the label, then the value, the change with its direction in
  words, and the note — "Active users, 12,40,512, Up 3.2% this week". While loading, it reads "Loading"
  in the value's place.
- The change's direction is in the arrow's shape and the words, never in the colour alone. The trend is
  hidden from VoiceOver.
- Every tone's note holds 4.5:1, and the trend's line and mark 3:1, on the surfaces, in both schemes.
- Text grows with Dynamic Type and wraps; in right-to-left layouts the trend sits at the left of the
  value.

### Platform differences

- **The change** is iOS's: the web's `note` is a node the app writes ("+38 this week") and `tone`
  colours it. On iOS a ``QeetrixStatChange`` writes the amount through ``QeetrixFormat`` and says its
  direction; a plain `note` and `tone` work as on the web.
- **The trend reads left to right** in either direction, as the web's drawing does. Where a cell is too
  narrow for the number and the trend side by side, the trend goes under the number rather than the
  number breaking across lines.
- **Not carried**: `chart` and `action` (a summary band's small chart and link), `format` options
  beyond ``QeetrixStatValue``'s, and the page header's `--qx-stat-group-inset`.

On the web: [Stat on ui.qeet.in](https://ui.qeet.in/components/stat/).

## Topics

### The group

- ``QeetrixStatGroup``

### Values, changes and tones

- ``QeetrixStatValue``
- ``QeetrixStatChange``
- ``QeetrixStatDirection``
- ``QeetrixStatTone``
