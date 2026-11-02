import SwiftUI

/// One option of a ``QeetrixCombobox`` — `@qeetrix/react`'s `ComboboxItem`: the value it chooses, the
/// label shown and searched, an optional second line, and whether it can be chosen.
///
/// ```swift
/// let owners = members.map { QeetrixComboboxItem($0.name, value: $0.id, description: $0.email) }
/// ```
///
/// The label is what a search matches, so it is a `String`, already in the person's language. The value
/// has the selection's type, so an option can only choose a value the binding can hold.
public struct QeetrixComboboxItem<Value: Hashable>: Identifiable {
    /// What the selection holds when this option is chosen: an ID, such as a user's.
    public let value: Value
    /// Shown, and matched against what's typed.
    public let label: String
    /// A second, quieter line under the label — an email, a code. It isn't searched.
    public let description: String?
    /// Shown, but can't be chosen.
    public let isDisabled: Bool

    /// The value, which identifies the option: give each option its own.
    public var id: Value { value }

    /// An option shown as `label`; choosing it puts `value` in the selection.
    public init<S: StringProtocol>(_ label: S, value: Value, description: String? = nil, isDisabled: Bool = false) {
        self.value = value
        self.label = String(label)
        self.description = description
        self.isDisabled = isDisabled
    }
}

/// Options under a heading — `@qeetrix/react`'s `ComboboxItemGroup`, drawn as a ``QeetrixSectionHeader``
/// above its rows.
public struct QeetrixComboboxGroup<Value: Hashable>: Identifiable {
    /// The heading above the group's options, in sentence case: "Asia".
    public let label: String
    /// The options in the group.
    public let items: [QeetrixComboboxItem<Value>]

    /// The heading, which identifies the group: give each group its own.
    public var id: String { label }

    /// A group of `items` under the heading `label`.
    public init<S: StringProtocol>(_ label: S, items: [QeetrixComboboxItem<Value>]) {
        self.label = String(label)
        self.items = items
    }
}

/// The words a ``QeetrixCombobox`` shows, to replace its built-in ones — `@qeetrix/react`'s `messages`
/// for `combobox`. Any left `nil` keep their default.
public struct QeetrixComboboxMessages {
    /// When nothing matches what's typed: "No matches". Announced, so it's a `String`.
    public var empty: String?
    /// While `isLoading`: "Searching…". Announced.
    public var loading: String?
    /// The trigger's value with several options chosen: "3 selected".
    public var selected: ((Int) -> String)?
    /// The button that closes a sheet of several choices: "Done".
    public var done: Text?

    /// The words to replace.
    public init(empty: String? = nil, loading: String? = nil, selected: ((Int) -> String)? = nil, done: Text? = nil) {
        self.empty = empty
        self.loading = loading
        self.selected = selected
        self.done = done
    }
}

/// Pick from a long list — dozens to thousands of options — by searching it: `@qeetrix/react`'s
/// Combobox on a phone, behind ``QeetrixSelect``'s trigger, with its label, help text and error.
///
/// ```swift
/// QeetrixCombobox("Country", selection: $country, items: countries, placeholder: Text("e.g. India"))
/// QeetrixCombobox("Languages", selection: $languages, groups: languageGroups)
/// ```
///
/// - **The trigger** is the Select's (design rules §8): the filled field with its bottom line, the
///   choice in `body.md` or the placeholder in `color.text.subtlest`, and a trailing 16 pt sharp
///   chevron. While the sheet is open it shows the Ember frame, as the web's open list does.
/// - **Tapping it** presents a sheet (ADR 0014): the label as its title, a ``QeetrixSearchField``, and
///   the options as ``QeetrixListItem`` rows — under a ``QeetrixSectionHeader`` for each group — the
///   chosen ones with a sharp `check` in `color.icon.brand`, read as selected. A search matches an
///   option whose label contains what's typed, ignoring case, accents and width, as the environment's
///   locale compares letters. When nothing matches, a ``QeetrixEmptyState`` says "No matches".
/// - **One choice** (`selection: Binding<Value>`): choosing an option sets it and closes the sheet.
///   "Nothing chosen" is a value no option has, such as `nil`.
/// - **Several** (`selection: Binding<Set<Value>>`): each tap adds or removes an option, and Done
///   closes the sheet. The trigger shows the option's label, or "3 selected" once there are more.
/// - **On a server.** For a directory too large to send whole, `onSearch` runs once typing pauses
///   (`searchDelay`, 300 ms) and with "" when the search is cleared; pass its results as the options,
///   which are then shown as given, and `isLoading` while they're on the way ("Searching…"). A chosen
///   option keeps its label in the trigger when new results leave it out.
///
/// The sheet is presented by state the combobox owns; pass `isPresented` to open or close it yourself.
public struct QeetrixCombobox<Value: Hashable>: View {
    let context: QeetrixFieldContext
    let isOptional: Bool
    let selection: QeetrixComboboxSelection<Value>
    let sections: [QeetrixComboboxSection<Value>]
    let placeholder: Text?
    let searchPrompt: Text?
    let isReadOnly: Bool
    let isLoading: Bool
    let isPresented: Binding<Bool>?
    let messages: QeetrixComboboxMessages
    let searchDelay: Duration
    let onSearch: (@MainActor (String) -> Void)?
    @State private var isPresentedState = false
    @State private var knownLabels: [Value: String] = [:]
    @Environment(\.locale) private var locale

