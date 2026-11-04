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
public struct QeetrixIconButton: View {
    let icon: QeetrixIconName
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

    public var body: some View {
        let iconSize = QeetrixButtonStyle.iconSize(for: size)
        // The spinner is drawn at its token size; it grows with the icon it stands in for.
        Button {
            if !isLoading { action() }
        } label: {
            if isLoading {
                QeetrixSpinner(size: size == .lg ? .lg : .md, isDecorative: true)
                    .scaleEffect(spinnerScale / 100)
            } else {
                QeetrixIcon(icon, size: iconSize, shape: .sharp)
            }
        }
        .buttonStyle(QeetrixButtonStyle(variant, tone: tone, size: size, layout: .icon, isLoading: isLoading))
        .accessibilityLabel(label)
        .help(tooltip ?? label)
        .modifier(QeetrixBusyAccessibility(isLoading: isLoading))
    }
}
