import SwiftUI

extension View {
    /// The system search bar, with the search behaviour of ``QeetrixSearchField`` — for a list in a
    /// `NavigationStack`, where the bar's search field is the native choice.
    ///
    /// ```swift
    /// NavigationStack {
    ///     List(results) { account in
    ///         Text(account.name)
    ///     }
    ///     .navigationTitle("Accounts")
    ///     .qeetrixSearchable(text: $query, prompt: Text("e.g. Asha")) { query in
    ///         results = accounts.matching(query)
    ///     }
    ///     .qeetrixNavigationBar()
    /// }
    /// ```
    ///
    /// `onSearch` runs when typing pauses for `searchDelay` (300 ms by default), at once on the keyboard's
    /// search key, and with "" when the text is emptied — by its clear button, Cancel or the delete key.
    /// Text you write into the binding yourself is not searched. The caret and Cancel take the brand tint
    /// (`color.text.brand`), as the bar's other buttons do with `qeetrixNavigationBar()`.
    ///
    /// The bar is drawn by iOS, in its own font and fill: its placement, its scope bar, its appearance on
    /// scroll and its Cancel button are the system's (ADR 0014).
    public func qeetrixSearchable(
        text: Binding<String>,
        placement: SearchFieldPlacement = .automatic,
        prompt: Text? = nil,
        searchDelay: Duration = .milliseconds(300),
        onSearch: (@MainActor (String) -> Void)? = nil
    ) -> some View {
        modifier(QeetrixSearchableModifier(text: text, placement: placement, prompt: prompt, searchDelay: searchDelay, onSearch: onSearch))
    }
}

struct QeetrixSearchableModifier: ViewModifier {
    let text: Binding<String>
    let placement: SearchFieldPlacement
    let prompt: Text?
    let searchDelay: Duration
    let onSearch: (@MainActor (String) -> Void)?
    @State private var search = QeetrixSearchState()

    func body(content: Content) -> some View {
        content
            .searchable(text: typing, placement: placement, prompt: prompt)
            .onSubmit(of: .search) { searchNow(text.wrappedValue) }
            .tint(QeetrixColor.textBrand)
            .task(id: search.pending) {
                guard let pending = search.pending else { return }
                try? await Task.sleep(for: searchDelay)
                guard !Task.isCancelled, let query = search.pauseEnded(pending) else { return }
                onSearch?(query)
            }
    }

    /// The binding the search bar edits. The bar's own clear button and Cancel empty it through here, so
    /// an emptied field searches "" at once; other edits wait for a pause.
    private var typing: Binding<String> {
        Binding(
            get: { text.wrappedValue },
            set: { newValue in
                guard newValue != text.wrappedValue else { return }
                text.wrappedValue = newValue
                if newValue.isEmpty {
                    searchNow("")
                } else {
                    search.typed(newValue)
                }
            })
    }

    private func searchNow(_ query: String) {
        onSearch?(search.searchNow(query))
    }
}