    init(
        label: Text, selection: QeetrixComboboxSelection<Value>, sections: [QeetrixComboboxSection<Value>], placeholder: Text?,
        searchPrompt: Text?, description: Text?, error: String?, isRequired: Bool, isOptional: Bool, isReadOnly: Bool, isLoading: Bool,
        isPresented: Binding<Bool>?, messages: QeetrixComboboxMessages, searchDelay: Duration, onSearch: (@MainActor (String) -> Void)?
    ) {
        context = QeetrixFieldContext(label: label, description: description, error: error, isRequired: isRequired)
        self.isOptional = isOptional
        self.selection = selection
        self.sections = sections
        self.placeholder = placeholder
        self.searchPrompt = searchPrompt
        self.isReadOnly = isReadOnly
        self.isLoading = isLoading
        self.isPresented = isPresented
        self.messages = messages
        self.searchDelay = searchDelay
        self.onSearch = onSearch
    }

    public var body: some View {
        let presented = isPresented ?? $isPresentedState
        let summary = QeetrixComboboxSummary(
            selection: selection, sections: sections, knownLabels: knownLabels, messages: messages, locale: locale)
        QeetrixFieldLayout(context: context, isOptional: isOptional) {
            QeetrixComboboxTrigger(
                value: summary.text.map { Text(verbatim: $0) }, placeholder: placeholder,
                accessibilityValue: Text(verbatim: summary.accessibilityValue ?? ""), isOpen: presented.wrappedValue, isReadOnly: isReadOnly
            ) {
                presented.wrappedValue = true
            }
        }
        .qeetrixSheet(isPresented: presented) {
            QeetrixComboboxSheet(
                title: context.label, sections: sections, selection: selection, searchPrompt: searchPrompt, isLoading: isLoading,
                messages: messages, searchDelay: searchDelay, onSearch: onSearch)
        }
        // With server search the options change under the trigger: remember every label seen, so a choice
        // that a new search leaves out still shows by name (react's Combobox does the same).
        .onChange(of: labelsToRemember, initial: true) { _, labels in
            knownLabels.merge(labels) { _, new in new }
        }
    }

    /// The labels of the options on hand, kept only while the options come from a server search.
    var labelsToRemember: [Value: String] {
        guard onSearch != nil else { return [:] }
        return Dictionary(sections.flatMap(\.items).map { ($0.value, $0.label) }) { first, _ in first }
    }
}

/// What the trigger says, worked out apart from the view: the chosen options' labels, the text and
/// the VoiceOver value.
struct QeetrixComboboxSummary<Value: Hashable> {
    let selection: QeetrixComboboxSelection<Value>
    let sections: [QeetrixComboboxSection<Value>]
    /// Labels seen in earlier server results.
    var knownLabels: [Value: String] = [:]
    var messages = QeetrixComboboxMessages()
    let locale: Locale

    /// The label of the option with `value`, from the options on hand or the ones seen before.
    func label(of value: Value) -> String? {
        for section in sections {
            if let item = section.items.first(where: { $0.value == value }) { return item.label }
        }
        return knownLabels[value]
    }

