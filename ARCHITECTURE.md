# Architecture

Qeetrix for iOS is one Swift package with one library module, `Qeetrix`, built from the same sources
of truth as the web: `@qeetrix/tokens`, `@qeetrix/icons` and `@qeetrix/react`, as published on npm
(ADR 0015). Nothing visual is authored here. This repository turns those artifacts into typed SwiftUI
API, and follows `@qeetrix/react`'s components and design rules.

## Layout

```text
Package.swift                 the library: product Qeetrix, iOS 17 (+ macOS 14 as a dev host)
Sources/Qeetrix/
├── Tokens/                   token value types, provenance — and Generated/ (never edited)
├── Foundations/              behaviour over tokens: Colors, Typography, Sizing, Shadow, Motion, Accessibility
├── Theme/                    theme mode, theme, environment; the navigation bar styling
├── Icons/                    QeetrixIcon, its drawing types, Image(qeetrix:) for system chrome — and
│                             Generated/ (never edited)
├── Components/<Family>/<Component>/   the components, one folder per @qeetrix/react family; Shared/
│                             for what several families use (component text styles, text tones, hit
│                             area, text-input traits, the option model, dialog actions); Field/Field
│                             and Input/Input for the field layer every input builds on
├── Internal/                 implementation details (colour storage, built-in strings, logging)
├── Resources/                Fonts/ (TTF + licence), Metadata/token-provenance.json,
│                             Localization/<language>.lproj (built-in strings)
└── Qeetrix.docc/             API and usage documentation (DocC): landing page, foundation guides,
                              Components/ (one page per component)
Tests/QeetrixTests/           mirrors Sources: Tokens, Foundations/*, Theme, Icons, Components/*, Integration
Tests/QeetrixSnapshotTests/   component specimens in the ADR 0009 matrix; __Snapshots__/ holds the baselines
Templates/Component/          what Scripts/new-component.sh renders for a new component
Examples/QeetrixShowcase/     an iOS app that depends on the package, and its XCUITests
Tools/QeetrixGen/             the build tool: its own Swift package (Sources/QeetrixGenCore, Tests)
Tools/dependency-allowlist.json   the reviewed test-only dependencies, versions and licences
Upstream/                     pins.json (edited), upstream.lock.json (written by sync), the pinned
                              inputs: qeetrix-tokens/, qeetrix-icons/, qeetrix-react/
Scripts/                      the commands people and CI run: sync-upstream, generate, verify, lint,
                              warnings, dependencies, resources, api-check, docs, check,
                              new-component, ci-simulator
Documentation/
├── Decisions/                numbered architecture decision records
├── Standards/                component contract, accessibility
├── Website/                  handoffs to the ui.qeet.in documentation
├── Foundations/ API/         generated: token coverage, token values, public API baseline
├── MIGRATION_QEETRIX_REACT.md   old → new names and decisions of the @qeetrix/react migration
├── CROSS_PLATFORM_CONTRACT.md
└── THIRD_PARTY_NOTICES.md    licences of the bundled fonts and the icon artwork
.github/                      CI workflow, CODEOWNERS, PR and issue templates
```

Components live under `Sources/Qeetrix/Components/<Family>/<Component>/`, one folder per
`@qeetrix/react` family; no folder exists before its first component. The rules for a component are in
[Documentation/Standards/COMPONENT_CONTRACT.md](Documentation/Standards/COMPONENT_CONTRACT.md), and its
API conventions in [ADR 0010](Documentation/Decisions/0010-component-api-conventions.md).
Decisions behind this layout are in [Documentation/Decisions](Documentation/Decisions/README.md).

## Layers and dependency rules

```text
Generated tokens  →  Foundations  →  Theme
        ↘                ↘
          Icons  ←────────
                  ↘
                   Components  (Tokens, Foundations, Icons)
Internal supports every layer; nothing depends on Theme except apps.
```

- **Tokens** (`Tokens/`, `Tokens/Generated/`) hold values only. The generated files declare the typed
  token API (`QeetrixColor`, `QeetrixSpace`, `QeetrixTextRole`, …) and the internal per-scheme tables
  (`QeetrixLightTokens`, `QeetrixDarkTokens`). They depend only on the value types in
  `QeetrixTokens.swift` and on `Internal/`.
