import SwiftUI

/// What a ``QeetrixListItem`` shows at its end, after any trailing content.
public enum QeetrixListItemAccessory: String, CaseIterable, Sendable {
    /// Nothing: a row that acts in place, or only shows a value.
    case none
    /// The sharp `chevron-right` in `color.icon.subtle`, mirrored in right-to-left layouts: the row
    /// opens another screen.
    case chevron
}

/// A row of a collection — an account, a setting, a device, a file — with a title and, optionally, a
/// description, a value, a leading avatar or icon, trailing content and an accessory.
///
/// ```swift
/// List {
///     QeetrixListItem("Priya Sharma", description: Text(verbatim: "priya@acme.in"), value: Route.account(priya.id)) {
///         QeetrixAvatar(name: "Priya Sharma", isDecorative: true)
///     }
///     QeetrixListItem("Face ID", description: Text("Unlock Qeet Auth with your face"), isOn: $faceID) {
///         QeetrixListItemIcon(.scanLine)
///     }
///     QeetrixListItem("Language", metadata: Text("English"), accessory: .chevron) { showLanguages = true }
///     QeetrixListItem("Sign out", role: .destructive) { signOut() }
/// }
/// .qeetrixListStyle()
/// ```
///
/// `@qeetrix/react` has no list row — a web screen uses a Table where a phone uses a list — so this row
/// is iOS's, with qeetrix-android's API, drawn by the Table's row rules (design rules §15): at least
/// the density's `size.row` and 44 pt tall, `space.gap.xs` above and below its content, the page
/// gutter (`space.inset.lg`) at the sides, `space.gap.md` between its parts, a neutral tint when
/// pressed or under the pointer and the Ember tint (`color.bg.selected`) when selected. The title is
/// `label.md`, the description and the value `body.sm` in `color.text.subtle`, the value in tabular
/// figures at the end of the title's line.
///
/// - **What it does comes from its initialiser.** With `action` it is a button, and `role:
///   .destructive` draws its title and icon in the danger colours; with `value` it is a
///   `NavigationLink` with the chevron; with `isOn` the whole row toggles the trailing switch; with
///   none of them it only shows its content. Disabled comes from `disabled(_:)`.
/// - **Selection is the app's.** `isSelected` is the Ember tint — "chosen for an action", not the
///   current item — and VoiceOver reads the row as selected. So that it isn't colour alone (§11), mark
///   it too: a sharp `check` in `trailing`, as iOS marks a chosen option.
/// - **VoiceOver** reads the row as one element: the title, the description, the value, then any text
///   in `leading` and `trailing`. Give a leading avatar `isDecorative` when the title names the person.
///   A control in `trailing` becomes part of the row: VoiceOver reads its name with the row's and
///   offers it as the row's action. Prefer `qeetrixSwipeActions(edge:allowsFullSwipe:actions:)`, applied
///   from outside, which also offers the actions to VoiceOver and in the row's context menu.
/// - **Large text.** Every text wraps; at the accessibility sizes the trailing content moves below the
///   text and the value below the description.
///
/// In a `List` the row draws its own insets, sits on `color.surface.raised`, and tints the list's
/// separator `color.border.subtle`, edge to edge; `qeetrixListStyle()` gives the list itself the
/// plain, ruled look. In a stack, put a ``QeetrixSeparator`` between rows. The list's own behaviours —
/// swipe actions (`qeetrixSwipeActions`), pull to refresh (`qeetrixRefreshable`), `onDelete`, selection
/// in edit mode — are left to it: apply them to the row or the list.
public struct QeetrixListItem<Leading: View, Trailing: View>: View {
    let title: Text
    let description: Text?
    let metadata: Text?
    let accessory: QeetrixListItemAccessory
    let isSelected: Bool
    let control: QeetrixListItemControl<QeetrixListItemContent<Leading, Trailing>>
    let leading: Leading
    let trailing: Trailing
    @Environment(\.colorScheme) private var colorScheme