    /// The chosen options' labels, in the options' order, then any known only from earlier results.
    var chosenLabels: [String] {
        switch selection {
        case let .single(binding):
            return label(of: binding.wrappedValue).map { [$0] } ?? []
        case let .multiple(binding):
            let chosen = binding.wrappedValue
            var labels: [String] = []
            var found: Set<Value> = []
            for item in sections.flatMap(\.items) where chosen.contains(item.value) && !found.contains(item.value) {
                labels.append(item.label)
                found.insert(item.value)
            }
            return labels + chosen.subtracting(found).compactMap { knownLabels[$0] }.sorted()
        }
    }

    /// The trigger's text: the chosen option's label; with several chosen, "3 selected"; `nil` for the
    /// placeholder.
    var text: String? {
        switch selection {
        case .single:
            return chosenLabels.first
        case let .multiple(binding):
            let count = binding.wrappedValue.count
            if count == 0 { return nil }
            if count == 1, let only = chosenLabels.first { return only }
            return messages.selected?(count) ?? QeetrixComboboxStrings.selected(count, locale: locale)
        }
    }

    /// The trigger's VoiceOver value: its text, then — with several chosen — their labels as a list.
    var accessibilityValue: String? {
        guard let text else { return nil }
        guard case let .multiple(binding) = selection, binding.wrappedValue.count > 1 else { return text }
        return text + ", " + chosenLabels.formatted(.list(type: .and).locale(locale))
    }
}

// MARK: - One choice