- **Foundations** give tokens behaviour: `QeetrixColor` becomes a `ShapeStyle`, `QeetrixTextRole` gets
  a font and Dynamic Type, `QeetrixShadow` gets drawn, easings become `Animation`s. Foundations read
  the SwiftUI environment directly (`colorScheme`, `legibilityWeight`, `accessibilityReduceMotion`), never
  the Theme layer.
- **Theme** is the environment surface apps use: `QeetrixThemeMode`, `QeetrixTheme`, and the modifiers
  that set them. It is built from Foundations.
- **Icons** use the icon tokens (size, stroke) and their own generated catalogue.
- **Inputs** are built on one field layer (`Components/Field/Field`): `QeetrixField` lays out the label,
  description and error and passes them, through the environment, to the native control inside, which
  carries them for VoiceOver; `QeetrixInputSurface` (`Components/Input/Input`) draws every filled input's
  states — fill, bottom line, focus and invalid frames. Each input wraps
  the system control — `SecureField`, `TextField`, `Toggle`, `Menu` — rather than imitating it (ADR 0012).
- **Overlays and navigation** wrap the system presentations — `.alert`, `.confirmationDialog`, `.sheet`,
  `.popover`, `Menu`, `TabView`, the navigation bar — and are driven by a binding the presenting view
  owns, which they reset when the presentation ends (ADR 0014). There is no presentation manager,
  router or global state; the toast host's lifecycle is a value type (`QeetrixToastState`) with a
  view-scoped timer.
- **Components** are built from semantic tokens, the foundations' modifiers and icons, with the
  lengths `@qeetrix/react`'s CSS writes as literals restated beside the CSS rule they come from (ADR
  0015). Their type comes from `QeetrixTypeSpec` — a role, or a role at another weight — resolved by the
  same code as `qeetrixTextStyle(_:)`, so Dynamic Type and Bold Text behave identically. Components read
  the environment (`isEnabled`, `isFocused`, `qeetrixDensity`, `colorScheme`), not the Theme layer.
- The library depends on no other package and on no Qeet product. Its only package dependency is
  test-only (SnapshotTesting, ADR 0009), which apps never resolve. The example app and the tests depend
  on the library, never the reverse.

There is one module. Extracting another target or product later is a real API change, not a move: it
brings new module names, imports and access levels, and needs compatibility work. The conditions that
would justify it are in [ADR 0001](Documentation/Decisions/0001-one-package-one-public-module.md).

## Design-token pipeline

```text
@qeetrix/tokens (npm)                     @qeetrix/icons (npm)          @qeetrix/react (npm)
  dist/dtcg/** · tokens.css · fonts/*.ttf    svg/**/*.svg · manifest.json  manifest.json · css/<family>.css
                └────────── Scripts/sync-upstream.sh (integrity, native.json, lock) ──────────┘
                                         ↓
                    Upstream/ + Resources/Fonts + upstream.lock.json
                                         ↓   Scripts/generate.sh (offline, deterministic)
        Tokens/Generated/*.swift · Icons/Generated/*.swift · Metadata/token-provenance.json
            Documentation/Foundations/TOKEN_COVERAGE.md · token-values.json
```

**Input.** The DTCG build of `@qeetrix/tokens`: its resolver, every source file it names, and the two
schemes it publishes pre-resolved (`light.tokens.json`, `dark.tokens.json`), plus `tokens.css`. Each
tarball is checked against the npm registry's integrity hash; the lock records its version and the
commit it was published from (`gitHead`).

**Resolution.** `Tools/QeetrixGen/Sources/QeetrixGenCore/Tokens/DTCG.swift` does what the resolver
says: the `foundation` set, then the `colorScheme` context, then the `density` context, later sources
replacing tokens at the same path, `$type` inherited from groups, every `{alias}` followed. It resolves
all six contexts (light and dark × default, comfortable, compact) and fails unless:

- light/default and dark/default reproduce the package's pre-resolved files token for token;
- every context has the same token paths;
- the modifiers are exactly `colorScheme` (light, dark) and `density` — a new modifier or scheme needs
  a mapping first;
- `tokens.css` agrees with every generated token it declares, in `:root`, each
  `[data-qx-color-scheme]` and each `[data-qx-density]` block, evaluated by the strict CSS reader.

**Scope.** `Tokens/Scope.swift` decides what is generated, by path:

