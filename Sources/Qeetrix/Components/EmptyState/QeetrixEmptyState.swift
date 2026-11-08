import SwiftUI

/// How much room a ``QeetrixEmptyState`` takes, as `@qeetrix/react`'s `EmptyStateSize`.
public enum QeetrixEmptyStateSize: String, CaseIterable, Sendable {
    /// A whole screen: the title in `title.md`, 48 pt (`space.layout.lg`) above and below. The default.
    case page
    /// Inside a card or a list: the title in `title.sm`, 24 pt (`space.inset.xl`) above and below.
    case section

    var titleRole: QeetrixTextRole {
        switch self {
        case .page: .titleMd
        case .section: .titleSm
        }
    }

    /// empty-state.css: `padding: var(--qx-space-layout-lg) …`, `[data-size="section"]`
    /// `var(--qx-space-inset-xl) …`.
    var paddingBlock: CGFloat {
        switch self {
        case .page: QeetrixSpace.layoutLg
        case .section: QeetrixSpace.insetXl
        }
    }

    var headingSize: QeetrixHeadingSize {
        switch self {
        case .page: .titleMd
        case .section: .titleSm
        }
    }
}

/// The colour of a ``QeetrixEmptyState``'s icon, as `@qeetrix/react`'s `EmptyStateTone`.
public enum QeetrixEmptyStateTone: String, CaseIterable, Sendable {
    /// `color.icon.subtle`: nothing yet, no results. The default.
    case neutral
    /// `color.icon.danger`: an error, such as a load that failed.
    case danger
    /// `color.icon.success`: an outcome screen that went well — "Sign-in approved". Native only,
    /// as on Android: the web's EmptyState has neutral and danger. The title says it, so the colour is never
    /// the only sign.
    case success
    /// `color.icon.warning`: an outcome that needs a look — "Approve on your other phone". Native only, as
    /// `success`.
    case warning

    var iconColor: QeetrixColor {
        switch self {
        case .neutral: .iconSubtle
        case .danger: .iconDanger
        case .success: .iconSuccess
        case .warning: .iconWarning
        }
    }
}

/// The message where content would be — nothing yet, no results, or an error — as `@qeetrix/react`'s
/// EmptyState: an optional sharp 24 pt icon, a title that says what is missing, a line saying why and
/// what to do, the actions (one primary at most), and under them an optional footer.
///
/// ```swift
/// QeetrixEmptyState("No accounts yet", description: "Add an account to sign in with this phone.", icon: .userPlus) {
///     QeetrixButton("Add account", icon: .plus) { addAccount() }
/// }
/// QeetrixEmptyState("No pending approvals", description: "Sign-in requests appear here.", icon: .inbox, size: .section)
/// ```
///
/// It shows what you give it: whether a list is empty because there is nothing yet, because a filter
/// excludes everything or because a load failed is the app's to decide. Never put a raw error, a status
/// code or a stack trace in the description. Centred, at most 480 pt wide, its parts 8 pt apart; the
/// actions wrap onto more rows, centred, and the text wraps at every size. The icon is decorative; with
/// a `level` the title is a heading — set one when this is the screen's main message. For the loading,
/// failure and empty states of one screen together, use ``QeetrixDataState``.
///
/// An outcome or lock screen can lead with an image instead of the icon — the app's icon on a Locked
/// screen — and `centredInHeight()` puts the column in the middle of the screen:
///
/// ```swift
/// QeetrixEmptyState(title: Text("Qeet ID is locked"), description: Text("Unlock to see your codes."), image: AppIconImage()) {
///     QeetrixButton("Unlock", icon: .lockOpen) { unlock() }
/// }
/// .centredInHeight()
/// ```
public struct QeetrixEmptyState<Actions: View, Footer: View>: View {
    let title: Text
    let description: Text?
    let icon: QeetrixIconName?
    /// The app's image in place of the icon: decorative.
    let image: AnyView?
    /// Centred in all the height it's offered.
    private(set) var isCentredInHeight = false
    let size: QeetrixEmptyStateSize
    let tone: QeetrixEmptyStateTone
    let level: Int?
    let actions: Actions?
    let footer: Footer?

