# Component maturity matrix

Phase 6, 2026-10-19. One row per public component. It shows what each one has, what checks it, and
how mature it is. Test counts are in `TEST_COVERAGE.md`; the findings named here are in
`PHASE_6_AUDIT.md`.

## Levels

| Level | Meaning |
|:--|:--|
| **Stable** | Beta, plus: VoiceOver, Full Keyboard Access and Dynamic Type checked by a person on a device; run on the oldest supported iOS (17); shipped in a versioned release. |
| **Beta** | The API follows ADR 0010 and is in the API baseline. Behaviour unit tests. A snapshot specimen in light, dark, accessibility size and right-to-left where Qeetrix draws it. A UI test or the accessibility audit gate in the running app. A DocC page with compiled examples. A showcase page. |
| **Preview** | Missing one of Beta's checks. |

**No component is Stable**, for reasons shared by all of them: no device checks have been done, the iOS
17 runtime hasn't been run, there is no release, and the CI workflow hasn't run on GitHub. Those gaps
are in `RELEASE_READINESS_GAPS.md` and are not repeated per row.

Every component below is Beta.

## Matrix

Columns: **Unit** — behaviour tests in `Tests/QeetrixTests`. **Snapshot** — a specimen in
`Tests/QeetrixSnapshotTests` ("system" means the system draws it, so there is nothing of Qeetrix's to
compare). **UI** — a test in `QeetrixShowcaseUITests` that drives the component. **Audit** — its
showcase page is in `AccessibilityAuditUITests`.

### Foundations and core (Phase 2)

| Component | Unit | Snapshot | UI | Audit | Phase 6 notes |
|:--|:--|:--|:--|:--|:--|
| `QeetrixText` | ✓ | ✓ | — | ✓ | No dedicated UI test: it has no behaviour beyond `Text`; the audit covers its page |
| `QeetrixSeparator` | ✓ | ✓ | — | ✓ | Decorative and hidden from VoiceOver; the audit covers its page |
| `QeetrixCard` | ✓ | ✓ | ✓ | ✓ | |
| `QeetrixBadge` | ✓ | ✓ | — | ✓ | Static text; the audit covers its page |
| `QeetrixButton` | ✓ | ✓ | ✓ | ✓ | |
| `QeetrixIconButton` | ✓ | ✓ | ✓ | ✓ | A11Y-6 fixed: the square grows with its icon at large text sizes |
| `QeetrixSpinner` | ✓ | ✓ | ✓ | ✓ | A11Y-4: its VoiceOver frame turns with it (P3, open) |
| `QeetrixProgress` | ✓ | ✓ | ✓ | ✓ | |
| `QeetrixAvatar` | ✓ | ✓ | ✓ | ✓ | Initials and the fallback icon stay at the avatar's size by design; the label is the name |
| `QeetrixSwitch` | ✓ | ✓ | ✓ | ✓ | |
| `QeetrixTextField` | ✓ | ✓ | ✓ | ✓ | |
| `QeetrixIcon`, `Image(qeetrix:)` | ✓ | via components; unit tests check rendered pixels and mirroring | via components | via components | API-1: `QeetrixIconName` is now an open set (ADR 0016) |

### Inputs and forms (Phase 3)

| Component | Unit | Snapshot | UI | Audit | Phase 6 notes |
|:--|:--|:--|:--|:--|:--|
| `QeetrixField`, `QeetrixFieldSet` | ✓ | ✓ | via inputs | ✓ | Exercised through every input's UI tests |
| `QeetrixTextarea` | ✓ | ✓ | ✓ | ✓ | New test: a tap in the box below the text focuses it |
| `QeetrixPasswordInput` | ✓ | ✓ | ✓ | ✓ | A11Y-1 fixed: the whole field is the target; A11Y-6 fixed: the eye stays inside the field |
| `QeetrixOTPInput` | ✓ | ✓ | ✓ | ✓ | |
| `QeetrixCheckbox` | ✓ | ✓ | ✓ | ✓ | A11Y-6: the mark is fixed, like its box |
| `QeetrixRadioGroup` | ✓ | ✓ | ✓ | ✓ | |
| `QeetrixSelect` | ✓ | ✓ | ✓ | ✓ | A11Y-5 fixed: the value wraps at the accessibility sizes |
| `QeetrixNumberField` | ✓ | ✓ | ✓ | ✓ | A11Y-6 fixed: the steppers grow with their icons |
| `QeetrixFormActions`, `QeetrixFormErrorSummary` | ✓ | ✓ (summary) | ✓ | ✓ | |

### Navigation, overlays and feedback (Phase 4)

| Component | Unit | Snapshot | UI | Audit | Phase 6 notes |
|:--|:--|:--|:--|:--|:--|
| `QeetrixTabs` | ✓ | ✓ | ✓ | ✓ | |
| Navigation and tab bar styling | ✓ | system | ✓ | ✓ | |
| `QeetrixAlertDialog`, `QeetrixConfirmationDialog` | ✓ | system | ✓ | ✓ | |
| `qeetrixSheet`, `QeetrixSheetContent` | ✓ | ✓ (content) | ✓ | ✓ | |
| `qeetrixPopover` | ✓ | ✓ (surface) | ✓ | ✓ | |
| `QeetrixMenu`, `QeetrixMenuItem` | ✓ | ✓ | ✓ | ✓ | A11Y-6 fixed for the icon-only trigger |
| `QeetrixToast` | ✓ | ✓ | ✓ | ✓ | |

### Data display and content states (Phase 5)

| Component | Unit | Snapshot | UI | Audit | Phase 6 notes |
|:--|:--|:--|:--|:--|:--|
| `QeetrixListItem`, `qeetrixListRow()` | ✓ | ✓ | ✓ | ✓ | |
| `QeetrixSectionHeader` | ✓ | ✓ | via list pages | ✓ | Documented on the list item's DocC page |
| `QeetrixDescriptionList` | ✓ | ✓ | ✓ | ✓ | |
| `QeetrixAccordion`, `.disclosureGroupStyle(.qeetrix)` | ✓ | ✓ | ✓ | ✓ | |
| `QeetrixEmptyState` | ✓ | ✓ | ✓ | ✓ | |
| `QeetrixDataState` | ✓ | ✓ | ✓ | ✓ | |
| `QeetrixSkeleton`, `QeetrixSkeletonText` | ✓ | ✓ | ✓ | ✓ | |
| `QeetrixChip`, `QeetrixChipGroup` | ✓ | ✓ | ✓ | ✓ | |
| `QeetrixTimeline` | ✓ | ✓ | ✓ | ✓ | LOC-3 fixed: the connector mirrors in right-to-left |
| Search (native `searchable`) | — | system | ✓ | ✓ | No Qeetrix component; the audit excludes the system field |

## What would move a component to Stable

1. A person checks it with VoiceOver, Full Keyboard Access and the largest text size on an iPhone and
   an iPad, and with Switch Control where it is interactive (`ACCESSIBILITY_REPORT.md`).
2. The library and UI tests run on an iOS 17 runtime.
3. CI runs green on GitHub.
4. It ships in a versioned release, after which the API rules in `API_COMPATIBILITY.md` apply.