extension QeetrixCombobox {
    /// A combobox for one choice, with a localised label.
    public init(
        _ titleKey: LocalizedStringKey, selection: Binding<Value>, items: [QeetrixComboboxItem<Value>], placeholder: Text? = nil,
        searchPrompt: Text? = nil, description: Text? = nil, error: String? = nil, isRequired: Bool = false, isOptional: Bool = false,
        isReadOnly: Bool = false, isLoading: Bool = false, isPresented: Binding<Bool>? = nil,
        messages: QeetrixComboboxMessages = QeetrixComboboxMessages(), searchDelay: Duration = .milliseconds(300),
        onSearch: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: Text(titleKey), selection: .single(selection), sections: [QeetrixComboboxSection(items)], placeholder: placeholder,
            searchPrompt: searchPrompt, description: description, error: error, isRequired: isRequired, isOptional: isOptional,
            isReadOnly: isReadOnly, isLoading: isLoading, isPresented: isPresented, messages: messages, searchDelay: searchDelay,
            onSearch: onSearch)
    }

    /// A combobox for one choice, with a label shown as given.
    public init<S: StringProtocol>(
        _ title: S, selection: Binding<Value>, items: [QeetrixComboboxItem<Value>], placeholder: Text? = nil, searchPrompt: Text? = nil,
        description: Text? = nil, error: String? = nil, isRequired: Bool = false, isOptional: Bool = false, isReadOnly: Bool = false,
        isLoading: Bool = false, isPresented: Binding<Bool>? = nil, messages: QeetrixComboboxMessages = QeetrixComboboxMessages(),
        searchDelay: Duration = .milliseconds(300), onSearch: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: Text(title), selection: .single(selection), sections: [QeetrixComboboxSection(items)], placeholder: placeholder,
            searchPrompt: searchPrompt, description: description, error: error, isRequired: isRequired, isOptional: isOptional,
            isReadOnly: isReadOnly, isLoading: isLoading, isPresented: isPresented, messages: messages, searchDelay: searchDelay,
            onSearch: onSearch)
    }

    /// A combobox for one choice, with a `Text` label.
    ///
    /// - Parameters:
    ///   - label: Names the field, titles its sheet, and names the trigger for VoiceOver.
    ///   - selection: The chosen option's value. "Nothing chosen" is a value no option has, such as `nil`.
    ///   - items: The options, in the order shown.
    ///   - placeholder: Shown while nothing is chosen: an example ("e.g. India"), never an instruction.
    ///   - searchPrompt: The search field's example, shown while it's empty ("e.g. Germany").
    ///   - description: Help under the trigger, read by VoiceOver as its hint.
    ///   - error: What to fix, already localised. It marks the trigger invalid and replaces the description.
    ///   - isRequired: Tells VoiceOver the field is required.
    ///   - isOptional: Appends "(optional)" to the label.
    ///   - isReadOnly: Shows the choice without the fill, and doesn't open.
    ///   - isLoading: Results are on the way: "Searching…" heads the list, and "No matches" waits.
    ///   - isPresented: Opens and closes the sheet from outside; without it the combobox keeps its own.
    ///   - messages: Replaces the built-in words.
    ///   - searchDelay: How long typing must pause before `onSearch` runs.
    ///   - onSearch: Searches elsewhere — a server: the options are then shown as given.
    public init(
        label: Text, selection: Binding<Value>, items: [QeetrixComboboxItem<Value>], placeholder: Text? = nil, searchPrompt: Text? = nil,
        description: Text? = nil, error: String? = nil, isRequired: Bool = false, isOptional: Bool = false, isReadOnly: Bool = false,
        isLoading: Bool = false, isPresented: Binding<Bool>? = nil, messages: QeetrixComboboxMessages = QeetrixComboboxMessages(),
        searchDelay: Duration = .milliseconds(300), onSearch: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: label, selection: .single(selection), sections: [QeetrixComboboxSection(items)], placeholder: placeholder,
            searchPrompt: searchPrompt, description: description, error: error, isRequired: isRequired, isOptional: isOptional,
            isReadOnly: isReadOnly, isLoading: isLoading, isPresented: isPresented, messages: messages, searchDelay: searchDelay,
            onSearch: onSearch)
    }

    /// A combobox for one choice from options in groups, with a localised label.
    public init(
        _ titleKey: LocalizedStringKey, selection: Binding<Value>, groups: [QeetrixComboboxGroup<Value>], placeholder: Text? = nil,
        searchPrompt: Text? = nil, description: Text? = nil, error: String? = nil, isRequired: Bool = false, isOptional: Bool = false,
        isReadOnly: Bool = false, isLoading: Bool = false, isPresented: Binding<Bool>? = nil,
        messages: QeetrixComboboxMessages = QeetrixComboboxMessages(), searchDelay: Duration = .milliseconds(300),
        onSearch: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: Text(titleKey), selection: .single(selection), sections: groups.map(QeetrixComboboxSection.init),
            placeholder: placeholder, searchPrompt: searchPrompt, description: description, error: error, isRequired: isRequired,
            isOptional: isOptional, isReadOnly: isReadOnly, isLoading: isLoading, isPresented: isPresented, messages: messages,
            searchDelay: searchDelay, onSearch: onSearch)
    }

    /// A combobox for one choice from options in groups, with a label shown as given.
    public init<S: StringProtocol>(
        _ title: S, selection: Binding<Value>, groups: [QeetrixComboboxGroup<Value>], placeholder: Text? = nil, searchPrompt: Text? = nil,
        description: Text? = nil, error: String? = nil, isRequired: Bool = false, isOptional: Bool = false, isReadOnly: Bool = false,
        isLoading: Bool = false, isPresented: Binding<Bool>? = nil, messages: QeetrixComboboxMessages = QeetrixComboboxMessages(),
        searchDelay: Duration = .milliseconds(300), onSearch: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: Text(title), selection: .single(selection), sections: groups.map(QeetrixComboboxSection.init), placeholder: placeholder,
            searchPrompt: searchPrompt, description: description, error: error, isRequired: isRequired, isOptional: isOptional,
            isReadOnly: isReadOnly, isLoading: isLoading, isPresented: isPresented, messages: messages, searchDelay: searchDelay,
            onSearch: onSearch)
    }

    /// A combobox for one choice from options in groups, with a `Text` label.
    public init(
        label: Text, selection: Binding<Value>, groups: [QeetrixComboboxGroup<Value>], placeholder: Text? = nil, searchPrompt: Text? = nil,
        description: Text? = nil, error: String? = nil, isRequired: Bool = false, isOptional: Bool = false, isReadOnly: Bool = false,
        isLoading: Bool = false, isPresented: Binding<Bool>? = nil, messages: QeetrixComboboxMessages = QeetrixComboboxMessages(),
        searchDelay: Duration = .milliseconds(300), onSearch: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: label, selection: .single(selection), sections: groups.map(QeetrixComboboxSection.init), placeholder: placeholder,
            searchPrompt: searchPrompt, description: description, error: error, isRequired: isRequired, isOptional: isOptional,
            isReadOnly: isReadOnly, isLoading: isLoading, isPresented: isPresented, messages: messages, searchDelay: searchDelay,
            onSearch: onSearch)
    }
}

