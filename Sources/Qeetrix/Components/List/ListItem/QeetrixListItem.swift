import SwiftUI

/// A row of a collection — a file, a member, a setting, a device — with a title and, optionally, a
/// description, metadata, a leading view and a trailing view.
///
/// ```swift
/// List(files) { file in
///     NavigationLink(value: file) {
///         QeetrixListItem(file.name, description: Text(file.owner), icon: .fileText) {
///             QeetrixBadge("Shared", variant: .secondary)
///         }
///     }
///     .qeetrixListRow()
/// }
///
/// QeetrixListItem("Asha Rao", description: Text("asha@example.com")) {
///     QeetrixBadge("Owner", variant: .brand)
/// } leading: {
///     QeetrixAvatar(name: "Asha Rao")
/// }
/// ```
///
/// The row presents; it doesn't act. Make it interactive the native way — wrap it in a `NavigationLink`
/// or a `Button`, and add `swipeActions` or a `contextMenu` — so the row keeps the system's highlight,
/// disclosure, keyboard and VoiceOver behaviour. Your data, its identity (`ForEach`/`List` with your
/// `id`) and what happens on a tap stay yours.
///
/// - **Inside a `List`** it sets its own insets and row background, so the separator lines up under the
///   title and a selected row is tinted edge to edge. A list reads those from the row's outermost view,
///   so a row wrapped in a `NavigationLink` or a `Button` needs `qeetrixListRow()` on the
///   link or button.
/// - **Outside a `List`** — in a card, a sheet — stack rows in a `VStack(spacing: 0)` with
///   ``QeetrixSeparator`` between them, and give buttons the ``QeetrixListItemButtonStyle``.
/// - **Selection** is yours too: pass `isSelected` and the row is tinted with the brand, marked by a
///   2 pt edge and reported as selected to VoiceOver — as the web table's selected row.
/// - **Large text.** At the accessibility sizes the trailing view moves below the text instead of
///   squeezing it.
///
/// For a setting that is a switch, use ``QeetrixSwitch`` as the row: it is the label and the control in
/// one 44 pt target.
///
/// VoiceOver reads the title, description and metadata as one element; the leading view is read on its
/// own unless it is decorative (an icon), and controls in the trailing view stay separately reachable. A
/// row wrapped in a button is one button. Don't put a button in the trailing view of a row that is itself
/// a button: use swipe actions, a context menu or a ``QeetrixMenu`` beside the row instead.
public struct QeetrixListItem<Leading: View, Trailing: View>: View {
    let title: Text
    let description: Text?
    let metadata: Text?
    let isSelected: Bool
    let leading: Leading
    let trailing: Trailing
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.qeetrixListRowInset) private var rowInset

    /// A row with a localised title.
    ///
    /// - Parameters:
    ///   - titleKey: The title, looked up in the main bundle.
    ///   - description: A second line, muted.
    ///   - metadata: A short note at the trailing end of the title line — a time, a size, a count.
    ///   - isSelected: Draws the row as selected.
    ///   - trailing: A view after the text — a ``QeetrixBadge``, a value, a ``QeetrixSwitch``. The
    ///     unlabelled trailing closure.
    ///   - leading: A view before the text — a ``QeetrixListItemIcon``, a ``QeetrixAvatar``.
    public init(
        _ titleKey: LocalizedStringKey,
        description: Text? = nil,
        metadata: Text? = nil,
        isSelected: Bool = false,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() },
        @ViewBuilder leading: () -> Leading = { EmptyView() }
    ) {
        self.init(
            title: Text(titleKey), description: description, metadata: metadata, isSelected: isSelected, trailing: trailing,
            leading: leading)
    }

    /// A row with a title shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        description: Text? = nil,
        metadata: Text? = nil,
        isSelected: Bool = false,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() },
        @ViewBuilder leading: () -> Leading = { EmptyView() }
    ) {
        self.init(
            title: Text(title), description: description, metadata: metadata, isSelected: isSelected, trailing: trailing,
            leading: leading)
    }

    /// A row with a `Text` title.
    public init(
        title: Text,
        description: Text? = nil,
        metadata: Text? = nil,
        isSelected: Bool = false,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() },
        @ViewBuilder leading: () -> Leading = { EmptyView() }
    ) {
        self.title = title
        self.description = description
        self.metadata = metadata
        self.isSelected = isSelected
        self.leading = leading()
        self.trailing = trailing()
    }

    public var body: some View {
        let trailingBelow = dynamicTypeSize.isAccessibilitySize
        let layout =
            trailingBelow
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: QeetrixWebScale.spacing(2)))
            : AnyLayout(HStackLayout(alignment: .center, spacing: QeetrixWebScale.spacing(3)))
        HStack(alignment: trailingBelow ? .top : .center, spacing: QeetrixWebScale.spacing(3)) {  // gap-3
            leading
            layout {
                text
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
                trailing
            }
        }
        // In a row that qeetrixListRow() set up, the list's trailing inset is the trailing padding — so a
        // link's chevron keeps its margin — and the selection reaches across it.
        .padding(.leading, QeetrixListItemMetrics.horizontalPadding)
        .padding(.trailing, QeetrixListItemMetrics.horizontalPadding - rowInset)
        .padding(.vertical, density.cellPaddingY)
        .frame(maxWidth: .infinity, minHeight: max(density.rowHeight, QeetrixAccessibility.minimumTouchTarget), alignment: .leading)
        .background {
            if isSelected { QeetrixListItemSelection().padding(.trailing, -rowInset) }
        }
        .opacity(isEnabled ? 1 : QeetrixOpacity.disabled)
        .contentShape(Rectangle())
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: rowInset))
        .listRowBackground(Rectangle().fill(QeetrixColor.surfaceDefault))
    }

    private var text: some View {
        VStack(alignment: .leading, spacing: QeetrixWebScale.spacing(0.5)) {  // gap-0.5
            HStack(alignment: .firstTextBaseline, spacing: QeetrixWebScale.spacing(2)) {  // gap-2
                title
                    .qeetrixType(QeetrixListItemMetrics.titleType)
                    .foregroundStyle(QeetrixColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilitySortPriority(3)
                if let metadata {
                    metadata
                        .qeetrixType(QeetrixListItemMetrics.metadataType)
                        .monospacedDigit()  // tabular-nums
                        .foregroundStyle(QeetrixColor.textTertiary)
                        .fixedSize()  // shrink-0
                        .accessibilitySortPriority(1)
                }
            }
            if let description {
                // Read before the metadata: the title, what it is, then the note.
                description
                    .qeetrixType(QeetrixListItemMetrics.descriptionType)
                    .foregroundStyle(QeetrixColor.textTertiary)  // text-muted-foreground
                    .accessibilitySortPriority(2)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

extension View {
    /// Makes this view a Qeetrix list row: the ``QeetrixListItem`` inside supplies the insets, in place of
    /// the list's, on the Qeetrix row surface. Apply it to a `NavigationLink` or `Button` whose label is a
    /// list item, alongside your `swipeActions` and `contextMenu`:
    ///
    /// ```swift
    /// ForEach(files) { file in
    ///     NavigationLink(value: file) { QeetrixListItem(file.name, icon: .fileText) }
    ///         .qeetrixListRow()
    /// }
    /// ```
    ///
    /// A list takes row insets and backgrounds from a row's outermost view, which a list item inside a
    /// link or a button is not. A list item that is itself the row needs nothing: it does this already.
    public func qeetrixListRow() -> some View {
        let inset = QeetrixListItemMetrics.horizontalPadding
        return listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: inset))
            .listRowBackground(Rectangle().fill(QeetrixColor.surfaceDefault))
            .environment(\.qeetrixListRowInset, inset)
    }
}

private struct QeetrixListRowInsetKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    /// The trailing inset `qeetrixListRow()` leaves to the list, which the list item inside takes off its
    /// own padding.
    var qeetrixListRowInset: CGFloat {
        get { self[QeetrixListRowInsetKey.self] }
        set { self[QeetrixListRowInsetKey.self] = newValue }
    }
}

/// A row's 32 pt icon tile, for the leading slot of a ``QeetrixListItem``: the icon, muted, on the
/// sunken surface — as on the web's notification row and empty state. Decorative: the row's text says
/// what it is.
public struct QeetrixListItemIcon: View {
    let icon: QeetrixIconName
    @ScaledMetric(relativeTo: .subheadline) private var side = QeetrixWebScale.spacing(8)  // size-8

    /// - Parameter icon: The icon.
    public init(_ icon: QeetrixIconName) {
        self.icon = icon
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixCorner.chip)  // rounded-md
        QeetrixIcon(icon, size: QeetrixIconSize(side / 2), relativeTo: nil)  // [&>svg]:size-4
            .foregroundStyle(QeetrixColor.textTertiary)
            .frame(width: side, height: side)
            .background(QeetrixColor.surfaceSunken, in: shape)
            .overlay { shape.strokeBorder(QeetrixColor.borderSubtle, lineWidth: QeetrixStroke.hairline) }
            .accessibilityHidden(true)
    }
}

