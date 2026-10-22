# ui.qeet.in handoff: iOS quality and maturity

For whoever maintains the component pages on ui.qeet.in (`qeetrix-docs`). Phase 6 added no components.
It audited and hardened the existing ones, so this handoff changes what each page's **iOS** section says
about status, accessibility and compatibility. Nothing here has been published: qeetrix-ios has no
release, and nothing should be documented as installable until it does.

The sources of truth are the reports in `Documentation/Quality/` and ADR 0016.

## What to change

### Every iOS section: a status line

Use the level from `Documentation/Quality/COMPONENT_MATURITY_MATRIX.md`. Today every component is
**Beta**: fully tested and audited by machine, not yet checked by a person on a device, and not
released. Suggested wording:

> **iOS: Beta.** Tested on the iOS simulator, including Apple's accessibility audit. Not yet verified
> with VoiceOver on a device or on iOS 17, and not yet released.

Don't call any iOS component stable, production-ready or WCAG-conformant. Automated checks can't show
conformance.

### The Icon page

`QeetrixIconName` is now an open set of names rather than an enum (ADR 0016). If the page shows Swift
that switches over icon names, add a `default:` case. New icons will no longer break apps.

### The accessibility overview page

An iOS paragraph can say, from `ACCESSIBILITY_REPORT.md`:

- every component's showcase page passes Apple's accessibility audit — contrast, hit regions, labels,
  traits, Dynamic Type, and text clipping at the largest size — in a test that fails on any new issue;
- the exclusions are documented, each with its reason;
- interactive controls have 44 pt targets; the password field's target was fixed in this phase;
- at the largest text sizes, icon buttons and the icons inside fields grow with their icon, and the
  select's value wraps rather than being cut short — both fixed in this phase.

### Right-to-left and localization

From `LOCALIZATION_REPORT.md`:

- layouts mirror, while codes and numbers keep reading left to right; the timeline's connector was fixed
  to mirror in this phase;
- the library's own strings ("Loading", "Required", "Close"…) are **English only** for now. Say so on
  any page that lists built-in strings.

## What not to add

- **No performance numbers.** The figures in `PERFORMANCE_REPORT.md` come from a Mac and a simulator in
  debug builds. They catch regressions; they are not a phone's performance.
- **No screenshots from the repository.** As before, capture showcase pages locally.

## Verification status to quote

- **Verified on the iOS 27.1 iPhone simulator:** unit, snapshot and UI tests; the accessibility audit
  gate in light and dark, and at the largest text size; right-to-left and doubled-length strings on
  twelve pages; source compatibility against the last merged revision.
- **Not yet verified:** VoiceOver, Full Keyboard Access and Switch Control on a device; an iPad; an iOS
  17 runtime; performance on a device; the CI workflow on GitHub.
