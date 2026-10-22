# Searching a collection

Native search over your data, with Qeetrix filters and a no-results state.

## Overview

Search is SwiftUI's `searchable(text:placement:prompt:)`: the system draws the field, its keyboard, its
clear and cancel buttons and its placement in the navigation bar, and VoiceOver knows it as a search
field. Qeetrix doesn't add a second search field. It provides what goes around the search: chips that
filter and the state for no results.

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
                QeetrixEmptyState("No results", description: Text("Nothing matches your search."), variant: .noResults, size: .sm) {
                    QeetrixButton("Clear search", variant: .outline, size: .sm) { query = ""; status = nil }
                }
            }
            ForEach(results) { document in QeetrixListItem(document.title, icon: .fileText) }
        }
        .searchable(text: $query, prompt: Text("Search documents"))
    }
}
```

## What is yours

- **Matching.** Filter in memory, query a database or call a server: Qeetrix never sees the query.
- **Timing.** Debounce, cancel stale requests and show progress as your data source needs; a
  ``QeetrixDataState`` shows the loading and failure branches.
- **Submission.** `onSubmit(of: .search)` runs when the person presses Search.
- **Scope and suggestions.** `searchScopes` and `searchSuggestions` are SwiftUI's, and work as they do in
  any app.

## No results

Show a ``QeetrixEmptyState`` with `variant: .noResults` in place of the rows, say what was searched for,
and offer a way back — clearing the search, or the filters. It is not an error.
