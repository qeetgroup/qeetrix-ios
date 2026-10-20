# Component contract

What every Qeetrix iOS component must provide, so the first component and the hundredth have the same
shape. Written before Phase 2 and revised with its first eleven components, which follow it; the
template and `Scripts/new-component.sh` produce its file set.

## The catalogue it follows

Verified on 2026-10-18 against `@qeetrix/ui` 2.1.6 (git `7d7f651`), the version this package is pinned
to:

| Source | Count |
|:--|:--|
| Published `component-manifest.json` | 137 components |
| qeetrix-ui `scripts/config/component-map.json` (family → components) | 97 families, 137 components |
| qeetrix-ui `src/components/<Family>/` folders | 97 |
| ui.qeet.in component pages (qeetrix-docs `main`, `ede2ea7`) | 137 pages in 9 categories |

The three agree exactly: every manifest slug has a docs page, and every page has a manifest entry.

- **Docs categories.** Actions (11), Forms & inputs (34), Date & time (9), Data display (30),
  Feedback (12), Overlays (14), Navigation (11), Layout (13), Utilities (3).
- **Status.** 74 stable, 62 beta, 1 deprecated.

**Discrepancies.**

- **Categories don't map onto families.** The Button family spans Actions and Overlays, and
  DropdownMenu spans Navigation and Overlays. Folders therefore follow families, and categories are
  used only for documentation and the showcase (ADR 0007).
- **The older 145-component / 103-family count.** qeetrix-ui had 103 family folders until
  2026-10-06; the 2026-10-07 cleanup left 97.
- **Stale README.** qeetrix-ui's README at 2.1.6 has the right counts (137 modules, 97 families), but
  its status line still reads "1.0.3".

Re-run this check whenever the `@qeetrix/ui` pin moves.

## Where a component lives

```text
Sources/Qeetrix/Components/<Family>/<Component>/     <Family> = the qeetrix-ui family identifier
Tests/QeetrixTests/Components/<Family>/<Component>Tests.swift
Tests/QeetrixSnapshotTests/<Family>/<Component>SnapshotTests.swift      (ADR 0009)
Tests/QeetrixSnapshotTests/__Snapshots__/<Family>/<Component>SnapshotTests/   its baselines — local, never committed (ADR 0013)
Sources/Qeetrix/Qeetrix.docc/Components/<Component>.md
Examples/QeetrixShowcase/QeetrixShowcase/Components/<Family>/<Component>Page.swift
```

For example, IconButton belongs to the Button family: `Components/Button/IconButton/`.

## What every component defines