extension QeetrixListItem where Leading == QeetrixListItemIcon {
    /// A row with a localised title and an icon tile.
    public init(
        _ titleKey: LocalizedStringKey,
        description: Text? = nil,
        metadata: Text? = nil,
        icon: QeetrixIconName,
        isSelected: Bool = false,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.init(
            title: Text(titleKey), description: description, metadata: metadata, isSelected: isSelected,
            trailing: trailing, leading: { QeetrixListItemIcon(icon) })
    }

    /// A row with a title shown as given, without localisation, and an icon tile.
    public init<S: StringProtocol>(
        _ title: S,
        description: Text? = nil,
        metadata: Text? = nil,
        icon: QeetrixIconName,
        isSelected: Bool = false,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.init(
            title: Text(title), description: description, metadata: metadata, isSelected: isSelected,
            trailing: trailing, leading: { QeetrixListItemIcon(icon) })
    }
}

/// The selected row: the brand tint, and a 2 pt brand edge at the leading side, so selection is a shape
/// as well as a colour — the web table's selected row (`row-background-selected`, `row-indicator`).
struct QeetrixListItemSelection: View {
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle().fill(QeetrixColor.surfaceBrandSubtle)
            Rectangle().fill(QeetrixColor.borderBrand).frame(width: QeetrixStroke.thin)
        }
        .accessibilityHidden(true)
    }
}

