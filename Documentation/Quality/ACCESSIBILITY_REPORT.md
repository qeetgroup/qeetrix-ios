# Accessibility report

Phase 6, 2026-10-19 and 2026-10-20, on the iOS 27.1 iPhone simulator (iPhone Duo) with Xcode 27.1.
What the components promise is in `Documentation/Standards/ACCESSIBILITY.md`; this report is what was
measured, what was fixed and what is still unverified.

## Method

1. **Survey.** Apple's accessibility audit (`XCUIApplication.performAccessibilityAudit`) on the 40
   showcase pages, three screens each: dark at the default text size and light at Accessibility Large
   on every page (about 15 minutes each), and light at the default size on four pages before that run
   was stopped for time — the gate covers it in full. Every issue was printed rather than failed, then
   triaged by hand with the element's frame, the audit's detailed description and a screenshot.
2. **Fixes**, each with a regression test (below).
3. **Gate.** `AccessibilityAuditUITests` replaces the survey and runs in the UI suite: an issue fails
   the test unless an exclusion names it and says why.
4. **Targeted checks** the audit can't make: tap-to-focus on fields, rows growing at accessibility
   sizes, contrast of non-text marks in unit tests.

## What the survey found

| Check | Raw issues | Real defects | Disposition |
|:--|:--|:--|:--|
| Hit region | 16 | 2 | A11Y-1 password field, A11Y-2 showcase link — fixed. The textarea's text view and the small spinner are audit artefacts (below). |
| Element description | 92 | 0 | Foundations swatch labels are token names by design (`text.secondary`); the field message "Available." is a sentence the readability heuristic misreads. |
| Trait | 4 | 1 | A11Y-3: a showcase button labelled "Native button" repeated its trait — renamed "Native style". |
| Element detection | 5 | 0 | "Potentially inaccessible text", with no element, on the one-time-code, number-field and form pages: drawn glyphs the audit reads as text — the steppers' + and − (the Increase and Decrease buttons) and the code cells (whose code is the field's value). |
| Contrast | 61 | 0 | Disabled controls (exempt under WCAG 1.4.3), elements under the navigation bar or partly off screen when measured, and the system search field. |
| Dynamic Type | 170 | 0 | Avatar initials are sized to the avatar by design; Foundations pins its specimens; the rest is text in a `List` or a lazy grid — system text in a list footer included — which the check reports even with the size unpinned, and which a UI test measured scaling. |
| Text clipped | 65 | 0 in the survey | The check is a prediction ("may be clipped at larger Dynamic Type sizes") at every size. Screenshots at the largest size showed the flagged toggle rows wrapping and growing (103 and 111 pt) and text fields fitting. |

The gate's first run, at the largest size, went further than the survey: it flagged the select cutting
its value short (A11Y-5), and the screenshots taken to check its flags showed icons spilling out of
fixed squares (A11Y-6). Neither shows at the survey's sizes.

## Findings and fixes

