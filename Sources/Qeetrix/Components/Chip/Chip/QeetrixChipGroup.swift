import SwiftUI

/// What a ``QeetrixChipGroup`` does with chips that don't fit on one line.
public enum QeetrixChipGroupOverflow: String, CaseIterable, Sendable {
    /// They wrap onto more lines, `space.gap.sm` apart, as on the web. The default.
    case wrap
    /// They stay on one line that scrolls sideways, for a filter bar over a list.
    case scroll
}

/// Chips that choose from a set, as `@qeetrix/react`'s ChipGroup: one value, or any number.
///
/// ```swift
/// QeetrixChipGroup("Status", selection: $status, options: [  // a Status?
///     QeetrixOption("All", value: nil),
///     QeetrixOption("Open", value: .open),
///     QeetrixOption("Closed", value: .closed),
/// ], size: .sm)
///
/// QeetrixChipGroup("Departments", selection: $departments, options: departmentOptions)  // a Set
/// ```
///
/// A `Binding<Value>` chooses one value: the chips are radios, and choosing one releases the
/// other. A `Binding<Set<Value>>` chooses any number: each chip is a checkbox. The label names the
/// group for VoiceOver and isn't shown; put a heading beside it where the page needs one. Chips show
/// their option's title, and read its description as their hint; a disabled option can't be chosen.
/// The chips are `space.gap.sm` apart and wrap onto more lines, each row a 44 pt target; with
/// `overflow: .scroll` they stay on one line that scrolls sideways.
public struct QeetrixChipGroup<Value: Hashable>: View {
    let label: Text
    let selection: Selection
    let options: [QeetrixOption<Value>]
    let size: QeetrixControlSize
    let overflow: QeetrixChipGroupOverflow

    enum Selection {
        case one(Binding<Value>)
        case many(Binding<Set<Value>>)
    }

    /// Chips that choose one value, named by a localised label.
    public init(
        _ titleKey: LocalizedStringKey, selection: Binding<Value>, options: [QeetrixOption<Value>], size: QeetrixControlSize = .md,
        overflow: QeetrixChipGroupOverflow = .wrap
    ) {
        self.init(label: Text(titleKey), selection: .one(selection), options: options, size: size, overflow: overflow)
    }

    /// Chips that choose one value, named by a label used as given.
    public init<S: StringProtocol>(
        _ title: S, selection: Binding<Value>, options: [QeetrixOption<Value>], size: QeetrixControlSize = .md,
        overflow: QeetrixChipGroupOverflow = .wrap
    ) {
        self.init(label: Text(title), selection: .one(selection), options: options, size: size, overflow: overflow)
    }

    /// Chips that choose one value, named by a `Text`.
    public init(
        label: Text, selection: Binding<Value>, options: [QeetrixOption<Value>], size: QeetrixControlSize = .md,
        overflow: QeetrixChipGroupOverflow = .wrap
    ) {
        self.init(label: label, selection: .one(selection), options: options, size: size, overflow: overflow)
    }

    /// Chips that choose any number of values — the web's `multiple` — named by a localised label.
    public init(
        _ titleKey: LocalizedStringKey, selection: Binding<Set<Value>>, options: [QeetrixOption<Value>],
        size: QeetrixControlSize = .md, overflow: QeetrixChipGroupOverflow = .wrap
    ) {
        self.init(label: Text(titleKey), selection: .many(selection), options: options, size: size, overflow: overflow)
    }

    /// Chips that choose any number of values, named by a label used as given.
    public init<S: StringProtocol>(
        _ title: S, selection: Binding<Set<Value>>, options: [QeetrixOption<Value>], size: QeetrixControlSize = .md,
        overflow: QeetrixChipGroupOverflow = .wrap
    ) {
        self.init(label: Text(title), selection: .many(selection), options: options, size: size, overflow: overflow)
    }

    /// Chips that choose any number of values, named by a `Text`.
    public init(
        label: Text, selection: Binding<Set<Value>>, options: [QeetrixOption<Value>], size: QeetrixControlSize = .md,
        overflow: QeetrixChipGroupOverflow = .wrap
    ) {
        self.init(label: label, selection: .many(selection), options: options, size: size, overflow: overflow)
    }

    private init(
        label: Text, selection: Selection, options: [QeetrixOption<Value>], size: QeetrixControlSize, overflow: QeetrixChipGroupOverflow
    ) {
        self.label = label
        self.selection = selection
        self.options = options
        self.size = size
        self.overflow = overflow
    }

