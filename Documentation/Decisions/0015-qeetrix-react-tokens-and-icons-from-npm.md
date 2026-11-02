# 0015 — Built from `@qeetrix/react`, `@qeetrix/tokens` and `@qeetrix/icons`

**Status:** Accepted, 2026-10-30. Supersedes ADRs 0002 and 0011; amends 0004, 0005, 0007, 0010, 0012
and 0014. Brought to `@qeetrix/tokens` 0.0.13, `@qeetrix/icons` 2.1.0 and `@qeetrix/react` 0.4.0 the
same day, before release: decisions 1, 2, 5 and 6 say how.

## Context

Qeetrix for iOS was built from `@qeetrix/ui` 2.1.6: its Style Dictionary output (`tokens.json`,
`tokens.css`, `index.css`), its component manifest, and its shadcn-style components, whose geometry
came from Tailwind utility classes (ADR 0011). The web has moved on. `@qeetrix/react` is the successor
to `@qeetrix/ui`, with its own design language (direction C · Structured, `qeetrix-files/qeetrix-react/
04-design-language.md`, `05-design-rules.md`, `06-component-specs.md`), and the tokens are a package of
their own, `@qeetrix/tokens`, published as a DTCG build with a resolver. Nothing of Qeetrix for iOS has
been released, so the move can break every API.

## Decision

1. **Three npm packages, nothing else.** `Upstream/pins.json` pins `@qeetrix/tokens` 0.0.13,
   `@qeetrix/icons` 2.1.0 and `@qeetrix/react` 0.4.0. `Scripts/sync-upstream.sh` fetches each tarball
   from the npm registry, checks it against the registry's integrity hash, takes the files iOS reads
   and writes their sha256 into `upstream.lock.json`. `@qeetrix/ui`, the calcom and FiraCode release
   downloads and the qeetrix-icons git checkout are gone from the pipeline.
2. **Tokens from the DTCG build, resolved as its resolver says.** The generator reads
   `dist/dtcg/qeetrix.resolver.json`, merges its foundation set, then the colour-scheme context, then
   the density context, for all six combinations, and follows every alias. It must reproduce the
   package's own `light.tokens.json` and `dark.tokens.json` token for token, and agree with
   `tokens.css` on every value it declares, or generation fails. Reduce Motion is a rule the DTCG
   build states (`motion.duration`: every duration is 0 ms) but has no context for, so the generator
   reads `tokens.css`'s `prefers-reduced-motion` block and fails unless it sets every duration to that
   one value.
3. **The semantic layer only.** Every token outside `primitive.*` is generated or excluded with a
   reason (`Tokens/Scope.swift`); of the primitives, only the font weight scale the type roles use.
   Swift names are the path after the group in lowerCamelCase — `color.bg.brand.bold` →
   `QeetrixColor.bgBrandBold`, `radius.control` → `QeetrixRadius.control`, `size.control.lg` →
   `QeetrixDensity.sizeControlLg` — and raw values are the full paths (`body.md` for a text role).
   `Documentation/Foundations/token-values.json` lists every generated token with its source file,
   alias, Swift name and resolved value in each context, so another platform's build can be diffed.
4. **No component tokens.** `@qeetrix/tokens` publishes component tokens only for components iOS
   doesn't have (sidebar, tour, command palette, timeline). A component's geometry is in
   `@qeetrix/react`'s CSS, so the sync keeps each implemented family's compiled CSS
   (`dist/css/<family>.css`) in `Upstream/qeetrix-react/css/` as the reference, and each component
   restates its values next to the CSS they come from (`padding-inline: 14px`). A version bump shows
   the CSS diff. This replaces ADR 0011's component tokens and `QeetrixWebScale`.
