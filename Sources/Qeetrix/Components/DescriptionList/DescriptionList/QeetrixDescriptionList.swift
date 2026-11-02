import SwiftUI

/// How a ``QeetrixDescriptionList`` lays out its pairs, as `@qeetrix/react`'s `DescriptionListLayout`.
public enum QeetrixDescriptionListLayout: String, CaseIterable, Sendable {
    /// Each term beside its value, a `color.border.subtle` rule between rows, each row at least the
    /// density's `size.row`. Where the list is narrower than 24 rem — a phone in portrait, a narrow
    /// column — the term moves above its value. The default.
    case rows
    /// Each term above its value, in up to `columns` columns of at least 8 rem: fewer where there isn't
    /// room.
    case columns
}

/// Facts about one record, as term and value pairs — `@qeetrix/react`'s DescriptionList: an approval
/// request's app, place, device and time; a user's email and ID; an audit event's actor and IP
/// address. Put ``QeetrixDescriptionItem``s in it.
///
/// ```swift
/// QeetrixDescriptionList {
///     QeetrixDescriptionItem("App", value: "Qeet Pay console")
///     QeetrixDescriptionItem("Device", value: "MacBook Pro · Safari")
///     QeetrixDescriptionItem("Status") { QeetrixBadge("Pending", tone: .warning) }
///     QeetrixDescriptionItem("Phone", value: nil)  // "—", read as "Not set"
/// }
/// ```
///
/// - **Reading.** Terms are `label.sm` in `color.text.subtle`; values `body.md` in `color.text.default`,
///   wrapping rather than truncating. VoiceOver reads each pair as one element ("App, Qeet Pay
///   console"); an item's `action` is its own control.
/// - **Rows** (the default): the term column is 30 % of the row and at least 8 rem, beside the value
///   and on its first line; rows are at least `size.row` with a rule between them. The layout follows
///   the width the list is given, as the web's container query does: on an iPhone in portrait — compact
///   width — the term sits above its value; on an iPad, or in landscape, beside it.
/// - **Columns**: terms above values, `columns` at most (1 to 4).
/// - **Values are what you pass.** Format dates, amounts and identifiers first, and never pass a
///   secret: the list logs, copies and announces nothing.
///
/// A rem is 16 pt at the default text size and grows with Dynamic Type, as the web's grows with the
/// browser's font size.
public struct QeetrixDescriptionList<Content: View>: View {
    let layout: QeetrixDescriptionListLayout
    let columns: Int
    let content: Content
    @ScaledMetric(relativeTo: .body) private var rem: CGFloat = QeetrixDescriptionListMetrics.rem

    /// - Parameters:
    ///   - layout: `rows`, or `columns`.
    ///   - columns: In `columns`, the most columns, 1 to 4; a number outside that range is clamped.
    ///   - content: The ``QeetrixDescriptionItem``s.
    public init(layout: QeetrixDescriptionListLayout = .rows, columns: Int = 2, @ViewBuilder content: () -> Content) {
        self.layout = layout
        self.columns = min(max(columns, 1), 4)
        self.content = content()
    }