- the semantic layer — everything outside `primitive.*` — into typed groups (`QeetrixColor`,
  `QeetrixShadow`, `QeetrixTextRole`, `QeetrixSpace`, `QeetrixRadius`, `QeetrixBorderWidth`,
  `QeetrixFocus`, `QeetrixOpacity`, `QeetrixIconSize`, `QeetrixIconStroke`, `QeetrixSize`,
  `QeetrixDuration`, `QeetrixEasing`, `QeetrixSpring`, `QeetrixFontGeometry`, and `QeetrixDensity` for
  the density-dependent sizes);
- of the primitives, only the font weight scale the type roles use;
- excluded with a reason: palette and scale primitives, font families (resolved into the roles),
  z-indices, breakpoints, and the component tokens of components iOS doesn't have.

A token that matches no rule fails generation. Only colours and shadows may follow the colour scheme,
and only the density group the density. Reduce Motion's durations come from `tokens.css`'s
`prefers-reduced-motion` block, which the DTCG build has no context for.

**Colour conversion** follows the CSS Color 4 reference matrices (OKLCH → OKLab → XYZ):

- a colour inside sRGB is emitted as sRGB and must round to the package's own `hex` (±1 per channel);
- a colour outside sRGB but inside Display P3 is emitted as Display P3, which is what Safari paints on
  an iPhone — one value today, `color.dataviz.categorical.2` in light;
- a colour outside P3 would be gamut-mapped with the CSS Color 4 algorithm; none is today;
- components are rounded to six decimals, so the output is byte-stable.

**Outputs.** Besides the Swift, `Documentation/Foundations/token-values.json` lists every generated
token with its source file, alias, Swift name, CSS variable and value in each context it varies over,
for diffing against another platform's build; `TOKEN_COVERAGE.md` explains what is and isn't
generated.

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
| Qeet Sans | `QeetSans.ttf` | `@qeetrix/tokens` `fonts/QeetSans.ttf` (Cal Sans 2.011) | its sha256 and size match `fonts/native.json`, which names the package's full `QeetSans.woff2` it was made from (the web loads per-script subsets of it), whose sha256 the sync checks too |
| Fira Code | `FiraCode-VF.ttf` | `@qeetrix/tokens` `fonts/FiraCode-VF.ttf` (Fira Code 6.2) | the same, against `FiraCode-VF.woff2` |

- **Why TTF.** WOFF2 is a web container; the package ships TrueType for native platforms (fontTools'
  decompression of its WOFF2, every glyph and axis kept).
- **Licences.** The package's own licence files, bundled beside the fonts.
- **Loading.** `QeetrixFontRegistry` registers the fonts process-wide, once, and builds every font from
  the descriptor CoreText reads out of the bundled file. Fonts are never looked up by PostScript name:
  name lookups on this variable font returned a synthesised instance in testing.
- **Axes.** Each role sets `wght` (weight), `GEOM` (the letter style its token names:
  `font.geometry.display` 100 for display sizes, `.heading` 50 for headings and titles, `.body` 0 for
  body text and labels), `opsz` (the scaled point size, the web's `font-optical-sizing: auto`) and
  `ital` 0. YTAS and SHRP keep their defaults, as on the web.
- **Line height.** A role's line height is exact, the length its token gives on the 4 pt grid (20 pt
  for `body.md`, not 14 × 1.4286). It applies to every line: `lineSpacing` between lines, and CSS's
  half-leading above the first and below the last, so one line is the role's height.
- **Failure.** A failed registration is logged and reported by `register()`. Text then falls back to
  the system font at the same weight, never silently.
- **Other scripts.** Scripts the fonts do not cover, such as the Indic scripts, fall back through
  CoreText's system cascade, as browsers do without Noto Sans.

## Icons

The pinned icons' SVG files are read at generation time, not at run time.

- **Input.** `@qeetrix/icons` publishes every drawing as an SVG file and its catalogue as JSON. The
  sync keeps each pinned icon's manifest entry and the files of the drawings it lists, verbatim
  (`Upstream/qeetrix-icons/svg/<shape>-<variant>/<name>.svg`); a file the entry doesn't list, or a
  listed one that is missing, fails the sync and the generator.
- **Supported subset.** The SVG parser accepts `path` (every command; arcs become cubics per SVG F.6),
  `line`, `circle`, `ellipse`, `rect`, `polyline` and `polygon`, painted only in `currentColor`.
- **Rejected.** Transforms, groups, gradients, hard-coded colours and per-element stroke widths fail
  generation.
