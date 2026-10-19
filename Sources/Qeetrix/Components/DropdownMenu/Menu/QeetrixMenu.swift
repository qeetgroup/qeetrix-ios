import SwiftUI

/// A button that opens a menu of actions — the web's `DropdownMenu`, as the system menu.
///
/// ```swift
/// QeetrixMenu(icon: .ellipsis, label: "More actions") {
///     QeetrixMenuItem("Rename", icon: .pencil) { rename() }
///     QeetrixMenuItem("Share", icon: .share2) { share() }
///     Divider()
///     QeetrixMenuItem("Delete", icon: .trash, role: .destructive) { delete() }
/// }
/// ```
///
/// The trigger is a Qeetrix button — a variant and size, with a title or just an icon. The menu is the
/// system's: it positions itself, scrolls, dismisses on a tap outside, supports the keyboard, and draws
/// destructive items in the destructive style. Use ``QeetrixMenuItem`` for items with Qeetrix icons, and
/// the native `Divider`, `Section` and `Button` for the rest. The same items work in `contextMenu`.
///
/// The menu surface — its font, colours and corner — is drawn by iOS and is not Qeetrix-styled.
public struct QeetrixMenu<Content: View>: View {
    let title: Text
    let icon: QeetrixIconName?
    let isIconOnly: Bool
    let variant: QeetrixButtonVariant
    let size: QeetrixButtonSize
    let content: Content
    @Environment(\.qeetrixDensity) private var density

    /// A menu with a localised title on its button.
    public init(
        _ titleKey: LocalizedStringKey,
        icon: QeetrixIconName? = nil,
        variant: QeetrixButtonVariant = .outline,
        size: QeetrixButtonSize = .default,
        @ViewBuilder content: () -> Content
    ) {
        self.init(title: Text(titleKey), icon: icon, isIconOnly: false, variant: variant, size: size, content: content)
    }

    /// A menu with a title shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        icon: QeetrixIconName? = nil,
        variant: QeetrixButtonVariant = .outline,
        size: QeetrixButtonSize = .default,
        @ViewBuilder content: () -> Content
    ) {
        self.init(title: Text(title), icon: icon, isIconOnly: false, variant: variant, size: size, content: content)
    }

    /// A menu behind an icon-only button, named for VoiceOver by `label`.
    public init(
        icon: QeetrixIconName,
        label: Text,
        variant: QeetrixButtonVariant = .ghost,
        size: QeetrixButtonSize = .default,
        @ViewBuilder content: () -> Content
    ) {
        self.init(title: label, icon: icon, isIconOnly: true, variant: variant, size: size, content: content)
    }

    /// A menu behind an icon-only button, named for VoiceOver by a localised `label`.
    public init(
        icon: QeetrixIconName,
        label: LocalizedStringKey,
        variant: QeetrixButtonVariant = .ghost,
        size: QeetrixButtonSize = .default,
        @ViewBuilder content: () -> Content
    ) {
        self.init(title: Text(label), icon: icon, isIconOnly: true, variant: variant, size: size, content: content)
    }

    private init(
        title: Text, icon: QeetrixIconName?, isIconOnly: Bool, variant: QeetrixButtonVariant, size: QeetrixButtonSize,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.isIconOnly = isIconOnly
        self.variant = variant
        self.size = size
        self.content = content()
    }

    public var body: some View {
        let metrics = QeetrixButtonMetrics(size: size, density: density)
        if isIconOnly, let icon {
            Menu {
                content
            } label: {
                QeetrixIcon(icon, size: QeetrixIconButton.iconSize(size))
            }
            .buttonStyle(QeetrixButtonStyle(variant, size: size, layout: .icon, isLoading: false))
            .accessibilityLabel(title)
        } else {
            Menu {
                content
            } label: {
                HStack(spacing: metrics.gap) {
                    if let icon {
                        QeetrixIcon(icon, size: metrics.iconSize)
                    }
                    title
                    QeetrixIcon(.chevronDown, size: metrics.iconSize)
                }
            }
            .buttonStyle(
                QeetrixButtonStyle(variant, size: size, layout: .text(leadingIcon: icon != nil, trailingIcon: true), isLoading: false))
        }
    }
}

/// An item of a ``QeetrixMenu`` or a `contextMenu`: a title, an optional Qeetrix icon, and a role.
///
/// `.destructive` draws it in the destructive style, and VoiceOver says so. Disable it with
/// `disabled(_:)`; the system shows it dimmed and skips it.
public struct QeetrixMenuItem: View {
    let title: Text
    let icon: QeetrixIconName?
    let role: ButtonRole?
    let action: @MainActor () -> Void

    /// An item with a localised title.
    public init(
        _ titleKey: LocalizedStringKey, icon: QeetrixIconName? = nil, role: ButtonRole? = nil, action: @escaping @MainActor () -> Void
    ) {
        self.init(title: Text(titleKey), icon: icon, role: role, action: action)
    }

    /// An item with a title shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S, icon: QeetrixIconName? = nil, role: ButtonRole? = nil, action: @escaping @MainActor () -> Void
    ) {
        self.init(title: Text(title), icon: icon, role: role, action: action)
    }

    /// An item with a `Text` title.
    public init(title: Text, icon: QeetrixIconName? = nil, role: ButtonRole? = nil, action: @escaping @MainActor () -> Void) {
        self.title = title
        self.icon = icon
        self.role = role
        self.action = action
    }

    public var body: some View {
        // The branch is outside the button: a system menu reads an item's title and image from the button's
        // label, and finds neither in conditional content — the item would be listed without a name.
        if let icon {
            Button(role: role, action: action) {
                Label {
                    title
                } icon: {
                    Image(qeetrix: icon, size: .sm)  // [&_svg]:size-4
                }
            }
        } else {
            Button(role: role, action: action) { title }
        }
    }
}
