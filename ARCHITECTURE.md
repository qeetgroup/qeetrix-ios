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
├── Theme/                    theme mode, theme, environment; the navigation bar styling
├── Icons/                    QeetrixIcon, its drawing types, Image(qeetrix:) for system chrome — and
│                             Generated/ (never edited)
├── Components/<Family>/<Component>/   the components, one folder per qeetrix-ui family; Shared/ for
│                             what several families use (component text styles, hit area, spinning,
│                             text-input traits, the option model, dialog actions); Input/Field/ for
│                             the field layer every input builds on
├── Internal/                 implementation details (colour storage, component colours, the web
│                             scale, built-in strings, logging)
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
Upstream/                     pins.json (edited), upstream.lock.json (written by sync), pinned inputs
Scripts/                      the commands people and CI run: sync-upstream, generate, verify, lint,
                              warnings, dependencies, resources, api-check, docs, check,
                              new-component, ci-simulator
Documentation/
├── Decisions/                numbered architecture decision records
├── Standards/                component contract, accessibility
├── Website/                  handoffs to the ui.qeet.in documentation
├── Foundations/ API/         generated: token coverage, public API baseline
├── CROSS_PLATFORM_CONTRACT.md
└── THIRD_PARTY_NOTICES.md    licences of the bundled fonts and the icon artwork
.github/                      CI workflow, CODEOWNERS, PR and issue templates
```

Components live under `Sources/Qeetrix/Components/<Family>/<Component>/`, one folder per qeetrix-ui
family; no folder exists before its first component. The rules for a component are in
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
- **Inputs** are built on one field layer (`Components/Input/Field`): `QeetrixField` lays out the label,
  description and message and passes them, through the environment, to the native control inside, which
  carries them for VoiceOver; `QeetrixFieldSurface` draws every bordered input's states. Each input wraps
  the system control — `SecureField`, `TextField`, `Toggle`, `Menu` — rather than imitating it (ADR 0012).
- **Overlays and navigation** wrap the system presentations — `.alert`, `.confirmationDialog`, `.sheet`,
  `.popover`, `Menu`, `TabView`, the navigation bar — and are driven by a binding the presenting view
  owns, which they reset when the presentation ends (ADR 0014). There is no presentation manager,
  router or global state; the toast host's lifecycle is a value type (`QeetrixToastState`) with a
  view-scoped timer.
- **Components** are built from semantic and component tokens, the foundations' modifiers and icons.
  Their type comes from `QeetrixTypeSpec` — a role, or a component text style the web sets with
  utility classes — resolved by the same code as `qeetrixTextStyle(_:)`, so Dynamic Type and Bold Text
  behave identically. Component tokens and `QeetrixWebScale` are internal (ADR 0011). Components read
  the environment (`isEnabled`, `qeetrixDensity`, `colorScheme`), not the Theme layer.
- The library depends on no other package and on no Qeet product. Its only package dependency is
  test-only (SnapshotTesting, ADR 0009), which apps never resolve. The example app and the tests depend
  on the library, never the reverse.

There is one module. Extracting another target or product later is a real API change, not a move: it
brings new module names, imports and access levels, and needs compatibility work. The conditions that
would justify it are in [ADR 0001](Documentation/Decisions/0001-one-package-one-public-module.md).

## Design-token pipeline

```text
@qeetrix/ui (npm, published)        calcom/sans · tonsky/FiraCode      qeetrix-icons (git commit)
  tokens.json · tokens.css · index.css    native TTF + OFL                 SVGs + manifest entries
                └───────── Scripts/sync-upstream.sh (verify, copy, lock) ─────────┘
                                         ↓
                    Upstream/ + Resources/Fonts + upstream.lock.json
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

**Scope.** `Tools/QeetrixGen/Sources/QeetrixGenCore/Tokens/Scope.swift` decides what is generated:

- Included: the consumable layer, minus z-indices (no SwiftUI meaning), gradients (not yet a
  foundation) and component token groups no component uses yet.
- Component tokens are generated per group, for the groups listed in `Upstream/pins.json`
  (`componentTokens`) — today avatar, badge, button, card, input, progress, switch and typography — as
  internal `Qeetrix<Group>Tokens` enums. A colour that names a semantic colour stays that
  `QeetrixColor`; a density-resolved size stays a function of `QeetrixDensity`. qeetrix-ui 2.1.6
  defines 41 groups covering 40 of its 97 families; the other 57 families use semantic tokens only
  ([ADR 0002](Documentation/Decisions/0002-tokens-from-the-published-qeetrix-ui-build.md),
  [ADR 0011](Documentation/Decisions/0011-component-tokens-and-web-metrics.md)).
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
- Behaviour is exposed as SwiftUI modifiers, `ShapeStyle`s and styles (`ButtonStyle`, `ToggleStyle`,
  `ProgressViewStyle`); a component's named view is built on its style (ADR 0010).
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
- Component geometry is not in the token contract. Heights, padding, gaps and type steps come from
  Tailwind utility classes in each component's source, so a change to them changes the web without
  changing `tokens.json` (ADR 0011).
- The shadcn bridge colours (`--secondary`, `--muted-foreground`, …) are emitted into `tokens.css` as
  literal OKLCH values, not references; their meaning is only in `src/tokens/theme/*/bridge.json`,
  which is not published. iOS maps them to the semantic tokens that file names.
- `component-manifest.json` calls a component's family its `category`; the ui.qeet.in documentation
  category (Actions, Forms & inputs, …) is not in the manifest.

## Open design questions

These are not decided here, because they are design decisions:

- **Body size.** Web body text is 14 px; iOS's default body is 17 pt. Qeetrix keeps the web's sizes and
  scales them with Dynamic Type.
- **Touch targets.** The densities' control heights (28 / 32 / 36) are pointer-sized. Components keep
  the web's drawn size and extend their hit area to 44 pt without moving layout, as the web Switch
  does; adjacent controls closer than 44 pt can therefore share a target edge. Whether iOS should
  draw controls at 44 pt instead is a design decision.
- **Field text.** Text fields use the web's 16 pt mobile field size, not the 14 pt body size.
- **Switch layout.** Label leading, switch trailing, as iOS lays out a toggle; the web places the
  switch where the form puts it.
- **Selection rows.** Checkbox, radio and switch rows are 44 pt tall and flush; the web draws 16 px
  controls 12 px apart with 24 px pointer targets.
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
  so the `component.menu` tokens have no iOS use yet.