    /// An empty state with actions and a footer.
    ///
    /// - Parameters:
    ///   - title: What is missing or what went wrong, in a few words: "No accounts yet".
    ///   - description: One or two sentences: why, and what to do.
    ///   - icon: A 24 pt icon, drawn sharp.
    ///   - size: `page` for a whole screen, `section` inside a card or list.
    ///   - tone: `danger` colours the icon for an error.
    ///   - level: Makes the title a heading of this level (1–6) for VoiceOver; the look stays `size`'s.
    ///   - actions: Buttons under the description, in a centred row that wraps: one primary at most.
    ///   - footer: Under the actions in `body.sm`, `color.text.subtle`: a link to help, or a second way in.
    public init(
        title: Text, description: Text? = nil, icon: QeetrixIconName? = nil, size: QeetrixEmptyStateSize = .page,
        tone: QeetrixEmptyStateTone = .neutral, level: Int? = nil, @ViewBuilder actions: () -> Actions,
        @ViewBuilder footer: () -> Footer
    ) {
        self.init(
            title: title, description: description, icon: icon, size: size, tone: tone, level: level, actions: actions(), footer: footer())
    }

    /// An empty state with a localised title and description, actions and a footer.
    public init(
        _ titleKey: LocalizedStringKey, description: LocalizedStringKey? = nil, icon: QeetrixIconName? = nil,
        size: QeetrixEmptyStateSize = .page, tone: QeetrixEmptyStateTone = .neutral, level: Int? = nil,
        @ViewBuilder actions: () -> Actions, @ViewBuilder footer: () -> Footer
    ) {
        self.init(
            title: Text(titleKey), description: description.map { Text($0) }, icon: icon, size: size, tone: tone, level: level,
            actions: actions(), footer: footer())
    }

    /// An empty state with a title and description shown as given, actions and a footer.
    public init<S: StringProtocol>(
        _ title: S, description: String? = nil, icon: QeetrixIconName? = nil, size: QeetrixEmptyStateSize = .page,
        tone: QeetrixEmptyStateTone = .neutral, level: Int? = nil, @ViewBuilder actions: () -> Actions,
        @ViewBuilder footer: () -> Footer
    ) {
        self.init(
            title: Text(title), description: description.map { Text(verbatim: $0) }, icon: icon, size: size, tone: tone, level: level,
            actions: actions(), footer: footer())
    }

    /// An empty state that leads with the app's image — its icon on a Locked screen — in place of the
    /// icon, with actions and a footer. The image is decorative: hidden from VoiceOver.
    ///
    /// - Parameters:
    ///   - title: What happened or what is missing, in a few words: "Qeet ID is locked".
    ///   - description: One or two sentences: why, and what to do.
    ///   - image: The image at the size it is drawn, such as `Image("AppIcon").resizable().frame(width: 64,
    ///     height: 64)`; a template image takes `tone`'s colour.
    ///   - size: `page` for a whole screen, `section` inside a card or list.
    ///   - tone: The colour of a template image: `success` and `warning` for an outcome.
    ///   - level: Makes the title a heading of this level (1–6) for VoiceOver.
    ///   - actions: Buttons under the description, in a centred row that wraps: one primary at most.
    ///   - footer: Under the actions in `body.sm`, `color.text.subtle`.
    public init<Leading: View>(
        title: Text, description: Text? = nil, image: Leading, size: QeetrixEmptyStateSize = .page,
        tone: QeetrixEmptyStateTone = .neutral, level: Int? = nil, @ViewBuilder actions: () -> Actions,
        @ViewBuilder footer: () -> Footer
    ) {
        self.init(
            title: title, description: description, icon: nil, size: size, tone: tone, level: level, actions: actions(), footer: footer(),
            image: AnyView(image))
    }

    init(
        title: Text, description: Text?, icon: QeetrixIconName?, size: QeetrixEmptyStateSize, tone: QeetrixEmptyStateTone,
        level: Int?, actions: Actions?, footer: Footer?, image: AnyView? = nil
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.image = image
        self.size = size
        self.tone = tone
        self.level = level.map { min(max($0, 1), 6) }
        self.actions = actions
        self.footer = footer
    }

    /// Centres the column in all the height it is offered — an outcome or lock screen, where the message
    /// sits in the middle rather than at the top. In a scroll view, which offers no height, give
    /// the empty state the screen's height as its minimum.
    public func centredInHeight() -> Self {
        var centred = self
        centred.isCentredInHeight = true
        return centred
    }

