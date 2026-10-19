# 0011 — Component tokens, and web metrics that are not tokens

**Status:** Accepted (Phase 2, 2026-10-18). Refines ADR 0002.

## Context

Components need two kinds of values qeetrix-ui does not publish as foundation tokens:

1. **Component tokens** (`component.<group>.*`): 41 groups covering 40 of 97 families. Phase 1 excluded
   all of them.
2. **Tailwind utility values** the web components use directly: heights (`h-7`), padding (`px-2.5`),
   gaps (`gap-1.5`), type steps (`text-sm`, `text-xs`, `leading-snug`) and `animate-spin`. These come
   from Tailwind's default theme, not from Qeetrix tokens, so they are not in `tokens.json`.

## Decision

- **Component tokens are adopted per group.** `Upstream/pins.json` lists the adopted groups
  (`qeetrixUI.componentTokens`); the generator emits one internal `Qeetrix<Group>Tokens` enum per
  group and excludes the rest with a reason in `TOKEN_COVERAGE.md`. Naming a group upstream does not
  define fails the run. Phase 2 adopts avatar, badge, button, card, input, progress, switch and
  typography.
- **References stay references.** A component colour that names a semantic colour in both themes is
  generated as that `QeetrixColor`, so it follows the theme and any future contrast theme. One that is
  a different value per theme (a `color-mix`, `transparent`) is generated as a value per theme. A size
  that resolves through the density (`component.input.height`) is generated as a function of
  `QeetrixDensity`. A non-colour value that differs by theme fails generation, because no component
  needs one yet and silently picking a theme would be wrong.
- **Component tokens are internal.** They are implementation details of the components; the public
  surface stays the semantic tokens.
- **Tailwind values are restated once, with their source.** `QeetrixWebScale` (internal) holds the
  Tailwind 4.3.3 defaults the components use, citing `theme.css` from the version in qeetrix-ui's
  `bun.lock` at the pinned commit. Component code writes the web class beside each use
  (`QeetrixWebScale.spacing(2.5)  // px-2.5`), so a reviewer can compare it with the web source line by
  line. The shadcn bridge colours the web components use (`bg-secondary`, `text-muted-foreground`) are
  mapped to the semantic tokens qeetrix-ui's own `bridge.json` maps them to.

## Upstream discrepancy

The web components' geometry is part of the design but not of the token contract: a change to
Tailwind's defaults, or to a component's utility classes, changes the web without changing
`tokens.json`, and the generator cannot see it. The drift check covers tokens only. Until qeetrix-ui
publishes component geometry as tokens, component metrics are reviewed against the web source when the
`@qeetrix/ui` pin moves.

## Consequences

- Adopting a group is a one-line pins change and a regeneration; `new-component` does it when the
  group exists.
- `QeetrixWebScale` is the one place a Tailwind value enters the package.