// MARK: - Several choices

extension QeetrixCombobox {
    /// A combobox for several choices, with a localised label.
    public init(
        _ titleKey: LocalizedStringKey, selection: Binding<Set<Value>>, items: [QeetrixComboboxItem<Value>], placeholder: Text? = nil,
        searchPrompt: Text? = nil, description: Text? = nil, error: String? = nil, isRequired: Bool = false, isOptional: Bool = false,
        isReadOnly: Bool = false, isLoading: Bool = false, isPresented: Binding<Bool>? = nil,
        messages: QeetrixComboboxMessages = QeetrixComboboxMessages(), searchDelay: Duration = .milliseconds(300),
        onSearch: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: Text(titleKey), selection: .multiple(selection), sections: [QeetrixComboboxSection(items)], placeholder: placeholder,
            searchPrompt: searchPrompt, description: description, error: error, isRequired: isRequired, isOptional: isOptional,
            isReadOnly: isReadOnly, isLoading: isLoading, isPresented: isPresented, messages: messages, searchDelay: searchDelay,
            onSearch: onSearch)
    }

    /// A combobox for several choices, with a label shown as given.
    public init<S: StringProtocol>(
        _ title: S, selection: Binding<Set<Value>>, items: [QeetrixComboboxItem<Value>], placeholder: Text? = nil,
        searchPrompt: Text? = nil, description: Text? = nil, error: String? = nil, isRequired: Bool = false, isOptional: Bool = false,
        isReadOnly: Bool = false, isLoading: Bool = false, isPresented: Binding<Bool>? = nil,
        messages: QeetrixComboboxMessages = QeetrixComboboxMessages(), searchDelay: Duration = .milliseconds(300),
        onSearch: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: Text(title), selection: .multiple(selection), sections: [QeetrixComboboxSection(items)], placeholder: placeholder,
            searchPrompt: searchPrompt, description: description, error: error, isRequired: isRequired, isOptional: isOptional,
            isReadOnly: isReadOnly, isLoading: isLoading, isPresented: isPresented, messages: messages, searchDelay: searchDelay,
            onSearch: onSearch)
    }

    /// A combobox for several choices, with a `Text` label: each tap in the sheet adds or removes an
    /// option, and Done closes it.
    public init(
        label: Text, selection: Binding<Set<Value>>, items: [QeetrixComboboxItem<Value>], placeholder: Text? = nil,
        searchPrompt: Text? = nil, description: Text? = nil, error: String? = nil, isRequired: Bool = false, isOptional: Bool = false,
        isReadOnly: Bool = false, isLoading: Bool = false, isPresented: Binding<Bool>? = nil,
        messages: QeetrixComboboxMessages = QeetrixComboboxMessages(), searchDelay: Duration = .milliseconds(300),
        onSearch: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: label, selection: .multiple(selection), sections: [QeetrixComboboxSection(items)], placeholder: placeholder,
            searchPrompt: searchPrompt, description: description, error: error, isRequired: isRequired, isOptional: isOptional,
            isReadOnly: isReadOnly, isLoading: isLoading, isPresented: isPresented, messages: messages, searchDelay: searchDelay,
            onSearch: onSearch)
    }

    /// A combobox for several choices from options in groups, with a localised label.
    public init(
        _ titleKey: LocalizedStringKey, selection: Binding<Set<Value>>, groups: [QeetrixComboboxGroup<Value>], placeholder: Text? = nil,
        searchPrompt: Text? = nil, description: Text? = nil, error: String? = nil, isRequired: Bool = false, isOptional: Bool = false,
        isReadOnly: Bool = false, isLoading: Bool = false, isPresented: Binding<Bool>? = nil,
        messages: QeetrixComboboxMessages = QeetrixComboboxMessages(), searchDelay: Duration = .milliseconds(300),
        onSearch: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: Text(titleKey), selection: .multiple(selection), sections: groups.map(QeetrixComboboxSection.init),
            placeholder: placeholder, searchPrompt: searchPrompt, description: description, error: error, isRequired: isRequired,
            isOptional: isOptional, isReadOnly: isReadOnly, isLoading: isLoading, isPresented: isPresented, messages: messages,
            searchDelay: searchDelay, onSearch: onSearch)
    }

    /// A combobox for several choices from options in groups, with a label shown as given.
    public init<S: StringProtocol>(
        _ title: S, selection: Binding<Set<Value>>, groups: [QeetrixComboboxGroup<Value>], placeholder: Text? = nil,
        searchPrompt: Text? = nil, description: Text? = nil, error: String? = nil, isRequired: Bool = false, isOptional: Bool = false,
        isReadOnly: Bool = false, isLoading: Bool = false, isPresented: Binding<Bool>? = nil,
        messages: QeetrixComboboxMessages = QeetrixComboboxMessages(), searchDelay: Duration = .milliseconds(300),
        onSearch: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: Text(title), selection: .multiple(selection), sections: groups.map(QeetrixComboboxSection.init),
            placeholder: placeholder, searchPrompt: searchPrompt, description: description, error: error, isRequired: isRequired,
            isOptional: isOptional, isReadOnly: isReadOnly, isLoading: isLoading, isPresented: isPresented, messages: messages,
            searchDelay: searchDelay, onSearch: onSearch)
    }

    /// A combobox for several choices from options in groups, with a `Text` label.
    public init(
        label: Text, selection: Binding<Set<Value>>, groups: [QeetrixComboboxGroup<Value>], placeholder: Text? = nil,
        searchPrompt: Text? = nil, description: Text? = nil, error: String? = nil, isRequired: Bool = false, isOptional: Bool = false,
        isReadOnly: Bool = false, isLoading: Bool = false, isPresented: Binding<Bool>? = nil,
        messages: QeetrixComboboxMessages = QeetrixComboboxMessages(), searchDelay: Duration = .milliseconds(300),
        onSearch: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            label: label, selection: .multiple(selection), sections: groups.map(QeetrixComboboxSection.init), placeholder: placeholder,
            searchPrompt: searchPrompt, description: description, error: error, isRequired: isRequired, isOptional: isOptional,
            isReadOnly: isReadOnly, isLoading: isLoading, isPresented: isPresented, messages: messages, searchDelay: searchDelay,
            onSearch: onSearch)
    }
}

