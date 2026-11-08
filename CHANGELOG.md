# 📝 Changelog

All notable changes to Qeetrix for iOS. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and versions follow [Semantic Versioning](https://semver.org/) as [docs/releases.md](docs/releases.md) describes.

## [Unreleased]

`VERSION` is `0.2.0`: these are additions, and one is source-breaking, which before 1.0 takes a minor release
([docs/releases.md](docs/releases.md)).

### ⚠️ Breaking

- **`QeetrixEmptyStateTone` has two more cases**, `success` and `warning`. A `switch` over the tone without a
  `default` no longer compiles: add the two cases, or a `default`.

### Added

- **20 icons** for the native Qeet ID app, so iOS carries the same 88 names as Qeetrix for Android:
  `arrowBigUp`, `arrowLeft`, `arrowRight`, `circleQuestionMark`, `ellipsisVertical`, `externalLink`,
  `fingerprintPattern`, `hourglass`, `key`, `link`, `lockOpen`, `mail`, `rectangleEllipsis`, `scanFace`,
  `scanQrCode`, `searchX`, `shieldCheck`, `shieldX`, `timer` and `users`, from `@qeetrix/icons` 2.1.0.
- **`QeetrixIcon(_:…, mirrorsInRightToLeft:)`**: a physical arrow or link mark mirrors where its use gives it a
  direction ("next", "open"), as on Android; by default an icon mirrors only when its name means a direction.
- Decision 0019: components take catalogue icons only; an app asks for a pin.
- **A number match on `QeetrixOTPInput`**: `.qeetrixOTPSlotWidth(.square)` keeps each slot as wide as it is
  tall at the leading edge, the label and error at the container's width (the name qeetrix-android uses);
  `.qeetrixOTPAutoFill(false)` drops one-time-code AutoFill, so iOS offers no SMS or authenticator code over the number
  pad and a pasted code isn't cut to its first digits; `.qeetrixOTPFocus(_:)` binds focus both ways, so a screen can
  open with the number pad up; and `init(code:accessibilityLabel:…)` names an input whose label the screen draws.
  The showcase has a Number match page.
- **List rows for an authenticator**: `QeetrixListItemIcon(monogram:)`, the tile with one or two characters
  (an issuer's letter, a step's number) in `label.md` at weight 600, growing with Dynamic Type and hidden from
  VoiceOver; `.qeetrixListItemContent { … }`, a view `space.gap.xs` under a row's description, such as a
  `QeetrixOTPCode`; and `.qeetrixListRow()`, the row's list look (its insets, `color.surface.raised`, a
  `color.border.subtle` separator) for a row the app draws itself.