    init(
        title: Text, description: Text?, metadata: Text?, accessory: QeetrixListItemAccessory, isSelected: Bool,
        control: QeetrixListItemControl<QeetrixListItemContent<Leading, Trailing>>, leading: () -> Leading, trailing: () -> Trailing
    ) {
        self.title = title
        self.description = description
        self.metadata = metadata
        self.accessory = accessory
        self.isSelected = isSelected
        self.control = control
        self.leading = leading()
        self.trailing = trailing()
    }

    public var body: some View {
        row
            // The row draws its own insets, so its tints reach the cell's edges.
            .listRowInsets(EdgeInsets())
            .listRowBackground(Rectangle().fill(QeetrixColor.surfaceRaised))
            // §15: rows are ruled in border.subtle, edge to edge, as a table's are.
            .listRowSeparatorTint(QeetrixColor.borderSubtle.color(for: colorScheme))
            .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
    }

    @ViewBuilder private var row: some View {
        switch control {
        case .none:
            content(end: QeetrixListItemEnd(accessory))
                .background { if isSelected { Rectangle().fill(QeetrixColor.bgSelected) } }
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
        case let .button(role, action):
            Button(role: role, action: action) {
                content(end: QeetrixListItemEnd(accessory))
            }
            .buttonStyle(QeetrixListItemButtonStyle(isSelected: isSelected))
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        case let .link(link):
            link(content(end: .chevron))
                .buttonStyle(QeetrixListItemButtonStyle())
                // The row draws its own chevron; a List would add the system's as well.
                .navigationLinkIndicatorVisibility(.hidden)
        case let .toggle(isOn):
            Button {
                isOn.wrappedValue.toggle()
            } label: {
                content(end: .switch(isOn: isOn.wrappedValue))
            }
            .buttonStyle(QeetrixListItemButtonStyle())
            // VoiceOver gets the system switch: "Face ID, switch button, on".
            .accessibilityRepresentation {
                Toggle(isOn: isOn) { content(end: .none) }
            }
        }
    }

    private func content(end: QeetrixListItemEnd) -> QeetrixListItemContent<Leading, Trailing> {
        QeetrixListItemContent(
            title: title, description: description, metadata: metadata, end: end, leading: leading, trailing: trailing)
    }
}

// MARK: - A row that shows its content

extension QeetrixListItem {
    /// A row that only shows its content, with a localised title. It is also the label of a `Button`,
    /// `NavigationLink`, `ShareLink` or `Menu` styled with ``QeetrixListItemButtonStyle``.
    ///
    /// - Parameters:
    ///   - titleKey: What the row is: a person's name, a setting.
    ///   - description: A second line under the title, `body.sm` in `color.text.subtle`.
    ///   - metadata: A short value at the end of the title's line — a setting's value, a time, a size,
    ///     a count — in `body.sm`, tabular figures.
    ///   - accessory: What the row shows at its end.
    ///   - isSelected: Draws the Ember tint and reads the row as selected.
    ///   - leading: Before the text: a ``QeetrixListItemIcon`` or a ``QeetrixAvatar``.
    ///   - trailing: After the text: a badge, a short text, a spinner.
    public init(
        _ titleKey: LocalizedStringKey,
        description: Text? = nil,
        metadata: Text? = nil,
        accessory: QeetrixListItemAccessory = .none,
        isSelected: Bool = false,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.init(
            title: Text(titleKey), description: description, metadata: metadata, accessory: accessory, isSelected: isSelected,
            leading: leading, trailing: trailing)
    }

    /// A row that only shows its content, with a title shown as given.
    public init<S: StringProtocol>(
        _ title: S,
        description: Text? = nil,
        metadata: Text? = nil,
        accessory: QeetrixListItemAccessory = .none,
        isSelected: Bool = false,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.init(
            title: Text(title), description: description, metadata: metadata, accessory: accessory, isSelected: isSelected,
            leading: leading, trailing: trailing)
    }