// MARK: - The trigger

/// ``QeetrixSelect``'s trigger as a button that opens the sheet: the field box, the value or the
/// placeholder on one line, and the trailing sharp chevron (select.css `.qx-select-trigger`).
struct QeetrixComboboxTrigger: View {
    let value: Text?
    let placeholder: Text?
    let accessibilityValue: Text
    let isOpen: Bool
    let isReadOnly: Bool
    let action: @MainActor () -> Void
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixFieldContext) private var context

    var body: some View {
        // `[data-popup-open]` draws the focus frame, as `:focus-visible` does.
        let state = QeetrixInputState(
            isEnabled: isEnabled, isReadOnly: isReadOnly, isFocused: (isFocused || isOpen) && !isReadOnly,
            isHovered: isHovered && !isReadOnly, isInvalid: context?.invalid ?? false)
        let type = QeetrixInputMetrics.textType
        Button(action: action) {
            HStack(spacing: QeetrixInputMetrics.gap) {
                ZStack(alignment: .leading) {
                    // A hidden line keeps an empty trigger one line tall at every text size.
                    Text(verbatim: "X").hidden()
                    (value ?? placeholder ?? Text(verbatim: ""))
                        .foregroundStyle(value == nil ? QeetrixInputMetrics.placeholder : state.foreground)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                QeetrixIcon(.chevronDown, size: .sm, shape: .sharp)
                    .foregroundStyle(isEnabled ? QeetrixColor.iconDefault : QeetrixColor.iconDisabled)
            }
            .qeetrixTypeEnvironment(type)
            .padding(.horizontal, QeetrixInputMetrics.padding)
            .qeetrixControlBlockSize(QeetrixInputMetrics.height(density), type: type)
            .qeetrixInputSurface(state)
            .contentShape(Rectangle())
        }
        .buttonStyle(QeetrixPlainControlStyle())
        .disabled(isReadOnly)
        .qeetrixHitArea()
        .onHover { isHovered = $0 }
        .qeetrixFieldControlAccessibility()
        .accessibilityValue(value == nil ? (placeholder ?? Text(verbatim: "")) : accessibilityValue)
    }
}

