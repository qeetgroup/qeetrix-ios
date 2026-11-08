import SwiftUI

/// One top-level destination of a ``QeetrixSidebar`` or a ``QeetrixNavigationScaffold`` — `@qeetrix/react`'s
/// SidebarItem: your own value for it (a route, an enum case), its title and icon, an optional count, and
/// whether it can be chosen.
///
/// ```swift
/// QeetrixNavigationItem("Inbox", value: Destination.inbox, icon: .inbox, badge: unread)
/// QeetrixNavigationItem("Audit log", value: Destination.audit, icon: .fileText, isDisabled: !plan.includesAudit)
/// ```
///
/// Qeetrix keeps no navigation state: the selection is yours. Values must be distinct, as each is one
/// destination.
public struct QeetrixNavigationItem<Value: Hashable>: Identifiable {
    public let value: Value
    public let title: Text
    /// The destination's icon, drawn round: navigation is the one place Qeetrix uses round icons (design
    /// rules §16). Icons stand for destinations, not actions.
    public let icon: QeetrixIconName
    /// A count after the title: in the sidebar, tabular `label.sm` text; in the tab bar, the system badge.
    public let badge: Int?
    /// Draws the icon filled while the destination is current, where it has a filled drawing; on by
    /// default, as the filled icon is part of the current mark (design rules §11; react 0.4.0).
    /// An icon without one keeps its outline, and the Ember bar marks the item.
    public let filledWhenCurrent: Bool
    /// A destination shown but not available, such as one outside the plan: greyed, and it can't be chosen.
    /// VoiceOver still finds it, dimmed.
    public let isDisabled: Bool
    public var id: Value { value }

    /// An item with a localised title.
    public init(
        _ titleKey: LocalizedStringKey, value: Value, icon: QeetrixIconName, badge: Int? = nil, filledWhenCurrent: Bool = true,
        isDisabled: Bool = false
    ) {
        self.init(
            title: Text(titleKey), value: value, icon: icon, badge: badge, filledWhenCurrent: filledWhenCurrent, isDisabled: isDisabled)
    }

    /// An item with a title shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S, value: Value, icon: QeetrixIconName, badge: Int? = nil, filledWhenCurrent: Bool = true, isDisabled: Bool = false
    ) {
        self.init(
            title: Text(title), value: value, icon: icon, badge: badge, filledWhenCurrent: filledWhenCurrent, isDisabled: isDisabled)
    }

    /// An item with a `Text` title.
    public init(
        title: Text, value: Value, icon: QeetrixIconName, badge: Int? = nil, filledWhenCurrent: Bool = true, isDisabled: Bool = false
    ) {
        self.value = value
        self.title = title
        self.icon = icon
        self.badge = badge
        self.filledWhenCurrent = filledWhenCurrent
        self.isDisabled = isDisabled
    }

    /// The drawing shown: filled while current, where the icon has one and the item asks for it.
    func iconVariant(isCurrent: Bool) -> QeetrixIconVariant {
        isCurrent && filledWhenCurrent && icon.hasDrawing(.round, .filled) ? .filled : .outline
    }
}

/// A list of an app's top-level destinations for the sidebar column of a `NavigationSplitView` —
/// `@qeetrix/react`'s Sidebar, its current item marked as the web marks it.
///
/// ```swift
/// NavigationSplitView {
///     QeetrixSidebar("Qeet Auth", selection: $destination, items: [
///         QeetrixNavigationItem("Accounts", value: Destination.accounts, icon: .keyRound),
///         QeetrixNavigationItem("Devices", value: Destination.devices, icon: .smartphone, badge: 2),
///         QeetrixNavigationItem("Settings", value: Destination.settings, icon: .settings),
///     ])
/// } detail: {
///     DestinationView(destination)
/// }
/// ```
///
/// Rows run edge to edge on `color.surface.canvas`, at least 44 pt tall (`size.control.lg` on the web):
/// a 16 pt round icon in `color.icon.subtle`, the title in `label.md`, `color.text.subtle`, and the count
/// in tabular `label.sm`, `color.text.subtlest`. The current item is `color.bg.neutral.subtle-hover`
/// behind `color.text.default` at weight 600, with an Ember icon, filled, and the 3 pt Ember bar on its
/// leading edge. A pressed or hovered row takes the neutral overlay. The title is the column's navigation
/// title. Titles wrap at large text sizes rather than truncating. For the tab bar on a phone and the
/// sidebar on a tablet from one list, use ``QeetrixNavigationScaffold``.
public struct QeetrixSidebar<Value: Hashable>: View {
    let title: Text
    let selection: Binding<Value>
    let items: [QeetrixNavigationItem<Value>]

