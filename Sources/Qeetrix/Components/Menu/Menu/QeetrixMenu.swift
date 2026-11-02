import SwiftUI

/// A menu of actions opened from a Qeetrix button — `@qeetrix/react`'s Menu with its trigger.
///
/// ```swift
/// QeetrixMenu("Export", icon: .share2) {
///     QeetrixMenuItem("Export as CSV", icon: .copy, description: Text("Opens in a spreadsheet")) { export(.csv) }
/// }
/// QeetrixMenu(icon: .ellipsis, label: "Actions for Priya Sharma") {
///     QeetrixMenuItem("Edit", icon: .pencil) { edit() }
///     Divider()
///     QeetrixMenuItem("Remove from Acme", icon: .trash, tone: .danger) { remove() }
/// }
/// ```
///
/// The trigger is a ``QeetrixButton`` — `soft` with a trailing icon (a chevron unless you give one) —
/// or, icon-only, a neutral ghost ``QeetrixIconButton``, as ui.qeet.in builds them. The list is the
/// system menu (ADR 0014): its surface, font, highlight and keyboard and VoiceOver handling are the
/// system's, so `@qeetrix/react`'s menu surface, Ember highlight edge and shortcuts don't apply; items
/// keep their Qeetrix icons, descriptions and the danger tone. Put destructive items last, after a
/// `Divider`.
public struct QeetrixMenu<Content: View>: View {
    let title: Text
    let icon: QeetrixIconName?
    let isIconOnly: Bool
    let variant: QeetrixButtonVariant
    let tone: QeetrixButtonTone
    let size: QeetrixControlSize
    let content: Content

    /// A menu behind a text button, with a localised title.
    public init(
        _ titleKey: LocalizedStringKey,
        icon: QeetrixIconName = .chevronDown,
        variant: QeetrixButtonVariant = .soft,
        tone: QeetrixButtonTone = .brand,
        size: QeetrixControlSize = .md,
        @ViewBuilder content: () -> Content
    ) {
        self.init(title: Text(titleKey), icon: icon, isIconOnly: false, variant: variant, tone: tone, size: size, content: content)
    }

    /// A menu behind a text button, with a title shown as given.
    public init<S: StringProtocol>(
        _ title: S,
        icon: QeetrixIconName = .chevronDown,
        variant: QeetrixButtonVariant = .soft,
        tone: QeetrixButtonTone = .brand,
        size: QeetrixControlSize = .md,
        @ViewBuilder content: () -> Content
    ) {
        self.init(title: Text(title), icon: icon, isIconOnly: false, variant: variant, tone: tone, size: size, content: content)
    }

    /// A menu behind an icon-only button, with its required accessible label.
    public init(
        icon: QeetrixIconName,
        label: Text,
        variant: QeetrixButtonVariant = .ghost,
        tone: QeetrixButtonTone = .neutral,
        size: QeetrixControlSize = .md,
        @ViewBuilder content: () -> Content
    ) {
        self.init(title: label, icon: icon, isIconOnly: true, variant: variant, tone: tone, size: size, content: content)
    }

    /// A menu behind an icon-only button, with a localised accessible label.
    public init(
        icon: QeetrixIconName,
        label: LocalizedStringKey,
        variant: QeetrixButtonVariant = .ghost,
        tone: QeetrixButtonTone = .neutral,
        size: QeetrixControlSize = .md,
        @ViewBuilder content: () -> Content
    ) {
        self.init(title: Text(label), icon: icon, isIconOnly: true, variant: variant, tone: tone, size: size, content: content)
    }

    private init(
        title: Text, icon: QeetrixIconName?, isIconOnly: Bool, variant: QeetrixButtonVariant, tone: QeetrixButtonTone,
        size: QeetrixControlSize, @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.isIconOnly = isIconOnly
        self.variant = variant
        self.tone = tone
        self.size = size
        self.content = content()
    }

    public var body: some View {
        if isIconOnly, let icon {
            Menu {
                content
            } label: {
                QeetrixIcon(icon, size: QeetrixButtonStyle.iconSize(for: size), shape: .sharp)
            }
            .buttonStyle(QeetrixButtonStyle(variant, tone: tone, size: size, layout: .icon, isLoading: false))
            .accessibilityLabel(title)
            .help(title)
        } else {
            Menu {
                content
            } label: {
                QeetrixButtonLabel(title: title, icon: icon, size: size, isLoading: false)
            }
            .buttonStyle(QeetrixButtonStyle(variant, tone: tone, size: size, layout: .textWithZone, isLoading: false))
        }
    }
}

/// A menu item's meaning, as `@qeetrix/react`'s MenuItem `tone`.
public enum QeetrixMenuItemTone: String, CaseIterable, Sendable {
    case `default`
    /// A destructive action: the system menu draws it in its destructive red.
    case danger
}

/// An item of a ``QeetrixMenu`` (or of any system menu or context menu): its title, an optional
/// leading 16 pt sharp Qeetrix icon and an optional second line, as `@qeetrix/react`'s MenuItem.
public struct QeetrixMenuItem: View {
    let title: Text
    let icon: QeetrixIconName?
    let description: Text?
    let tone: QeetrixMenuItemTone
    let action: @MainActor () -> Void

    public init(
        _ titleKey: LocalizedStringKey, icon: QeetrixIconName? = nil, description: Text? = nil, tone: QeetrixMenuItemTone = .default,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(title: Text(titleKey), icon: icon, description: description, tone: tone, action: action)
    }

    public init<S: StringProtocol>(
        _ title: S, icon: QeetrixIconName? = nil, description: Text? = nil, tone: QeetrixMenuItemTone = .default,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(title: Text(title), icon: icon, description: description, tone: tone, action: action)
    }

    public init(
        title: Text, icon: QeetrixIconName? = nil, description: Text? = nil, tone: QeetrixMenuItemTone = .default,
        action: @escaping @MainActor () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.description = description
        self.tone = tone
        self.action = action
    }

    public var body: some View {
        let role: ButtonRole? = tone == .danger ? .destructive : nil
        // The branches are outside the button: a system menu reads an item's title, subtitle and image
        // from the button's label, and finds none of them in conditional content.
        switch (icon, description) {
        case let (icon?, description?):
            Button(role: role, action: action) {
                Label {
                    title
                    description
                } icon: {
                    Image(qeetrix: icon, size: .sm, shape: .sharp)
                }
            }
        case let (icon?, nil):
            Button(role: role, action: action) {
                Label {
                    title
                } icon: {
                    Image(qeetrix: icon, size: .sm, shape: .sharp)
                }
            }
        case let (nil, description?):
            Button(role: role, action: action) {
                title
                description
            }
        case (nil, nil):
            Button(role: role, action: action) { title }
        }
    }
}