    /// A row that only shows its content, with a `Text` title.
    public init(
        title: Text,
        description: Text? = nil,
        metadata: Text? = nil,
        accessory: QeetrixListItemAccessory = .none,
        isSelected: Bool = false,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.init(
            title: title, description: description, metadata: metadata, accessory: accessory, isSelected: isSelected, control: .none,
            leading: leading, trailing: trailing)
    }
}

// MARK: - A row that is a button

extension QeetrixListItem {
    /// A row that is a button, with a localised title.
    ///
    /// - Parameters:
    ///   - titleKey: What the row does.
    ///   - description: A second line under the title.
    ///   - metadata: A short value at the end of the title's line.
    ///   - accessory: `.chevron` when the action opens another screen — pushing onto the app's
    ///     navigation path, say.
    ///   - isSelected: Draws the Ember tint and reads the row as selected: a row that toggles its
    ///     selection when tapped.
    ///   - role: `.destructive` draws the title in `color.text.danger` and a ``QeetrixListItemIcon`` in
    ///     `color.icon.danger`. Put destructive rows last.
    ///   - action: What a tap does.
    ///   - leading: Before the text: a ``QeetrixListItemIcon`` or a ``QeetrixAvatar``.
    ///   - trailing: After the text: a badge, a short text, a spinner.
    public init(
        _ titleKey: LocalizedStringKey,
        description: Text? = nil,
        metadata: Text? = nil,
        accessory: QeetrixListItemAccessory = .none,
        isSelected: Bool = false,
        role: ButtonRole? = nil,
        action: @escaping @MainActor () -> Void,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.init(
            title: Text(titleKey), description: description, metadata: metadata, accessory: accessory, isSelected: isSelected,
            role: role, action: action, leading: leading, trailing: trailing)
    }

    /// A row that is a button, with a title shown as given.
    public init<S: StringProtocol>(
        _ title: S,
        description: Text? = nil,
        metadata: Text? = nil,
        accessory: QeetrixListItemAccessory = .none,
        isSelected: Bool = false,
        role: ButtonRole? = nil,
        action: @escaping @MainActor () -> Void,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.init(
            title: Text(title), description: description, metadata: metadata, accessory: accessory, isSelected: isSelected,
            role: role, action: action, leading: leading, trailing: trailing)
    }

    /// A row that is a button, with a `Text` title.
    public init(
        title: Text,
        description: Text? = nil,
        metadata: Text? = nil,
        accessory: QeetrixListItemAccessory = .none,
        isSelected: Bool = false,
        role: ButtonRole? = nil,
        action: @escaping @MainActor () -> Void,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.init(
            title: title, description: description, metadata: metadata, accessory: accessory, isSelected: isSelected,
            control: .button(role: role, action: action), leading: leading, trailing: trailing)
    }
}

// MARK: - A row that opens another screen

extension QeetrixListItem {
    /// A row that opens another screen — a `NavigationLink` that presents `value` — with a localised
    /// title and the chevron. The destination is the app's `navigationDestination(for:)`.
    public init<P: Hashable>(
        _ titleKey: LocalizedStringKey,
        description: Text? = nil,
        metadata: Text? = nil,
        value: P?,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.init(title: Text(titleKey), description: description, metadata: metadata, value: value, leading: leading, trailing: trailing)
    }

    /// A row that opens another screen, with a title shown as given.
    public init<S: StringProtocol, P: Hashable>(
        _ title: S,
        description: Text? = nil,
        metadata: Text? = nil,
        value: P?,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.init(title: Text(title), description: description, metadata: metadata, value: value, leading: leading, trailing: trailing)
    }

    /// A row that opens another screen, with a `Text` title.
    public init<P: Hashable>(
        title: Text,
        description: Text? = nil,
        metadata: Text? = nil,
        value: P?,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.init(
            title: title, description: description, metadata: metadata, accessory: .chevron, isSelected: false,
            control: .link { label in NavigationLink(value: value) { label } }, leading: leading, trailing: trailing)
    }
}

// MARK: - A row that toggles a setting