    /// A sidebar with a localised title.
    public init(_ titleKey: LocalizedStringKey, selection: Binding<Value>, items: [QeetrixNavigationItem<Value>]) {
        self.init(title: Text(titleKey), selection: selection, items: items)
    }

    /// A sidebar with a title shown as given, without localisation.
    public init<S: StringProtocol>(_ title: S, selection: Binding<Value>, items: [QeetrixNavigationItem<Value>]) {
        self.init(title: Text(title), selection: selection, items: items)
    }

    /// A sidebar with a `Text` title: the column's navigation title, and VoiceOver's name for the list.
    public init(title: Text, selection: Binding<Value>, items: [QeetrixNavigationItem<Value>]) {
        self.title = title
        self.selection = selection
        self.items = items
    }

    public var body: some View {
        ScrollView {
            QeetrixSidebarList(selection: selection, items: items)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(QeetrixColor.surfaceCanvas)
        .navigationTitle(title)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(title)
    }
}

/// The rows, without the scroll view: sidebar.css `.qx-sidebar-nav` `padding-block: space.gap.sm
/// space.inset.md`.
struct QeetrixSidebarList<Value: Hashable>: View {
    let selection: Binding<Value>
    let items: [QeetrixNavigationItem<Value>]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                QeetrixSidebarRow(item: item, isCurrent: item.value == selection.wrappedValue) {
                    selection.wrappedValue = item.value
                }
            }
        }
        .padding(.top, QeetrixSpace.gapSm)
        .padding(.bottom, QeetrixSpace.insetMd)
    }
}

/// One destination (sidebar.css `.qx-sidebar-item`).
struct QeetrixSidebarRow<Value: Hashable>: View {
    let item: QeetrixNavigationItem<Value>
    let isCurrent: Bool
    let select: @MainActor () -> Void

    var body: some View {
        Button(action: select) {
            HStack(spacing: QeetrixSidebarMetrics.gap) {
                QeetrixIcon(item.icon, size: .sm, shape: .round, variant: item.iconVariant(isCurrent: isCurrent))
                    .foregroundStyle(QeetrixSidebarMetrics.iconColor(isCurrent: isCurrent, isEnabled: !item.isDisabled))
                HStack(alignment: .firstTextBaseline, spacing: QeetrixSidebarMetrics.gap) {
                    item.title
                        .qeetrixType(isCurrent ? QeetrixSidebarMetrics.currentType : QeetrixSidebarMetrics.labelType)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let badge = item.badge {
                        Text(badge.formatted())
                            .qeetrixTextStyle(.labelSm)
                            .monospacedDigit()
                            .foregroundStyle(QeetrixColor.textSubtlest)
                    }
                }
            }
        }
        .buttonStyle(QeetrixSidebarItemStyle(isCurrent: isCurrent))
        .disabled(item.isDisabled)
        .accessibilityAddTraits(isCurrent ? .isSelected : [])
    }
}

/// The row's look in every state: rest, hover, pressed, current, disabled and keyboard focus.
struct QeetrixSidebarItemStyle: ButtonStyle {
    let isCurrent: Bool

    func makeBody(configuration: Configuration) -> some View {
        QeetrixSidebarItemBody(isCurrent: isCurrent, configuration: configuration)
    }
}