    public var body: some View {
        Group {
            switch layout {
            case .rows:
                // A 1 pt gap between items, where each item after the first draws its rule
                // (`.qx-description-item + .qx-description-item { border-block-start }`).
                VStack(alignment: .leading, spacing: QeetrixBorderWidth.default) {
                    content
                }
                .coordinateSpace(.named(QeetrixDescriptionListMetrics.space))
            case .columns:
                QeetrixDescriptionColumnsLayout(columns: columns, minimum: 8 * rem) {
                    content
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .environment(\.qeetrixDescriptionListLayout, layout)
        .accessibilityElement(children: .contain)
    }
}

/// One term and its value — `@qeetrix/react`'s DescriptionItem. Its value is a text, or any content:
/// a badge, a link, a copy button.
///
/// ```swift
/// QeetrixDescriptionItem("Email", value: "priya@acme.in")
/// QeetrixDescriptionItem("Display name", value: "Acme", description: Text("Shown in the top bar and in invitations.")) {
///     QeetrixButton("Change", variant: .ghost, size: .sm) { editName() }
/// }
/// QeetrixDescriptionItem("Status") { QeetrixBadge("Active", tone: .success) }
/// ```
///
/// A text value takes its own direction, so an email, a phone number or an amount reads left to right
/// in a right-to-left layout, at the layout's start. An empty value — `nil` or `""` — shows "—" in
/// `color.text.subtlest`, read by VoiceOver as "Not set".
public struct QeetrixDescriptionItem<Value: View, Action: View>: View {
    let term: Text
    let description: Text?
    let value: Value
    /// A text value as VoiceOver reads it: without the isolates that set its direction.
    let spokenValue: Text?
    let isEmpty: Bool
    let emptyLabel: Text?
    let action: Action
    @Environment(\.qeetrixDescriptionListLayout) private var layout
    @Environment(\.qeetrixDensity) private var density
    @ScaledMetric(relativeTo: .body) private var rem: CGFloat = QeetrixDescriptionListMetrics.rem

    init(
        term: Text, description: Text?, value: Value, spokenValue: Text? = nil, isEmpty: Bool, emptyLabel: Text?, action: () -> Action
    ) {
        self.term = term
        self.description = description
        self.value = value
        self.spokenValue = spokenValue
        self.isEmpty = isEmpty
        self.emptyLabel = emptyLabel
        self.action = action()
    }

    public var body: some View {
        let hasAction = Action.self != EmptyView.self
        QeetrixDescriptionItemLayout(isColumns: layout == .columns, rem: rem, rowHeight: density.sizeRow) {
            // VoiceOver reads the pair as one element over the term and the value; the action, if any,
            // stays its own (the web's `dt` and `dd` in a `div`, the action a second `dd`).
            Color.clear
                .accessibilityRepresentation { pairForVoiceOver }
                .layoutValue(key: QeetrixDescriptionItemPart.self, value: .pair)
            termView
                .accessibilityHidden(true)
                .layoutValue(key: QeetrixDescriptionItemPart.self, value: .term)
            valueBlock
                .accessibilityHidden(true)
                .layoutValue(key: QeetrixDescriptionItemPart.self, value: .value)
            if hasAction {
                action
                    .layoutValue(key: QeetrixDescriptionItemPart.self, value: .action)
            }
        }
        .background(alignment: .top) {
            if layout == .rows { QeetrixDescriptionListRule() }
        }
    }

    private var termView: some View {
        // .qx-description-term: label.sm, text.subtle
        term
            .qeetrixTextStyle(.labelSm)
            .foregroundStyle(QeetrixColor.textSubtle)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// `.qx-description-value`: the value's pieces side by side, `space.gap.xs` apart, wrapping and
    /// centred on each other; the note on a line of its own below.
    private var valueBlock: some View {
        VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
            QeetrixDescriptionValueLayout(spacing: QeetrixSpace.gapXs) {
                if isEmpty {
                    Text(verbatim: "—")
                        .qeetrixTextStyle(.bodyMd)
                        .foregroundStyle(QeetrixColor.textSubtlest)
                } else if Value.self == Text.self {
                    value
                        .qeetrixTextStyle(.bodyMd)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    value
                }
            }
            if let description {
                // .qx-description-note: body.sm, text.subtle, flex-basis 100%
                description
                    .qeetrixTextStyle(.bodySm)
                    .foregroundStyle(QeetrixColor.textSubtle)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .qeetrixTypeEnvironment(QeetrixTypeSpec(.bodyMd))
        .foregroundStyle(QeetrixColor.textDefault)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var pairForVoiceOver: some View {
        VStack {
            term
            if isEmpty {
                emptyLabel ?? QeetrixStrings.descriptionListEmpty
            } else if let spokenValue {
                spokenValue
            } else {
                value
            }
            if let description {
                description
            }
        }
        .accessibilityElement(children: .combine)
    }
}

extension QeetrixDescriptionItem {
    /// A term with a localised name and a value of any content, read together with the term. For an
    /// empty value use the text initialiser with `nil`.
    ///
    /// - Parameters:
    ///   - termKey: What the value is: "Email".
    ///   - description: A sentence under the value on what it means, `body.sm` in `color.text.subtle`.
    ///   - value: The value: text, a badge, a link, a copy button. Its pieces sit `space.gap.xs` apart
    ///     and wrap; text in it is `body.md`.
    ///   - action: An action on this fact at the row's end, such as a ghost "Change" — a settings row.
    ///     Below the value where the list is narrow, and in `columns`.
    public init(
        _ termKey: LocalizedStringKey, description: Text? = nil, @ViewBuilder value: () -> Value,
        @ViewBuilder action: () -> Action = { EmptyView() }
    ) {
        self.init(term: Text(termKey), description: description, value: value(), isEmpty: false, emptyLabel: nil, action: action)
    }

    /// A term shown as given and a value of any content.
    public init<S: StringProtocol>(
        _ term: S, description: Text? = nil, @ViewBuilder value: () -> Value, @ViewBuilder action: () -> Action = { EmptyView() }
    ) {
        self.init(term: Text(term), description: description, value: value(), isEmpty: false, emptyLabel: nil, action: action)
    }

    /// A `Text` term and a value of any content.
    public init(
        term: Text, description: Text? = nil, @ViewBuilder value: () -> Value, @ViewBuilder action: () -> Action = { EmptyView() }
    ) {
        self.init(term: term, description: description, value: value(), isEmpty: false, emptyLabel: nil, action: action)
    }
}

extension QeetrixDescriptionItem where Value == Text {
    /// A term with a localised name and a text value, shown as given.
    ///
    /// - Parameters:
    ///   - termKey: What the value is: "Email".
    ///   - value: The value, already formatted. `nil` or `""` shows "—", read as `emptyLabel`.
    ///   - description: A sentence under the value on what it means.
    ///   - emptyLabel: What VoiceOver reads for an empty value; "Not set" unless you give one.
    ///   - action: An action on this fact at the row's end.
    public init(
        _ termKey: LocalizedStringKey, value: String?, description: Text? = nil, emptyLabel: Text? = nil,
        @ViewBuilder action: () -> Action = { EmptyView() }
    ) {
        self.init(term: Text(termKey), value: value, description: description, emptyLabel: emptyLabel, action: action)
    }

    /// A term shown as given and a text value.
    public init<S: StringProtocol>(
        _ term: S, value: String?, description: Text? = nil, emptyLabel: Text? = nil, @ViewBuilder action: () -> Action = { EmptyView() }
    ) {
        self.init(term: Text(term), value: value, description: description, emptyLabel: emptyLabel, action: action)
    }

    /// A `Text` term and a text value.
    public init(
        term: Text, value: String?, description: Text? = nil, emptyLabel: Text? = nil, @ViewBuilder action: () -> Action = { EmptyView() }
    ) {
        let text = value ?? ""
        self.init(
            term: term, description: description, value: Text(verbatim: QeetrixDescriptionListMetrics.isolated(text)),
            spokenValue: Text(verbatim: text), isEmpty: text.isEmpty, emptyLabel: emptyLabel, action: action)
    }
}

// MARK: - Layout

/// The parts of a ``QeetrixDescriptionItem`` its layout places.
enum QeetrixDescriptionItemPart: LayoutValueKey {
    /// The pair as VoiceOver reads it, over the term and the value.
    case pair
    case term
    case value
    case action

    static let defaultValue = QeetrixDescriptionItemPart.value
}

/// One item, as description-list.css lays it out.
///
/// - `rows`, 24 rem and wider: `grid-template-columns: minmax(8rem, 30%) minmax(0, 1fr) [auto]`,
///   `column-gap: space.gap.md`, `padding-block: space.gap.sm`, `min-block-size: size.row`; the term on
///   the value's first baseline (`align-items: baseline`), or everything centred with an action.
/// - `rows`, narrower (`@container (width < 24rem)`): one column — the term, the value, the action at
///   the start — `space.gap.xs` apart, with the same padding and minimum height.
/// - `columns`: the term, the value and the action at the end, `space.gap.xs` apart, nothing more.
struct QeetrixDescriptionItemLayout: Layout {
    let isColumns: Bool
    let rem: CGFloat
    let rowHeight: CGFloat

    struct Frames {
        var term: CGRect = .zero
        var value: CGRect = .zero
        var action: CGRect?
        var size: CGSize = .zero
        var isStacked = true
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        frames(width: proposal.width, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let frames = frames(width: bounds.width, subviews: subviews)
        for subview in subviews {
            let frame: CGRect? =
                switch subview[QeetrixDescriptionItemPart.self] {
                case .pair: frames.term.union(frames.value)
                case .term: frames.term
                case .value: frames.value
                case .action: frames.action
                }
            guard let frame else { continue }
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }

    func frames(width proposed: CGFloat?, subviews: Subviews) -> Frames {
        func part(_ part: QeetrixDescriptionItemPart) -> LayoutSubview? {
            subviews.first { $0[QeetrixDescriptionItemPart.self] == part }
        }
        let term = part(.term)
        let value = part(.value)
        let action = part(.action)
        let width =
            proposed.flatMap { $0.isFinite ? $0 : nil }
            ?? [term, value, action].compactMap { $0?.sizeThatFits(.unspecified).width }.max() ?? 0
        func height(_ subview: LayoutSubview?, _ width: CGFloat) -> CGFloat {
            subview?.sizeThatFits(ProposedViewSize(width: width, height: nil)).height ?? 0
        }
        func idealCapped(_ subview: LayoutSubview, _ maximum: CGFloat) -> CGSize {
            let ideal = subview.sizeThatFits(.unspecified)
            guard ideal.width > maximum else { return ideal }
            return CGSize(width: maximum, height: subview.sizeThatFits(ProposedViewSize(width: maximum, height: nil)).height)
        }
        var frames = Frames()
        let rowGap = QeetrixSpace.gapXs

        if isColumns || width < QeetrixDescriptionListMetrics.stackedBelow * rem {
            // `columns` has no padding or minimum; a narrow `rows` item keeps the row's.
            let padding = isColumns ? 0 : QeetrixSpace.gapSm
            var y = padding
            frames.term = CGRect(x: 0, y: y, width: width, height: height(term, width))
            y += frames.term.height + rowGap
            frames.value = CGRect(x: 0, y: y, width: width, height: height(value, width))
            y += frames.value.height
            if let action {
                let size = idealCapped(action, width)
                y += rowGap
                // `columns`: under the value at the end; a narrow row: at the start (`flex-start`).
                frames.action = CGRect(x: isColumns ? width - size.width : 0, y: y, width: size.width, height: size.height)
                y += size.height
            }
            y += padding
            frames.size = CGSize(width: width, height: isColumns ? y : max(y, rowHeight))
            return frames
        }

        frames.isStacked = false
        let gap = QeetrixSpace.gapMd
        let padding = QeetrixSpace.gapSm
        let actionSize = action.map { idealCapped($0, width / 2) }
        let termWidth = min(max(QeetrixDescriptionListMetrics.termMinimum * rem, width * 0.3), width)
        let valueWidth = max(0, width - termWidth - gap - (actionSize.map { $0.width + gap } ?? 0))
        let termSize = CGSize(width: termWidth, height: height(term, termWidth))
        let valueSize = CGSize(width: valueWidth, height: height(value, valueWidth))
        var termY: CGFloat = 0
        var valueY: CGFloat = 0
        var actionY: CGFloat = 0
        let content: CGFloat
        if let actionSize {
            // `[data-action]`: align-items: center.
            content = max(termSize.height, valueSize.height, actionSize.height)
            termY = (content - termSize.height) / 2
            valueY = (content - valueSize.height) / 2
            actionY = (content - actionSize.height) / 2
        } else if let term, let value {
            // align-items: baseline — the term on the value's first line.
            let termBaseline = term.dimensions(in: ProposedViewSize(termSize))[VerticalAlignment.firstTextBaseline]
            let valueBaseline = value.dimensions(in: ProposedViewSize(valueSize))[VerticalAlignment.firstTextBaseline]
            let shift = valueBaseline - termBaseline
            termY = max(shift, 0)
            valueY = max(-shift, 0)
            content = max(termY + termSize.height, valueY + valueSize.height)
        } else {
            content = max(termSize.height, valueSize.height)
        }
        let rowHeight = max(content + 2 * padding, rowHeight)
        let top = actionSize == nil ? padding : (rowHeight - content) / 2
        frames.term = CGRect(origin: CGPoint(x: 0, y: top + termY), size: termSize)
        frames.value = CGRect(origin: CGPoint(x: termWidth + gap, y: top + valueY), size: valueSize)
        if let actionSize {
            frames.action = CGRect(origin: CGPoint(x: width - actionSize.width, y: top + actionY), size: actionSize)
        }
        frames.size = CGSize(width: width, height: rowHeight)
        return frames
    }
}

/// `[data-layout="columns"]`:
/// `repeat(auto-fill, minmax(max(8rem, (100% − (columns − 1) × gap.xl) / columns), 1fr))` — as many
/// columns as fit, at most `columns`, sharing the width; `space.gap.lg` between rows and
/// `space.gap.xl` between columns, filled row by row.
struct QeetrixDescriptionColumnsLayout: Layout {
    let columns: Int
    let minimum: CGFloat
    var columnGap = QeetrixSpace.gapXl
    var rowGap = QeetrixSpace.gapLg

    /// How many columns fit in `width`.
    func count(width: CGFloat) -> Int {
        let track = max(minimum, (width - CGFloat(columns - 1) * columnGap) / CGFloat(columns))
        // A hair of tolerance: `columns` tracks of exactly the share fit exactly.
        let fit = Int(((width + columnGap) / (track + columnGap) + 0.0001).rounded(.down))
        return min(max(fit, 1), columns)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width.flatMap { $0.isFinite ? $0 : nil } ?? idealWidth(subviews)
        return arrange(width: width, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let arrangement = arrange(width: bounds.width, subviews: subviews)
        for (index, frame) in arrangement.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(width: frame.width, height: nil))
        }
    }

    private func idealWidth(_ subviews: Subviews) -> CGFloat {
        let widest = subviews.map { $0.sizeThatFits(.unspecified).width }.max() ?? 0
        return CGFloat(columns) * max(widest, minimum) + CGFloat(columns - 1) * columnGap
    }

    func arrange(width: CGFloat, subviews: Subviews) -> (frames: [CGRect], size: CGSize) {
        let count = count(width: width)
        let cell = max(0, (width - columnGap * CGFloat(count - 1)) / CGFloat(count))
        var frames: [CGRect] = []
        var y: CGFloat = 0
        var index = 0
        while index < subviews.count {
            let row = subviews[index..<min(index + count, subviews.count)]
            if index > 0 { y += rowGap }
            let heights = row.map { $0.sizeThatFits(ProposedViewSize(width: cell, height: nil)).height }
            for (column, height) in heights.enumerated() {
                frames.append(CGRect(x: CGFloat(column) * (cell + columnGap), y: y, width: cell, height: height))
            }
            y += heights.max() ?? 0
            index += count
        }
        return (frames, CGSize(width: width, height: y))
    }
}

/// A value's pieces in a row that wraps (`display: flex; flex-wrap: wrap; align-items: center;
/// gap: space.gap.xs`): each at its own width — a text wider than the line takes the line and wraps —
/// centred on the others in its line. Its first baseline is its first piece's, so a term can sit on it.
struct QeetrixDescriptionValueLayout: Layout {
    let spacing: CGFloat

    struct Line {
        var indices: [Int] = []
        var sizes: [CGSize] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let lines = lines(width: proposal.width, subviews: subviews)
        let height = lines.map(\.height).reduce(0, +) + spacing * CGFloat(max(0, lines.count - 1))
        let natural = lines.map(\.width).max() ?? 0
        return CGSize(width: proposal.width.flatMap { $0.isFinite ? $0 : nil } ?? natural, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for line in lines(width: bounds.width, subviews: subviews) {
            var x = bounds.minX
            for (index, size) in zip(line.indices, line.sizes) {
                subviews[index].place(at: CGPoint(x: x, y: y + (line.height - size.height) / 2), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += line.height + spacing
        }
    }

    func explicitAlignment(
        of guide: VerticalAlignment, in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) -> CGFloat? {
        guard guide == .firstTextBaseline, let line = lines(width: bounds.width, subviews: subviews).first,
            let index = line.indices.first, let size = line.sizes.first
        else { return nil }
        let baseline = subviews[index].dimensions(in: ProposedViewSize(size))[VerticalAlignment.firstTextBaseline]
        return bounds.minY + (line.height - size.height) / 2 + baseline
    }

    func lines(width proposed: CGFloat?, subviews: Subviews) -> [Line] {
        let width = proposed.flatMap { $0.isFinite ? $0 : nil } ?? .infinity
        var lines: [Line] = []
        var line = Line()
        for index in subviews.indices {
            var size = subviews[index].sizeThatFits(.unspecified)
            if size.width > width {
                size = CGSize(width: width, height: subviews[index].sizeThatFits(ProposedViewSize(width: width, height: nil)).height)
            }
            if !line.indices.isEmpty, line.width + spacing + size.width > width {
                lines.append(line)
                line = Line()
            }
            line.width += (line.indices.isEmpty ? 0 : spacing) + size.width
            line.height = max(line.height, size.height)
            line.indices.append(index)
            line.sizes.append(size)
        }
        if !line.indices.isEmpty { lines.append(line) }
        return lines
    }
}

/// The 1 pt `color.border.subtle` rule above a `rows` item, in the gap the list leaves between items,
/// drawn by every item but the first (`.qx-description-item + .qx-description-item`).
struct QeetrixDescriptionListRule: View {
    var body: some View {
        GeometryReader { proxy in
            // Below the top by more than half the rule: not the first item.
            if proxy.frame(in: .named(QeetrixDescriptionListMetrics.space)).minY > QeetrixBorderWidth.default * 0.5 {
                Rectangle()
                    .fill(QeetrixColor.borderSubtle)
                    .frame(width: proxy.size.width, height: QeetrixBorderWidth.default)
                    .offset(y: -QeetrixBorderWidth.default)
            }
        }
        .accessibilityHidden(true)
    }
}

/// description-list.css's lengths, and the list's names.
enum QeetrixDescriptionListMetrics {
    /// CSS's root font size; scaled with Dynamic Type where it is used.
    static let rem: CGFloat = 16
    /// `minmax(8rem, 30%)`: the term column's minimum, and a column's minimum in `columns`.
    static let termMinimum: CGFloat = 8
    /// `@container (width < 24rem)`: narrower than this, a row's term moves above its value.
    static let stackedBelow: CGFloat = 24
    /// The coordinate space in which an item finds whether it is the first.
    static let space = "qeetrix.description-list"

    /// `text` in Unicode first-strong isolates, so it takes its own direction — an email or a phone
    /// number stays left to right in a right-to-left layout — without reordering what is around it.
    static func isolated(_ text: String) -> String {
        text.isEmpty ? text : "\u{2068}\(text)\u{2069}"
    }
}

private struct QeetrixDescriptionListLayoutKey: EnvironmentKey {
    static let defaultValue: QeetrixDescriptionListLayout? = nil
}

extension EnvironmentValues {
    /// The layout of the ``QeetrixDescriptionList`` an item is in; `nil` outside one, where an item is a
    /// lone unruled row.
    var qeetrixDescriptionListLayout: QeetrixDescriptionListLayout? {
        get { self[QeetrixDescriptionListLayoutKey.self] }
        set { self[QeetrixDescriptionListLayoutKey.self] = newValue }
    }
}

extension QeetrixStrings {
    /// "Not set" — `descriptionList.empty`, what VoiceOver reads for an empty value.
    static var descriptionListEmpty: Text {
        Text(verbatim: String(localized: "qeetrix.description-list.empty", defaultValue: "Not set", bundle: .module))
    }
}
