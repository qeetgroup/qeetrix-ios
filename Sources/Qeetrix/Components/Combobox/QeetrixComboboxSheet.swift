import Accessibility
import SwiftUI

/// The combobox's sheet: a ruled header with the field's label, the close control and the search field,
/// then the options as list rows, or the empty state when nothing matches.
///
/// The header and rows share the rows' 16 pt gutter (`space.inset.lg`), so the title, the search box,
/// the group labels and the option labels line up; the rest is the drawer's (drawer.css): `title.md`,
/// a 1 pt `color.border.subtle` rule under the header, the sheet's `color.surface.overlay`.
struct QeetrixComboboxSheet<Value: Hashable>: View {
    let title: Text
    let sections: [QeetrixComboboxSection<Value>]
    let selection: QeetrixComboboxSelection<Value>
    let searchPrompt: Text?
    let isLoading: Bool
    let messages: QeetrixComboboxMessages
    let searchDelay: Duration
    let onSearch: (@MainActor (String) -> Void)?
    @State private var query: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale

    init(
        title: Text, sections: [QeetrixComboboxSection<Value>], selection: QeetrixComboboxSelection<Value>, searchPrompt: Text?,
        isLoading: Bool, messages: QeetrixComboboxMessages, searchDelay: Duration, onSearch: (@MainActor (String) -> Void)?,
        query: String = ""
    ) {
        self.title = title
        self.sections = sections
        self.selection = selection
        self.searchPrompt = searchPrompt
        self.isLoading = isLoading
        self.messages = messages
        self.searchDelay = searchDelay
        self.onSearch = onSearch
        _query = State(initialValue: query)
    }

    /// The options shown: the ones matching the query, or — with `onSearch`, whose results they are —
    /// all of them, as given.
    var shown: [QeetrixComboboxSection<Value>] {
        QeetrixComboboxFilter.sections(sections, matching: onSearch == nil ? query : "", locale: locale)
    }

    var body: some View {
        let shown = self.shown
        let isEmpty = shown.isEmpty && !isLoading
        VStack(spacing: 0) {
            header
            QeetrixSheetRule()
            if isEmpty {
                ScrollView {
                    QeetrixEmptyState(title: Text(verbatim: emptyText), icon: .search, size: .section)
                }
                .scrollDismissesKeyboard(.immediately)
            } else {
                QeetrixComboboxResults(sections: shown, selection: selection, loading: isLoading ? loadingText : nil) { item in
                    selection.choose(item.value)
                    if !selection.isMultiple { dismiss() }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .qeetrixTypeEnvironment(QeetrixTypeSpec(.bodyMd))
        // react's Combobox.Status and Empty are live regions: say when a search is on its way, and when
        // what's typed matches nothing.
        .onChange(of: isLoading) { _, loading in
            if loading { AccessibilityNotification.Announcement(loadingText).post() }
        }
        .onChange(of: isEmpty) { _, empty in
            if empty { AccessibilityNotification.Announcement(emptyText).post() }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) {
            HStack(alignment: .top, spacing: QeetrixSpace.gapSm) {
                title
                    .qeetrixTextStyle(.titleMd)
                    .foregroundStyle(QeetrixColor.textDefault)
                    .accessibilityAddTraits(.isHeader)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                // The 28 pt control centred on the title's 24 pt line, as the sheet's close button is.
                if selection.isMultiple {
                    QeetrixButton(title: messages.done ?? QeetrixComboboxStrings.done, variant: .ghost, size: .sm) { dismiss() }
                        .padding(.vertical, -2)
                } else {
                    QeetrixIconButton(.x, label: QeetrixStrings.close, tone: .neutral, size: .sm) { dismiss() }
                        .padding(.vertical, -2)
                }
            }
            QeetrixSearchField(text: $query, prompt: searchPrompt, searchDelay: searchDelay, onSearch: onSearch)
        }
        .padding(QeetrixListItemMetrics.inlinePadding)
    }

    private var emptyText: String { messages.empty ?? QeetrixComboboxStrings.empty }
    private var loadingText: String { messages.loading ?? QeetrixComboboxStrings.loading }
}

/// The options as rows — a lazy stack, so a list of thousands draws only what's on screen — under their
/// groups' headers, which stay pinned while their rows scroll. Opens scrolled to the first choice.
struct QeetrixComboboxResults<Value: Hashable>: View {
    let sections: [QeetrixComboboxSection<Value>]
    let selection: QeetrixComboboxSelection<Value>
    /// "Searching…" above the rows while results are on the way.
    let loading: String?
    let choose: @MainActor (QeetrixComboboxItem<Value>) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    if let loading {
                        QeetrixComboboxStatus(text: loading)
                    }
                    ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                        Section {
                            ForEach(section.items) { item in
                                row(item, isLast: item.value == section.items.last?.value)
                            }
                        } header: {
                            if let label = section.label {
                                // The first group has no rule above it, as the Sidebar's first group.
                                QeetrixSectionHeader(label, isRuled: index > 0)
                                    .background(QeetrixColor.surfaceOverlay)
                            }
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .onAppear {
                if let first = sections.lazy.flatMap(\.items).first(where: { selection.contains($0.value) }) {
                    proxy.scrollTo(first.value, anchor: .center)
                }
            }
        }
    }

    private func row(_ item: QeetrixComboboxItem<Value>, isLast: Bool) -> some View {
        let isChosen = selection.contains(item.value)
        return VStack(spacing: 0) {
            QeetrixListItem(title: Text(verbatim: item.label), description: item.description.map { Text(verbatim: $0) }) {
                choose(item)
            } trailing: {
                if isChosen { QeetrixComboboxCheck() }
            }
            .disabled(item.isDisabled)
            .accessibilityAddTraits(isChosen ? .isSelected : [])
            // Rows in a stack are ruled by a separator (§15: 1 pt `border.subtle` between rows).
            if !isLast { QeetrixSeparator() }
        }
        .id(item.value)
    }
}

/// The chosen option's mark (combobox.css `.qx-combobox-option-check`): a 16 pt sharp `check` in
/// `color.icon.brand` — `color.icon.disabled` on a disabled option. Decorative: the row reads as selected.
struct QeetrixComboboxCheck: View {
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        QeetrixIcon(.check, size: .sm, shape: .sharp)
            .foregroundStyle(isEnabled ? QeetrixColor.iconBrand : QeetrixColor.iconDisabled)
    }
}

/// "Searching…" with a small spinner (combobox.css `.qx-combobox-status`): `body.md` in
/// `color.text.subtle`, `space.gap.sm` apart, `space.inset.sm` above and below — at the rows' gutter.
struct QeetrixComboboxStatus: View {
    let text: String

    var body: some View {
        HStack(spacing: QeetrixSpace.gapSm) {
            QeetrixSpinner(size: .sm, isDecorative: true)
            Text(verbatim: text)
                .qeetrixTextStyle(.bodyMd)
                .foregroundStyle(QeetrixColor.textSubtle)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, QeetrixListItemMetrics.inlinePadding)
        .padding(.vertical, QeetrixSpace.insetSm)
        .accessibilityElement(children: .combine)
    }
}
