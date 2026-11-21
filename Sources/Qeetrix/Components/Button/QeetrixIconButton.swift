import SwiftUI

/// A square, icon-only button, as `@qeetrix/react`'s IconButton. Its accessible label is required.
///
/// ```swift
/// QeetrixIconButton(.x, label: "Close", tone: .neutral, size: .sm) { dismiss() }
/// QeetrixIconButton(.share2, label: "Share", variant: .soft) { share() }
/// ```
///
/// `ghost` by default; the same ``QeetrixButtonVariant``s, ``QeetrixButtonTone``s and control heights
/// as ``QeetrixButton``, as a square, with a 16 pt sharp icon (20 pt at `lg`). VoiceOver reads the
/// label; with a pointer (iPad) it shows as a tooltip, as on the web — `tooltip` replaces the text
/// shown. While `isLoading` is true the spinner takes the icon's place.
///
/// The `icon` closure draws any view in place of a ``QeetrixIconName``, centred in the square:
///
/// ```swift
/// QeetrixIconButton(label: "Hang up", variant: .solid, tone: .danger) { hangUp() } icon: {
///     QeetrixIcon(.phone, size: .sm, variant: .filled).rotationEffect(.degrees(135))
/// }
/// ```
public struct QeetrixIconButton: View {
    let icon: QeetrixIconName?
    /// The app's own drawing, in place of `icon`.
    var customIcon: AnyView?
    let label: Text
    let variant: QeetrixButtonVariant
    let tone: QeetrixButtonTone
    let size: QeetrixControlSize
    let isLoading: Bool
    let tooltip: Text?
    let action: @MainActor () -> Void
    @ScaledMetric(relativeTo: .body) private var spinnerScale: CGFloat = 100

    /// An icon button with a localised accessible label.
    public init(
        _ icon: QeetrixIconName,
        label: LocalizedStringKey,
        variant: QeetrixButtonVariant = .ghost,
        tone: QeetrixButtonTone = .brand,
        size: QeetrixControlSize = .md,
        isLoading: Bool = false,
        tooltip: Text? = nil,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(
            icon, label: Text(label), variant: variant, tone: tone, size: size, isLoading: isLoading, tooltip: tooltip, action: action)
    }

    /// An icon button with an accessible label used as given, without localisation.
    public init<S: StringProtocol>(
        _ icon: QeetrixIconName,
        label: S,
        variant: QeetrixButtonVariant = .ghost,
        tone: QeetrixButtonTone = .brand,
        size: QeetrixControlSize = .md,
        isLoading: Bool = false,
        tooltip: Text? = nil,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(
            icon, label: Text(label), variant: variant, tone: tone, size: size, isLoading: isLoading, tooltip: tooltip, action: action)
    }

    /// An icon button with a `Text` accessible label.
    public init(
        _ icon: QeetrixIconName,
        label: Text,
        variant: QeetrixButtonVariant = .ghost,
        tone: QeetrixButtonTone = .brand,
        size: QeetrixControlSize = .md,
        isLoading: Bool = false,
        tooltip: Text? = nil,
        action: @escaping @MainActor () -> Void
    ) {
        self.icon = icon
        self.label = label
        self.variant = variant
        self.tone = tone
        self.size = size
        self.isLoading = isLoading
        self.tooltip = tooltip
        self.action = action
    }

    /// An icon button with a localised accessible label and a drawing of the app's own.
    public init<Icon: View>(
        label: LocalizedStringKey,
        variant: QeetrixButtonVariant = .ghost,
        tone: QeetrixButtonTone = .brand,
        size: QeetrixControlSize = .md,
        isLoading: Bool = false,
        tooltip: Text? = nil,
        action: @escaping @MainActor () -> Void,
        @ViewBuilder icon: () -> Icon
    ) {
        self.init(
            label: Text(label), variant: variant, tone: tone, size: size, isLoading: isLoading, tooltip: tooltip, action: action,
            icon: icon)
    }

    /// An icon button with an accessible label used as given, without localisation, and a drawing of the
    /// app's own.
    public init<S: StringProtocol, Icon: View>(
        label: S,
        variant: QeetrixButtonVariant = .ghost,
        tone: QeetrixButtonTone = .brand,
        size: QeetrixControlSize = .md,
        isLoading: Bool = false,
        tooltip: Text? = nil,
        action: @escaping @MainActor () -> Void,
        @ViewBuilder icon: () -> Icon
    ) {
        self.init(
            label: Text(label), variant: variant, tone: tone, size: size, isLoading: isLoading, tooltip: tooltip, action: action,
            icon: icon)
    }

    /// An icon button with a `Text` accessible label and a drawing of the app's own, centred in the square
    /// in a box the size of the control size's icon (``QeetrixButtonStyle/iconSize(for:)``, scaled with
    /// Dynamic Type), in the button's foreground colour. Draw it at that icon size, as a ``QeetrixIcon``
    /// is. While `isLoading` is true the spinner takes its place.
    public init<Icon: View>(
        label: Text,
        variant: QeetrixButtonVariant = .ghost,
        tone: QeetrixButtonTone = .brand,
        size: QeetrixControlSize = .md,
        isLoading: Bool = false,
        tooltip: Text? = nil,
        action: @escaping @MainActor () -> Void,
        @ViewBuilder icon: () -> Icon
    ) {
        self.icon = nil
        customIcon = AnyView(icon())
        self.label = label
        self.variant = variant
        self.tone = tone
        self.size = size
        self.isLoading = isLoading
        self.tooltip = tooltip
        self.action = action
    }

    public var body: some View {
        let iconSize = QeetrixButtonStyle.iconSize(for: size)
        // The spinner is drawn at its token size; it grows with the icon it stands in for.
        Button {
            if !isLoading { action() }
        } label: {
            if isLoading {
                QeetrixSpinner(size: size == .lg ? .lg : .md, isDecorative: true)
                    .scaleEffect(spinnerScale / 100)
            } else if let customIcon {
                // The named icon's box, scaled as it is.
                customIcon.frame(width: iconSize.points * spinnerScale / 100, height: iconSize.points * spinnerScale / 100)
            } else if let icon {
                QeetrixIcon(icon, size: iconSize, shape: .sharp)
            }
        }
        .buttonStyle(QeetrixButtonStyle(variant, tone: tone, size: size, layout: .icon, isLoading: isLoading))
        .accessibilityLabel(label)
        .help(tooltip ?? label)
        .modifier(QeetrixBusyAccessibility(isLoading: isLoading))
    }
}
