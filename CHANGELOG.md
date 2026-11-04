# 📝 Changelog

All notable changes to Qeetrix for iOS. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and versions follow [Semantic Versioning](https://semver.org/) as [docs/releases.md](docs/releases.md) describes.
Ticket numbers are QTRX issues.

## [Unreleased]

Nothing yet.

## [0.1.0] — Unreleased

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
  platforms (QTRX-91); **icons** come from `@qeetrix/icons`' SVG files.
- **Every component** is re-specified to its `@qeetrix/react` counterpart: variants, tones and sizes by the web's
  names, metrics and states from its CSS.
- **From `@qeetrix/react` 0.4.0:** an invalid checkbox, radio or switch keeps its danger edge when checked
  (QTRX-161); the switch's on thumb is white in dark too (QTRX-162); read-only fields draw the editable line
  (QTRX-175); the dark progress track keeps 3:1 (QTRX-176).
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
