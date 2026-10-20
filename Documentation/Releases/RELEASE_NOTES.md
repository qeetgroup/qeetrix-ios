# Qeetrix for iOS 0.1.0-rc.1 — release notes (draft)

**Status: release candidate, not released.** No tag exists. This is the first candidate for 0.1.0, the
first version of Qeetrix for iOS. It is for evaluation by Qeet Group app teams, pinned exactly, until the
owner approves a release.

## Overview

The Qeet Group design system in native SwiftUI, generated from the same sources as the web:
`@qeetrix/ui` 2.1.6 for tokens and `qeetrix-icons` 1.0.11 for icons. It contains the foundations, the
core components, forms, navigation and overlays, data display and content states, hardened in Phase 6
for accessibility, localisation, performance and API stability.

- **Platforms:** iOS and iPadOS 17 or later. Tested on the iOS 27.1 simulator (iPhone). iOS 17, iPad and
  devices are not yet tested (`COMPATIBILITY_MATRIX.md`).
- **Toolchain:** Xcode 27.1, Swift 6.
- **Install:** `.package(url: "https://github.com/qeetgroup/qeetrix-ios.git", exact: "0.1.0-rc.1")`
  once tagged (`DISTRIBUTION.md`).
- **Dependencies:** none.

## What's in it

**Foundations.** 84 semantic colours, light, dark and system themes, nine typography roles in Qeet
Sans and Fira Code with Dynamic Type and Bold Text, and the token scales for spacing, size, corners,
strokes, focus, density, elevation and motion. 37 icons in round and sharp, outline and filled drawings,
mirrored where they have a direction. Accessibility helpers for touch targets and Reduce Motion.

**Components**, each following its web counterpart's variants, sizes and states:

| Family | Components |
|:--|:--|
| Typography and layout | Text, Separator, Card |
| Actions and status | Button, Icon button, Badge, Avatar, Spinner, Progress, Skeleton |
| Inputs and forms | Field, Field set, Text field, Textarea, Password input, One-time code, Checkbox, Radio group, Select, Number field, Switch, Form actions, Form error summary |
| Navigation and overlays | Tabs; navigation and tab bar styling; Alert dialog, Confirmation dialog, Sheet, Popover, Menu, Toast |
| Data display | List item and section header, Description list, Accordion, Chip and chip group, Timeline, Empty state, Data state; search through native `searchable` |

Not included: data tables, charts, rich text, date pickers, comboboxes and the other web components
not listed above. Qeetrix for iOS covers a subset of Qeetrix for the web.

## Accessibility

Every interactive control has a 44 pt target and VoiceOver labels, traits and values. Layouts reflow at
the largest text size rather than truncate, checked with Apple's audit and screenshots. Apple's accessibility audit runs over every showcase page in light,
dark and the largest text size, as a test, and over an independent app's screens. Phase 6 fixed:

- the password field's target;
- icons spilling out of icon buttons and field actions at large text sizes;
- the select cutting its value short;
- the right-to-left timeline.

Device checks with VoiceOver and other assistive technology are still to be done; no conformance to a
formal standard is claimed.

## Performance

Text styles cache their resolved font: resolving 2,000 typefaces took 0.094 s before and 0.001 s after,
on the iOS simulator in a debug build (`Documentation/Quality/PERFORMANCE_REPORT.md`). Device figures
are not yet measured.

## Breaking changes and migration

This is the first version, so nothing breaks for released consumers. For anyone who built against the
repository's `main` before it:

- **`QeetrixIconName` is a struct, not an enum** (ADR 0016). Add a `default:` case to any `switch` over
  icon names. Everything else that names an icon compiles unchanged.

## Known limitations

- The library's 19 built-in strings ("Loading", "Required", "Close"…) are English only.
- No increased-contrast colours: `@qeetrix/ui` defines none yet.
- The small spinner's VoiceOver frame turns with it (P3).
- Not tested on iOS 17, iPad or devices.
- No licence has been chosen for the package's own code: it is for Qeet Group's own use
  (`LICENSE_COMPLIANCE.md`).

## Third-party content

Cal Sans and Fira Code (SIL OFL 1.1), and icon artwork from Lucide (ISC) and Feather (MIT) through
`qeetrix-icons` (MIT). Their notices are in the resource bundle. The full list is
`qeetrix-ios-0.1.0-rc.1.cdx.json`.