- **Output.** Each drawing becomes path commands in the 24-unit grid. `QeetrixIcon` draws them in a
  `Canvas`: the stroke width is the icon-stroke token scaled with the icon, as on the web, and the
  colour is the inherited foreground style. Components draw the sharp shape (design rules §16).
- **Why not an asset catalogue.** Generated paths keep vectors exact, let the stroke token apply at
  run time, need no asset compiler, and can be tested on any host.

## Public API principles

- Every public name starts `Qeetrix` and follows the token's own name, for example `color.bg.brand.bold`
  → `QeetrixColor.bgBrandBold`. Raw values are the upstream names. Component parameters follow
  `@qeetrix/react`'s props (`variant`, `tone`, `size`).
- Defaults match the web: an icon is `md`/`regular`/round outline, a button `solid`/`brand`/`md`, and
  the theme mode is `.system`.
- Behaviour is exposed as SwiftUI modifiers, `ShapeStyle`s and styles (`ButtonStyle`, `ToggleStyle`,
  `ProgressViewStyle`); a component's named view is built on its style (ADR 0010).
- Implementation types are internal: colour storage, per-theme tables, icon drawings and logging.
- `Documentation/API/Qeetrix.public-api.txt` lists the public API. `Scripts/api-check.sh` fails when it
  changes, so an API change is always a decision, recorded in `CHANGELOG.md`.

## Upstream observations

Found while building on `@qeetrix/tokens` 0.0.12, `@qeetrix/icons` 2.0.0 and `@qeetrix/react` 0.3.0,
and reported as QTRX tickets: the icons' SVG files and JSON manifest (QTRX-188), each typography role's
letter style in its token (QTRX-186), the neutral and ghost danger button states (QTRX-157, QTRX-158)
and four places where the design documents disagreed with the CSS (QTRX-159, QTRX-162, QTRX-169,
QTRX-171). Tokens 0.0.13, icons 2.1.0, react 0.4.0 and the specs fixed every one, so iOS carries no
upstream workaround; the migration file lists each.

Two things look like gaps and aren't:

- `@qeetrix/icons` marks the arrows and chevrons `directionality: "preserve"` on purpose: a physical
  arrow never mirrors, and the call site decides when a direction should follow the reading order.
- The DTCG build states the Reduce Motion rule (every duration 0 ms) without a context for it; the
  generator reads `tokens.css`'s `prefers-reduced-motion` block and checks it says the same.
## Open design questions

These are not decided here, because they are design decisions:

- **Body size.** Web body text is 14 px; iOS's default body is 17 pt. Qeetrix keeps the web's sizes and
  scales them with Dynamic Type.
- **Touch targets.** The default density's control heights (28 / 32 / 40) are pointer-sized; only the
  comfortable density reaches 44 pt, the design rules' touch size. Components keep the web's drawn
  size and extend their hit area to 44 pt without moving layout; adjacent controls closer than 44 pt
  can therefore share a target edge. Whether iOS screens should default to the comfortable density is
  a design decision.
- **Field text.** Fields use the web's 14 pt `body.md`, as `@qeetrix/react` does (the previous 16 pt
  mobile size came from `@qeetrix/ui`).
- **Switch layout.** The control first and the label after it, as the design rules say; iOS settings
  usually put the switch at the trailing edge.
- **Selection rows.** Checkbox, radio and switch rows are 44 pt tall and flush; the web draws 16 px
  controls in 24 px rows 4 px apart.
- **Extended hit areas can overlap.** Controls drawn under 44 pt and placed closer than 44 pt apart
  share target space: a UI test caught a tap on one error-summary link landing on the next. Components
  that stack (selection rows, summary links) use full 44 pt rows instead; buttons in tightly wrapped
  rows still overlap by a few points.
- **Bold Text.** It is mapped to one step up the weight scale, a platform choice that needs a
  designer's review.
- **One toast at a time.** The web stacks toasts; iOS shows one and replaces it (ADR 0014). Whether a
  product needs a short stack on iPad is open.
- **A centred dialog on iPhone.** The sheet stands in for the web `Dialog` everywhere; a centred,
  non-sheet modal is deferred until a product needs one.
- **System menu surfaces.** Menus, alerts and confirmation dialogs keep the system's font and material,
  so `@qeetrix/react`'s menu surface, Ember highlight edge and shortcuts have no iOS use yet.
