# 0003 — Colours are converted per CSS Color 4

**Status:** Accepted, 2026-10-18

## Context

Qeetrix colours are authored in OKLCH and mixed with `color-mix(in oklab, …)`. iPhones have Display P3
screens. A few Qeetrix colours, from the data palette and rating, lie outside sRGB, and Safari draws
those in P3.

## Decision

- **Conversion.** The CSS Color 4 reference matrices (OKLCH → OKLab → XYZ → RGB), and CSS Color 5
  premultiplied mixing for `color-mix`.
- **Output space:**
  - sRGB when the colour fits, so it matches the web's hex exactly;
  - Display P3 when it fits P3 but not sRGB;
  - the CSS Color 4 gamut-mapping algorithm when it fits neither.
- **Rounding.** Six decimals, so the generated source is byte-stable.

## Consequences

- The agreed brand values (#F26D0E, #D04800, #B73D10) are reproduced exactly and tested.
- Nine colour values (seven tokens) are drawn in Display P3. None needed gamut mapping in 2.1.6.
  `TOKEN_COVERAGE.md` lists them.
- Upstream's WCAG AA pairs are re-measured on the converted values in both themes (`ContrastTests`).
