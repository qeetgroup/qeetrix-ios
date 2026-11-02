# 0015 — Data display and content states: native containers, the app's data

**Status:** Accepted (Phase 5, 2026-10-19). Builds on ADRs 0010, 0011 and 0014. Amended by ADR 0018
(2026-11-02): the components are re-specified from `@qeetrix/react` 0.4.0 by the iOS component tickets,
decision 6 gains `QeetrixSearchField` (QTRX-96), and decision 9's helpers are gone with the Phase 5
implementations.

## Context

Phase 5 adds what collection and detail screens are built from: rows, grouped sections, labelled
details, expandable content, empty and loading states, search, filters and histories.

SwiftUI already provides the hard parts:

- `List` and `Section` scroll lazily, reuse rows, and provide separators, swipe actions, edit mode and
  keyboard navigation.
- `DisclosureGroup` expands and collapses.
- `searchable` provides the search field, its keyboard and its placement.
- `ContentUnavailableView` is the system's empty state.
- `Table` shows columns on iPad.

The web catalogue (`@qeetrix/ui` 2.1.6) has `DescriptionList`, `Accordion` and `Collapsible`,
`EmptyState`, `DataState`, `Skeleton`, `Chip`, `Timeline`, `Table`, `DataTable` and `AspectRatio`.

The web has no list-row component and no search component. A web screen uses a table or a listbox where
an iOS screen uses a list.

## Decision

1. **Qeetrix presents; the app owns the data.**
   - Components take values and views. There is no data store, view model, fetching, caching,
     pagination, search index or filter engine.
   - Selection, expansion, the query and the load state are bindings or plain values the app passes.
   - Rows take the app's stable identity through `ForEach` and `List`.
2. **Native containers are not wrapped.**
   - `List`, `Section`, `LazyVStack`, `DisclosureGroup`, `searchable`, `Table` and `AsyncImage` are used
     directly.
   - Qeetrix supplies what goes inside or around them: `QeetrixListItem`, `QeetrixSectionHeader`,
     `.disclosureGroupStyle(.qeetrix)`, chips, and the empty state.
3. **Web names where the web has the component.** `QeetrixDescriptionList` (the proposal's
   "KeyValueRow"), `QeetrixChip` and `QeetrixChipGroup` ("FilterChip"), `QeetrixAccordion`,
   `QeetrixEmptyState`, `QeetrixDataState`, `QeetrixSkeleton` and `QeetrixTimeline` follow the
   web's names, variants and metrics. Their component tokens are adopted: `accordion`, `skeleton` and
   `timeline`.
4. **One iOS-only family: `List`.** `QeetrixListItem` and `QeetrixSectionHeader` have no web
   counterpart. They live in `Components/List/` and are built from web tokens and compositions: the
   notification row's tile and type, the table's selected-row colours, and the density's row height and
   cell padding.
5. **Rows inside lists.**
   - A list reads row insets and backgrounds from a row's outermost view.
   - A list item that is itself the row sets them.
   - A row wrapped in a `NavigationLink` or `Button` gets them from `qeetrixListRow()`. It
     leaves the list a trailing inset, so a link's chevron keeps its margin, and tells the item, through
     the environment, to give up the same amount of trailing padding. A UI test checked that the value
     doesn't change a standalone row on a pushed destination.
6. **Search is native.** `searchable` is the search field. Qeetrix adds no search component and no
   debouncing or cancellation. It provides the no-results `QeetrixEmptyState` and chips to filter
   with.
7. **Empty states are drawn by Qeetrix, not by `ContentUnavailableView`.** The system view can't draw
   the web contract: a tinted tile per variant, three sizes, Qeet Sans.
8. **The data state follows the web's order**: loading, then failure, then empty, then content.
   - A failure carries a message written for the person, and an optional retry. Unlike the web, it never
     shows an error object's message.
   - The loading branch is one "Loading" element for VoiceOver.
   - The failure is announced once, at high priority.
9. **Shared layout helpers stay internal**:
   - rules between stacked items, drawn from their positions, so the first has none;
   - a wrapping row layout for chips and actions;
   - a timeline layout that leaves no gap after the last event.
10. **Deferred:**
    - **`QeetrixDataTable`.** The web's is a TanStack data grid. SwiftUI's `Table` shows only its first
      column in compact width. On iPhone a list of rows opening a description list serves the purpose;
      on iPad, `Table` can be used directly.
    - **Image presentation.** `Image`, `AsyncImage` and `.aspectRatio` cover the web's `AspectRatio`, and
      Qeetrix has no business loading or caching images.
    - **`Feed`, `TreeView`, `FilterBar`, `Pagination`, `Stat`.** These are not in this phase's scope.

## Consequences

- Collections behave as iOS users expect — scrolling, swipe actions, edit mode, keyboard navigation and
  VoiceOver rotors — because they are the system's. In exchange, a row inside a link or button needs
  `qeetrixListRow()`.
- Apps write their own filtering and loading logic, a few lines each. The showcase's collection-patterns
  page shows the idiom.
- The snapshot host measures a specimen at the default text size and draws it at AX3. So the AX3 images
  of components that reflow at the accessibility sizes (list rows, the tabs strip) overlap. Their
  accessibility-size layout is checked in the running app by UI tests instead.
- Component tokens built on `control.*` resolve at the default density, so the accordion's header
  padding and the timeline's gaps don't follow a compact density as the web's do.