| ID | Severity | Finding | Fix | Regression test |
|:--|:--|:--|:--|:--|
| A11Y-1 | P1 | The password field's element was 19–20 pt tall, and a tap on its padding didn't focus it: the secure field took touches only on its line of text. | The entry takes the padded box as its content shape and hit area, and a tap anywhere in it focuses the field, as the text field does. | `PasswordInputUITests.testATapOnTheFieldsPaddingFocusesIt`: taps 8 pt below the line, waits for focus, and checks the element is at least 36 pt tall |
| A11Y-2 | P3 | Showcase: the app-navigation page's link was 17 pt tall. | `.qeetrixMinimumTouchTarget()` on its label. | The audit gate's hit-region check on that page |
| A11Y-3 | P3 | Showcase: "Native button" repeated the button trait. | Renamed "Native style". | The audit gate's trait check |
| A11Y-4 | P3, open | The small spinner's accessibility frame turns with it: measured 22.6 × 22.6 pt for a 16 pt spinner caught at 45°. VoiceOver's cursor would turn with it. | Not fixed in Phase 6: it needs the element on a frame that doesn't rotate, verified in the running app. | Recorded in `RELEASE_READINESS_GAPS.md` |
| A11Y-5 | P2 | At the accessibility sizes the select cut its value to one line: "Choose a co…" at the largest size. | The value wraps at the accessibility sizes and the trigger grows; it stays one line (`line-clamp-1`) otherwise. | `LargeTextTests` "At the accessibility sizes the select's value wraps…"; the audit gate's clipping check at the largest size |
| A11Y-6 | P2 | Icons spilled out of fixed squares at the accessibility sizes: the icon scales with Dynamic Type (about 50 pt at the largest size) but the square didn't — icon buttons and icon-only menus (36 pt) over their neighbours, the password eye over the field's edge, the number field's + and −. The checkbox's mark and the avatar's fallback icon would also outgrow their fixed boxes. | One shared rule, `qeetrixIconSquare(_:icon:)`: the square is the web's size at the default text size and grows with its icon, keeping the inset, as a native button grows with its symbol. The busy indicator scales like the icon it replaces, so a busy button keeps its size. The checkbox mark and the avatar's icon are fixed, like their boxes. Nothing changes at the default size. | `LargeTextTests`: the square and the icon button grow with the icon, busy or not; the checkbox mark draws the same at the default and the largest size. On iOS each test first checks that the icon does scale, so it can't pass vacuously; the Mac host has no Dynamic Type |
| — | — | The textarea's text view is one line tall while it is empty, so the audit reports a small hit region. | None needed: a tap anywhere in the two-control-height box focuses the field. | New: `TextareaUITests.testATapInTheBoxBelowTheTextFocusesIt` taps 24 pt below the line |
| — | — | A minor timeline event's dot measures 1.48:1 (light) and 1.65:1 (dark) on the canvas: upstream's design for minor events, whose text says what happened. | Recorded for design review (GAP-7), not changed. | Default events' dots: `TimelineContrastTests`, at least 3:1 on canvas, default and subtle surfaces in both themes (lowest 3.89:1, brand on subtle, dark) |

The tap-to-focus tests wait for focus rather than checking at once: focus set from a tap gesture lands
a moment after the tap, and on a busy simulator the first version of the textarea test failed for that
reason while the field had in fact been focused (confirmed with a screenshot two seconds later).

## The gate

`Examples/QeetrixShowcase/QeetrixShowcaseUITests/Accessibility/AccessibilityAuditUITests.swift`:

| Test | Configuration | Checks |
|:--|:--|:--|
| `testLightTheme` | Light; the simulator's own text size (not pinned) | Everything but text clipping; two screens per page |
| `testDarkTheme` | Dark | Contrast — the check a theme changes; two screens per page |
| `testLargestAccessibilitySize` | Light; Accessibility XXXL | Text clipping and hit regions; three screens per page |
| `testTextInListsAndGridsScales` | Default and Accessibility Large launches | A list row's title, system text in a list footer and a lazy grid's value are at least 1.5 times taller at the larger size — the measurement behind the Dynamic Type exclusion |

Every catalogue page is audited except Foundations, a token specimen that pins its own sizes and labels
swatches with token names.

Contrast is enforced at the default size. Body text needs 4.5:1 there; at accessibility sizes all text
is large and needs 3:1, so the default size is the stricter test.

**The Dynamic Type check runs in its own audit call, after the others** (Phase 7, finding TEST-2, P2).
In one call with the contrast check, it re-lays out the text while it tries sizes. On a scrolled screen
the contrast check then measured at the old positions, and every heading and button label "failed"
contrast: 41 issues on 12 pages in the release-candidate dry run, reproduced twice. With the two checks
in separate calls the same screens report only the known, excluded issues. Diagnostic runs showed it:
on the button page's scrolled screen, contrast alone found only the disabled buttons, and contrast with
Dynamic Type found 18 issues with "Sizes" placed 20 pt from where it was drawn; split into two calls,
the button, text-field, chip and list-item pages found only known issues on both screens. The Phase 6
run that passed must have measured before the layout moved; the gate no longer depends on that timing.

