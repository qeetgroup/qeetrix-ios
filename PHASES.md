# Phases

Qeetrix for iOS is built in phases. Each one ends with its own verification. Later phases are planning
boundaries, not commitments of scope.

| Phase | Scope | Status |
|:--|:--|:--|
| 1 — Foundations | Token pipeline from `@qeetrix/ui`; semantic colours; light/dark/system theming; typography with the bundled fonts and Dynamic Type; spacing, size, corners, stroke, focus, density, elevation, motion; icon infrastructure with a representative set; accessibility helpers; showcase app; tests, CI, docs | Done |
| 2 — Core components | Text, Separator, Card, Badge, Button, Icon button, Spinner, Progress, Avatar, Switch, Text field, with their `component.*` tokens; the component template and scaffold; snapshot and UI tests; CI gates | Done |
| 3 — Inputs and forms | Field and field set, textarea, password, one-time code, checkbox, radio group, select, number field; form actions and error summary | Done |
| **4 — Navigation, overlays, feedback** | Tabs; navigation and tab bar styling; alert and confirmation dialogs; sheets; popovers; menus; toasts | **Current** |
| 5 — Data display and advanced | Lists, tables, charts and the other data components | Planned |
| 6 — Accessibility and maturity | Device-verified VoiceOver, Switch Control and keyboard; increased-contrast values (with upstream); performance | Planned |
| 7 — Documentation and release | DocC catalogue, docs on ui.qeet.in, versioned releases | Planned |

## Phase 4 — what is done and what is not

Done, and verified on the Mac and the iOS 27.1 iPhone simulator:

- **Components.**
  - Tabs.
  - Navigation and tab bar styling.
  - Alert and confirmation dialogs.
  - The sheet and its layout.
  - Popover, menu and menu item.
  - Toast.
  - `Image(qeetrix:)` for system chrome.
- **Their tests:** behaviour tests, snapshot specimens for what Qeetrix draws (recorded and compared
  locally), and UI tests for presentation, dismissal, roles and the toast lifecycle.
- **Documentation:** DocC pages, the showcase pages, and an overlay-patterns page.
- **Decisions and handoffs:** ADR 0014 and a ui.qeet.in handoff.

Deferred, with the reasons in ADR 0014:

- a separate centred `QeetrixDialog` (the sheet is the dialog);
- `QeetrixSnackbar` (the toast with an action covers it);
- the inline `QeetrixAlert`;
- a stack of toasts;
- styling the system menu surface (`component.menu`).

Not done, by scope:

- the web's `NavigationMenu`, `Sidebar`, `Breadcrumb`, `Pagination`, `HoverCard`, `Tooltip`, `Tour` and
  `FloatingWindow`;
- Phase 5's data display.

Still to verify:

- VoiceOver speech for toasts, tabs and dialogs on a device;
- Full Keyboard Access in overlays;
- an iPad, where no simulator was available (regular width was checked through an iPhone in landscape);
- an iOS 17 runtime;
- the CI workflow on GitHub.

## Phase 3 — what is done and what is not

Done, and verified on the Mac and the iOS 27.1 Simulator: the field layer and eight inputs, the form
patterns, their behaviour tests, snapshot specimens (recorded and compared locally), UI tests, DocC pages
and showcase pages, and ADRs 0012 and 0013.

Not done, by scope: date and time pickers, combobox, multi-select, currency, masked, tag and mention
inputs, file upload, rich text, and Phase 4's navigation, overlays and feedback.

Still to verify: VoiceOver speech for field hints, attached messages and announcements; Password and
one-time-code AutoFill on a device; an iOS 17 runtime; the CI workflow on GitHub.

## Phase 2 — what is done and what is not

Done, and verified on the Mac and the iOS 27.1 Simulator:

- **Components.** The eleven above, each with its style where SwiftUI has one, behaviour tests, a
  specimen in the snapshot matrix, a DocC page with compiled examples, and a showcase page.
- **Component tokens.** Eight groups adopted: avatar, badge, button, card, input, progress, switch,
  typography (ADR 0011).
- **Tooling.** `Scripts/new-component.sh` and `Templates/Component/`; the snapshot target (ADR 0009);
  the showcase's XCUITest target; gates for warnings, dependencies and licences, and resources;
  `Scripts/check.sh`.
- **Decisions.** ADR 0009 accepted; ADR 0010 (component API) and ADR 0011 (component tokens and web
  metrics).

Not done in Phase 2, by scope:

- the other 125 of the web's 137 components (the text field covers two, `input` and `field`), and the
  33 component token groups not yet adopted;
- interactive or focus-visible states that need a person to judge (Full Keyboard Access focus order);
- package releases and distribution.

Still to verify, as for Phase 1: an iOS 17 runtime, a person using VoiceOver on a device, and the CI
workflow on GitHub-hosted runners.

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