// MARK: - Parts

/// Which values are chosen, and how: one, or a set.
enum QeetrixComboboxSelection<Value: Hashable> {
    case single(Binding<Value>)
    case multiple(Binding<Set<Value>>)

    var isMultiple: Bool {
        if case .multiple = self { return true }
        return false
    }

    func contains(_ value: Value) -> Bool {
        switch self {
        case let .single(binding): binding.wrappedValue == value
        case let .multiple(binding): binding.wrappedValue.contains(value)
        }
    }

    /// Chooses `value`: sets it, or adds it to the set or takes it out.
    func choose(_ value: Value) {
        switch self {
        case let .single(binding):
            binding.wrappedValue = value
        case let .multiple(binding):
            if binding.wrappedValue.contains(value) {
                binding.wrappedValue.remove(value)
            } else {
                binding.wrappedValue.insert(value)
            }
        }
    }
}

/// A group of options as the sheet lists them: flat options are one group without a heading.
struct QeetrixComboboxSection<Value: Hashable>: Identifiable {
    let label: String?
    let items: [QeetrixComboboxItem<Value>]

    var id: String { label ?? "" }

    init(label: String?, items: [QeetrixComboboxItem<Value>]) {
        self.label = label
        self.items = items
    }

    init(_ items: [QeetrixComboboxItem<Value>]) {
        self.init(label: nil, items: items)
    }

    init(_ group: QeetrixComboboxGroup<Value>) {
        self.init(label: group.label, items: group.items)
    }
}

/// How an option matches what's typed — react's default filter: the label contains the text, ignoring
/// case and accents, as the locale compares them (and, on iOS, full- and half-width forms too).
enum QeetrixComboboxFilter {
    /// `text` folded for comparison: lower case by the locale's rules first (Turkish `İ` is `i`), then
    /// without accents, case or width.
    static func fold(_ text: String, locale: Locale) -> String {
        text.lowercased(with: locale).folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: locale)
    }

    /// Whether `label` contains `query`. The comparison is of code units, not characters, so a query
    /// that ends inside a conjunct — "हिन" of "हिन्दी" — still matches, as it does on the web.
    static func matches(_ label: String, query: String, locale: Locale) -> Bool {
        let needle = fold(query.trimmingCharacters(in: .whitespacesAndNewlines), locale: locale)
        return needle.isEmpty || contains(fold(label, locale: locale), needle)
    }

    /// The groups with only their matching options, and without the groups left empty.
    static func sections<Value>(
        _ sections: [QeetrixComboboxSection<Value>], matching query: String, locale: Locale
    )
        -> [QeetrixComboboxSection<Value>]
    {
        let needle = fold(query.trimmingCharacters(in: .whitespacesAndNewlines), locale: locale)
        return sections.compactMap { section in
            let items = needle.isEmpty ? section.items : section.items.filter { contains(fold($0.label, locale: locale), needle) }
            return items.isEmpty ? nil : QeetrixComboboxSection(label: section.label, items: items)
        }
    }

    private static func contains(_ folded: String, _ needle: String) -> Bool {
        (folded as NSString).range(of: needle, options: .literal).location != NSNotFound
    }
}

/// The combobox's built-in strings: `@qeetrix/react`'s `combobox` messages, and the sheet's Done.
enum QeetrixComboboxStrings {
    /// "No matches" — `combobox.empty`.
    static var empty: String {
        String(localized: "qeetrix.combobox.empty", defaultValue: "No matches", bundle: .module)
    }

    /// "Searching…" — `combobox.loading`.
    static var loading: String {
        String(localized: "qeetrix.combobox.loading", defaultValue: "Searching…", bundle: .module)
    }

    /// "3 selected" — `combobox.selected`, its first sentence; the count in the locale's digits.
    static func selected(_ count: Int, locale: Locale) -> String {
        String(localized: "qeetrix.combobox.selected", defaultValue: "\(count) selected", bundle: .module, locale: locale)
    }

    /// "Done" — iOS only: the web's list closes when focus leaves it.
    static var done: Text { Text("qeetrix.combobox.done", bundle: .module) }
}
