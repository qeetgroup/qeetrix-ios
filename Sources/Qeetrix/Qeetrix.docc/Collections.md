# Building collections

Lists of rows, grouped, selectable and fast — SwiftUI's containers with Qeetrix rows.

## Overview

A collection screen is SwiftUI's `List` — or a `LazyVStack` in a `ScrollView` — of your data, with Qeetrix
drawing the rows, the section headers and the states around them. Qeetrix keeps no copy of your data, no
selection and no scroll position.

```swift
struct Members: View {
    let members: [Member]
    @State private var selected: Member.ID?

    var body: some View {
        List {
            Section {
                ForEach(members) { member in
                    QeetrixListItem(member.name, description: Text(verbatim: member.email), isSelected: selected == member.id) {
                        selected = member.id
                    } leading: {
                        QeetrixAvatar(name: member.name, isDecorative: true)
                    } trailing: {
                        QeetrixBadge(member.role)
                    }
                }
            } header: {
                QeetrixSectionHeader("Members", isRuled: false)
            }
            .listSectionSeparator(.hidden)
        }
        .qeetrixListStyle()
    }
}
```

## Choosing the container

- **`List`** for rows that the person scrolls, selects, swipes or reorders: it is lazy, reuses rows, draws
  separators and gives swipe actions, edit mode, context menus and keyboard navigation.
  `qeetrixListStyle()` makes it plain — square and ruled — on the page's `color.surface.canvas`.
- **`LazyVStack` in a `ScrollView`** for a feed of cards, where rows aren't separated and the list's
  chrome isn't wanted.
- **`VStack`** for a handful of rows in a card or a sheet, with ``QeetrixSeparator`` between them.

Prefer the native containers. Qeetrix doesn't wrap `List`, `Section`, `Table` or
`ContentUnavailableView` where they already do the job; use them directly and style their contents.

## Identity and performance

- Give `List` and `ForEach` your data's stable `id`, so a row keeps its state — an open disclosure, a
  selection — while the collection changes around it.
- Rows are plain views: they keep no state objects, load nothing and animate nothing at rest. The showcase
  scrolls 5,000 of them in a `List`; see `LargeListPerformanceUITests` for what was measured, and on what.
- Keep work out of a row's body: format dates and sizes once, in your model (``QeetrixFormat``), rather
  than on every render.
- Images: use `AsyncImage` or your app's image loader in the row's leading view, sized with `frame`.
  Qeetrix has no image loading, caching or authenticated requests of its own.
- Show people's data verbatim: `Text(verbatim:)` for a name, an email or a phone number, so iOS doesn't
  read it as Markdown and turn it into a link.

## Actions on rows

- **Tap**: the row's `action`, or its `value` for a `NavigationLink`; ``QeetrixListItemButtonStyle``
  gives the row's look to a `Button`, `ShareLink` or `Menu` of your own.
- **Swipe**: ``QeetrixSwipeAction``s with `qeetrixSwipeActions(edge:allowsFullSwipe:actions:)`. The same
  actions reach VoiceOver and the row's context menu, and a danger action can ask first.
- **Pull to refresh**: `qeetrixRefreshable(action:)` on the list (<doc:PullToRefresh>).
- **Touch and hold**: `contextMenu` with ``QeetrixMenuItem``s — the same items as a ``QeetrixMenu``.
- **A destructive action** confirms with a ``QeetrixConfirmationDialog``, then offers undo with a
  ``QeetrixToast``.

Don't nest a button inside a row that is itself a button; put a ``QeetrixMenu`` beside the row instead.

## Tables

SwiftUI's `Table` shows its columns on iPad and in a regular-width window; on iPhone it shows only the
first. Qeetrix has no data table: on iPhone, show each record as a ``QeetrixListItem`` that opens a
``QeetrixDescriptionList`` of its fields, and use `Table` directly on iPad where columns help.

## See Also

- <doc:Searching>
- <doc:Overlays>
