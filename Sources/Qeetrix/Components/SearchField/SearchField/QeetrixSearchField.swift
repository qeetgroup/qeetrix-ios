import SwiftUI

/// A search box for a list — `@qeetrix/react`'s SearchField: the Qeetrix field box with a search icon, the
/// keyboard's search key, and a Clear search button while there is text.
///
/// ```swift
/// QeetrixSearchField(text: $query, prompt: Text("e.g. Asha")) { query in
///     accounts.search(query)
/// }
/// QeetrixSearchField("Find a member", text: $query, description: Text("Name or email."))
/// ```
///
/// - **Searching.** `onSearch` runs when typing pauses for `searchDelay` (300 ms by default), at once on
///   the keyboard's search key, and with "" when the field is cleared — so a list searched on a server
///   asks once per pause, not per key, and the search key never asks twice. Text you write into the
///   binding yourself is not searched. The query is yours; keep recent searches out of logs.
/// - **Clearing.** While there is text, a "Clear search" button — a neutral `sm` ``QeetrixIconButton``
///   with a sharp `x` — empties it, searches "" and keeps the keyboard. **Escape** on a hardware
///   keyboard clears it too, and only lets the key through once the field is empty, so a sheet around
///   it closes on the second press.
/// - **Name.** A label names the field and shows above it; without one the field is named "Search" for
///   VoiceOver, its icon the visible sign, as in a toolbar. VoiceOver reads it as a search field. The
///   prompt is an example ("e.g. Asha"), never an instruction.
///
/// The box is the Qeetrix field (design rules §8), `size.control.lg` tall and growing with Dynamic Type:
/// the sharp 16 pt `search` icon in `color.icon.subtle`, the text in `body.md`, 4 pt at the end for the
/// clear button (search-field.css). Read-only shows the text without the fill or the clear button.
/// Where the system search bar is the native choice — a list in a `NavigationStack` — use
/// `qeetrixSearchable(text:placement:prompt:searchDelay:onSearch:)` instead.
public struct QeetrixSearchField: View {
    let context: QeetrixFieldContext
    let isLabelHidden: Bool
    let text: Binding<String>
    let prompt: Text?
    let searchDelay: Duration
    let isReadOnly: Bool
    let onSearch: (@MainActor (String) -> Void)?

    /// A search field without a visible label, named "Search" for VoiceOver.
    public init(
        text: Binding<String>, prompt: Text? = nil, searchDelay: Duration = .milliseconds(300), isReadOnly: Bool = false,
        onSearch: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            context: QeetrixFieldContext(label: QeetrixSearchFieldStrings.search), isLabelHidden: true, text: text, prompt: prompt,
            searchDelay: searchDelay, isReadOnly: isReadOnly, onSearch: onSearch)
    }

    /// A search field with a localised label.
    public init(
        _ titleKey: LocalizedStringKey, text: Binding<String>, prompt: Text? = nil, description: Text? = nil,
        searchDelay: Duration = .milliseconds(300), isReadOnly: Bool = false, isLabelHidden: Bool = false,
        onSearch: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: Text(titleKey), text: text, prompt: prompt, description: description, searchDelay: searchDelay, isReadOnly: isReadOnly,
            isLabelHidden: isLabelHidden, onSearch: onSearch)
    }

    /// A search field with a label shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S, text: Binding<String>, prompt: Text? = nil, description: Text? = nil, searchDelay: Duration = .milliseconds(300),
        isReadOnly: Bool = false, isLabelHidden: Bool = false, onSearch: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: Text(title), text: text, prompt: prompt, description: description, searchDelay: searchDelay, isReadOnly: isReadOnly,
            isLabelHidden: isLabelHidden, onSearch: onSearch)
    }

    /// A search field with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: Names the field, above it and for VoiceOver.
    ///   - text: The query, yours.
    ///   - prompt: An example of what to type, shown while the field is empty.
    ///   - description: Help under the field, read by VoiceOver as its hint.
    ///   - searchDelay: How long typing must pause before `onSearch` runs.
    ///   - isReadOnly: Shows the query, selectable, without the fill or the clear button.
    ///   - isLabelHidden: Hides the label visually and keeps it for VoiceOver.
    ///   - onSearch: Runs the search: when typing pauses, on the search key, and with "" when cleared.
    public init(
        label: Text, text: Binding<String>, prompt: Text? = nil, description: Text? = nil, searchDelay: Duration = .milliseconds(300),
        isReadOnly: Bool = false, isLabelHidden: Bool = false, onSearch: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            context: QeetrixFieldContext(label: label, description: description), isLabelHidden: isLabelHidden, text: text, prompt: prompt,
            searchDelay: searchDelay, isReadOnly: isReadOnly, onSearch: onSearch)
    }

    init(
        context: QeetrixFieldContext, isLabelHidden: Bool, text: Binding<String>, prompt: Text?, searchDelay: Duration, isReadOnly: Bool,
        onSearch: (@MainActor (String) -> Void)?
    ) {
        self.context = context
        self.isLabelHidden = isLabelHidden
        self.text = text
        self.prompt = prompt
        self.searchDelay = searchDelay
        self.isReadOnly = isReadOnly
        self.onSearch = onSearch
    }

    public var body: some View {
        QeetrixFieldLayout(context: context, isOptional: false, isLabelHidden: isLabelHidden) {
            QeetrixSearchInput(text: text, prompt: prompt, searchDelay: searchDelay, isReadOnly: isReadOnly, onSearch: onSearch)
        }
    }
}

/// The Input box around a SwiftUI `TextField`: the search icon, the text and the clear button.
struct QeetrixSearchInput: View {
    let text: Binding<String>
    let prompt: Text?
    let searchDelay: Duration
    let isReadOnly: Bool
    let onSearch: (@MainActor (String) -> Void)?