extension QeetrixListItem {
    /// A setting that applies at once, with a localised title: the whole row toggles the Qeetrix switch
    /// at its end, and VoiceOver reads it as the system's switch.
    public init(
        _ titleKey: LocalizedStringKey,
        description: Text? = nil,
        metadata: Text? = nil,
        isOn: Binding<Bool>,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.init(title: Text(titleKey), description: description, metadata: metadata, isOn: isOn, leading: leading, trailing: trailing)
    }

    /// A setting that applies at once, with a title shown as given.
    public init<S: StringProtocol>(
        _ title: S,
        description: Text? = nil,
        metadata: Text? = nil,
        isOn: Binding<Bool>,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.init(title: Text(title), description: description, metadata: metadata, isOn: isOn, leading: leading, trailing: trailing)
    }

    /// A setting that applies at once, with a `Text` title.
    public init(
        title: Text,
        description: Text? = nil,
        metadata: Text? = nil,
        isOn: Binding<Bool>,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.init(
            title: title, description: description, metadata: metadata, accessory: .none, isSelected: false, control: .toggle(isOn),
            leading: leading, trailing: trailing)
    }
}

// MARK: - The button style

/// The list row look for any `Button`, `NavigationLink`, `ShareLink` or `Menu` whose label is a
/// ``QeetrixListItem``: a neutral tint when pressed (`color.bg.neutral.subtle-hover`) or under the
/// pointer (`color.bg.neutral.subtle`), the Ember tint when selected, and keyboard focus as the 2 pt
/// Ember frame inside the row (design rules §10, §15). A button's `.destructive` role turns the row's
/// title and icon to the danger colours.
///
/// ```swift
/// ShareLink(item: inviteURL) {
///     QeetrixListItem("Invite a teammate") { QeetrixListItemIcon(.userPlus) }
/// }
/// .buttonStyle(.qeetrixListItem())
/// ```
///
/// In a `List`, a `NavigationLink` styled this way also needs `navigationLinkIndicatorVisibility(.hidden)`,
/// or the list adds its chevron to the row's; ``QeetrixListItem``'s `value:` initialiser does both.
public struct QeetrixListItemButtonStyle: ButtonStyle {
    let isSelected: Bool

    /// - Parameter isSelected: Draws the Ember tint and reads the row as selected.
    public init(isSelected: Bool = false) {
        self.isSelected = isSelected
    }

    public func makeBody(configuration: Configuration) -> some View {
        QeetrixListItemButtonBody(configuration: configuration, isSelected: isSelected)
    }
}

extension ButtonStyle where Self == QeetrixListItemButtonStyle {
    /// The Qeetrix list row as a button style.
    public static func qeetrixListItem(isSelected: Bool = false) -> QeetrixListItemButtonStyle {
        QeetrixListItemButtonStyle(isSelected: isSelected)
    }
}

private struct QeetrixListItemButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let isSelected: Bool
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        configuration.label
            .environment(\.qeetrixListItemIsDestructive, configuration.role == .destructive)
            .background {
                if let fill = QeetrixListItemMetrics.background(
                    isSelected: isSelected, isPressed: configuration.isPressed, isHovered: isHovered, isEnabled: isEnabled)
                {
                    Rectangle().fill(fill)
                }
            }
            // Table rows: the focus frame inside the row (design rules §10).
            .overlay {
                if isFocused {
                    Rectangle().strokeBorder(QeetrixColor.borderFocus, lineWidth: QeetrixFocus.ringWidth).accessibilityHidden(true)
                }
            }
            .contentShape(Rectangle())
            .onHover { isHovered = $0 }
            .qeetrixAnimation(.standard, .fast, value: configuration.isPressed)
            .qeetrixAnimation(.standard, .fast, value: isHovered)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - The row's parts

