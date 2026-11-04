import SwiftUI

extension View {
    /// Qeetrix styling for a `TabView`'s tab bar: Ember (`color.icon.brand`) on the current tab, as on the web's current navigation item. The bar's material,
    /// layout and adaptation (a sidebar on iPad where the system offers one) stay the system's.
    public func qeetrixTabBar() -> some View {
        tint(QeetrixColor.iconBrand)
    }

    /// Makes this view a tab of a `TabView`, labelled with a title and a Qeetrix icon, with an optional
    /// count badge.
    ///
    /// ```swift
    /// TabView(selection: $tab) {
    ///     InboxView().qeetrixTabItem("Inbox", icon: .inbox, badge: unread).tag(Tab.inbox)
    ///     SettingsView().qeetrixTabItem("Settings", icon: .settings).tag(Tab.settings)
    /// }
    /// .qeetrixTabBar()
    /// ```
    ///
    /// The selection, the tags and the destinations are yours; VoiceOver reads each tab with its title,
    /// its position and its badge, as for any tab item.
    public func qeetrixTabItem(_ titleKey: LocalizedStringKey, icon: QeetrixIconName, badge: Int? = nil) -> some View {
        modifier(QeetrixTabItemModifier(title: Text(titleKey), icon: icon, badge: badge))
    }

    /// Makes this view a tab of a `TabView`, with a title shown as given, without localisation.
    public func qeetrixTabItem<S: StringProtocol>(_ title: S, icon: QeetrixIconName, badge: Int? = nil) -> some View {
        modifier(QeetrixTabItemModifier(title: Text(title), icon: icon, badge: badge))
    }
}

struct QeetrixTabItemModifier: ViewModifier {
    let title: Text
    let icon: QeetrixIconName
    let badge: Int?

    func body(content: Content) -> some View {
        content
            .tabItem {
                Label {
                    title
                } icon: {
                    Image(qeetrix: icon, size: .lg)
                }
            }
            .badge(badge ?? 0)
    }
}
