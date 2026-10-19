# 0006 — Theming goes through the SwiftUI environment

**Status:** Accepted, 2026-10-18

## Context

The web has three theme modes (`light`, `dark`, `system`), set on `<html>`, plus nested `.dark` scopes.
Qeet Group uses one brand colour across all products. Users personalise comfort settings — theme, text
size, motion — not branding.

## Decision

- **Colours.** `QeetrixColor` is a `ShapeStyle` that resolves its light or dark value from
  `environment.colorScheme` (the iOS 17 `resolve(in:)`).
- **App-wide mode.** `.qeetrixThemeMode(_:)` sets the window's colour scheme. `QeetrixThemeMode` uses
  the web's raw values, so a stored preference reads the same on both platforms.
- **Subtree override.** `.qeetrixTheme(_:)` fixes one part of a screen in a theme.
- **No global state.** There is no theme singleton and no public way to build a palette.
- **Increased contrast.** It is read from the environment and resolves to standard values until
  upstream defines a contrast theme.

## Consequences

- Live appearance changes, nested overrides and previews work with no extra plumbing.
- Products cannot be re-skinned in code. A new theme has to come from upstream, and the generator
  fails until it is mapped (`TokenSource.themeSelectors`).
