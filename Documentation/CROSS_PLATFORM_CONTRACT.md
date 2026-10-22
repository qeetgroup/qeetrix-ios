# Cross-platform contract

How a Qeetrix design decision made for the web arrives on iOS unchanged, and what "unchanged" means
where the platforms differ. Android, when it comes, should follow the same rules.

## Source of truth

| Concern | Authority | iOS reads |
|:--|:--|:--|
| Tokens | qeetrix-ui `src/tokens/**` (DTCG), compiled by its Style Dictionary build | the published `@qeetrix/ui` `tokens.json` / `tokens.css` / `index.css` |
| Themes | qeetrix-ui `scripts/config/themes.json` (light, dark) | the theme keys in `tokens.json` |
| Typeface | qeetrix-ui `fonts/` (WOFF2) | the same releases' TTFs, proven byte-identical through their WOFF2 |
| Icons | qeetrix-icons `icons/**.svg` + `icon-manifest.json` | the pinned commit's SVGs and manifest entries |
| Components | qeetrix-ui `src/components/<Family>/` (variants, sizes, states, utility classes) and the published `component-manifest.json` (slugs, families) | the manifest, pinned; component sources read at the pinned commit and restated in each component, with the web class beside each value |

Changes flow one way: upstream release → `pins.json` → sync → generate. Generated files and the
snapshot are never edited in this repository.

## Names

- A token keeps its upstream path. The Swift name is that path in lowerCamelCase without its group
  (`color.text.on-brand` → `QeetrixColor.textOnBrand`), and the raw value is the full path.
- Swift identifiers cannot start with a digit, so a leading number moves to the end (`space.2xl` →
  `QeetrixSpacing.xl2`) and `0` becomes `zero`.
- Typography roles, theme modes and icon names keep their upstream spelling as raw values
  (`label-compact`, `system`, `send`), so stored values and analytics read the same on both
  platforms.
- Icon names are an open set of static members rather than an enum on iOS (ADR 0016), so the catalogue
  can grow toward upstream's without breaking apps; the raw values are still the upstream names.

## Units and values

| Web | iOS |
|:--|:--|
| `1px` | 1 pt (both are the 1/96-inch reference pixel) |
| `1rem` | 16 pt: qeetrix-ui sets no root font size, so browsers use 16 px |
| `em` letter-spacing | multiplied by the scaled point size |
| `ms` | seconds |
| `oklch()` / `color-mix(in oklab, …)` | sRGB when inside sRGB, else Display P3 (CSS Color 4 conversion) |
| `cubic-bezier()` / `linear` | `Animation.timingCurve` / `.linear` |
| `box-shadow` | `.qeetrixElevation`: offset, spread, blur (σ = blur ÷ 2), outer layers clipped outside the shape, inset layers inside |
| `font-weight` | the `wght` axis |
| `font-variation-settings: "GEOM" n` | the `GEOM` axis |
| `font-optical-sizing: auto` | `opsz` = point size, clamped to the axis |
| `.dark` on `<html>` / nested `.dark` | `.qeetrixThemeMode(.dark)` / `.qeetrixTheme(.dark)` |
| `prefers-reduced-motion` → `motion.reduced.*` | `accessibilityReduceMotion` → `motion.reduced.*` |
| Tailwind utilities in components (`h-7`, `px-2.5`, `text-sm`, `leading-snug`) | `QeetrixWebScale`, restating Tailwind 4.3.3's defaults (ADR 0011) |
| shadcn bridge colours (`bg-secondary`, `text-muted-foreground`) | the semantic token qeetrix-ui's `bridge.json` names (`surfaceInteractive`, `textTertiary`) |
| `cva` variant and size names | the same names as Swift enum cases (`.default`, `.outline`, `.sm`), ADR 0010 |
| `aria-*` and roles | native controls, traits and `accessibilityRepresentation` |

## Deliberate differences

Differences are platform requirements, never restyling:

- **Dynamic Type.** Token sizes are the default-size values and scale with the user's text size. The
  web scales with browser zoom instead.
- **Bold Text.** It raises a role one weight step. The web has no equivalent setting.
- **Touch targets.** Interactive hit areas are at least 44 pt, even where the drawn control uses a
  smaller density height. Components extend the hit area without moving layout.
- **Components.** Each component's DocC page lists where it differs from the web and why, under
  *Platform adaptations* — for example a switch's label leading, or a text field's announcements.
- **Line height.** It is applied as SwiftUI `lineSpacing`, which cannot go below the font's natural
  height and adds no half-leading above the first line.
- **Not mapped.** z-index tokens (SwiftUI orders siblings only) and gradients (not yet a
  foundation). See [TOKEN_COVERAGE.md](Foundations/TOKEN_COVERAGE.md).

## Form fields (Phase 3)

The iOS form contract (ADR 0012), compared with what exists on each side on 2026-10-19:

