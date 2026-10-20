# Localization and right-to-left report

Phase 6, 2026-10-19, on the iOS 27.1 iPhone simulator and the Mac host.

## Summary

| Area | Status |
|:--|:--|
| Strings the app passes | Localised by the app: `LocalizedStringKey` and `String.LocalizationValue` initialisers resolve in the app's bundle; `verbatim` initialisers show text as given |
| The library's own strings | 19 strings, **English only** — finding LOC-1 |
| Right-to-left layout | Mirrors; codes and numbers keep reading left to right. The timeline's connector didn't — finding LOC-3, fixed |
| Longer translations | Layouts wrap; nothing clipped with every library string doubled |
| Scripts other than Latin | Qeet Sans covers Latin; other scripts fall back through CoreText |
| Numbers | The number field and the one-time code accept Arabic-Indic and Devanagari digits |
| Dates, plurals, currencies | The library formats none; the app passes text |

## The library's strings

`Sources/Qeetrix/Resources/Localization/en.lproj/Localizable.strings` holds 19 strings, read through
`QeetrixStrings` with `bundle: .module`: "Loading", "Required", "(optional)", "Error", "Warning",
"Success", "Show password", "Hide password", "One-time code", "Decrease", "Increase", "There is a
problem", "Close", "Cancel", "Remove", "Try again", "Expanded", "Collapsed" and the data state's
failure message. Most are what VoiceOver says for a control.

No other user-visible text is written into the library. Searched with
`find Sources/Qeetrix -name '*.swift' -exec grep -nE 'Text\("[^"]|accessibilityLabel\("|Label\("[^"]|Button\("[^"]' {} +`:
the only matches are `QeetrixStrings` itself.

**LOC-1 (P2, open).** The package has only an English table, so an app localised into Hindi, Arabic or
any other language still gets these 19 strings in English — spoken by VoiceOver, and shown for
"Required", "(optional)", "Close", "Cancel", "Try again" and the failure message. Translations need a
source of truth. None of the upstream inputs Qeetrix pins (tokens, fonts, icons, the component
manifest) carries translations, and Phase 6 does not invent them. Phase 7 must choose: ship reviewed translations for the
languages Qeet products support, or let an app supply its own table. It is recorded in
`RELEASE_READINESS_GAPS.md`.

**LOC-2 (P3, accepted).** Two accessibility labels join parts with a Latin comma: a required field's
"Email, Required" and an avatar's "Asha Rao, Online". VoiceOver pauses at a comma in every language, and
both parts are localised, so it is kept.

## Right-to-left

Checked by launching the showcase with `-AppleLanguages (ar) -AppleLocale ar_SA -AppleTextDirection YES
-NSForceRightToLeftWritingDirection YES` on twelve pages — list item, number field, one-time code,
password, data state, accordion, chip, toast, tabs, timeline, text field and sheet — running the text
clipping and hit-region audits on each and reading the screenshots.

- Layout mirrors: in the screenshots, list rows with their chevrons and separators, tabs and chips run
  from the right. The switch thumb, the progress sweep, the avatar badge and directional icons
  (`directionality: mirror` upstream) are covered by the right-to-left snapshot specimens.
- **LOC-3 (P2, fixed).** The timeline's markers moved to the right edge, but the line joining them
  stayed at the left, running through the times. The connector was placed at the marker's x with
  `position`, and in right-to-left layout an anchor's x and `position` don't agree. It is now placed
  from the leading edge, where the markers are, so it mirrors with them. Regression test:
  `TimelineTests` "Right to left, the connector follows the markers to the right edge", a rendered-pixel
  check that failed before the fix and passes after. The right-to-left snapshot specimen didn't show
  the defect and still matches after the fix: the snapshot host's right-to-left drawing, set through
  its trait collection, didn't reproduce it. The defect showed in the running app and in `ImageRenderer`, so
  the pixel test uses the renderer, and the fix was checked again in the app.
  The library's other uses of `position` and `offset` were checked: the dividers between stacked items
  are centred across the full width, the avatar badge sets `flipsForRightToLeftLayoutDirection`, and
  elevation offsets follow CSS, which doesn't mirror shadows.
- One-time-code cells and the number field keep left-to-right order, as numbers do in Arabic.
- The number field shows Western digits under `ar_SA` here because the showcase has no Arabic
  localisation, which is the system's behaviour, not the field's. Unit tests check that it reads
  Arabic-Indic digits and the Arabic decimal separator and minus (`NumberFieldTests`), and that the
  one-time code turns Arabic-Indic and Devanagari digits into 0–9 (`OTPInputTests`).
- The audits found nothing beyond the text field's "may be clipped at larger sizes" prediction, which
  they also report in left-to-right (see the accessibility report).
- Every component has a right-to-left snapshot specimen, compared locally (ADR 0013).

## Longer translations

`-NSDoubleLocalizedStrings YES` doubles every string read from a bundle's table — the library's, here,
as the showcase has none. On the same twelve pages the doubled strings ("Required Required", "Try again
Try again") wrapped or widened their row; nothing was clipped or overlapped, and the audits found
nothing new. App strings were not doubled, so a long app label is covered by the layout rules instead:
labels wrap, tabs never truncate, rows move trailing content below the text at accessibility sizes.

## Scripts

`Tests/QeetrixTests/Localization/ScriptFallbackTests.swift` checks that Qeet Sans covers Latin and does
not cover Devanagari, Tamil, Arabic or Bengali, and that CoreText finds a font covering each through
`CTFontCreateForString` — the fallback a `Text` in those scripts gets. It passes on the Mac host.

Not verified: how fallback glyphs sit against Qeet Sans in a mixed line (baseline, weight, line height).
That needs a person to look at real translated screens.

## Not verified

- A fully translated app: no Qeet product ships iOS translations yet.
- Right-to-left with VoiceOver on a device.
- Mixed-script lines, as above.
