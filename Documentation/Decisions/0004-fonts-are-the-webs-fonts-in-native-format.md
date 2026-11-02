# 0004 — Fonts are the web's fonts, in native format

**Status:** Accepted, 2026-10-18. Amended by ADR 0015: the TTFs now come from `@qeetrix/tokens`.

## Context

`@qeetrix/ui` 2.1.6 ships two variable fonts as WOFF2, a web container:

- "Qeet Sans", which is Cal Sans v2.011;
- Fira Code 6.2.

Both are SIL OFL 1.1 with no Reserved Font Name.

A variable font's PostScript-name lookup in CoreText returned a synthesised instance during
development, rather than the bundled file.

## Decision

- **Files.** Bundle each font's TTF from the same upstream release (calcom/sans `v2.011`, Fira Code
  `6.2`), unmodified. Accept it only if that release's WOFF2 is byte-identical to the one in the
  pinned `@qeetrix/ui`.
- **Licences.** Bundle each project's licence file verbatim, beside its font.
- **Loading.** Build fonts from the descriptor CoreText reads out of the bundled file, never by name.
- **Axes.** Set them as the web does: `wght` from the weight, `GEOM` from the role's letter style,
  `opsz` from the point size, `ital` 0.

## Consequences

- iOS text uses the exact outlines, kerning and letter styles the web uses.
- A registration failure is logged and reported by `QeetrixFontRegistry.register()`. Text falls back to
  the system font at the same weight, never silently.
- A font upgrade starts upstream: qeetrix-ui ships it, the pin moves, and the sync proves the match
  again.
