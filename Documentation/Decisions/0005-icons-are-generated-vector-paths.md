# 0005 — Icons are generated vector paths

**Status:** Accepted, 2026-10-18

## Context

qeetrix-icons draws on a 24-unit grid, in round and sharp shapes, outline and filled, in
`currentColor`, with Lucide names. The web lets a stroke-width token change how thick outlines are
drawn. An asset catalogue bakes the stroke in at build time and needs Xcode's asset compiler.

## Decision

- **Conversion.** At generation time, the pinned SVGs become Swift path data. Arcs and smooth curves
  are expanded to cubics.
- **Accepted SVG.** A strict subset only. Transforms, groups, gradients, hard-coded colours and
  per-element stroke widths fail generation.
- **Rendering.** `QeetrixIcon` draws in a `Canvas`. The stroke token scales with the icon, and the
  colour is the inherited foreground style.
- **Metadata.** Names and right-to-left mirroring come from the pinned manifest entries.

## Consequences

- Vectors stay exact at every size, the stroke token works at run time, and icons can be tested on
  any host.
- Phase 1 carries 12 icons. Adding one means listing it in `Upstream/pins.json`, then syncing and
  generating.
- Logos, which are multi-colour, are out of this pipeline until a decision covers them.
