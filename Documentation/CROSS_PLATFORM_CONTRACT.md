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

## Deliberate differences

Differences are platform requirements, never restyling:

- **Dynamic Type.** Token sizes are the default-size values and scale with the user's text size. The
  web scales with browser zoom instead.
- **Bold Text.** It raises a role one weight step. The web has no equivalent setting.
- **Touch targets.** Interactive hit areas are at least 44 pt, even where the drawn control uses a
  smaller density height.
- **Line height.** It is applied as SwiftUI `lineSpacing`, which cannot go below the font's natural
  height and adds no half-leading above the first line.
- **Not mapped.** z-index tokens (SwiftUI orders siblings only) and gradients (not a Phase 1
  foundation). See [TOKEN_COVERAGE.md](Foundations/TOKEN_COVERAGE.md).

## Checking parity

- `Tests/QeetrixTests/Tokens` compares the generated Swift with the snapshot: every consumable colour
  and typography role, and representative scales.
- `Tests/QeetrixTests/Foundations/Accessibility` re-runs qeetrix-ui's WCAG AA pairs on the converted
  iOS colours.
- `Resources/Metadata/token-provenance.json`, read with `QeetrixProvenance.bundled()`, names the exact
  upstream versions, so a web and an iOS build can be checked for the same release.
