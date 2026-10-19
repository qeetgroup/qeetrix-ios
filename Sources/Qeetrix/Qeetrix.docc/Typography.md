# Typography

Set text in the Qeetrix roles, in the Qeet Sans typeface, scaling with Dynamic Type.

## Overview

Qeetrix text uses nine roles, the same as the web. Each role fixes a family, size, weight, line height,
letter spacing and letter style:

| Role | Size | Weight | Scales like |
|:--|:--|:--|:--|
| ``QeetrixTextRole/display`` | 48 | semibold | `.largeTitle` |
| ``QeetrixTextRole/title`` | 32 | semibold | `.title` |
| ``QeetrixTextRole/heading`` | 20 | semibold | `.title3` |
| ``QeetrixTextRole/body`` | 14 | regular | `.body` |
| ``QeetrixTextRole/label`` | 13 | medium | `.subheadline` |
| ``QeetrixTextRole/labelCompact`` | 12.8 | medium | `.footnote` |
| ``QeetrixTextRole/caption`` | 12 | regular | `.caption` |
| ``QeetrixTextRole/micro`` | 11 | medium | `.caption2` |
| ``QeetrixTextRole/code`` | 13 | regular | `.body` |

Sizes are at the default text size. Apply a role with `.qeetrixTextStyle(_:)`:

```swift
Text("Two-step sign-in").qeetrixTextStyle(.heading)
Text("We sent a code to your phone.").qeetrixTextStyle(.body)
```

## Dynamic Type and Bold Text

A role scales with the user's text size along the curve of the system style in the table, up to the
accessibility sizes. Let text wrap rather than truncate.

With Bold Text on, a role is drawn one step heavier on the weight scale (``QeetrixFontWeight/scale``),
for example regular becomes medium.

## The typeface

``QeetrixFontFamily/sans`` is Qeet Sans, the Cal Sans variable font the web ships, bundled as the
identical font in TrueType form. ``QeetrixFontFamily/mono`` is Fira Code, used by the `code` role.

A role sets the font's variation axes the way the web does:

- weight, from the role;
- letter style (`GEOM`): ``QeetrixFontGeometry/base`` for headings, ``QeetrixFontGeometry/ui`` for
  body and interface text;
- optical size, from the scaled point size: larger text gets the tighter display drawing.

Fonts register automatically on first use. ``QeetrixFontRegistry/register()`` does it eagerly and
reports each family. If a font cannot load, text falls back to the system font at the same weight and
the failure is logged. Characters the fonts don't include, such as Indic scripts, fall back to the
system's fonts.

To use a role's font outside SwiftUI text, ``QeetrixTextMetrics`` resolves it at any size.
