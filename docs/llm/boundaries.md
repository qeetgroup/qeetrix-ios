# Boundaries — qeetrix-ios

**Level:** L2 · **Last verified:** 2026-11-04
**Verification scope:** rules taken from the build's checks, the tests and the release workflows.

## Owns

The iOS form of Qeetrix: generated Swift tokens, the theme, fonts, icons and the SwiftUI components, their tests, DocC
pages and showcase pages, and the release of the `Qeetrix` package by Git tag.

## Does not own

| Not owned | Owner |
|---|---|
| **Tokens, fonts, icons and how components look** | `@qeetrix/tokens`, `@qeetrix/icons`, `@qeetrix/react` (upstream) |
| The design rules | qeetrix-files (`qeetrix-react/05-design-rules.md`) |
| The documentation site, ui.qeet.in | `qeetrix-docs` |
| Jetpack Compose | `qeetrix-android`, which pins the same packages and versions |
| Apps' navigation, data, permissions and validation | Each app |

## Consumes

`@qeetrix/tokens` 0.0.13, `@qeetrix/react` 0.4.0 and `@qeetrix/icons` 2.1.0, pinned and integrity-checked in
`Upstream/`. No runtime dependency; swift-snapshot-testing for tests only.

## Rules that the build enforces

- **Never edit `Upstream/`, a `Generated/` folder, `docs/tokens.md` or `docs/token-values.json` by hand.** Sync and
  generate instead.
- **The public API changes only on purpose:** document it in DocC, run `Scripts/api-check.sh --update`, and note it in
  the CHANGELOG. A source-breaking change fails CI unless `api/breaking-changes-allowlist.txt` accepts it.
- **Swift 6 strict concurrency, no compiler warnings, `swift-format` strict, DocC without warnings.**
- **No runtime dependency.** A test-only one needs its entry in `Tools/dependency-allowlist.json`.
- **No required-reason API without a privacy manifest** (checked by `Scripts/release-check.sh`).

## Rules every component follows

- **It is the counterpart of an `@qeetrix/react` component:** the same variants, tones and sizes, by the same names,
  with its CSS restated beside each literal. No colour or font parameters.
- **It wraps the system control or presentation** rather than imitating it, and works as a SwiftUI style on native
  controls where a style protocol exists.
- **The app owns state.** Values, selections and presentations come in as bindings; no router, presentation manager or
  global state.
- **Accessibility:** a 44 pt touch target, VoiceOver labels, values and traits, Dynamic Type to the largest size
  without cutting text, right to left, and Reduce Motion.
- **Complete:** tests that fail without the behaviour, a snapshot test, a DocC page and a showcase page, in
  `Sources/Qeetrix/Components/<Family>/`.

## Rules of the repository

- **Snapshot baselines stay on the maintainer's machine.** They aren't committed and CI doesn't compare them.
- **Releases go through `main`:** a pull request with CI passing, then the owner's approval of the release job.
- **Cross-platform:** a change to naming, colour conversion or token scope is made in `qeetrix-android` too, or
  recorded as a difference here.
