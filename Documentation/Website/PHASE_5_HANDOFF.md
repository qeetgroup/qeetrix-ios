# ui.qeet.in handoff: iOS data display, collections and content states

For whoever maintains the component pages on ui.qeet.in (`qeetrix-docs`). It lists what Qeetrix for iOS
now provides for each web component, so a page can gain an **iOS** section. Nothing here has been
published: qeetrix-ios has no release, and nothing should be documented as installable until it does.

The source of truth for wording is the DocC catalogue in `Sources/Qeetrix/Qeetrix.docc`. The decisions
behind it are in ADR 0015.

## What to add, page by page

| ui.qeet.in page | iOS API | One-line summary for the page |
|:--|:--|:--|
| Description List | `QeetrixDescriptionList`, `QeetrixDescriptionItem` | The same three layouts and `divided`. Columns follow the size class: stacked on a portrait iPhone. |
| Accordion, Collapsible | `QeetrixAccordion`, `QeetrixAccordionItem`, `.disclosureGroupStyle(.qeetrix)` | Native disclosure groups in the Qeetrix style; several open at once, or one at a time through the app's binding. |
| Empty State | `QeetrixEmptyState` | The same five variants and three sizes. |
| Data State | `QeetrixDataState`, `QeetrixDataFailure` | The same order of branches. The failure message is written for the person, and a retry is optional. |
| Skeleton | `QeetrixSkeleton`, `QeetrixSkeletonText` | The same tint and sweep; text lines sized to a typography role. |
| Chip | `QeetrixChip`, `QeetrixChipGroup` | The same sizes, selected look and remove button; groups for one value or several. |
| Timeline | `QeetrixTimeline`, `QeetrixTimelineItem` | The same tones, minor events and icon markers. |
| Table, Data Table, Aspect Ratio | — | Not on iOS. Say so, and point to native `Table` (iPad) and `AsyncImage`. |

iOS-only entries for an iOS overview page:

- **List item.** `QeetrixListItem`, `QeetrixListItemIcon`, `.qeetrixListRow()` and `QeetrixSectionHeader`
  are the rows and section headers of native lists.
- **Search.** iOS uses the native `.searchable`. Qeetrix provides the no-results empty state and the
  filter chips around it.

## Examples to show

Use the DocC examples verbatim. They are compiled by
`Tests/QeetrixTests/Integration/DataDisplayDocumentationExamplesTests.swift`.

## Differences each page should state

- **The data is the app's.** No component fetches, filters, sorts, caches or paginates. The web's
  `DataState` reads TanStack Query state; on iOS the app passes the three states itself.
- **No error objects.** The iOS data state never shows an error object's message.
- **Size classes, not breakpoints.** Layout changes follow the iOS size class, not the web's `sm`
  breakpoint.
- **Lists are SwiftUI's.** Swipe actions, context menus and edit mode come from `List`, not from Qeetrix.

## Images

As before: no screenshots from the repository. Capture showcase pages locally — `list-item`, `search`,
`description-list`, `chip`, `timeline`, `collection-patterns`, `empty-state`, `data-state`, `skeleton` and
`accordion` — with their synthetic data.

## Verification status to quote

- **Verified on the iOS 27.1 iPhone simulator:**
  - unit, snapshot and UI tests;
  - row reflow at an accessibility text size;
  - scrolling 5,000 rows (a simulator measurement, not a device benchmark).
- **Not yet verified:** VoiceOver speech on a device, an iPad, an iOS 17 runtime, and performance on a
  device.