/// A row's 32 pt icon tile, for a ``QeetrixListItem``'s `leading` content — a `md` avatar's size, so a
/// list of settings and a list of people line up. Drawn as the Timeline's marker (timeline.css
/// `.qx-timeline-marker`): `color.bg.neutral.subtle` inside a 1 pt `color.border.subtle` edge, 4 pt
/// corners (`radius.control`), and a 16 pt sharp icon in `color.icon.subtle` — `color.icon.danger` in a
/// destructive row, `color.icon.disabled` in a disabled one. The tile grows with the icon at larger
/// text sizes. Decorative: the row's text says what it is.
public struct QeetrixListItemIcon: View {
    let icon: QeetrixIconName
    @ScaledMetric(relativeTo: .body) private var side = QeetrixListItemMetrics.iconTile
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.qeetrixListItemIsDestructive) private var isDestructive

    public init(_ icon: QeetrixIconName) {
        self.icon = icon
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.control)
        QeetrixIcon(icon, size: .sm, shape: .sharp)
            .foregroundStyle(color)
            .frame(width: side, height: side)
            .background(QeetrixColor.bgNeutralSubtle, in: shape)
            // box-shadow: inset 0 0 0 border.width.default border.subtle
            .overlay { shape.strokeBorder(QeetrixColor.borderSubtle, lineWidth: QeetrixBorderWidth.default) }
            .accessibilityHidden(true)
    }

    var color: QeetrixColor {
        QeetrixListItemMetrics.iconColor(isEnabled: isEnabled, isDestructive: isDestructive)
    }
}

/// What a row does: its control, built by its initialiser.
enum QeetrixListItemControl<Label: View> {
    case none
    case button(role: ButtonRole?, action: @MainActor () -> Void)
    case link(@MainActor (Label) -> NavigationLink<Label, Never>)
    case toggle(Binding<Bool>)
}

/// What a row draws at its end.
enum QeetrixListItemEnd: Equatable {
    case none
    case chevron
    case `switch`(isOn: Bool)

    init(_ accessory: QeetrixListItemAccessory) {
        switch accessory {
        case .none: self = .none
        case .chevron: self = .chevron
        }
    }
}

/// The row as drawn: leading content, the text, trailing content and the end, in the row's padding.
struct QeetrixListItemContent<Leading: View, Trailing: View>: View {
    let title: Text
    let description: Text?
    let metadata: Text?
    let end: QeetrixListItemEnd
    let leading: Leading
    let trailing: Trailing
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixListItemIsDestructive) private var isDestructive

    var body: some View {
        let isLarge = dynamicTypeSize.isAccessibilitySize
        let hasTrailing = Trailing.self != EmptyView.self
        HStack(alignment: isLarge ? .top : .center, spacing: QeetrixSpace.gapMd) {
            leading
            if isLarge && hasTrailing {
                // From the accessibility sizes the trailing content moves below the text instead of
                // squeezing it, as qeetrix-android's row does from 150 %.
                VStack(alignment: .leading, spacing: QeetrixSpace.gapSm) {
                    text(isStacked: true)
                    trailing
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                text(isStacked: isLarge)
                    .frame(maxWidth: .infinity, alignment: .leading)
                trailing
            }
            endView
        }
        .padding(.horizontal, QeetrixListItemMetrics.inlinePadding)
        .padding(.vertical, QeetrixListItemMetrics.blockPadding)
        .frame(maxWidth: .infinity, minHeight: QeetrixListItemMetrics.minimumHeight(density), alignment: .leading)
        .contentShape(Rectangle())
    }

    private func text(isStacked: Bool) -> some View {
        let subtle = isEnabled ? QeetrixColor.textSubtle : QeetrixColor.textSubtlest
        return QeetrixListItemTextLayout(isStacked: isStacked, gap: QeetrixSpace.gapSm) {
            title
                .qeetrixTextStyle(.labelMd)
                .foregroundStyle(QeetrixListItemMetrics.titleColor(isEnabled: isEnabled, isDestructive: isDestructive))
                .fixedSize(horizontal: false, vertical: true)
                .layoutValue(key: QeetrixListItemTextPart.self, value: .title)
            if let description {
                description
                    .qeetrixTextStyle(.bodySm)
                    .foregroundStyle(subtle)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutValue(key: QeetrixListItemTextPart.self, value: .description)
            }
            if let metadata {
                // §5, §15: numbers in tabular figures.
                metadata
                    .qeetrixTextStyle(.bodySm)
                    .monospacedDigit()
                    .foregroundStyle(subtle)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutValue(key: QeetrixListItemTextPart.self, value: .metadata)
            }
        }
    }

    @ViewBuilder private var endView: some View {
        switch end {
        case .none:
            EmptyView()
        case .chevron:
            // menu.css `.qx-menu-submenu-icon`: icon.subtle, and `[dir="rtl"] { scale: -1 1 }` — the
            // icon itself is `preserve`, so the row mirrors it.
            QeetrixIcon(.chevronRight, size: .sm, shape: .sharp)
                .foregroundStyle(isEnabled ? QeetrixColor.iconSubtle : QeetrixColor.iconDisabled)
                .flipsForRightToLeftLayoutDirection(true)
        case let .switch(isOn):
            QeetrixSwitchTrack(isOn: isOn, isHovered: false, isEnabled: isEnabled)
        }
    }
}