    public var body: some View {
        // .qx-empty-state: a centred column, gap-sm apart.
        VStack(spacing: QeetrixSpace.gapSm) {
            if let image {
                image
                    .foregroundStyle(tone.iconColor)
                    // Decorative even when the app's view is an accessibility element of its own: nothing
                    // of it reaches VoiceOver.
                    .accessibilityRepresentation { EmptyView() }
                    .padding(.bottom, QeetrixSpace.gapXs)
            } else if let icon {
                QeetrixIcon(icon, size: .lg, shape: .sharp)
                    .foregroundStyle(tone.iconColor)
                    .padding(.bottom, QeetrixSpace.gapXs)  // .qx-empty-state-icon: margin-block-end gap-xs
            }
            titleText
            if let description {
                description
                    .qeetrixTextStyle(.bodyMd)
                    .foregroundStyle(QeetrixColor.textSubtle)
                    .modifier(QeetrixEmptyStateLine())
            }
            if let actions {
                // .qx-empty-state-actions: centred, wrapping, gap-sm apart, gap-sm under the text.
                QeetrixFeedbackActionsLayout(spacing: QeetrixSpace.gapSm, alignment: .center) { actions }
                    .padding(.top, QeetrixSpace.gapSm)
            }
            if let footer {
                // .qx-empty-state-footer: body.sm, color.text.subtle.
                footer
                    .qeetrixTypeEnvironment(QeetrixTypeSpec(.bodySm))
                    .foregroundStyle(QeetrixColor.textSubtle)
                    .multilineTextAlignment(.center)
            }
        }
        .foregroundStyle(QeetrixColor.textDefault)
        // padding: <size> var(--qx-space-inset-lg), inside max-inline-size: 480px; margin-inline: auto.
        .padding(.vertical, size.paddingBlock)
        .padding(.horizontal, QeetrixSpace.insetLg)
        .frame(maxWidth: QeetrixEmptyStateMetrics.maximumWidth)
        .frame(maxWidth: .infinity, maxHeight: isCentredInHeight ? .infinity : nil)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder private var titleText: some View {
        if let level {
            QeetrixHeading(title, level: level, size: size.headingSize, align: .center)
                .modifier(QeetrixEmptyStateLine())
        } else {
            title
                .qeetrixTextStyle(size.titleRole)
                .foregroundStyle(QeetrixColor.textDefault)
                .modifier(QeetrixEmptyStateLine())
        }
    }
}

extension QeetrixEmptyState where Footer == EmptyView {
    /// An empty state that leads with the app's image in place of the icon, with actions and no footer.
    public init<Leading: View>(
        title: Text, description: Text? = nil, image: Leading, size: QeetrixEmptyStateSize = .page,
        tone: QeetrixEmptyStateTone = .neutral, level: Int? = nil, @ViewBuilder actions: () -> Actions
    ) {
        self.init(
            title: title, description: description, icon: nil, size: size, tone: tone, level: level, actions: actions(), footer: nil,
            image: AnyView(image))
    }

    /// An empty state with actions and no footer.
    public init(
        title: Text, description: Text? = nil, icon: QeetrixIconName? = nil, size: QeetrixEmptyStateSize = .page,
        tone: QeetrixEmptyStateTone = .neutral, level: Int? = nil, @ViewBuilder actions: () -> Actions
    ) {
        self.init(
            title: title, description: description, icon: icon, size: size, tone: tone, level: level, actions: actions(), footer: nil)
    }

    /// An empty state with a localised title and description, and actions.
    public init(
        _ titleKey: LocalizedStringKey, description: LocalizedStringKey? = nil, icon: QeetrixIconName? = nil,
        size: QeetrixEmptyStateSize = .page, tone: QeetrixEmptyStateTone = .neutral, level: Int? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.init(
            title: Text(titleKey), description: description.map { Text($0) }, icon: icon, size: size, tone: tone, level: level,
            actions: actions(), footer: nil)
    }