For the same reason the gate now waits for the screen to be still after each swipe — two identical
screenshots a quarter-second apart, at most five seconds — before auditing it. A flung list keeps
decelerating after `swipeUp()` returns (the 5,000-row list for about 2.4 s), and one run reported a
contrast issue with no element on that page, which six diagnostic audits of the settled list didn't
reproduce.

### Exclusions

Each one is in `AccessibilityAuditUITests.exclusion(for:on:content:)` with its reason.

| Exclusion | Applies to | Why it isn't a defect |
|:--|:--|:--|
| System search field | Every check | `searchable` is UIKit's field; Qeetrix doesn't draw or style it. |
| Not fully inside the content area | Contrast, text clipping | The audit reads colours from the screen. An element under the navigation bar or partly off screen is measured against the bar or nothing. It is audited again after the page scrolls. |
| Disabled controls | Contrast | WCAG 1.4.3 exempts inactive components. Disabled is 50% opacity, as on the web. The showcase's disabled demos are listed by page and label; any element the audit reports as not enabled is also excluded. |
| Avatar initials | Dynamic Type, on the avatar and list-item pages, labels of one or two capitals | The initials are sized to the avatar, as on the web; the avatar's VoiceOver label is the full name. |
| Text, images and the busy indicator | Hit region | They are not controls. |
| The textarea's text view | Hit region | The box is the target (`TextareaUITests`). |
| "Available." | Element description, text-field page | A field message that is a sentence; the readability heuristic misreads it. |
| `navigator.credentials.create()` | Element description, text page | The inline-code specimen: code, read as written; the heuristic expects prose. |
| Toggles and text fields | Text clipping | A prediction, not clipping: toggle labels wrap and their rows grow; a text field's single line scrolls. Checked in screenshots at the largest size. |
| Drawn glyphs, no element | Element detection, on the number-field, one-time-code and form pages | The steppers' + and − are the Increase and Decrease buttons; the code cells draw the field's value. |
| Lists and lazy grids | Dynamic Type, on the list-item, search, description-list, collection-patterns and large-list pages | The check can't follow the size into lazy content, and flags system text there too. `testTextInListsAndGridsScales` measures the text scaling instead. |
| The disabled row, no element | Contrast, list-item page | In a diagnostic run the same issue resolved to the disabled row's "Archived workspace" and "Read-only". |

## Component by component

Every component below was checked for: labels, traits and values; Dynamic Type up to the largest
size; touch targets; contrast in light and dark; Reduce Motion where it moves; right to left. The
automated evidence is the audit gate on its showcase page, its UI tests, and its snapshot specimens at
an accessibility size and right to left. **Manual device verification has not been done for any
component** (GAP-1); the remaining-risk column is what a person should look at first.