/// Which text of a row a subview of ``QeetrixListItemTextLayout`` is.
enum QeetrixListItemTextPart: LayoutValueKey {
    case title
    case description
    case metadata

    static let defaultValue = QeetrixListItemTextPart.title
}

/// The title with the value at the end of its line, on the same first baseline, and the description
/// below — qeetrix-android's row text. The value takes at most half the width and wraps; stacked (at
/// the accessibility sizes) it follows the description instead. Subviews are given in reading order —
/// title, description, value — which is the order VoiceOver reads them in.
struct QeetrixListItemTextLayout: Layout {
    let isStacked: Bool
    let gap: CGFloat

    struct Frames {
        var title: CGRect = .zero
        var description: CGRect?
        var metadata: CGRect?
        var size: CGSize = .zero
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        frames(width: proposal.width, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let frames = frames(width: bounds.width, subviews: subviews)
        for subview in subviews {
            let frame: CGRect? =
                switch subview[QeetrixListItemTextPart.self] {
                case .title: frames.title
                case .description: frames.description
                case .metadata: frames.metadata
                }
            guard let frame else { continue }
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }

    func frames(width proposed: CGFloat?, subviews: Subviews) -> Frames {
        func part(_ part: QeetrixListItemTextPart) -> LayoutSubview? {
            subviews.first { $0[QeetrixListItemTextPart.self] == part }
        }
        let title = part(.title)
        let description = part(.description)
        let metadata = part(.metadata)
        // Without a width (an ideal size), each text takes its own.
        let width =
            proposed.flatMap { $0.isFinite ? $0 : nil }
            ?? [title, description, metadata].compactMap { $0?.sizeThatFits(.unspecified).width }.max() ?? 0
        var frames = Frames()
        func measure(_ subview: LayoutSubview, _ width: CGFloat) -> CGSize {
            CGSize(width: width, height: subview.sizeThatFits(ProposedViewSize(width: width, height: nil)).height)
        }

        if isStacked {
            var y: CGFloat = 0
            func stack(_ subview: LayoutSubview?) -> CGRect? {
                guard let subview else { return nil }
                let size = measure(subview, width)
                defer { y += size.height }
                return CGRect(origin: CGPoint(x: 0, y: y), size: size)
            }
            frames.title = stack(title) ?? .zero
            frames.description = stack(description)
            frames.metadata = stack(metadata)
            frames.size = CGSize(width: width, height: y)
            return frames
        }

        // The value: at most half the width, at its own width when it fits, at the end of the line.
        var metaSize = CGSize.zero
        if let metadata {
            let ideal = metadata.sizeThatFits(.unspecified)
            let available = width / 2
            metaSize =
                ideal.width <= available
                ? ideal : CGSize(width: available, height: metadata.sizeThatFits(ProposedViewSize(width: available, height: nil)).height)
        }
        let titleWidth = max(0, width - (metadata == nil ? 0 : metaSize.width + gap))
        // The texts fill their width rather than their content, so a right-to-left paragraph aligns to
        // its start.
        let titleSize = title.map { measure($0, titleWidth) } ?? .zero
        var top: CGFloat = 0
        var metaY: CGFloat = 0
        if let metadata, let title {
            // On the title's first baseline.
            let titleBaseline = title.dimensions(in: ProposedViewSize(titleSize))[VerticalAlignment.firstTextBaseline]
            let metaBaseline = metadata.dimensions(in: ProposedViewSize(metaSize))[VerticalAlignment.firstTextBaseline]
            metaY = titleBaseline - metaBaseline
            top = min(0, metaY)
        }
        let lineHeight = max(titleSize.height, metadata == nil ? 0 : metaSize.height + metaY) - top
        frames.title = CGRect(origin: CGPoint(x: 0, y: -top), size: titleSize)
        if metadata != nil {
            frames.metadata = CGRect(origin: CGPoint(x: width - metaSize.width, y: metaY - top), size: metaSize)
        }
        var height = lineHeight
        if let description {
            let size = measure(description, width)
            frames.description = CGRect(origin: CGPoint(x: 0, y: lineHeight), size: size)
            height += size.height
        }
        frames.size = CGSize(width: width, height: height)
        return frames
    }
}

/// The row's metrics and colours, from the Table's rows (design rules §15) and qeetrix-android's row.
enum QeetrixListItemMetrics {
    /// The page gutter on a phone, `space.inset.lg` (the Sidebar item's `padding-inline-start`).
    static let inlinePadding = QeetrixSpace.insetLg
    /// Table cells' `space.gap.xs` above and below.
    static let blockPadding = QeetrixSpace.gapXs
    /// A `md` avatar's side: a row's two lines (`label.md` and `body.sm`) are this tall.
    static let iconTile: CGFloat = 32

