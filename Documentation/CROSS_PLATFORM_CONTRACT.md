# Cross-platform contract

How a Qeetrix design decision made for the web arrives on iOS unchanged, and what "unchanged" means
where the platforms differ. Qeetrix for Android follows the same rules; the two libraries are compared
through `Documentation/Foundations/token-values.json` and `Documentation/MIGRATION_QEETRIX_REACT.md`,
which each keeps.

## Source of truth

| Concern | Authority | iOS reads |
|:--|:--|:--|
| Tokens | `@qeetrix/tokens` (DTCG, `qeetrix.resolver.json`) | the published `dist/dtcg/` build, resolved as the resolver says, checked against the package's `light.tokens.json`, `dark.tokens.json` and `tokens.css` |
| Colour schemes, densities | the resolver's `colorScheme` (light, dark) and `density` (default, comfortable, compact) modifiers | the same contexts |
| Typeface | `@qeetrix/tokens` `fonts/` | the package's native TTFs, checked against `fonts/native.json` and the package's full WOFF2 they were made from (the web loads per-script subsets of it) |
| Icons | `@qeetrix/icons` (Lucide names; round and sharp; outline and filled) | the published SVG files and manifest entries of the pinned subset |
| Components | `@qeetrix/react` (each family's TSX and CSS) and the design documents (`qeetrix-files/qeetrix-react/05-design-rules.md`, `06-component-specs.md`) | the published `dist/manifest.json` and each implemented family's `dist/css/<family>.css`, kept in `Upstream/qeetrix-react/`; values restated in each component beside the CSS they come from |

Changes flow one way: npm release → `pins.json` → sync → generate. Generated files and the snapshot
are never edited in this repository.

## Names

- A token keeps its path. The Swift name is the path after its group in lowerCamelCase
  (`color.bg.brand.bold` → `QeetrixColor.bgBrandBold`, `radius.control` → `QeetrixRadius.control`), and
  the raw value is the full path. Density tokens keep the whole path (`QeetrixDensity.sizeControlLg`).
- Swift identifiers cannot start with a digit, so a leading number moves to the end
  (`size.icon.2xs` → `QeetrixIconSize.xs2`).
- Typography roles, colour-scheme modes and icon names keep their upstream spelling as raw values
  (`body.md`, `system`, `send`), so stored values and analytics read the same on every platform.
- Component props keep `@qeetrix/react`'s names in Swift idiom: `variant`, `tone`, `size` as enums
  with the same cases (`.solid`, `.danger`, `.lg`); boolean states as `is…` (`loading` → `isLoading`,
  `fullWidth` → `isFullWidth`); `onValueComplete` stays.
- Icon names are an open set of static members rather than an enum on iOS (ADR 0016), so the catalogue
  can grow toward upstream's without breaking apps; the raw values are still the upstream names.

## Units and values

| Web | iOS |
|:--|:--|
| `1px` | 1 pt (both are the 1/96-inch reference pixel) |
| `1rem` | 16 pt: Qeetrix sets no root font size, so browsers use 16 px |
| `letterSpacing` in px | points at the role's size, scaled with the text |
| `ms` | seconds |
| DTCG `oklch` colour | sRGB when inside sRGB (it must round to the package's own `hex`), else Display P3 (CSS Color 4) |
| `cubicBezier` | `Animation.timingCurve` / `.linear` |
| DTCG spring (stiffness, damping ratio, mass 1) | `Animation.interpolatingSpring` |
| `box-shadow` | `.qeetrixShadow`: offset, spread, blur (σ = blur ÷ 2), outer layers outside the shape, inset inside |
| `font-weight` | the `wght` axis |
| `font-variation-settings: "GEOM" n` | the `GEOM` axis: each role's letter style as `@qeetrix/react` sets it |
| `font-optical-sizing: auto` | `opsz` = point size, clamped to the axis |
| `line-height` | the role's line on every line: `lineSpacing` between lines plus CSS half-leading above and below |
| `data-qx-color-scheme` on `<html>` / on a section | `.qeetrixThemeMode(_:)` / `.qeetrixTheme(_:)` |
| `data-qx-density` on a region | `.qeetrixDensity(_:)` |
| `prefers-reduced-motion` → every duration 0 ms | `accessibilityReduceMotion` → `QeetrixMotion.reducedDuration` (0) |
| component CSS lengths (`padding-inline: 14px`) | the same points, written beside the CSS rule they come from |
| `:focus-visible` frames | the same frames where SwiftUI reports focus (Full Keyboard Access) |
| `aria-*` and roles | native controls, traits and `accessibilityRepresentation` |

## Deliberate differences

Differences are platform requirements, never restyling:

- **Dynamic Type.** Token sizes are the default-size values and scale with the user's text size along
  a system text style per role. The web scales with browser zoom instead.
- **Bold Text.** It raises a role one weight step (past semibold, to 700). The web has no equivalent.
- **Touch targets.** Interactive hit areas are at least 44 pt, even where the drawn control uses a
  smaller density height, without moving layout. Choice rows are 44 pt and flush, where the web's are
  24 px rows 4 px apart.
- **System presentations.** Alerts, confirmation dialogs, sheets, popovers and menus are the system's
  (ADR 0014); their surface, material and font are iOS's, Qeetrix supplies the content, triggers and
  tint.
- **Components.** Each component's DocC page lists where it differs from the web and why, under
  *Platform differences* — for example the select's system menu, or the toast that shows one at a time.
- **Not mapped.** z-index tokens (SwiftUI orders siblings only), breakpoints (iOS size classes) and the
  component tokens of components iOS doesn't have. See [TOKEN_COVERAGE.md](Foundations/TOKEN_COVERAGE.md).

## Components

Every component's mapping — `@qeetrix/react` counterpart, old and new API, status — is in
[MIGRATION_QEETRIX_REACT.md](MIGRATION_QEETRIX_REACT.md#components). The rules both platforms keep:

- **Hierarchy.** At most one `solid` and one `soft` button per region; a destructive confirmation
  replaces the primary.
- **Ember** only where it means something: the primary action, focus, the current item, checked
  controls, links, the standard dialog line.
- **Shadows** only on floating layers: menus, popovers, toasts, dialogs.
- **Fields.** Filled, with a bottom line; the error replaces the description; optional fields say so,
  required ones carry no mark.
- **Dialog roles.** A destructive action is marked destructive; a cancel is always available; choosing
  an action closes the overlay and runs it once.
- **Toasts.** 5 s; danger toasts stay until dismissed and are announced at high priority; hover and
  focus hold a toast on screen.
- **Strings** are `@qeetrix/react`'s message catalogue ("(optional)", "Close", "Dismiss", "Show
  password", "Fix these to continue").

## Data display and content states (Phase 5)

The iOS contract (ADR 0015), compared with what exists on each side on 2026-10-19. Android has none of
these components yet (its working tree is at Phase 4), so no parity is claimed for it.

| Web (`@qeetrix/ui` 2.1.6) | iOS | Mapping |
|:--|:--|:--|
| — (a table or listbox row) | `QeetrixListItem`, `QeetrixListItemIcon`, `qeetrixListRow()` | iOS only: the list row, from the notification row's composition and the table's selected-row colours. |
| — | `QeetrixSectionHeader` in a native `Section` | iOS only: a group title with an action slot. |
| `DescriptionList` (`horizontal`, `vertical`, `grid`, `divided`) | `QeetrixDescriptionList`, `QeetrixDescriptionItem` | The same layouts. Columns switch on the size class, not the `sm` breakpoint. |
| `Accordion`, `Collapsible` | `QeetrixAccordion`, `QeetrixAccordionItem`, `.disclosureGroupStyle(.qeetrix)` | Native `DisclosureGroup`; `component.accordion` tokens; expansion read as a value. |
| `EmptyState` (5 variants, 3 sizes) | `QeetrixEmptyState` | The same variants, sizes, tiles and default glyphs. |
| `DataState` | `QeetrixDataState`, `QeetrixDataFailure`, `QeetrixDataLoadingRows` | The same order. iOS takes a message for the person instead of an error object, and adds a retry. |
| `Skeleton` | `QeetrixSkeleton`, `QeetrixSkeletonText` | `component.skeleton` tint; the same 1.6 s sweep, still under Reduce Motion. |
| `Chip`, `ChipGroup` | `QeetrixChip`, `QeetrixChipGroup` | The same sizes, selected vocabulary, check mark and remove button. iOS gives each chip its own focus stop. |
| `Timeline` | `QeetrixTimeline`, `QeetrixTimelineItem` | The same tones, emphasis, icon markers and connector; `component.timeline` tokens. |
| — (search lives in `FilterBar`, `CommandPalette`) | `searchable`, unwrapped | Native search field; Qeetrix adds the no-results state and chips. |
| `Table`, `DataTable`, `AspectRatio` | — | Deferred: native `Table` on iPad; `Image` and `AsyncImage` for images. |

## Verified against Android (2026-10-20)

Compared read-only with `qeetrix-android` at `5b4cb5b` (branch `phase-4-navigation-overlays-feedback`):

- **The same canonical inputs.** Both pin `@qeetrix/ui` 2.1.6, `qeetrix-icons` 1.0.11 at `331cd85`, Cal
  Sans v2.011 and Fira Code 6.2. Their `tokens.json`, `tokens.css` and `index.css` are byte-identical,
  so token identity, semantic colours and typography roles come from the same file.
- **Icons.** The iOS catalogue (37) is a subset of Android's (39), which also has `arrow-left` and
  `ellipsis-vertical`. Names are the same upstream names on both.
- **Component tokens.** Each platform adopts the groups its components use: both adopt accordion, avatar,
  badge, button, card, dialog, input, progress, skeleton, switch, timeline and typography. Only iOS adopts
  popover. Only Android adopts menu (iOS menus are system-drawn, ADR 0014) and sidebar (no iOS sidebar).
- **Licences.** Both bundle the fonts' licences and the icon notice under the same file name,
  `qeetrix-icons-LICENSE.txt`.

No contradiction in tokens or component contracts was found. Coordinated upstream work: none required.

## Checking parity

- `Tests/QeetrixTests/Tokens` compares the generated Swift with the snapshot: every colour and
  typography role, densities, motion and the provenance record.
- `Tests/QeetrixTests/Foundations/Accessibility` re-runs `@qeetrix/tokens`' WCAG AA pairs, and the pairs
  the iOS components draw, on the converted iOS colours.
- `Documentation/Foundations/token-values.json` holds every generated value per context; diff it with
  the Android library's file of the same name.
- `Resources/Metadata/token-provenance.json`, read with `QeetrixProvenance.bundled()`, names the exact
  package versions, so a web and an iOS build can be checked for the same release.
- Phase 6 added checks of the contract in the running app: Apple's accessibility audit over every
  showcase page (`AccessibilityAuditUITests`) and the timeline drawn right to left (`TimelineTests`).
  Results are in `Documentation/Quality/`.
