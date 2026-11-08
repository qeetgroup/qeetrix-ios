import SwiftUI

/// A card's surface, as `@qeetrix/react`'s `CardVariant`.
public enum QeetrixCardVariant: String, CaseIterable, Sendable {
    /// Raised (`color.surface.raised`).
    case `default`
    /// The sunken tone (`color.surface.sunken`), for a secondary panel: still ruled, still no shadow.
    case subdued
}

/// A card's meaning, as `@qeetrix/react`'s `CardTone`.
public enum QeetrixCardTone: String, CaseIterable, Sendable {
    case neutral
    /// A "danger zone" of settings that delete or can't be undone: the border and the title in the
    /// danger colour. The title's words still say what it is.
    case danger
}

/// Related content on a screen, as `@qeetrix/react`'s Card: a raised, ruled surface with 4 pt corners
/// and no shadow (design rules §12). An optional ruled header holds the title (`title.sm`), a line under
/// it and actions at the end; an optional ruled footer holds the card's actions, end-aligned.
///
/// ```swift
/// QeetrixCard(title: Text("Team plan"), description: Text("Billed monthly")) {
///     QeetrixText("Up to 25 members, with audit logs and SSO.")
/// } footer: {
///     QeetrixButton("Upgrade", size: .lg) { upgrade() }
/// }
/// ```
///
/// A titled card is read by VoiceOver with its title as a heading of `headingLevel`, so the page sets
/// the outline. For a card that is itself the control, use ``QeetrixCardButtonStyle``.
///
/// For a group of tappable rows — a settings card — `flushRows()` lays the body out as list rows, flush
/// with the card's edges and ruled between:
///
/// ```swift
/// QeetrixCard {
///     QeetrixListItem("AutoFill codes", accessory: .chevron) { openAutoFill() } leading: { QeetrixListItemIcon(.key) }
///     QeetrixListItem("Help and privacy", accessory: .chevron) { openHelp() } leading: {
///         QeetrixListItemIcon(.circleQuestionMark)
///     }
/// }
/// .flushRows()
/// ```
public struct QeetrixCard<Content: View, Actions: View, Footer: View>: View {
    let title: Text?
    let description: Text?
    let headingLevel: Int
    let variant: QeetrixCardVariant
    let tone: QeetrixCardTone
    let content: Content
    let actions: Actions?
    let footer: Footer?
    /// The body as flush list rows.
    private(set) var isFlushRows = false

    public init(
        title: Text? = nil,
        description: Text? = nil,
        headingLevel: Int = 2,
        variant: QeetrixCardVariant = .default,
        tone: QeetrixCardTone = .neutral,
        @ViewBuilder content: () -> Content,
        @ViewBuilder actions: () -> Actions,
        @ViewBuilder footer: () -> Footer
    ) {
        self.title = title
        self.description = description
        self.headingLevel = headingLevel
        self.variant = variant
        self.tone = tone
        self.content = content()
        self.actions = actions()
        self.footer = footer()
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.surface)
        VStack(alignment: .leading, spacing: 0) {
            if hasHeader { header }
            bodySection
            if let footer {
                QeetrixCardRule()
                QeetrixCardFooterLayout(spacing: QeetrixSpace.gapSm) { footer }
                    .padding(QeetrixSpace.insetLg)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(QeetrixColor.textDefault)
        .background(surface, in: shape)
        .clipShape(shape)
        .overlay {
            shape.strokeBorder(
                tone == .danger ? QeetrixColor.borderDanger : QeetrixColor.borderDefault, lineWidth: QeetrixBorderWidth.default)
        }
    }

    var hasHeader: Bool { title != nil || description != nil || actions != nil }

    /// Lays the body out as list rows, flush: no padding and no gap, so the rows meet the
    /// card's edges — their pressed tint and focus frame too, clipped to its corners — with a 1 pt
    /// `color.border.subtle` rule between them, edge to edge, and none above the first row or below the
    /// last. Put ``QeetrixListItem``s in the body: they keep their own insets. A header's and a footer's
    /// rules stay.
    public func flushRows() -> Self {
        var flush = self
        flush.isFlushRows = true
        return flush
    }

    private var surface: QeetrixColor {
        variant == .subdued ? .surfaceSunken : .surfaceRaised
    }

    /// The body, ruled off from a header above it. A body with nothing in it is left out, and the
    /// header's rule with it, so a header-only card ends at its header and a footer's own rule is the
    /// only one under it (`.qx-card-body:empty`, `.qx-card-header:is(:last-child, …)`).
    @ViewBuilder private var bodySection: some View {
        if #available(iOS 18, macOS 15, *) {
            Group(subviews: content) { subviews in
                if !subviews.isEmpty { cardBody(subviews) }
            }
        } else if Content.self != EmptyView.self {
            cardBody(content)
        }
    }

