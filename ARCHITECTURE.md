# Architecture

Qeetrix for iOS is one Swift package with one library module, `Qeetrix`, built from the same sources
of truth as the web: the published `@qeetrix/ui` token build and the `qeetrix-icons` drawings. Nothing
visual is authored here. This repository turns those artifacts into typed SwiftUI API.

## Layout

```text
Package.swift                 the library: product Qeetrix, iOS 17 (+ macOS 14 as a dev host)
Sources/Qeetrix/
├── Tokens/                   token value types, provenance — and Generated/ (never edited)
├── Foundations/              behaviour over tokens: Colors, Typography, Sizing, Elevation, Motion, Accessibility
├── Theme/                    theme mode, theme, environment
├── Icons/                    QeetrixIcon and its drawing types — and Generated/ (never edited)
├── Internal/                 implementation details (colour storage, logging)
└── Resources/                Fonts/ (TTF + licence), Metadata/token-provenance.json
Tests/QeetrixTests/           mirrors Sources: Tokens, Foundations/*, Theme, Icons, Integration
Scripts/                      the build tool (a separate Swift package) and its entry scripts
├── Upstream/                 pins.json, upstream.lock.json and the pinned artifacts
├── Sources/QeetrixGenCore/   Shared/, Tokens/, Fonts/, Icons/, Upstream/
└── *.sh                      sync-upstream, generate, verify, lint, api-check, ci-simulator
Examples/QeetrixShowcase/     an iOS app that depends on the package
Documentation/                cross-platform contract, standards, generated coverage and API baseline
```

## Layers and dependency rules

```text
Generated tokens  →  Foundations  →  Theme
        ↘                ↘
          Icons  ←────────
Internal supports every layer; nothing depends on Theme except apps.
```

- **Tokens** (`Tokens/`, `Tokens/Generated/`) hold values only. The generated files declare the typed
  token API (`QeetrixColor`, `QeetrixSpacing`, `QeetrixTextRole`, …) and the internal per-theme tables
  (`QeetrixLightTokens`, `QeetrixDarkTokens`). They depend only on the value types in
  `QeetrixTokens.swift` and on `Internal/`.
- **Foundations** give tokens behaviour: `QeetrixColor` becomes a `ShapeStyle`, `QeetrixTextRole` gets
  a font and Dynamic Type, `QeetrixElevation` gets drawn, easings become `Animation`s. Foundations read
  the SwiftUI environment directly (`colorScheme`, `legibilityWeight`, `accessibilityReduceMotion`), never
  the Theme layer.
- **Theme** is the environment surface apps use: `QeetrixThemeMode`, `QeetrixTheme`, and the modifiers
  that set them. It is built from Foundations.
- **Icons** use the icon tokens (size, stroke) and their own generated catalogue.
- The package depends on no other package and on no Qeet product. The example app and the tests
  depend on the library, never the reverse.

There is one module. Splitting into several would add no benefit until there is a distribution or
build-time reason to, such as a component family with a heavy dependency.

## Design-token pipeline

```text
@qeetrix/ui (npm, published)        calcom/sans · tonsky/FiraCode      qeetrix-icons (git commit)
  tokens.json · tokens.css · index.css    native TTF + OFL                 SVGs + manifest entries
                └───────── Scripts/sync-upstream.sh (verify, copy, lock) ─────────┘
                                         ↓
                    Scripts/Upstream/ + Resources/Fonts + upstream.lock.json
                                         ↓   Scripts/generate.sh (offline, deterministic)
        Tokens/Generated/*.swift · Icons/Generated/*.swift · Metadata/token-provenance.json
                       Documentation/Foundations/TOKEN_COVERAGE.md
```

**Input.** The input is the published output of qeetrix-ui's own Style Dictionary build, not the DTCG
source. That keeps one compiler of record:

- `tokens.json` holds the values per theme.
- `tokens.css` defines what is consumable: its `--qx-*` names are the semantic and component layers,
  and primitives are deliberately absent.
- `index.css` is read for the `--radius-*` scale only.

The sync checks the tarball against the npm registry's integrity hash and records the version and the
git commit it was published from.

**Scope.** `Scripts/Sources/QeetrixGenCore/Tokens/Scope.swift` decides what is generated:

- Included: the consumable layer, minus component tokens (Phase 2), z-indices (no SwiftUI meaning) and
  gradients (not a Phase 1 foundation).
- Also included: the non-colour primitive scales qeetrix-ui itself exposes to code in
  `token-values.ts`, namely spacing, icon size and stroke, stroke width, font weight and font geometry.
- Palette primitives are never generated, so product code cannot reach a raw colour.
- Every upstream token is either generated or excluded with a reason. A new consumable group with no
  rule fails generation.

**Values.** A strict CSS evaluator resolves what Style Dictionary leaves unresolved:

- `var()` with fallbacks, `calc()`, `min()`;
- `px` (one CSS px is one point) and `rem` (16 pt, because qeetrix-ui never sets a root font size);
- `oklch()`, `rgb()`, and `color-mix(in oklab, …)` with CSS Color 5 premultiplied mixing;
- `box-shadow` lists, cubic-bézier easings, and font stacks.

Any other syntax fails with the token named.

**Colour conversion** follows the CSS Color 4 reference matrices (OKLCH → OKLab → XYZ):

- A colour inside sRGB is emitted as sRGB, so it matches the web's hex exactly. The tests check the
  brand values #F26D0E, #D04800 and #B73D10.
- A colour outside sRGB but inside Display P3 is emitted as Display P3, which is what Safari paints on
  an iPhone. Nine values, across seven tokens, fall in this group.
- A colour outside P3 would be gamut-mapped with the CSS Color 4 algorithm. None is today.
- Components are rounded to six decimals, so the output is byte-stable.