| Component | Automated evidence beyond the gate | Defects and fixes | Remaining risk (manual) |
|:--|:--|:--|:--|
| Text | Snapshots | — | Reading order of long passages |
| Separator | Unit: hidden from VoiceOver | — | — |
| Card | `CardUITests`: a selectable card is one button with the selected trait | — | Rotor in card grids |
| Badge | Snapshots | — | Status read with its row, not alone |
| Button | `ButtonUITests`: trait, busy state, 44 pt target outside the drawn frame | Busy indicator now scales (A11Y-6) | VoiceOver hearing "Loading" |
| Icon button | `ButtonUITests`, `LargeTextTests` | A11Y-6: icon spilled out at large sizes — fixed | Large Content Viewer is not offered |
| Spinner | `FeedbackUITests`: one "Loading" element | A11Y-4: frame turns with it (open, P3) | Cursor box while turning |
| Progress | `FeedbackUITests`: progress indicator with value | — | Value updates spoken at a sensible rate |
| Avatar | `AvatarUITests`: the name and status as label | Fallback icon fixed to the avatar (A11Y-6) | — |
| Switch | `SwitchUITests`: switch trait, 44 pt row | — | Switch Control on a row |
| Text field | `TextFieldUITests`: label, "Required", message, padding tap | — | Hint and message speech with hints off |
| Field, field set | Through every input's UI tests | — | Announcement of a new message |
| Textarea | `TextareaUITests`: return, error, box tap (new) | — | — |
| Password | `PasswordInputUITests`: secure value, reveal, padding tap (new) | A11Y-1 fixed; eye inside the field (A11Y-6) | Never reading a hidden password; AutoFill |
| One-time code | `OTPInputUITests`: one native field | — | AutoFill from Messages |
| Checkbox | `SelectionUITests`: toggle, mixed cycle | Mark fixed inside the box (A11Y-6) | — |
| Radio group | `SelectionUITests`: single selection, disabled option | — | Rotor between options |
| Select | `SelectionUITests`: system menu | A11Y-5: value cut to one line — fixed | — |
| Number field | `NumberFieldUITests`: steppers named, bounds | Steppers grow with their icons (A11Y-6) | Adjustable action for VoiceOver swipes |
| Form patterns | `FormPatternsUITests`: focus order, error summary links | — | Full Keyboard Access through a form |
| Tabs | `TabsUITests`: tab-bar trait, selected, disabled skipped | — | "Tab, n of m" in context |
| Navigation and tab bars | `AppNavigationUITests` | Showcase link 44 pt (A11Y-2) | Large Content Viewer on the tab bar is the system's |
| Alert and confirmation dialogs | `AlertDialogUITests`, `ConfirmationDialogUITests` | — | Escape with a keyboard |
| Sheet | `SheetUITests`: title heading, Close, guarded dismissal | — | Focus return after dismissal |
| Popover, menu | `PopoverUITests`, `MenuUITests` | — | iPad presentation |
| Toast | `ToastUITests`, lifecycle unit tests | — | Hearing the announcement; focus hold |
| List item, section header | `ListItemUITests`: one element, selection, reflow | — | Rotor headings |
| Description list | `ContentStateUITests` | — | — |
| Accordion | `AccordionUITests`: heading button, expanded value | — | — |
| Empty, data and skeleton states | `ContentStateUITests`: one "Loading" element, retry | — | Hearing the failure announcement |
| Chip, chip group | `ChipUITests`: selected trait, named group, remove | — | — |
| Timeline | `ContentStateUITests`; `TimelineContrastTests` | LOC-3 right to left — fixed | Minor dots under 3:1 by design (GAP-7) |
| Search (native) | `SearchUITests` | Showcase footer contrast — fixed | — |

## Results

| Run | Result |
|:--|:--|
| First gate run (light, dark, largest size, 39 pages) | Dark passed. Light and largest size failed on 23 issues: the select's truncation (A11Y-5) and audit misreadings, each then checked with the audit's detailed description and a screenshot. Those screenshots showed A11Y-6 |
| Final full UI suite, 2026-10-20 | `testLightTheme` passed (543 s), `testDarkTheme` passed (421 s), `testLargestAccessibilitySize` passed (1,665 s), on all 40 catalogue pages but Foundations; `testTextInListsAndGridsScales` passed on re-run after a fix to its own query and threshold |

Every exclusion in force is listed above with its evidence. No issue was excluded without being looked
at in a screenshot, the audit's detailed description, or both.

## Not verified

These need a person and a device; the list per component is in `ACCESSIBILITY.md`:

- VoiceOver speech, reading order, rotor headings and announcements;
- Full Keyboard Access and Switch Control focus order;
- the largest text sizes on real screens and on an iPad;
- Bold Text, Increased Contrast, Smart Invert and Differentiate Without Colour on a device;
- the iOS 17 runtime.

The audit is Apple's heuristic, not a conformance test. Passing it doesn't make a component WCAG
conformant.