    private func cardBody(_ content: some View) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if hasHeader { QeetrixCardRule() }
            if isFlushRows {
                // Each row on the card's surface, 1 pt apart over border.subtle: the rules fall between
                // rows only. A group's modifiers apply to each of its views.
                VStack(alignment: .leading, spacing: QeetrixBorderWidth.default) {
                    Group { content }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(surface)
                }
                .background(QeetrixColor.borderSubtle)
                .qeetrixTypeEnvironment(QeetrixTypeSpec(.bodyMd))
            } else {
                VStack(alignment: .leading, spacing: QeetrixSpace.gapMd) {
                    content
                }
                .qeetrixTypeEnvironment(QeetrixTypeSpec(.bodyMd))
                .padding(QeetrixSpace.insetLg)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: QeetrixSpace.gapMd) {
            VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
                if let title {
                    QeetrixHeading(title, level: headingLevel, size: .titleSm)
                        .foregroundStyle(tone == .danger ? QeetrixColor.textDanger : QeetrixColor.textDefault)
                }
                if let description {
                    description
                        .qeetrixTextStyle(.bodySm)
                        .foregroundStyle(QeetrixColor.textSubtle)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if let actions {
                HStack(spacing: QeetrixSpace.gapSm) { actions }
                    .padding(.vertical, -4)  // card.css: margin-block -4px
            }
        }
        .padding(QeetrixSpace.insetLg)
    }
}

extension QeetrixCard where Actions == EmptyView, Footer == EmptyView {
    /// A card without header actions or a footer.
    public init(
        title: Text? = nil, description: Text? = nil, headingLevel: Int = 2, variant: QeetrixCardVariant = .default,
        tone: QeetrixCardTone = .neutral, @ViewBuilder content: () -> Content
    ) {
        self.init(
            title: title, description: description, headingLevel: headingLevel, variant: variant, tone: tone, content: content,
            actions: { EmptyView() }, footer: { EmptyView() }, hasActions: false, hasFooter: false)
    }

    /// A card with a localised title and description, without header actions or a footer.
    public init(
        _ titleKey: LocalizedStringKey, description: LocalizedStringKey? = nil, headingLevel: Int = 2,
        variant: QeetrixCardVariant = .default, tone: QeetrixCardTone = .neutral, @ViewBuilder content: () -> Content
    ) {
        self.init(
            title: Text(titleKey), description: description.map { Text($0) }, headingLevel: headingLevel, variant: variant, tone: tone,
            content: content)
    }
}

extension QeetrixCard where Actions == EmptyView {
    /// A card with a footer and no header actions.
    public init(
        title: Text? = nil, description: Text? = nil, headingLevel: Int = 2, variant: QeetrixCardVariant = .default,
        tone: QeetrixCardTone = .neutral, @ViewBuilder content: () -> Content, @ViewBuilder footer: () -> Footer
    ) {
        self.init(
            title: title, description: description, headingLevel: headingLevel, variant: variant, tone: tone, content: content,
            actions: { EmptyView() }, footer: footer, hasActions: false, hasFooter: true)
    }
}

extension QeetrixCard where Footer == EmptyView {
    /// A card with header actions and no footer.
    public init(
        title: Text? = nil, description: Text? = nil, headingLevel: Int = 2, variant: QeetrixCardVariant = .default,
        tone: QeetrixCardTone = .neutral, @ViewBuilder content: () -> Content, @ViewBuilder actions: () -> Actions
    ) {
        self.init(
            title: title, description: description, headingLevel: headingLevel, variant: variant, tone: tone, content: content,
            actions: actions, footer: { EmptyView() }, hasActions: true, hasFooter: false)
    }
}

extension QeetrixCard {
    init(
        title: Text?, description: Text?, headingLevel: Int, variant: QeetrixCardVariant, tone: QeetrixCardTone,
        content: () -> Content, actions: () -> Actions, footer: () -> Footer, hasActions: Bool, hasFooter: Bool
    ) {
        self.title = title
        self.description = description
        self.headingLevel = headingLevel
        self.variant = variant
        self.tone = tone
        self.content = content()
        self.actions = hasActions ? actions() : nil
        self.footer = hasFooter ? footer() : nil
    }
}

/// The 1 pt `color.border.default` line under a card's header and above its footer.
struct QeetrixCardRule: View {
    var body: some View {
        Rectangle()
            .fill(QeetrixColor.borderDefault)
            .frame(height: QeetrixBorderWidth.default)
            .accessibilityHidden(true)
    }
}

