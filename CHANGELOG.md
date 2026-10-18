# Changelog

## Unreleased — Phase 1: foundations

Built from `@qeetrix/ui` 2.1.6, `@qeetrix/icons` 1.0.11 (`331cd85`), Cal Sans v2.011 and Fira Code 6.2.

### Added

- **Token pipeline.** `Tools/QeetrixGen` (the `qeetrix-gen` tool, run through `Scripts/`) does the
  following:
  - syncs the published `@qeetrix/ui` token build, the native fonts and the pinned icons into
    `Upstream/`, verified and locked by sha256;
  - generates typed Swift from them;
  - verifies generated files byte-for-byte.
  It needs no dependencies and runs offline after a sync.
- **Colour.** `QeetrixColor`: the 84 semantic colours as a `ShapeStyle` resolving light or dark from
  the environment. OKLCH is converted per CSS Color 4: sRGB where possible, Display P3 where the web's
  colour is wider.
- **Theme.**
  - `QeetrixThemeMode` (`light`, `dark`, `system`; the same raw values as the web) and
    `.qeetrixThemeMode(_:)`.
  - `QeetrixTheme` with `@Environment(\.qeetrixTheme)`, and `.qeetrixTheme(_:)` for subtree overrides.
- **Typography.**
  - `QeetrixTextRole` (display, title, heading, body, label, label-compact, caption, micro, code) and
    `.qeetrixTextStyle(_:)`.
  - Dynamic Type scaling, the variable-font axes (weight, letter style, optical size) set as on the web,
    and one weight step heavier under Bold Text.
  - `QeetrixFontRegistry` and `QeetrixTextMetrics`.
- **Fonts.** Qeet Sans (Cal Sans VF) and Fira Code VF as TTF, each proven identical to the font the
  web ships, with their OFL licences.
- **Scales.** `QeetrixSpacing`, `QeetrixCorner`, `QeetrixStroke`, `QeetrixFocus`, `QeetrixOpacity`,
  `QeetrixDensity` (with `\.qeetrixDensity`), `QeetrixIconSize` and `QeetrixIconStroke`.
- **Elevation.** `QeetrixElevation` and `.qeetrixElevation(_:fill:in:)`, drawing the web's
  `box-shadow` layers: spread, the ring layer and inset highlights.
- **Motion.** `QeetrixDuration`, `QeetrixEasing`, `QeetrixMotion.animation(_:_:reduceMotion:)` and
  `.qeetrixAnimation(_:_:value:)`, which honour Reduce Motion.
- **Icons.**
  - `QeetrixIcon` and `QeetrixIconName`: 12 icons (bell, check, database, eye, inbox, info, lock,
    navigation, search, send, server, x) in round and sharp, outline and filled where drawn.
  - Decorative by default, labelled for VoiceOver, Dynamic Type scaling, and right-to-left mirroring.
- **Accessibility.** `QeetrixAccessibility.minimumTouchTarget`, `.qeetrixMinimumTouchTarget()` and
  `contrastRatio(_:on:)`.
- **Provenance.** `QeetrixProvenance.bundled()`, backed by `Resources/Metadata/token-provenance.json`.
- **Showcase.** `Examples/QeetrixShowcase`, an iOS app showing every foundation.
- **Tests.**
  - 48 library tests: token parity with upstream, brand colour values, upstream's WCAG pairs in both
    themes, font loading and axes, rendering, theme overrides, icons, the public API and the
    documentation examples.
  - 29 generator tests.
- **Repository layout** (ADR 0007): the generator in `Tools/QeetrixGen`, its pinned inputs and lock in
  `Upstream/`, and the commands in `Scripts/`.
- **Decision records** in `Documentation/Decisions/` (0001–0008 accepted, 0009 proposed), and the
  component contract for Phase 2 in `Documentation/Standards/COMPONENT_CONTRACT.md`.
- **Governance.** `SECURITY.md`, `.editorconfig`, `.github/CODEOWNERS`, a pull request template, and
  issue templates for bugs and design-system changes.
- **Documentation.** The DocC catalogue `Sources/Qeetrix/Qeetrix.docc`: a landing page and guides for
  getting started, theming, typography, spacing, shapes, sizing, elevation, motion, icons and
  accessibility. It is built with warnings as errors (`Scripts/docs.sh`, and in CI), and its examples
  are compiled by the tests.
- **Checks and CI.** `Scripts/lint.sh` (swift-format), `Scripts/api-check.sh` (public API baseline) and
  `.github/workflows/ci.yml`.