**Checks.** Generation fails on:

- unresolved references or cycles;
- unsupported syntax;
- light/dark key parity breaks;
- a theme other than light/dark;
- `tokens.json` and `tokens.css` disagreeing on any consumable value;
- two tokens folding to one Swift name;
- any snapshot file not matching its lock.

`Scripts/verify.sh` regenerates in memory and byte-compares with what is committed. That makes it the
drift check, the determinism check, and the guard against hand edits.

## Theme resolution

- `QeetrixColor.resolve(in:)` (the iOS 17 `ShapeStyle` requirement) picks the light or dark table from
  `environment.colorScheme`. Every SwiftUI override therefore works with no extra plumbing: the
  window's scheme, `.preferredColorScheme`, and a nested `.environment(\.colorScheme, …)`.
- `.qeetrixThemeMode(_:)` sets `preferredColorScheme` for the window, like the web `ThemeProvider` on
  `<html>`.
- `.qeetrixTheme(_:)` overrides one subtree, like a nested `.dark` scope.
- There is no global state and no public way to build a palette: Qeetrix has one brand across every Qeet
  product.
- Increased contrast is read but resolves to standard values, because upstream defines no contrast
  theme. When one is registered, the generator fails until it is mapped.

## Fonts

| Web family | File | Source | Proof it is the web's font |
|:--|:--|:--|:--|
| Qeet Sans | `CalSansVF.ttf` | calcom/sans `v2.011` | The release's `CalSansVF.woff2` is byte-identical to `@qeetrix/ui`'s `QeetSans.woff2` |
| Fira Code | `FiraCode-VF.ttf` | tonsky/FiraCode `6.2` | The release's `FiraCode-VF.woff2` is byte-identical to `@qeetrix/ui`'s |

- **Why TTF.** WOFF2 is a web container, so iOS bundles the native TTF from the same release. The sync
  refuses a TTF whose WOFF2 sibling differs from what the web ships.
- **Licences.** The licence files are taken verbatim from each font project at the pinned tag and are
  bundled beside the fonts.
- **Loading.** `QeetrixFontRegistry` registers the fonts process-wide, once, and builds every font from
  the descriptor CoreText reads out of the bundled file. Fonts are never looked up by PostScript name:
  name lookups on this variable font returned a synthesised instance in testing.
- **Axes.** Each role sets `wght` (weight), `GEOM` (letter style: `ui` 25 for text, `base` 50 for
  headings, as on the web), `opsz` (the scaled point size, the web's `font-optical-sizing: auto`) and
  `ital` 0.
- **Failure.** A failed registration is logged and reported by `register()`. Text then falls back to
  the system font at the same weight, never silently.
- **Other scripts.** Scripts the fonts do not cover, such as the Indic scripts, fall back through
  CoreText's system cascade, as browsers do.

## Icons

The pinned SVGs are parsed at generation time, not at run time.

- **Supported subset.** The parser accepts `path` (every command; arcs become cubics per SVG F.6),
  `line`, `circle`, `ellipse`, `rect`, `polyline` and `polygon`, painted only in `currentColor`.
- **Rejected.** Transforms, groups, gradients, hard-coded colours and per-element stroke widths fail
  generation.
- **Output.** Each drawing becomes path commands in the 24-unit grid. `QeetrixIcon` draws them in a
  `Canvas`: the stroke width is the icon-stroke token scaled with the icon, as on the web, and the
  colour is the inherited foreground style.
- **Why not an asset catalogue.** Generated paths keep vectors exact, let the stroke token apply at
  run time, need no asset compiler, and can be tested on any host.

## Public API principles

- Every public name starts `Qeetrix` and follows the token's own name, for example `color.text.on-brand`
  → `QeetrixColor.textOnBrand`. Raw values are the upstream names.
- Defaults match the web: an icon is `md`/`regular`/round outline, and the theme mode is `.system`.
- Behaviour is exposed as SwiftUI modifiers and `ShapeStyle`s rather than wrapper views.
- Implementation types are internal: colour storage, per-theme tables, icon drawings and logging.
- `Documentation/API/Qeetrix.public-api.txt` lists the public API. `Scripts/api-check.sh` fails when it
  changes, so an API change is always a decision, recorded in `CHANGELOG.md`.

## Upstream observations

These were found while building on qeetrix-ui 2.1.6. None is changed here; they are recorded so
upstream can decide.

- `tokens.json` is not fully resolved. 191 values still hold CSS `var()`, `calc()` or `min()`, and the
  semantic `corner.*` tokens resolve through Tailwind's `--radius-*` variables, which live in
  `index.css` outside the DTCG graph. iOS evaluates them from the published CSS; a token-only consumer
  could not.
- `control.*` resolves through CSS density variables rather than token references.
- qeetrix-ui's `fonts/FiraCode-OFL.txt` is a reflowed copy of the OFL, not Fira Code's own `LICENSE`.
  iOS bundles the upstream file verbatim.
- The web family "Qeet Sans" is a CSS alias. Inside the file the family is "Cal Sans" and the default
  instance is `CalSans-Regular`.
- Releases up to 2.1.5 shipped the earlier Cal Sans v1.100 webfonts without their OFL text; 2.1.6
  fixes this.

## Open design questions

These are not decided here, because they are design decisions:

- **Body size.** Web body text is 14 px; iOS's default body is 17 pt. Qeetrix keeps the web's sizes and
  scales them with Dynamic Type.
- **Touch targets.** The densities' control heights (28 / 32 / 36) are pointer-sized. Phase 2 controls
  must keep their hit areas at 44 pt (`qeetrixMinimumTouchTarget()`).
- **Bold Text.** It is mapped to one step up the weight scale, a platform choice that needs a
  designer's review.
