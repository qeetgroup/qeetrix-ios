# Phases

Qeetrix for iOS is built in phases. Each one ends with its own verification. Later phases are planning
boundaries, not commitments of scope.

| Phase | Scope | Status |
|:--|:--|:--|
| **1 — Foundations** | Token pipeline from `@qeetrix/ui`; semantic colours; light/dark/system theming; typography with the bundled fonts and Dynamic Type; spacing, size, corners, stroke, focus, density, elevation, motion; icon infrastructure with a representative set; accessibility helpers; showcase app; tests, CI, docs | **Current** |
| 2 — Core components | Actions and basics (button, icon button, link, badge, divider, …) with their `component.*` tokens | Planned |
| 3 — Forms and inputs | Text fields, selection controls, validation presentation | Planned |
| 4 — Navigation, overlays, feedback | Navigation patterns, sheets, menus, toasts, alerts | Planned |
| 5 — Data display and advanced | Lists, tables, charts and the other data components | Planned |
| 6 — Accessibility and maturity | Device-verified VoiceOver, Switch Control and keyboard; increased-contrast values (with upstream); performance | Planned |
| 7 — Documentation and release | DocC catalogue, docs on ui.qeet.in, versioned releases | Planned |

## Phase 1 — what is done and what is not

Done, and verified:

- **Pipeline.** Sync and lock from upstream, deterministic generation, and drift and API checks.
- **Generated tokens.** 217 tokens: 84 semantic colours, 14 elevations, 9 typography roles and the
  dimension and motion scales.
- **Fonts.** Qeet Sans and Fira Code, bundled as the web's exact fonts in native TTF.
- **Icons.** 12 icons, with their round, sharp, outline and filled drawings where upstream has them.
- **Tests.** 48 library tests on the Mac and on the iOS 27.1 Simulator, and 29 generator tests.
- **Example.** The showcase app.
- **Groundwork for Phase 2.** Decision records, and the component contract (catalogue, file set,
  tokens rule, test matrix). The template, the snapshot target and the components themselves wait for
  Phase 2.

Not done in Phase 1, by scope:

- components and the 216 component tokens;
- the full icon catalogue and the Qeet logos;
- gradients and z-index tokens;
- increased-contrast values, which upstream does not define yet;
- package releases and distribution.

Still to verify:

- running on an iOS 17 runtime, which has been compiled against but not run;
- VoiceOver and Bold Text on a device;
- the CI workflow on GitHub-hosted runners.
