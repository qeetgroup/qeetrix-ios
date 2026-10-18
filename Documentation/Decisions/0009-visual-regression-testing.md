# 0009 — Visual regression testing for components

**Status:** Proposed, for the first Phase 2 component. Nothing in this record is implemented yet.

## Context

Components can regress visually without failing a behaviour test, for example through a token change,
a layout change, or a new Dynamic Type size. Skyscanner Backpack and Adevinta Spark use Point-Free's
SnapshotTesting for this. Phase 1 checks rendering with targeted pixel assertions instead
(`Rendered` in the tests).

## Proposal

- **Target.** A test target, `QeetrixSnapshotTests`, using Point-Free's `swift-snapshot-testing`, a
  test-only dependency. It is never linked into the `Qeetrix` library.
- **Before adding it, verify:**
  - its licence;
  - compatibility with the pinned Xcode and Swift Testing;
  - what an app depending on `Qeetrix` actually resolves and downloads. SwiftPM's resolution can still
    involve test-only dependencies, so this is measured, not assumed.
- **The baseline matrix**, per component. It is representative, not a full cross-product of
  everything:

  | Configuration | Theme | Text size | Direction |
  |:--|:--|:--|:--|
  | Default | light | Large (default) | left-to-right |
  | Dark | dark | Large | left-to-right |
  | Large text | light | accessibility 3 | left-to-right |
  | Right-to-left | light | Large | right-to-left |

  Interaction states (disabled, pressed, selected, error) are added per component, only where they
  change the drawing. They are snapshotted in the default configuration.
- **Recording conditions.** One simulator device and OS version, light/dark set explicitly, the
  `en_US` locale, and a scale of 3. These are set in the test plan and the test helper, so references
  are reproducible.
- **Scope.** Snapshots complement behaviour and accessibility tests; they do not replace them.

## Consequences to confirm when adopted

- The package gains its first dependency, so `Package.resolved` is committed from then on.
- Reference images become reviewed artifacts in pull requests. Re-recording them needs a reason.
- This record becomes Accepted, or is replaced, when the first component lands.