| Concept | Web (`@qeetrix/ui` 2.1.6) | iOS | Android (`qeetrix-android` working tree, uncommitted) |
|:--|:--|:--|:--|
| Field parts | `Field`, `FieldLabel`, `FieldDescription`, `FieldError` / `FieldWarning` / `FieldSuccess` | `QeetrixField`; every input takes `description`, `message`, `isRequired`, `isOptional` | `QeetrixTextField` takes `description`, `message`, `required`, `optional` |
| Message | error, warning, success; icons circle-alert, triangle-alert, circle-check | `QeetrixFieldMessage`, same tones, icons and colours | `QeetrixFieldMessage`, same tones, icons and colours |
| Association | `aria-labelledby`, `aria-describedby`, `aria-errormessage` | the control's name, hint and custom content | the field's `error()` semantics |
| Announcement | error `role="alert"`, others `role="status"` | a VoiceOver announcement on each new message | live regions: assertive for errors, polite otherwise |
| Password, textarea | in the library | implemented | `QeetrixPasswordInput`, `QeetrixTextarea`, `QeetrixFieldSet` in progress; not compared yet |
| OTP, checkbox, radio group, select, number field | in the library | implemented | **not implemented** — no parity can be claimed |

Platform differences recorded on each iOS component page: the select uses the system menu, the radio group
gives each option its own keyboard stop, the number field has steppers but no pointer scrubbing, the OTP
input is one native field drawn as cells and also accepts letters (`.alphanumeric`, an iOS addition), and
checkbox and radio rows are 44 pt touch rows.

## Navigation, overlays and feedback (Phase 4)

The iOS contract (ADR 0014), compared with what exists on each side on 2026-10-19. Android has none of
these components yet, so no parity is claimed for it.

| Web (`@qeetrix/ui` 2.1.6) | iOS | Mapping |
|:--|:--|:--|
| `Tabs`, `default` and `line` | `QeetrixTabs`, `QeetrixTabsVariant.default` / `.line` | Same variants, metrics and states. The panel is the app's view, not a `TabsContent`. |
| `NavigationMenu`, `Sidebar` | `qeetrixNavigationBar(background:)`, `qeetrixTabBar()`, `qeetrixTabItem(_:icon:badge:)` | iOS styles the system bars; no Qeetrix-drawn navigation. |
| `AlertDialog` | `QeetrixAlertDialog` (`.alert`) | The same job and name. The system draws it; only the tint is Qeetrix's. |
| `Alert` (inline status) | — | Not this phase. The name `QeetrixAlert` is kept for it. |
| — | `QeetrixConfirmationDialog` (`.confirmationDialog`) | iOS only: the action sheet, where the web uses an `AlertDialog` or a `DropdownMenu`. |
| `Dialog`, `Drawer` | `qeetrixSheet` and `QeetrixSheetContent` | A bottom sheet (the web `Drawer`) on iPhone, a form sheet (the web `Dialog`) on iPad, on `component.dialog` tokens. |
| `Sheet` (side panel) | — | No iPhone equivalent; on iPad a sheet or a split view. |
| `Popover` | `qeetrixPopover` | On `component.popover` tokens. In compact width it adapts to a sheet unless `.popover` is asked for. |
| `DropdownMenu`, `ContextMenu` | `QeetrixMenu`, `QeetrixMenuItem`, `contextMenu` | A Qeetrix trigger and the system menu; `component.menu` tokens don't apply. |
| `Toast`, `Toaster`, `toast()` | `QeetrixToast`, `qeetrixToast(_:)` | The same types, icons, accent and timing (5 s; 10 s for warnings, errors and actions). One visible instead of a stack. A host per view instead of a global function. |
| — (no snackbar) | — | Deferred: a toast with an action covers it. |

The rules both platforms keep:

- **Dialog roles.** A destructive action is marked destructive. A cancel is always available.
- **Exactly once.** Choosing an action closes the overlay and runs the action once.
- **Toast announcements.** Errors are announced at high priority, other toasts politely.
- **Toast timing.** Hover and focus hold a toast on screen.
- **Strings.** "Close" is the close button's name (`overlayMessages.close`, `toastMessages.close`).

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

- `Tests/QeetrixTests/Tokens` compares the generated Swift with the snapshot: every consumable colour
  and typography role, and representative scales.
- `Tests/QeetrixTests/Foundations/Accessibility` re-runs qeetrix-ui's WCAG AA pairs on the converted
  iOS colours.
- `Resources/Metadata/token-provenance.json`, read with `QeetrixProvenance.bundled()`, names the exact
  upstream versions, so a web and an iOS build can be checked for the same release.
- Phase 6 added checks of the contract in the running app: Apple's accessibility audit over every
  showcase page (`AccessibilityAuditUITests`), the timeline dots' 3:1 contrast on every surface
  (`TimelineContrastTests`), and the timeline drawn right to left (`TimelineTests`). Results are in
  `Documentation/Quality/`.