1. **Public SwiftUI API.**
   - Named `Qeetrix<Component>` (`QeetrixButton`, `QeetrixIconButton`).
   - Where SwiftUI has a matching style protocol, Qeetrix provides a style (`.buttonStyle(.qeetrix())`,
     `.toggleStyle(.qeetrixSwitch())`, `.progressViewStyle(.qeetrix())`), and the named view is built on
     it, adding only what a style cannot (a button's loading state). See ADR 0010 for the naming,
     text-parameter and evolution rules.
   - Parameters use typed Swift: enums and option sets, not strings. The meaning matches the web
     component; the syntax is native. A web `variant="destructive"` becomes a typed `.destructive`, not
     a string.
2. **Variants and states.**
   - The variants are the web component's variants, by the same names.
   - States — enabled, disabled, pressed, focused, selected, error, loading — come from SwiftUI's
     environment and gestures where SwiftUI has them (`isEnabled`, `isFocused`). They are never
     tracked twice.
3. **Style customisation.** Limited to what the design system allows: variant, size and density.
   There are no arbitrary colour or font parameters; Qeetrix has one brand.
4. **Tokens.**
   - Semantic tokens by default.
   - Component tokens only where qeetrix-ui defines `component.<name>.*` (41 groups covering 40 of 97
     families today), adopted by listing the group in `Upstream/pins.json` (ADR 0011).
   - Geometry the web takes from Tailwind utility classes comes from `QeetrixWebScale`, with the web
     class beside each use (ADR 0011). No other literal colours, sizes or durations in component code.
5. **Fields.** An input — anything a person types into or chooses with in a form — takes a label,
   `description`, `message`, `isRequired` and `isOptional`, and builds itself on `QeetrixField`, whose
   environment gives its native control the VoiceOver name, hint and message (ADR 0012). It never lays
   out its own label or message, and never validates.
6. **Presentations.** An overlay or navigation component wraps the system presentation (ADR 0014). It is
   driven by a binding the app owns — an optional value or a `Bool` — and sets it back however the
   presentation ends. A chosen action runs once, after the overlay is dismissed. It keeps no global state:
   no router, manager or singleton. What the system draws is not restyled.
7. **Data.** A component that shows data takes values and views and keeps none: no store, fetching,
   caching, filtering, pagination or selection of its own. The app passes its data with its stable
   identity, and its state as bindings; native containers (`List`, `Section`, `DisclosureGroup`,
   `searchable`) are used, not wrapped (ADR 0015).
8. **Accessibility.**
   - Hit area of at least 44 pt — extended without moving layout (`qeetrixHitArea()`) where the web
     control is drawn smaller and has room around it; a full 44 pt row where controls are stacked closer
     than that, because extended targets would overlap.
   - VoiceOver label, traits and value.
   - Dynamic Type up to the accessibility sizes, with reflow rather than truncation.
   - Bold Text through the typography roles.
   - Reduce Motion through `qeetrixAnimation`.
   - Right-to-left layout.
   - 4.5:1 text contrast and 3:1 for boundaries and icons.
   - See [ACCESSIBILITY.md](ACCESSIBILITY.md).
9. **Native platform adaptations**, where iOS behaviour differs from the web, for example sheets
   instead of dialogs on compact width, haptics, or swipe actions. Each one is written down in the
   component's DocC page, with the reason.
10. **Behaviour tests.** Variants, states, accessibility semantics and token use, in Swift Testing.
   Interaction that needs a real touch — a tap, typing, a 44 pt target — goes in the showcase's UI
   tests (`Examples/QeetrixShowcase/QeetrixShowcaseUITests`).
11. **Visual regression tests.** One specimen of every variant and state Qeetrix draws, in the matrix of
   ADR 0009. Surfaces the system draws — alerts, confirmation dialogs, menus — are covered by UI tests
   instead.
12. **DocC page.** Purpose, usage, variants, accessibility notes and platform adaptations, linking the
   web component's page on ui.qeet.in. API details come from doc comments, not a second copy. Every
   example on the page is compiled by a documentation-examples test in `Tests/QeetrixTests/Integration`.
13. **Showcase page and previews.** Every variant and state, in both themes and at a large text size.
   The page is added to the accessibility audit gate (`AccessibilityAuditUITests.pages`), and passes it.

## Tooling

- **`Scripts/new-component.sh <Family> <Component> --category "<docs category>" [--slug <web slug>]`**
  renders `Templates/Component/` into the file set above, lists the component in the DocC landing page
  under its category, adds its page to the showcase catalogue, and adopts its component tokens when
  qeetrix-ui defines them. It checks the names, and the family and slug against the pinned
  `component-manifest.json`; it never overwrites, and a run that finds the component already there
  changes nothing. `--dry-run` lists the changes. The scaffold carries `#error`s until it is
  implemented, so it cannot be committed half-done by accident.
- **Snapshot tests**, as ADR 0009, with `assertSpecimen` from `Tests/QeetrixSnapshotTests/Support`.
- **Gates.** `Scripts/check.sh` runs every host gate; CI adds the iOS unit-test, UI-test and DocC gates.
  Snapshot tests run on your machine against local baselines (ADR 0013).
- **Not adopted: separate test plans** for right-to-left and large text. The snapshot matrix sets both
  per test, and the UI tests pin a text size, which covers the same ground without extra runs.