    /// An empty state with a title and description shown as given, and actions.
    public init<S: StringProtocol>(
        _ title: S, description: String? = nil, icon: QeetrixIconName? = nil, size: QeetrixEmptyStateSize = .page,
        tone: QeetrixEmptyStateTone = .neutral, level: Int? = nil, @ViewBuilder actions: () -> Actions
    ) {
        self.init(
            title: Text(title), description: description.map { Text(verbatim: $0) }, icon: icon, size: size, tone: tone, level: level,
            actions: actions(), footer: nil)
    }
}

extension QeetrixEmptyState where Actions == EmptyView, Footer == EmptyView {
    /// An empty state that leads with the app's image in place of the icon, with neither actions nor a
    /// footer.
    public init<Leading: View>(
        title: Text, description: Text? = nil, image: Leading, size: QeetrixEmptyStateSize = .page,
        tone: QeetrixEmptyStateTone = .neutral, level: Int? = nil
    ) {
        self.init(
            title: title, description: description, icon: nil, size: size, tone: tone, level: level, actions: nil, footer: nil,
            image: AnyView(image))
    }

    /// An empty state with neither actions nor a footer.
    public init(
        title: Text, description: Text? = nil, icon: QeetrixIconName? = nil, size: QeetrixEmptyStateSize = .page,
        tone: QeetrixEmptyStateTone = .neutral, level: Int? = nil
    ) {
        self.init(title: title, description: description, icon: icon, size: size, tone: tone, level: level, actions: nil, footer: nil)
    }

    /// An empty state with a localised title and description, without actions.
    public init(
        _ titleKey: LocalizedStringKey, description: LocalizedStringKey? = nil, icon: QeetrixIconName? = nil,
        size: QeetrixEmptyStateSize = .page, tone: QeetrixEmptyStateTone = .neutral, level: Int? = nil
    ) {
        self.init(
            title: Text(titleKey), description: description.map { Text($0) }, icon: icon, size: size, tone: tone, level: level,
            actions: nil, footer: nil)
    }

    /// An empty state with a title and description shown as given, without actions.
    public init<S: StringProtocol>(
        _ title: S, description: String? = nil, icon: QeetrixIconName? = nil, size: QeetrixEmptyStateSize = .page,
        tone: QeetrixEmptyStateTone = .neutral, level: Int? = nil
    ) {
        self.init(
            title: Text(title), description: description.map { Text(verbatim: $0) }, icon: icon, size: size, tone: tone, level: level,
            actions: nil, footer: nil)
    }
}

enum QeetrixEmptyStateMetrics {
    /// empty-state.css: `.qx-empty-state { max-inline-size: 480px }`.
    static let maximumWidth: CGFloat = 480
}

/// A line of the empty state's text: centred, filling its line so that a right-to-left paragraph
/// centres the same way, and wrapping rather than truncating.
private struct QeetrixEmptyStateLine: ViewModifier {
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
    }
}

/// The actions of an empty state, centred (empty-state.css `.qx-empty-state-actions`), and of an alert,
/// from the start (alert.css `.qx-alert-actions`): rows `spacing` apart, wrapping when they don't fit.
/// An action wider than the row — a long label at the largest text sizes — is offered the row's width,
/// so its label wraps instead of overflowing.
struct QeetrixFeedbackActionsLayout: Layout {
    let spacing: CGFloat
    let alignment: HorizontalAlignment

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = rows(width: proposal.width ?? .infinity, subviews: subviews)
        let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(max(0, rows.count - 1))
        let natural = rows.map(\.width).max() ?? 0
        return CGSize(width: proposal.width.map { $0.isFinite ? $0 : natural } ?? natural, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in rows(width: bounds.width, subviews: subviews) {
            var x = alignment == .center ? bounds.midX - row.width / 2 : bounds.minX
            for (index, size) in zip(row.indices, row.sizes) {
                subviews[index].place(at: CGPoint(x: x, y: y + (row.height - size.height) / 2), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    struct Row {
        var indices: [Int] = []
        var sizes: [CGSize] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    func rows(width: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var row = Row()
        for index in subviews.indices {
            var size = subviews[index].sizeThatFits(.unspecified)
            if size.width > width {
                size = subviews[index].sizeThatFits(ProposedViewSize(width: width, height: nil))
            }
            if !row.indices.isEmpty, row.width + spacing + size.width > width {
                rows.append(row)
                row = Row()
            }
            row.width = row.indices.isEmpty ? size.width : row.width + spacing + size.width
            row.height = max(row.height, size.height)
            row.indices.append(index)
            row.sizes.append(size)
        }
        if !row.indices.isEmpty { rows.append(row) }
        return rows
    }
}
