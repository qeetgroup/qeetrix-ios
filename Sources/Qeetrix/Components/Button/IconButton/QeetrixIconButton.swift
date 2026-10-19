import SwiftUI

/// A square button holding one icon, with a required accessible label.
///
/// ```swift
/// QeetrixIconButton(.x, label: "Close") { dismiss() }
/// QeetrixIconButton(.bell, label: "Notifications", variant: .outline, size: .sm) { openInbox() }
/// ```
///
/// It is a ``QeetrixButton`` without a visible title: `ghost` by default, the same ``QeetrixButtonSize``
/// heights as a square (24, 28, the density's height, 36 pt), with a 12 pt icon at `xs` and 16 pt
/// otherwise. The label is what VoiceOver reads; it is not shown. While `isLoading` is true the
/// spinner takes the icon's place in the same square.
public struct QeetrixIconButton: View {
    let icon: QeetrixIconName
    let label: Text
    let variant: QeetrixButtonVariant
    let size: QeetrixButtonSize
    let isLoading: Bool
    let action: @MainActor () -> Void

    /// An icon button with a localised accessible label.
    public init(
        _ icon: QeetrixIconName,
        label: LocalizedStringKey,
        variant: QeetrixButtonVariant = .ghost,
        size: QeetrixButtonSize = .default,
        isLoading: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(icon, label: Text(label), variant: variant, size: size, isLoading: isLoading, action: action)
    }

    /// An icon button with an accessible label used as given, without localisation.
    public init<S: StringProtocol>(
        _ icon: QeetrixIconName,
        label: S,
        variant: QeetrixButtonVariant = .ghost,
        size: QeetrixButtonSize = .default,
        isLoading: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(icon, label: Text(label), variant: variant, size: size, isLoading: isLoading, action: action)
    }

    /// An icon button with a `Text` accessible label.
    public init(
        _ icon: QeetrixIconName,
        label: Text,
        variant: QeetrixButtonVariant = .ghost,
        size: QeetrixButtonSize = .default,
        isLoading: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.icon = icon
        self.label = label
        self.variant = variant
        self.size = size
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        let iconSize = Self.iconSize(size)
        Button {
            if !isLoading { action() }
        } label: {
            if isLoading {
                QeetrixButtonBusyIndicator(size: iconSize)
            } else {
                QeetrixIcon(icon, size: iconSize)
            }
        }
        .buttonStyle(QeetrixButtonStyle(variant, size: size, layout: .icon, isLoading: isLoading))
        .accessibilityLabel(label)
        .modifier(QeetrixBusyAccessibility(isLoading: isLoading, loadingLabel: nil))
    }

    /// 12 pt at `xs` (`size-3`), 16 pt otherwise (`size-4`) — the web IconButton does not use the
    /// text button's 14 pt at `sm`.
    static func iconSize(_ size: QeetrixButtonSize) -> QeetrixIconSize {
        QeetrixIconSize(QeetrixWebScale.spacing(size == .xs ? 3 : 4))
    }
}
