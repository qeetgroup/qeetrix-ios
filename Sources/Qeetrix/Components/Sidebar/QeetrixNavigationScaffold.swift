import SwiftUI

/// How ``QeetrixNavigationScaffold`` presents its destinations. The raw values are the Android library's
/// `QeetrixNavigationLayout` values where they mean the same.
public enum QeetrixNavigationLayout: String, CaseIterable, Sendable {
    /// The tab bar at compact width, the sidebar at regular width, switching as the width class
    /// changes — rotation, Split View, Slide Over, Stage Manager. The default.
    case automatic
    /// A `TabView`'s tab bar, whatever the width.
    case bar
    /// A `NavigationSplitView` with a ``QeetrixSidebar``, whatever the width; at compact width the split
    /// view collapses into a stack, the sidebar first, then the destination chosen. Android's counterpart
    /// is its navigation rail.
    case sidebar

    /// The presentation for a width class: `.bar` or `.sidebar`, never `.automatic`.
    func resolved(for horizontalSizeClass: UserInterfaceSizeClass?) -> QeetrixNavigationLayout {
        switch self {
        case .automatic: horizontalSizeClass == .regular ? .sidebar : .bar
        case .bar, .sidebar: self
        }
    }
}

/// An app's top-level destinations, presented for the width it has — Android's
/// `QeetrixNavigationScaffold` and `@qeetrix/react`'s AppShell frame, in the system's containers: a tab
/// bar at compact width, and at regular width a `NavigationSplitView` with a ``QeetrixSidebar`` and the
/// current destination beside it.
///
/// ```swift
/// @State private var destination = Destination.accounts
///
/// QeetrixNavigationScaffold("Qeet Auth", selection: $destination, items: [
///     QeetrixNavigationItem("Accounts", value: Destination.accounts, icon: .keyRound),
///     QeetrixNavigationItem("Devices", value: Destination.devices, icon: .smartphone, badge: 2),
///     QeetrixNavigationItem("Settings", value: Destination.settings, icon: .settings),
/// ]) { destination in
///     NavigationStack {
///         DestinationView(destination)
///     }
/// }
/// ```
///
/// - **Only presentation.** The selection is yours, as for `TabView`; so are each destination's
///   `NavigationStack`, its path and its deep links. `detail` builds the destination for a value: in the
///   tab bar it is each tab, in the split view the detail column.
/// - **The tab bar** is the system's, tinted Ember (`color.icon.brand`), each item's Qeetrix icon filled
///   while current. Keep to five destinations: past that, iOS gathers the rest under More.
/// - **The sidebar** is a ``QeetrixSidebar`` 256 pt wide (`component.sidebar.width-expanded`), titled
///   with `title`, beside the detail — the split view's balanced style, so the detail stays in view on a
///   portrait iPad. The split view, its column toggle and its gestures are the system's.
/// - **Switching.** A destination's own `@State` starts afresh when the layout changes, as the views move
///   between containers; keep what must survive in your model or `@SceneStorage`.
public struct QeetrixNavigationScaffold<Value: Hashable, Detail: View>: View {
    let title: Text
    let selection: Binding<Value>
    let items: [QeetrixNavigationItem<Value>]
    let layout: QeetrixNavigationLayout
    let detail: (Value) -> Detail
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    /// The column a collapsed split view shows — `.sidebar` forced at compact width: the list first,
    /// then the destination once one is chosen.
    @State private var compactColumn = NavigationSplitViewColumn.sidebar

    /// A scaffold with a localised title.
    public init(
        _ titleKey: LocalizedStringKey, selection: Binding<Value>, items: [QeetrixNavigationItem<Value>],
        layout: QeetrixNavigationLayout = .automatic, @ViewBuilder detail: @escaping (Value) -> Detail
    ) {
        self.init(title: Text(titleKey), selection: selection, items: items, layout: layout, detail: detail)
    }

    /// A scaffold with a title shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S, selection: Binding<Value>, items: [QeetrixNavigationItem<Value>], layout: QeetrixNavigationLayout = .automatic,
        @ViewBuilder detail: @escaping (Value) -> Detail
    ) {
        self.init(title: Text(title), selection: selection, items: items, layout: layout, detail: detail)
    }

    /// A scaffold with a `Text` title.
    ///
    /// - Parameters:
    ///   - title: The app or area the destinations belong to ("Qeet Auth"): the sidebar's title.
    ///   - selection: The current destination.
    ///   - items: The destinations, in order. Values must be distinct.
    ///   - layout: The presentation; by default it follows the width class.
    ///   - detail: The view for a destination, usually in its own `NavigationStack`.
    public init(
        title: Text, selection: Binding<Value>, items: [QeetrixNavigationItem<Value>], layout: QeetrixNavigationLayout = .automatic,
        @ViewBuilder detail: @escaping (Value) -> Detail
    ) {
        self.title = title
        self.selection = selection
        self.items = items
        self.layout = layout
        self.detail = detail
    }

    public var body: some View {
        switch layout.resolved(for: horizontalSizeClass) {
        case .sidebar:
            NavigationSplitView(preferredCompactColumn: $compactColumn) {
                QeetrixSidebar(title: title, selection: choosable(showing: $compactColumn), items: items)
                    .navigationSplitViewColumnWidth(QeetrixSidebarMetrics.width)
                    .qeetrixNavigationBar()
            } detail: {
                detail(selection.wrappedValue)
            }
            .navigationSplitViewStyle(.balanced)
        default:
            TabView(selection: choosable(showing: nil)) {
                ForEach(items) { item in
                    detail(item.value)
                        .modifier(QeetrixNavigationScaffoldTab(item: item, isCurrent: item.value == selection.wrappedValue))
                }
            }
            .qeetrixTabBar()
        }
    }

    /// The selection, refusing a disabled destination — the system tab bar can't dim or disable a tab, so
    /// a tap on one leaves the current destination as it is — and, in a collapsed split view, showing the
    /// destination chosen.
    func choosable(showing column: Binding<NavigationSplitViewColumn>?) -> Binding<Value> {
        let selection = selection
        let items = items
        return Binding(
            get: { selection.wrappedValue },
            set: { value in
                guard Self.canChoose(value, in: items) else { return }
                selection.wrappedValue = value
                column?.wrappedValue = .detail
            })
    }

    /// Whether `value` is a destination that can be chosen: listed, and not disabled.
    static func canChoose(_ value: Value, in items: [QeetrixNavigationItem<Value>]) -> Bool {
        items.first { $0.value == value }.map { !$0.isDisabled } ?? false
    }
}

/// One destination as a tab: its title, its Qeetrix icon (filled while current) and its count.
struct QeetrixNavigationScaffoldTab<Value: Hashable>: ViewModifier {
    let item: QeetrixNavigationItem<Value>
    let isCurrent: Bool

    func body(content: Content) -> some View {
        content
            .tabItem {
                Label {
                    item.title
                } icon: {
                    Image(qeetrix: item.icon, size: .lg, variant: item.iconVariant(isCurrent: isCurrent))
                }
            }
            .badge(item.badge ?? 0)
            .tag(item.value)
    }
}
