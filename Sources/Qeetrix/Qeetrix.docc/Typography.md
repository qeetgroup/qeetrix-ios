# Typography

Set text in the Qeetrix roles, in Qeet Sans with each role's letter style, scaling with Dynamic Type.

## Overview

Qeetrix text uses the 18 typography roles of `@qeetrix/tokens`. Each fixes a family, size, weight and
line height; `@qeetrix/react` gives each group of roles its letter style on Qeet Sans's `GEOM` axis
(design rules §5):

| Role | Size | Weight | Letter style | Scales like |
|:--|--:|--:|:--|:--|
| ``QeetrixTextRole/displayLg`` · `displayMd` · `displaySm` | 56 · 48 · 40 | 600 | Geo (``QeetrixFontGeometry/display``, 100) | `.largeTitle` |
| ``QeetrixTextRole/headingLg`` · `headingMd` · `headingSm` | 32 · 28 · 24 | 600 | Base (``QeetrixFontGeometry/heading``, 50) | `.largeTitle` · `.title` · `.title2` |
| ``QeetrixTextRole/titleLg`` · `titleMd` · `titleSm` | 20 · 18 · 16 | 600 | Base | `.title3` · `.headline` · `.headline` |
| ``QeetrixTextRole/bodyLg`` · `bodyMd` · `bodySm` | 16 · 14 · 12 | 400 | A11y (``QeetrixFontGeometry/body``, 0) | `.body` · `.body` · `.footnote` |
| ``QeetrixTextRole/labelLg`` · `labelMd` · `labelSm` | 16 · 14 · 12 | 500 | A11y | `.callout` · `.subheadline` · `.footnote` |
| ``QeetrixTextRole/labelCaps`` | 11 | 600 | A11y | `.caption2` |
| ``QeetrixTextRole/codeMd`` · `codeSm` | 14 · 12 | 400 | — (Fira Code) | `.body` · `.footnote` |

Sizes are at the default text size. Use display roles only to headline welcoming pages — sign-in,
checkout, onboarding (design rules §17). `labelCaps` is the one tracked role (+6%), for group labels
set in capitals; the capitals are your text's, not the role's. Apply a role with
`.qeetrixTextStyle(_:)`, or use ``QeetrixHeading`` and ``QeetrixText``, which choose the role from a
size:

```swift
Text("Sign in to Qeet").qeetrixTextStyle(.displaySm)
Text("We sent a code to your phone.").qeetrixTextStyle(.bodyMd)
```

## Dynamic Type and Bold Text

A role scales with the user's text size along the curve of the system style in the table, up to the
accessibility sizes; the mapping pairs each role with the system style of the nearest purpose and size.
Let text wrap rather than truncate.

With Bold Text on, a role is drawn one step heavier (``QeetrixFontWeight/bolder(in:)``): regular
becomes medium, medium becomes semibold, and semibold — the top of the token scale — becomes 700, the
heaviest weight the fonts draw.

## The typeface

``QeetrixFontFamily/sans`` is Qeet Sans — the Cal Sans variable font — and ``QeetrixFontFamily/mono``
is Fira Code: the TrueType files `@qeetrix/tokens` ships for native platforms, decompressed from the
package's full WOFF2 files — the web loads per-script subsets of them — every glyph and axis kept.

A role sets the font's variation axes the way the web's CSS does:

- `wght` from the role's weight;
- `GEOM`, the letter style, from the role's group (Fira Code has no `GEOM` axis);
- `opsz`, the optical size, from the scaled point size — the web's `font-optical-sizing: auto` — so
  larger text gets the tighter display drawing;
- `ital` 0; the other axes keep the font's defaults.

Fonts register automatically on first use. ``QeetrixFontRegistry/register()`` does it eagerly and
reports each family. If a font cannot load, text falls back to the system font at the same weight and
the failure is logged. Characters the fonts don't include, such as the Indic scripts, fall back
through the system's font cascade, as browsers do without the Noto Sans faces the web's stack names.

To use a role's font outside SwiftUI text, ``QeetrixTextMetrics`` resolves it at any size.