/// A footer's actions: end-aligned in a row, wrapping onto more rows when they don't fit
/// (card.css `.qx-card-footer`: flex-wrap, justify-content flex-end). Choice groups use it start-aligned
/// for their horizontal options.
struct QeetrixCardFooterLayout: Layout {
    let spacing: CGFloat
    var alignment: HorizontalAlignment = .trailing

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = rows(width: proposal.width ?? .infinity, subviews: subviews)
        let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(max(0, rows.count - 1))
        let natural = rows.map(\.width).max() ?? 0
        return CGSize(width: proposal.width.map { $0.isFinite ? $0 : natural } ?? natural, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in rows(width: bounds.width, subviews: subviews) {
            var x = alignment == .leading ? bounds.minX : bounds.maxX - row.width
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y + (row.height - size.height) / 2), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    func rows(width: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var row = Row()
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let added = row.indices.isEmpty ? size.width : row.width + spacing + size.width
            if added > width, !row.indices.isEmpty {
                rows.append(row)
                row = Row()
            }
            row.width = row.indices.isEmpty ? size.width : row.width + spacing + size.width
            row.height = max(row.height, size.height)
            row.indices.append(index)
        }
        if !row.indices.isEmpty { rows.append(row) }
        return rows
    }
}

/// A card that is itself the control — iOS only: `@qeetrix/react` 0.2.2 has no selectable card yet.
/// It takes the ruled card surface and the selection look of the web's choice tiles: a neutral tint
/// when pressed or hovered, and, when selected, the selected tint (`color.bg.selected`) inside a 2 pt
/// Ember edge.
///
/// ```swift
/// Button { choose(plan) } label: {
///     VStack(alignment: .leading, spacing: QeetrixSpace.gapXs) {
///         QeetrixHeading("Team plan", level: 3, size: .titleSm)
///         QeetrixText("Billed monthly", size: .sm, tone: .subtle)
///     }
/// }
/// .buttonStyle(.qeetrixCard(isSelected: plan == selected))
/// ```
///
/// Put only the card's content in the label — a title and short copy, never other controls. When
/// `isSelected` is true VoiceOver reads the button as selected.
public struct QeetrixCardButtonStyle: ButtonStyle {
    let variant: QeetrixCardVariant
    let isSelected: Bool

    public init(_ variant: QeetrixCardVariant = .default, isSelected: Bool = false) {
        self.variant = variant
        self.isSelected = isSelected
    }

    public func makeBody(configuration: Configuration) -> some View {
        QeetrixCardButtonBody(style: self, configuration: configuration)
    }
}

extension ButtonStyle where Self == QeetrixCardButtonStyle {
    /// The Qeetrix card as a button style.
    public static func qeetrixCard(_ variant: QeetrixCardVariant = .default, isSelected: Bool = false) -> QeetrixCardButtonStyle {
        QeetrixCardButtonStyle(variant, isSelected: isSelected)
    }
}

private struct QeetrixCardButtonBody: View {
    let style: QeetrixCardButtonStyle
    let configuration: ButtonStyleConfiguration
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.surface)
        configuration.label
            .qeetrixTypeEnvironment(QeetrixTypeSpec(.bodyMd))
            .foregroundStyle(isEnabled ? QeetrixColor.textDefault : QeetrixColor.textDisabled)
            .padding(QeetrixSpace.insetLg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background, in: shape)
            .overlay {
                if style.isSelected && isEnabled {
                    shape.strokeBorder(QeetrixColor.borderBrand, lineWidth: QeetrixBorderWidth.strong)
                } else {
                    shape.strokeBorder(
                        isEnabled ? QeetrixColor.borderDefault : QeetrixColor.borderDisabled, lineWidth: QeetrixBorderWidth.default)
                }
            }
            .overlay { if isFocused { QeetrixOuterFocusFrame(shape: shape) } }
            .contentShape(shape)
            .onHover { isHovered = $0 }
            .qeetrixAnimation(.standard, .fast, value: configuration.isPressed)
            .qeetrixAnimation(.standard, .fast, value: isHovered)
            .accessibilityAddTraits(style.isSelected ? .isSelected : [])
    }

    var background: QeetrixColor {
        if !isEnabled { return .bgDisabled }
        if style.isSelected { return .bgSelected }
        if configuration.isPressed { return .bgNeutralSubtlePressed }
        if isHovered { return .bgNeutralSubtle }
        return style.variant == .subdued ? .surfaceSunken : .surfaceRaised
    }
}

/// Keyboard focus on a choice, tab or link: the 2 pt Ember frame, 2 pt outside the control (design
/// rules §10, `focus.ring.offset`).
struct QeetrixOuterFocusFrame<S: InsettableShape>: View {
    let shape: S

    var body: some View {
        shape
            .inset(by: -(QeetrixFocus.ringOffset + QeetrixFocus.ringWidth))
            .strokeBorder(QeetrixColor.borderFocus, lineWidth: QeetrixFocus.ringWidth)
            .accessibilityHidden(true)
    }
}