    /// The density's `size.row` — 32 / 40 / 48 pt — and never under the 44 pt touch target.
    static func minimumHeight(_ density: QeetrixDensity) -> CGFloat {
        max(density.sizeRow, QeetrixAccessibility.minimumTouchTarget)
    }

    /// `.qx-table-row`: `bg.selected` when selected, kept under the pointer, a step darker while
    /// pressed; otherwise `bg.neutral.subtle` under the pointer. A touch has no hover, so a press takes
    /// the next step, as a button's does.
    static func background(isSelected: Bool, isPressed: Bool, isHovered: Bool, isEnabled: Bool) -> QeetrixColor? {
        let isPressed = isPressed && isEnabled
        let isHovered = isHovered && isEnabled
        if isSelected { return isPressed ? .bgSelectedHover : .bgSelected }
        if isPressed { return .bgNeutralSubtleHover }
        if isHovered { return .bgNeutralSubtle }
        return nil
    }

    /// menu.css `[data-tone="danger"]`: `text.danger`; `[data-disabled]`: `text.disabled`.
    static func titleColor(isEnabled: Bool, isDestructive: Bool) -> QeetrixColor {
        if !isEnabled { return .textDisabled }
        return isDestructive ? .textDanger : .textDefault
    }

    /// menu.css: `icon.subtle`, `icon.danger` in a danger item, `icon.disabled` in a disabled one.
    static func iconColor(isEnabled: Bool, isDestructive: Bool) -> QeetrixColor {
        if !isEnabled { return .iconDisabled }
        return isDestructive ? .iconDanger : .iconSubtle
    }
}

private struct QeetrixListItemIsDestructiveKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// Whether the row is a destructive button's label: set by ``QeetrixListItemButtonStyle`` from the
    /// button's role.
    var qeetrixListItemIsDestructive: Bool {
        get { self[QeetrixListItemIsDestructiveKey.self] }
        set { self[QeetrixListItemIsDestructiveKey.self] = newValue }
    }
}

extension View {
    /// Gives a `List` the Qeetrix look for ``QeetrixListItem`` rows: the plain style — square and ruled,
    /// as Qeetrix's tables are (design rules §3, §15) — on the page's `color.surface.canvas`. The list's
    /// own behaviours stay as they are.
    public func qeetrixListStyle() -> some View {
        listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(QeetrixColor.surfaceCanvas)
    }
}