    @State private var search = QeetrixSearchState()
    @FocusState private var isFocused: Bool
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixFieldContext) private var context

    var body: some View {
        let state = QeetrixInputState(
            isEnabled: isEnabled, isReadOnly: isReadOnly, isFocused: isFocused, isHovered: isHovered, isInvalid: context?.invalid ?? false)
        HStack(spacing: QeetrixInputMetrics.gap) {
            QeetrixIcon(.search, size: .sm, shape: .sharp)
                .foregroundStyle(isEnabled ? QeetrixColor.iconSubtle : QeetrixColor.iconDisabled)
            field
            if QeetrixSearchState.canClear(text.wrappedValue, isEnabled: isEnabled, isReadOnly: isReadOnly) {
                QeetrixIconButton(.x, label: QeetrixSearchFieldStrings.clear, tone: .neutral, size: .sm) {
                    clear()
                    isFocused = true
                }
            }
        }
        .qeetrixTypeEnvironment(QeetrixInputMetrics.textType)
        .padding(.leading, QeetrixInputMetrics.padding)
        // search-field.css `.qx-search-field { padding-inline-end: space.gap.xs }`: room for the clear button.
        .padding(.trailing, QeetrixSpace.gapXs)
        .qeetrixControlBlockSize(QeetrixInputMetrics.height(density), type: QeetrixInputMetrics.textType)
        .qeetrixInputSurface(state)
        // A 44 pt target, as the text field's: a tap on the padding or the icon focuses the field.
        .qeetrixHitArea()
        .simultaneousGesture(
            TapGesture().onEnded {
                if isEnabled && !isReadOnly { isFocused = true }
            }
        )
        .onHover { isHovered = $0 }
        .task(id: search.pending) {
            guard let pending = search.pending else { return }
            try? await Task.sleep(for: searchDelay)
            guard !Task.isCancelled, let query = search.pauseEnded(pending) else { return }
            onSearch?(query)
        }
    }

    @ViewBuilder
    private var field: some View {
        if isReadOnly {
            Text(verbatim: text.wrappedValue)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .ignore)
                .qeetrixFieldControlAccessibility()
                .accessibilityValue(Text(verbatim: text.wrappedValue))
                .accessibilityAddTraits(.isSearchField)
        } else {
            TextField(text: typing, prompt: (prompt ?? Text(verbatim: "")).foregroundStyle(QeetrixInputMetrics.placeholder)) {
                context?.label ?? QeetrixSearchFieldStrings.search
            }
            .tint(QeetrixColor.borderFocus)
            .focused($isFocused)
            .submitLabel(.search)
            #if os(iOS)
                .textInputAutocapitalization(.never)
            #endif
            .onSubmit { searchNow(text.wrappedValue) }
            .onKeyPress(.escape) {
                guard QeetrixSearchState.canClear(text.wrappedValue, isEnabled: isEnabled, isReadOnly: isReadOnly) else { return .ignored }
                clear()
                return .handled
            }
            .qeetrixFieldControlAccessibility()
            .accessibilityAddTraits(.isSearchField)
        }
    }

    /// The binding the text field edits: typing writes your binding and waits for a pause; your own writes
    /// to the binding don't come through here, so they are never searched.
    private var typing: Binding<String> {
        Binding(
            get: { text.wrappedValue },
            set: { newValue in
                guard newValue != text.wrappedValue else { return }
                text.wrappedValue = newValue
                search.typed(newValue)
            })
    }

    private func clear() {
        text.wrappedValue = ""
        searchNow("")
    }

    private func searchNow(_ query: String) {
        onSearch?(search.searchNow(query))
    }
}

/// A search waiting for typing to pause. Each keystroke makes a new one, so typing the same text again
/// still restarts the wait.
struct QeetrixPendingSearch: Hashable, Sendable {
    let query: String
    let generation: Int
}

/// When a search runs: the lifecycle of `onSearch`, as a value, apart from the view. Shared by
/// ``QeetrixSearchField`` and `qeetrixSearchable`.
struct QeetrixSearchState: Equatable, Sendable {
    /// The search waiting for typing to pause, if any.
    private(set) var pending: QeetrixPendingSearch?
    private var generation = 0

    /// Typing: the search waits for a pause, replacing any search already waiting.
    mutating func typed(_ text: String) {
        generation += 1
        pending = QeetrixPendingSearch(query: text, generation: generation)
    }

    /// The search key, or clearing: the query runs now, and nothing waits any longer.
    mutating func searchNow(_ query: String) -> String {
        pending = nil
        return query
    }

    /// The pause after `search` is over: its query, if it is still the one waiting.
    mutating func pauseEnded(_ search: QeetrixPendingSearch) -> String? {
        guard pending == search else { return nil }
        pending = nil
        return search.query
    }

    /// Whether the clear button shows, and Escape clears: there is text and the field can be edited.
    static func canClear(_ text: String, isEnabled: Bool, isReadOnly: Bool) -> Bool {
        !text.isEmpty && isEnabled && !isReadOnly
    }
}

/// The search field's built-in strings: `@qeetrix/react`'s `searchField.clear`, and the field's name
/// without a label (Android's `qx_search`). The keys sit beside `Resources/Localization`'s; until a
/// translation adds them, the English defaults here are shown.
enum QeetrixSearchFieldStrings {
    /// "Search" — the field's name when it has no label.
    static var searchString: String {
        String(localized: "qeetrix.search-field.label", defaultValue: "Search", bundle: .module)
    }

    /// "Clear search" — `searchField.clear`.
    static var clearString: String {
        String(localized: "qeetrix.search-field.clear", defaultValue: "Clear search", bundle: .module)
    }

    static var search: Text { Text(searchString) }
    static var clear: Text { Text(clearString) }
}