- **`QeetrixOTPCode(_:…, actionHint:action:)`**: a tap runs the app's action with the code instead of
  copying it — no clipboard, toast or haptic — as an AutoFill credential provider's picker fills a code. It looks
  the same (a snapshot test checks it against the copying code's baselines), a hidden code still shows on the first
  tap, and VoiceOver's hint is the app's. The showcase's OTP code page has a "Fills instead of copying" demo.
- **`QeetrixCopy.copy(_:isSensitive:toast:locale:)`**: Qeetrix's copy from any trigger — a context menu's
  "Copy code", a swipe action, a keyboard shortcut — with the copy controls' rules: a secret local only and removed
  after 60 seconds, the light haptic (the error haptic if the clipboard refuses it), and the "Copied" toast with its
  expiry line on the given binding, or "Copied" announced without one. The showcase's accounts have a Copy code menu.
- **`qeetrixBottomActionBar(primary:tertiary:)`**: an `lg` ghost action under the solid primary — "Continue"
  over "Not now" — or on its own with no primary, for a quiet "Done". On a phone both span the bar; at regular width
  they share the wider one's width, at the end; VoiceOver reads the primary first. `qeetrixBottomActionBar(primary:secondary:)`
  is unchanged. The showcase's bottom action bar page has switches for both.
- **Text fields in `QeetrixAlertDialog`**: `QeetrixAlertDialog(_:message:textFields:actions:)` with up to two
  `QeetrixAlertTextField`s — a label (the placeholder and VoiceOver's name), the app's text binding, a
  `QeetrixTextContentType` for the keyboard and AutoFill, `isSecure` and `isRequired`. The confirming action (the last
  that doesn't cancel) is unavailable while a required field is empty or only spaces, and Return in the last field runs
  it. The one-value state and the added Cancel beside a lone destructive action are unchanged. The showcase's alert
  dialog page has a Rename account demo.
- **Outcome and lock screens on `QeetrixEmptyState`**: the `success` (`color.icon.success`) and `warning`
  (`color.icon.warning`) tones, native only as on Android; `QeetrixEmptyState(title:description:image:…)`, the app's
  image in place of the icon — its icon on a Locked screen — decorative and kept from VoiceOver; and
  `centredInHeight()`, the column in the middle of the height it is offered. The showcase's empty state page shows both.
- **`QeetrixCard.flushRows()`**: a card of list rows — no body padding or gap, the rows' tints and focus
  frames meeting the card's edges and clipped to its corners, a `color.border.subtle` rule between rows only. The
  default padded body is unchanged. The showcase's card page has a Settings card of rows.
- **A summary under an accordion section's title**: `QeetrixAccordionItem(_:description:isExpanded:…)` and
  `(_:description:value:…)`, in `body.sm`, `color.text.subtle`, read after the title and before "Expanded" or
  "Collapsed"; the chevron stays on the title's first line, as on Android. The showcase's accordion page shows one.
- **Permission primer**: Continue carries `arrow-right` and Open Settings `external-link` in their icon zones,
  mirrored right to left; Not now is short and centred; and `footnote(_:)` adds a short reassurance under the actions
  in `body.sm`, `color.text.subtle` — "Only sign-in requests. Nothing else, no marketing."

### Changed

- **A full-width button centres its label** on the whole button — `isFullWidth`, and the stacked actions of
  `QeetrixFormActions` and `qeetrixBottomActionBar` on a phone — with or without an icon, as the design rules now say
  on every platform. An icon keeps its zone at the end. Where a label is too long to centre, the leading side gives
  way first, so a button's ideal width is unchanged and the layouts that choose with `ViewThatFits` choose as before.

## [0.1.0] — 2026-11-04

The first version. Built from `@qeetrix/react` 0.4.0, `@qeetrix/tokens` 0.0.13 and `@qeetrix/icons` 2.1.0.

### ✨ Added

**Foundations**

- `QeetrixColor`: 109 colour roles, a `ShapeStyle` that resolves light or dark from the environment.
- `QeetrixThemeMode` (`light`, `dark`, `system`) and `.qeetrixThemeMode(_:)`, with the web's stored values.
- `QeetrixTextRole`: 18 text roles in Qeet Sans and Fira Code, following Dynamic Type and Bold Text.
- `QeetrixSpace`, `QeetrixRadius`, `QeetrixBorderWidth`, `QeetrixSize`, `QeetrixDensity`, `QeetrixShadow` and motion
  (`QeetrixDuration`, `QeetrixEasing`, `QeetrixSpring`), honouring Reduce Motion.
- `QeetrixFormat`: numbers, money, percentages, sizes, durations, dates, times and relative time.
- Haptics by role: `QeetrixFeedback`.
- 68 icons from `@qeetrix/icons`: `QeetrixIcon`, `QeetrixIconName`.

**Components** (71, each with a DocC page and a showcase page)

| Group | Components |
|:--|:--|
| 👆 Actions | `QeetrixButton`, `QeetrixIconButton`, `QeetrixCopyButton`, `QeetrixSegmentedControl`, the bottom action bar |
| ✍️ Forms | `QeetrixTextField`, `QeetrixTextarea`, `QeetrixPasswordInput`, `QeetrixNumberField`, `QeetrixSearchField`, `QeetrixSelect`, `QeetrixCombobox`, `QeetrixCheckbox`, `QeetrixRadioGroup`, `QeetrixSwitch`, `QeetrixSlider`, `QeetrixOTPInput`, `QeetrixDatePicker`, `QeetrixDateRangePicker`, `QeetrixTimePicker`, `QeetrixFileUpload`, `QeetrixField`, `QeetrixFieldset`, `QeetrixErrorSummary`, `QeetrixFormActions` |
| 📊 Data display | `QeetrixText`, `QeetrixHeading`, `QeetrixAvatar`, `QeetrixAvatarGroup`, `QeetrixBadge`, `QeetrixChip`, `QeetrixListItem`, `QeetrixSectionHeader`, `QeetrixDescriptionList`, `QeetrixTimeline`, `QeetrixStat`, `QeetrixCheckList`, `QeetrixRelativeTime`, `QeetrixQRCode`, `QeetrixOTPCode`, `QeetrixCopyField`, swipe actions, pull to refresh |
| 💬 Feedback | `QeetrixAlert`, `QeetrixProgress`, `QeetrixCircularProgress`, `QeetrixSpinner`, `QeetrixSkeleton`, `QeetrixToast`, `QeetrixEmptyState`, `QeetrixDataState` |
| 🪟 Overlays | `QeetrixAlertDialog`, `QeetrixConfirmationDialog`, sheets, popovers, `QeetrixMenu`, `QeetrixFullScreenForm` |
| 🧭 Navigation | `QeetrixTabs`, navigation and tab bar styles, the large title, `QeetrixSidebar`, `QeetrixNavigationScaffold`, `QeetrixSteps`, `QeetrixPageIndicator` |
| 📐 Layout | `QeetrixCard`, `QeetrixAccordion`, `QeetrixSeparator` |
| 🧰 Utilities | `QeetrixQRScanner`, `QeetrixPermissionPrimer` |

**Project**

- The MIT licence (`LICENSE`), as the web's `@qeetrix/*` packages and qeetrix-android have.
- The showcase app (`Showcase`), with a page for every foundation and component.
- The Qeetrix release flow: merging to `main` tags the version in `VERSION` after an approver approves, and opens a
  GitHub Release with the bill of materials.
- CI on the Xcode 27 runners, CodeQL code scanning, and monthly Dependabot updates.

### ⚠️ Breaking, since `0.1.0-rc.1`

- **Every public API changed** when the package moved from `@qeetrix/ui` to `@qeetrix/react`, `@qeetrix/tokens` and
  `@qeetrix/icons` (decision 0018). Nothing had been released, so there is no deprecation path.

### 🔄 Changed

- **Tokens** are generated from `@qeetrix/tokens`' DTCG build; **fonts** are the TrueType files it publishes for native
  platforms; **icons** come from `@qeetrix/icons`' SVG files.
- **Every component** is re-specified to its `@qeetrix/react` counterpart: variants, tones and sizes by the web's
  names, metrics and states from its CSS.
- **From `@qeetrix/react` 0.4.0:** an invalid checkbox, radio or switch keeps its danger edge when checked;
  the switch's on thumb is white in dark too; read-only fields draw the editable line; the dark progress track keeps 3:1.
- **The sources** keep one folder per component family, `Sources/Qeetrix/Components/<Family>/`.

### 🐛 Fixed

- A popover stays a popover in compact height, so it can be dismissed on an iPhone in landscape.
- A `QeetrixButton` with an icon no longer stretches to fill a stack's spare height.
- An avatar is read by VoiceOver as one image named by its name; the password input has a 44 pt target again.
- A select inside `ImageRenderer` no longer stops the process.

## 🧪 Release candidates

| Candidate | Built | Result |
|:--|:--|:--|
| `0.1.0-rc.1` | 20 October 2026, on `@qeetrix/ui` | Every gate passed. Superseded by the migration; never released. |

The phase-by-phase notes from before 4 November 2026 are in the git history (`git log -p -- CHANGELOG.md`).

[Unreleased]: https://github.com/qeetgroup/qeetrix-ios/compare/0.1.0...HEAD
[0.1.0]: https://github.com/qeetgroup/qeetrix-ios/releases/tag/0.1.0