struct QeetrixSidebarItemBody: View {
    let isCurrent: Bool
    let configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.qeetrixDensity) private var density
    @State private var isHovered = false

    var body: some View {
        let state = QeetrixSidebarItemState(
            isCurrent: isCurrent, isEnabled: isEnabled, isPressed: configuration.isPressed, isHovered: isHovered)
        configuration.label
            .foregroundStyle(state.foreground)
            .padding(.leading, QeetrixSidebarMetrics.leadingPadding)
            .padding(.trailing, QeetrixSidebarMetrics.trailingPadding)
            .padding(.vertical, QeetrixSpace.gapSm)
            .frame(maxWidth: .infinity, minHeight: QeetrixSidebarMetrics.rowHeight(density), alignment: .leading)
            .background { if let fill = state.background { Rectangle().fill(fill) } }
            .overlay(alignment: .leading) {
                if isCurrent {
                    Rectangle()
                        .fill(QeetrixColor.borderBrand)
                        .frame(width: QeetrixBorderWidth.accent)
                        .accessibilityHidden(true)
                }
            }
            // sidebar.css `:focus-visible`: the 2 pt Ember frame inside the row.
            .overlay {
                if isFocused {
                    Rectangle().strokeBorder(QeetrixColor.borderFocus, lineWidth: QeetrixFocus.ringWidth).accessibilityHidden(true)
                }
            }
            .contentShape(Rectangle())
            .onHover { isHovered = $0 }
            .qeetrixAnimation(.standard, .fast, value: state)
    }
}

/// A row's state, which its colours follow (sidebar.css; the pressed tint from Android's rail, as the web
/// has no `:active` rule).
struct QeetrixSidebarItemState: Hashable {
    let isCurrent: Bool
    let isEnabled: Bool
    let isPressed: Bool
    let isHovered: Bool

    /// `[data-current]` `bg.neutral.subtle-hover`; `:hover` `overlay.hover`; pressed `overlay.pressed`;
    /// `[data-disabled]` none.
    var background: QeetrixColor? {
        guard isEnabled else { return nil }
        if isCurrent { return .bgNeutralSubtleHover }
        if isPressed { return .overlayPressed }
        return isHovered ? .overlayHover : nil
    }

    /// The title's colour: `text.subtle`, `text.default` when current, hovered or pressed, `text.disabled`.
    var foreground: QeetrixColor {
        guard isEnabled else { return .textDisabled }
        return isCurrent || isPressed || isHovered ? .textDefault : .textSubtle
    }
}

/// The row's metrics (sidebar.css).
enum QeetrixSidebarMetrics {
    /// `.qx-sidebar-item` `gap: 10px`, and `.qx-sidebar-text` `gap: 10px` before the count.
    static let gap: CGFloat = 10
    /// `.qx-sidebar-item` `padding-inline: space.inset.lg space.inset.md`.
    static let leadingPadding = QeetrixSpace.insetLg
    static let trailingPadding = QeetrixSpace.insetMd
    /// `.qx-sidebar-item` `font: label.md`.
    static let labelType = QeetrixComponentType.role(.labelMd)
    /// `[data-current]` `font-weight: title.sm`'s 600.
    static let currentType = QeetrixComponentType.role(.labelMd, QeetrixTextRole.titleSm.tokens.weight)
    /// `.qx-sidebar` in the app shell: `component.sidebar.width-expanded`, 16rem.
    static let width: CGFloat = 256

    /// `block-size: size.control.lg`, and never under the 44 pt touch target: the rows sit flush, so an
    /// extended hit area would overlap the next row.
    static func rowHeight(_ density: QeetrixDensity) -> CGFloat {
        max(QeetrixAccessibility.minimumTouchTarget, density.sizeControlLg)
    }

    /// `.qx-sidebar-icon` `icon.subtle`; `[data-current] > .qx-sidebar-icon` `icon.brand`;
    /// `[data-disabled] > .qx-sidebar-icon` `icon.disabled`.
    static func iconColor(isCurrent: Bool, isEnabled: Bool) -> QeetrixColor {
        guard isEnabled else { return .iconDisabled }
        return isCurrent ? .iconBrand : .iconSubtle
    }
}