    public var body: some View {
        Group {
            switch overflow {
            case .wrap:
                QeetrixChipFlowLayout { chips }
            case .scroll:
                ScrollView(.horizontal) {
                    HStack(spacing: QeetrixSpace.gapSm) {
                        chips.fixedSize(horizontal: true, vertical: false)
                    }
                    // The row is a 44 pt target inside the scroll view, which takes no touches outside it.
                    .frame(minHeight: QeetrixAccessibility.minimumTouchTarget)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(label)
    }

    private var chips: some View {
        ForEach(options) { option in
            chip(option)
                .disabled(option.isDisabled)
                .accessibilityHint(option.description ?? Text(verbatim: ""))
        }
    }

    @ViewBuilder
    private func chip(_ option: QeetrixOption<Value>) -> some View {
        switch selection {
        case let .one(binding):
            let isSelected = option.value == binding.wrappedValue
            Button {
                if !isSelected { binding.wrappedValue = option.value }
            } label: {
                option.title
            }
            .buttonStyle(QeetrixChipButtonStyle(isSelected: isSelected, icon: nil, size: size))
            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        case let .many(binding):
            Toggle(
                isOn: Binding(
                    get: { binding.wrappedValue.contains(option.value) },
                    set: { binding.wrappedValue = Self.toggled(binding.wrappedValue, option.value, isOn: $0) })
            ) {
                option.title
            }
            .toggleStyle(QeetrixChipToggleStyle(size: size))
        }
    }

    /// The chosen values with `value` turned on or off.
    static func toggled(_ values: Set<Value>, _ value: Value, isOn: Bool) -> Set<Value> {
        var values = values
        if isOn { values.insert(value) } else { values.remove(value) }
        return values
    }
}

/// Lays chips out as ``QeetrixChipGroup`` does: in rows `space.gap.sm` apart that wrap where they
/// don't fit, for removable chips and other chips you place yourself.
///
/// ```swift
/// QeetrixChipFlowLayout {
///     ForEach(filters) { filter in
///         QeetrixChip(filter.title) { remove(filter) }
///     }
/// }
/// ```
///
/// Each chip has a slot at least 44 pt square, so neighbouring touch targets never overlap; rows are
/// at least `space.gap.sm` apart. A chip wider than the row is offered the row's width, and its label
/// wraps.
public struct QeetrixChipFlowLayout: Layout {
    public init() {}

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        let rows = Self.rows(sizes: sizes(subviews, width: width), width: width)
        let natural = rows.map(\.width).max() ?? 0
        let height = rows.last.map { $0.y + $0.height } ?? 0
        return CGSize(width: width.isFinite ? width : natural, height: height)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = sizes(subviews, width: bounds.width)
        for row in Self.rows(sizes: sizes, width: bounds.width) {
            for (index, slot) in zip(row.indices, row.slots) {
                let size = sizes[index]
                subviews[index].place(
                    at: CGPoint(x: bounds.minX + slot.midX, y: bounds.minY + row.y + row.height / 2), anchor: .center,
                    proposal: ProposedViewSize(size))
            }
        }
    }

    /// Each chip at its ideal size, or at the row's width when it is wider.
    private func sizes(_ subviews: Subviews, width: CGFloat) -> [CGSize] {
        subviews.map { subview in
            let size = subview.sizeThatFits(.unspecified)
            return size.width > width ? subview.sizeThatFits(ProposedViewSize(width: width, height: nil)) : size
        }
    }

    struct Row: Equatable {
        var indices: [Int] = []
        /// Each chip's slot, from the row's start.
        var slots: [CGRect] = []
        var width: CGFloat = 0
        /// The tallest chip.
        var tallest: CGFloat = 0
        /// The row's top, and its height: at least 44 pt.
        var y: CGFloat = 0
        var height: CGFloat { max(tallest, QeetrixAccessibility.minimumTouchTarget) }
    }

    /// The rows for chips of `sizes` in `width`: slots at least 44 pt wide, `space.gap.sm` apart, and
    /// rows spaced so the chips are at least `space.gap.sm` apart however much room their slots add.
    static func rows(sizes: [CGSize], width: CGFloat) -> [Row] {
        let gap = QeetrixSpace.gapSm
        let minimum = QeetrixAccessibility.minimumTouchTarget
        var rows: [Row] = []
        var row = Row()
        for (index, size) in sizes.enumerated() {
            let slotWidth = max(size.width, minimum)
            let x = row.indices.isEmpty ? 0 : row.width + gap
            if x + slotWidth > width, !row.indices.isEmpty {
                rows.append(row)
                row = Row()
            }
            let start = row.indices.isEmpty ? 0 : row.width + gap
            row.indices.append(index)
            row.slots.append(CGRect(x: start, y: 0, width: slotWidth, height: size.height))
            row.width = start + slotWidth
            row.tallest = max(row.tallest, size.height)
        }
        if !row.indices.isEmpty { rows.append(row) }
        var y: CGFloat = 0
        for index in rows.indices {
            if index > 0 {
                let previous = rows[index - 1]
                // The room the two slots already leave between the chips counts toward the gap.
                let room = (previous.height - previous.tallest) / 2 + (rows[index].height - rows[index].tallest) / 2
                y = previous.y + previous.height + max(0, gap - room)
            }
            rows[index].y = y
        }
        return rows
    }
}
