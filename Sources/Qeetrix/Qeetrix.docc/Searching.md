# Searching a collection

Search over your data, with Qeetrix filters and a no-results state.

## Overview

For a list in a `NavigationStack`, search is the system's search bar: `qeetrixSearchable(text:placement:prompt:searchDelay:onSearch:)`
is SwiftUI's `searchable` with Qeetrix's search behaviour — it asks once per pause in typing, at once on
the Search key, and with "" when the text is cleared. The system draws the field, its keyboard, its
clear and cancel buttons and its placement in the navigation bar, and VoiceOver knows it as a search
field. Where the field belongs in the content instead — in a sheet, a card or a sidebar — use a
``QeetrixSearchField``, which behaves the same. Around either, Qeetrix provides chips that filter and the
state for no results.

```swift
struct Documents: View {
    let documents: [Document]
    @State private var query = ""
    @State private var status: Document.Status? = nil

    private var results: [Document] {
        documents.filter { ($0.status == status || status == nil) && (query.isEmpty || $0.title.localizedCaseInsensitiveContains(query)) }
    }

    var body: some View {
        List {
            QeetrixChipGroup("Status", selection: $status, options: statusOptions)
            if results.isEmpty {
                QeetrixEmptyState("No results", description: "Nothing matches your search.", icon: .search, size: .section) {
                    QeetrixButton("Clear search", variant: .soft, size: .sm) { query = ""; status = nil }
                }
            }
            ForEach(results) { document in
                QeetrixListItem(document.title) { QeetrixListItemIcon(.fileText) }
            }
        }
        .qeetrixSearchable(text: $query, prompt: Text("Search documents"))
    }
}
```

## What is yours

- **Matching.** Filter in memory, query a database or call a server: Qeetrix never sees your data. A
  short local list can filter on every change of the binding; a server is asked from `onSearch`.
- **Timing.** `onSearch` waits for a pause (`searchDelay`, 300 ms by default). Cancel stale requests and
  show progress as your data source needs; a ``QeetrixDataState`` shows the loading and failure branches.
- **Scope and suggestions.** `searchScopes` and `searchSuggestions` are SwiftUI's, and work as they do in
  any app.

## No results

Show a ``QeetrixEmptyState`` in place of the rows, say what was searched for, and offer a way back —
clearing the search, or the filters. It is not an error.
