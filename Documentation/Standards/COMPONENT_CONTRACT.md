# Component contract

What every Qeetrix iOS component must provide, so the first component and the hundredth have the same
shape. Written before Phase 2, revised with its first eleven components and again for the move to
`@qeetrix/react` (ADR 0018); the template and `Scripts/new-component.sh` produce its file set.

## The catalogue it follows

`@qeetrix/react` 0.4.0's published component manifest (`dist/manifest.json`, kept as
`Upstream/qeetrix-react/component-manifest.json`), checked on 2026-10-30:

| Source | Count |
|:--|:--|
| Manifest families | 89: 87 components and 2 utilities (`format`, `provider`) |
| Their exported parts | 172 |
| Status | 39 stable, 50 experimental |
| ui.qeet.in component pages (`qeetrix-docs`, `src/qeetrix/components/`) | 70 |

- **Families, not pages, are the folders.** A family can hold several parts (`button`: Button,
  IconButton, LinkButton) and a page can cover a part (`icon-button`) or a pattern (`form`), so folders
  follow families and pages are used only for documentation links and the showcase (ADR 0007, 0018).
- **The design documents** (`qeetrix-files/qeetrix-react/05-design-rules.md`, `06-component-specs.md`,
  `07-components.md`) give each component's parts, sizes, states and API; the family's CSS is what
  ships. Where they disagree, iOS follows the CSS and the disagreement is reported upstream
  ([MIGRATION_QEETRIX_REACT.md](../MIGRATION_QEETRIX_REACT.md#upstream-gaps-and-bugs-found)).

Re-run this check whenever the `@qeetrix/react` pin moves.

## Where a component lives

```text
Sources/Qeetrix/Components/<Family>/<Component>/     <Family> = the @qeetrix/react family, UpperCamelCase
Tests/QeetrixTests/Components/<Family>/<Component>Tests.swift
Tests/QeetrixSnapshotTests/<Family>/<Component>SnapshotTests.swift      (ADR 0009)
Tests/QeetrixSnapshotTests/__Snapshots__/<Family>/<Component>SnapshotTests/   its baselines — local, never committed (ADR 0013)
Sources/Qeetrix/Qeetrix.docc/Components/<Component>.md
Examples/QeetrixShowcase/QeetrixShowcase/Components/<Family>/<Component>Page.swift
```

For example, IconButton belongs to the `button` family: `Components/Button/IconButton/`; RadioGroup to
`radio`: `Components/Radio/RadioGroup/`.

## What every component defines

1. **Public SwiftUI API.**
   - Named `Qeetrix<Component>` (`QeetrixButton`, `QeetrixIconButton`).
   - Where SwiftUI has a matching style protocol, Qeetrix provides a style (`.buttonStyle(.qeetrix())`,
     `.toggleStyle(.qeetrixSwitch())`, `.progressViewStyle(.qeetrix())`), and the named view is built on
     it, adding only what a style cannot (a button's icon zone and loading state). See ADR 0010 for the naming,
     text-parameter and evolution rules.
   - Parameters use typed Swift: enums and option sets, not strings. The names are the web component's
     props; the syntax is native. A web `tone="danger"` becomes a typed `tone: .danger`, a boolean
     `loading` becomes `isLoading`.
2. **Variants and states.**
   - The variants, tones and sizes are the `@qeetrix/react` component's, by the same names.
   - States — enabled, disabled, pressed, focused, selected, error, loading — come from SwiftUI's
     environment and gestures where SwiftUI has them (`isEnabled`, `isFocused`). They are never
     tracked twice.
3. **Style customisation.** Limited to what the design system allows: variant, tone, size and density.
   There are no arbitrary colour or font parameters; Qeetrix has one brand.
4. **Tokens.**
   - Semantic tokens only: `@qeetrix/react`'s CSS uses no component tokens for the components iOS has.
   - A length the family's CSS writes as a literal (`padding-inline: 14px`) is restated in the component,
     with the CSS rule beside it; the compiled CSS is pinned in `Upstream/qeetrix-react/css/` so a
     version bump shows what changed (ADR 0018). No literal colours or durations in component code.
   - Colour use follows design rules §4: Ember only for the primary action, focus, the current item,
     checked controls and links; shadows only on floating layers.
5. **Fields.** An input — anything a person types into or chooses with in a form — takes a label,
   `description`, `error`, `isRequired` and `isOptional`, and builds itself on `QeetrixField`, whose
   environment gives its native control the VoiceOver name, hint and error (ADR 0012). It never lays
   out its own label or error, and never validates.
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
  under its category, adds its page to the showcase catalogue, and names its component tokens when
  `@qeetrix/tokens` defines them. It checks the names, and that the family exports the part, against the
  pinned `@qeetrix/react` manifest; it never overwrites, and a run that finds the component already there
  changes nothing. `--dry-run` lists the changes. The scaffold carries `#error`s until it is
  implemented, so it cannot be committed half-done by accident.
- **Snapshot tests**, as ADR 0009, with `assertSpecimen` from `Tests/QeetrixSnapshotTests/Support`.
- **Gates.** `Scripts/check.sh` runs every host gate; CI adds the iOS unit-test, UI-test and DocC gates.
  Snapshot tests run on your machine against local baselines (ADR 0013).
- **Not adopted: separate test plans** for right-to-left and large text. The snapshot matrix sets both
  per test, and the UI tests pin a text size, which covers the same ground without extra runs.