/// A button whose label is a ``QeetrixListItem``, outside a `List`: the row's surface highlights while
/// pressed and under a pointer, edge to edge. Inside a `List` the system highlights the row; you don't
/// need this style there.
///
/// ```swift
/// Button { open(file) } label: {
///     QeetrixListItem(file.name, icon: .fileText)
/// }
/// .buttonStyle(.qeetrixListItem)
/// ```
public struct QeetrixListItemButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        QeetrixListItemButtonBody(configuration: configuration)
    }
}

extension ButtonStyle where Self == QeetrixListItemButtonStyle {
    /// The list-row button style: see ``QeetrixListItemButtonStyle``.
    public static var qeetrixListItem: QeetrixListItemButtonStyle { QeetrixListItemButtonStyle() }
}

private struct QeetrixListItemButtonBody: View {
    let configuration: ButtonStyleConfiguration
    @State private var isHovered = false

    var body: some View {
        configuration.label
            .background {
                if configuration.isPressed {
                    Rectangle().fill(QeetrixColor.surfaceInteractiveHover)
                } else if isHovered {
                    Rectangle().fill(QeetrixColor.surfaceInteractive)  // hover:bg-surface-interactive
                }
            }
            .contentShape(Rectangle())
            .onHover { isHovered = $0 }
    }
}

enum QeetrixListItemMetrics {
    /// The row's inline padding: the system list inset, which the row takes over inside a `List`.
    static let horizontalPadding = QeetrixSpacing.l
    /// `text-sm font-medium text-foreground`, the notification title.
    static let titleType = QeetrixComponentType.ui(QeetrixWebScale.textSM, .medium, scalesLike: .subheadline)
    /// `text-sm text-muted-foreground`.
    static let descriptionType = QeetrixComponentType.sans(QeetrixWebScale.textSM, .regular, scalesLike: .subheadline)
    /// `text-xs text-muted-foreground tabular-nums`, the notification time.
    static let metadataType = QeetrixComponentType.ui(QeetrixWebScale.textXS, .regular, scalesLike: .caption)
}
