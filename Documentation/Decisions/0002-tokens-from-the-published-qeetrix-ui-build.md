# 0002 — Tokens come from the published `@qeetrix/ui` build

**Status:** Superseded by ADR 0018 (2026-10-30). Accepted, 2026-10-18.

## Context

qeetrix-ui authors its tokens as DTCG JSON and compiles them with Style Dictionary. Its published
package ships the compiled outputs: `tokens.json` (values per theme), `tokens.css` (the runtime
variables) and `index.css`.

Two copies of the token vocabulary would drift apart. And reading the DTCG source would mean
re-implementing the web's compiler, which would then disagree with it in small ways.

## Decision

- **Input.** iOS reads the compiled outputs of a pinned, published `@qeetrix/ui` version. The sync
  checks the tarball against the npm registry's integrity hash.
- **Stored inputs.** Only the files generation needs are kept in `Upstream/`: three token artifacts,
  the font files, the pinned icon SVGs and their manifest entries. Each is locked by sha256 in
  `upstream.lock.json`. The rest of qeetrix-ui is not copied.
- **Scope.** What is generated follows the web's own runtime boundary:
  - the consumable `--qx-*` layer: semantic tokens and, from Phase 2, component tokens;
  - plus the non-colour scales qeetrix-ui itself exposes to code: spacing, icon size and stroke,
    stroke width, font weight and font geometry.
  - Palette primitives are never generated.
- **Component tokens** are generated only for components that have them in qeetrix-ui (41 groups
  covering 40 of 97 families in 2.1.6), or after a reviewed change adds them there. Every other
  component uses semantic tokens. iOS never defines its own design values, and never duplicates a
  semantic value as a component token.
- **Every token decided.** Each upstream token is either generated or excluded with a written reason
  (`Tools/QeetrixGen/Sources/QeetrixGenCore/Tokens/Scope.swift`). An unknown consumable group fails
  generation.

## Consequences

- A token change happens upstream, is released, and arrives here through a pin bump, a sync and a
  regeneration (`CONTRIBUTING.md`). There is nothing to edit by hand.
- iOS can trail the web by a release, but never contradicts a released version.
  `QeetrixProvenance.bundled()` names the version in use.
- The generator must understand the CSS the web emits, such as `var()`, `calc()` and `color-mix()`.
  New syntax fails loudly instead of producing a guess.
