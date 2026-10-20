# Public API compatibility

Phase 6, 2026-10-19. How the public API of the `Qeetrix` module is kept stable, what Phase 6 changed,
and the rules for later changes.

## The API today

`Documentation/API/Qeetrix.public-api.txt` lists 803 public symbols: 41 enums, 79 structs, 17 `View`
modifiers, 152 initialisers, 159 properties, 99 static properties, 51 methods and 212 enum cases.
Every public type is a struct or an enum: there are no public classes, protocols or global functions.
The two operators are `<` on `QeetrixDuration` and `QeetrixFontWeight`. Seven extensions add to
SwiftUI's `View`, `Image`, `EnvironmentValues` and the button, toggle, progress and disclosure-group
styles.

API conventions are in ADR 0010. The ones that matter for compatibility:

- Components are structs with initialisers; options are enums named for the web's variants.
- Style accessors are a static property when they take no parameters (`.qeetrix`) and a static
  function when they do (`.qeetrix(size:)`).
- State the app owns — selection, expansion, presentation, text — is a `Binding`; nothing is stored in
  a singleton.
- Nothing is `open`, and nothing is meant to be subclassed or conformed to by apps.

## Accidental exposure

The 120 public types were reviewed against what DocC documents. None is exposed by accident:

- Components, their styles and options are each on a DocC page.
- Foundation value types an app reads — `QeetrixTextMetrics`, `QeetrixTextRoleTokens`,
  `QeetrixFontFace`, `QeetrixFontAxis`, `QeetrixFontGeometry`, `QeetrixShadowLayer` — are listed in
  the catalogue's topics with doc comments, and the text types are explained on the Typography page.
- `QeetrixFontRegistry` and `QeetrixProvenance` are for checking font registration and upstream
  versions; both are on the Getting Started page.
- Implementation stays internal: colour storage, per-theme tables, component token groups, icon
  drawings, metrics, caches, layouts and logging.

Names follow one rule throughout: `Qeetrix` plus the web component's name, and the web's variant and
size names (ADR 0010). Two names differ from the Phase 6 prompt's list and are kept: `QeetrixAlertDialog`
(the web's `AlertDialog`) and `QeetrixDescriptionList` (the proposal's "KeyValueRow", ADR 0015).

## Two checks

| Check | What it compares | Catches | Where |
|:--|:--|:--|:--|
| `Scripts/api-check.sh` (ADR 0008) | The symbol list with `Qeetrix.public-api.txt` | Any symbol added, removed or renamed | `Scripts/check.sh`, CI on every push and pull request |
| `Scripts/api-compat.sh <revision>` (Phase 6) | The module with the same module built at `<revision>`, using Swift's `diagnose-api-breaking-changes` | Source breaks the symbol list can't see: a changed type, a new enum case, a removed conformance, a changed default | CI on every pull request, against the target branch |

`api-check` makes every API change visible in review. `api-compat` decides whether a change is
breaking. A break fails the pull request unless it is listed in
`Documentation/API/breaking-changes-allowlist.txt`, which only a decision record may extend.

The package is distributed as source (ADR 0001) and isn't built with library evolution, so only source
compatibility is checked. Binary compatibility is not offered.

## Results

| Command | Result |
|:--|:--|
| `Scripts/api-check.sh` | ✓ matches the baseline, updated in Phase 6 for `QeetrixIconName` |
| `Scripts/api-compat.sh 10b365f` (Phases 2–4, merged to `main` as `ed46253` with the same tree) | ✓ No breaking changes detected (with the allowlist) |
| `Scripts/api-compat.sh 8730aa7` (Phase 1) | ✓ No breaking changes detected (with the allowlist) |

Before the Phase 6 fix, `api-compat` against `10b365f` reported eight breaking changes: the eight icons
Phase 5 added as enum cases.

## Phase 6 changes

### Breaking: `QeetrixIconName` is a struct (ADR 0016)

`QeetrixIconName` was an enum, so every icon added to the catalogue broke apps that switch over it. It
is now an open set of names, like `Notification.Name`: a `RawRepresentable`, `Hashable`, `CaseIterable`,
`Sendable` struct with one static property per icon.

What still compiles unchanged:

- `QeetrixIcon(.bell)`, `Image(qeetrix: .bell)` and every other use of a name as a value;
- `QeetrixIconName(rawValue: "bell")`, `.rawValue` and `QeetrixIconName.allCases`;
- `if name == .bell` and `case .bell:` patterns inside a `switch` that has a `default`.

What needs a change: a `switch` over icon names with no `default` case. Add one.

```swift
switch icon {
case .bell: showNotifications()
case .settings: showSettings()
default: break  // added: the catalogue grows
}
```

Against `10b365f` the checker reports this change as 59 breaks: the enum becoming a struct, and two for
each of the 29 icons that existed then (an enum case that is now a static property, with a changed
declared type). All 59 are in the allowlist, recorded by ADR 0016. Against an older revision the same
lines cover the fewer icons it had.

### Not breaking

- `QeetrixPasswordInput`'s hit area, the type cache and the `containerSM` metric are internal.

## Rules for later changes

1. **Additive by default.** New types, new initialisers with new labels, new static members and new
   defaulted parameters are additions.
2. **No new cases on public enums without a decision record.** Adding a case breaks an app's exhaustive
   `switch`. Option enums follow the web's variants and change rarely; when one must, record the break
   in an ADR and the allowlist, and note the migration in `CHANGELOG.md`. A catalogue that grows —
   like icon names — is a struct, not an enum.
3. **Deprecate before removing.** Once versions are released, a symbol is deprecated with
   `@available(*, deprecated, renamed:)` for at least one minor version before a major version removes
   it.
4. **Semantic versioning from the first release.** Major for breaks, minor for additions, patch for
   fixes. The first release, its version and the deprecation window are Phase 7's to decide.
5. **Every change is reviewed twice:** `api-check.sh --update` puts the new symbol list in the pull
   request, and `api-compat.sh` against the target branch must pass.

## Not verified

- The CI step has not run on GitHub: the repository's Actions are blocked by billing. It was run
  locally with the commands above.