5. **Fonts are the package's own TTFs.** `@qeetrix/tokens` ships `fonts/QeetSans.ttf` and
   `fonts/FiraCode-VF.ttf` for native platforms, described by `fonts/native.json`. The sync takes them
   only if their sha256 and size match `native.json`, and only if the WOFF2 `native.json` says each
   was made from is the one in the package — the full font, of which the web loads per-script subsets
   (`QeetSans-latin.woff2`, …). Every axis is kept (Qeet Sans: opsz, GEOM, wght, YTAS, SHRP, ital).
   Each typography role names its letter style in its token (`$extensions["in.qeet.qeetrix"]
   .fontGeometry`): `font.geometry.display` for display sizes, `.heading` for headings and titles,
   `.body` for body text, labels and code (Fira Code has no `GEOM` axis, so iOS sets none there, as
   the browser does). Beside it is the exact line height (`.lineHeight`, a length on the 4 pt grid);
   the generator takes both from the extension and fails unless the DTCG ratio is that length over
   the size, exactly. `opsz` is the point size (CSS's `font-optical-sizing: auto`).
6. **Icons from the npm package's SVG files.** `@qeetrix/icons` 2.1.0 publishes every drawing as a
   plain SVG file (`dist/svg/<shape>-<variant>/<id>.svg`) and its catalogue as JSON
   (`dist/manifest.json`). The sync keeps the pinned icons' manifest entries and, verbatim, the file of
   each drawing an entry lists, and fails if the files and the entry disagree; the generator runs them
   through the same strict SVG parser as before (ADR 0005). The subset is the icons the components and
   the showcase use; a pinned name the package has renamed fails the sync with the new name. (2.0.0
   shipped only React modules, which a JavaScript reader turned back into SVG; it went with 2.1.0,
   QTRX-188, and the generated drawings are identical.)
7. **Components follow `@qeetrix/react`.** Every component is re-specified from its `@qeetrix/react`
   counterpart: its parts, metrics, states, motion and colour use from the family's CSS and the
   design rules, and its parameter, variant, tone and size names from the React props, in Swift idiom
   (`variant: .solid / .soft / .ghost`, `tone: .brand / .danger / .neutral`, `size: .sm / .md / .lg`,
   booleans as `isLoading`, `isFullWidth`). Folders follow `@qeetrix/react`'s families
   (`Components/Menu/Menu`, `Components/Radio/RadioGroup`, `Components/Field/Field`).
8. **Platform conventions stay.** 44 pt hit areas, VoiceOver through native controls, Dynamic Type,
   and the system's alerts, confirmation dialogs, sheets, popovers and menus (ADR 0014) are kept.
   Where `@qeetrix/react` has no counterpart — the confirmation dialog, the navigation and tab bar
   styling, the selectable card, the form actions row — the component is kept and restyled to the new
   tokens and design rules, never redesigned.
9. **Text has CSS line boxes.** A text role's line height applies to every line, the first and last
   included: half of the difference to the font's natural line height is added above and below the
   text (CSS's half-leading), negative where the role's line is shorter than the font's, so one line of
   `label.sm` is 16 pt as on the web. Containers that only set their descendants' type don't take it.

## Consequences

- Breaking changes everywhere: every component, the token API (`QeetrixSpacing` → `QeetrixSpace`,
  `QeetrixCorner` → `QeetrixRadius`, `QeetrixStroke` → `QeetrixBorderWidth`, `QeetrixElevation` →
  `QeetrixShadow`, the typography roles), the provenance record and the folder layout.
  `Documentation/MIGRATION_QEETRIX_REACT.md` maps each old name to its new one.
- The pipeline has one reader it didn't need before, the DTCG resolver. It fails on anything outside
  what the package publishes today.
- No Python, Node or other tool is needed: the WOFF2 conversion this migration first used was retired
  when `@qeetrix/tokens` 0.0.12 shipped the TTFs, which are byte-identical to it.
- Two `@qeetrix/react` 0.3.0 cascade bugs were not copied (a solid neutral button's Ember hover, a
  pressed ghost danger button's Ember tint). React 0.4.0 fixed both (QTRX-157, QTRX-158), and
  `QeetrixButtonStyle.swift` cites the rules that now say what iOS draws.
