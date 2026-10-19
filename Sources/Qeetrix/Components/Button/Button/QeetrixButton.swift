import SwiftUI

/// The Qeet action control: a text label with optional icons, in a ``QeetrixButtonVariant`` and
/// ``QeetrixButtonSize``, with a loading state.
///
/// ```swift
/// QeetrixButton("Save changes", isLoading: isSaving) { save() }
/// QeetrixButton("Delete", leadingIcon: .x, variant: .destructive) { delete() }
/// ```
///
/// Use one `default` (primary) button per screen. For a label other than text and icons, give any
/// `Button` the ``QeetrixButtonStyle``.
///
/// While `isLoading` is true the button keeps its label and colours, shows a spinner in the leading
/// slot — in place of a leading icon, so the width holds — and ignores taps. VoiceOver reads it as
/// busy ("Loading"), or by `loadingLabel` when one is given; with a loading label the button keeps
/// the wider of its resting and loading widths.
public struct QeetrixButton: View {
    let title: Text
    let leadingIcon: QeetrixIconName?
    let trailingIcon: QeetrixIconName?
    let variant: QeetrixButtonVariant
    let size: QeetrixButtonSize
    let isLoading: Bool
    let loadingLabel: Text?
    let action: @MainActor () -> Void

    /// A button with a localised title.
    public init(
        _ titleKey: LocalizedStringKey,
        leadingIcon: QeetrixIconName? = nil,
        trailingIcon: QeetrixIconName? = nil,
        variant: QeetrixButtonVariant = .default,
        size: QeetrixButtonSize = .default,
        isLoading: Bool = false,
        loadingLabel: LocalizedStringKey? = nil,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(
            title: Text(titleKey), leadingIcon: leadingIcon, trailingIcon: trailingIcon, variant: variant, size: size, isLoading: isLoading,
            loadingLabel: loadingLabel.map { Text($0) }, action: action)
    }

    /// A button with a title shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        leadingIcon: QeetrixIconName? = nil,
        trailingIcon: QeetrixIconName? = nil,
        variant: QeetrixButtonVariant = .default,
        size: QeetrixButtonSize = .default,
        isLoading: Bool = false,
        loadingLabel: S? = nil,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(
            title: Text(title), leadingIcon: leadingIcon, trailingIcon: trailingIcon, variant: variant, size: size, isLoading: isLoading,
            loadingLabel: loadingLabel.map { Text($0) }, action: action)
    }

    /// A button with a `Text` title.
    public init(
        title: Text,
        leadingIcon: QeetrixIconName? = nil,
        trailingIcon: QeetrixIconName? = nil,
        variant: QeetrixButtonVariant = .default,
        size: QeetrixButtonSize = .default,
        isLoading: Bool = false,
        loadingLabel: Text? = nil,
        action: @escaping @MainActor () -> Void
    ) {
        self.title = title
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.variant = variant
        self.size = size
        self.isLoading = isLoading
        self.loadingLabel = loadingLabel
        self.action = action
    }

    public var body: some View {
        let metrics = QeetrixButtonMetrics(size: size, density: .default)
        // The spinner takes the leading slot unless a loading label shares the resting content's cell.
        let spinnerLeads = isLoading && loadingLabel == nil
        Button {
            if !isLoading { action() }
        } label: {
            if isLoading, let loadingLabel {
                ZStack {
                    resting(metrics).hidden()
                    HStack(spacing: metrics.gap) {
                        QeetrixButtonBusyIndicator(size: metrics.iconSize)
                        loadingLabel
                    }
                }
            } else {
                resting(metrics)
            }
        }
        .buttonStyle(
            QeetrixButtonStyle(
                variant, size: size, layout: .text(leadingIcon: leadingIcon != nil || spinnerLeads, trailingIcon: trailingIcon != nil),
                isLoading: isLoading)
        )
        .modifier(QeetrixBusyAccessibility(isLoading: isLoading, loadingLabel: loadingLabel))
    }

    private func resting(_ metrics: QeetrixButtonMetrics) -> some View {
        HStack(spacing: metrics.gap) {
            if isLoading && loadingLabel == nil {
                QeetrixButtonBusyIndicator(size: metrics.iconSize)
            } else if let leadingIcon {
                QeetrixIcon(leadingIcon, size: metrics.iconSize)
            }
            title
            if let trailingIcon {
                QeetrixIcon(trailingIcon, size: metrics.iconSize)
            }
        }
    }
}

/// What VoiceOver reads for a busy button: the loading label as its name when there is one,
/// otherwise its name with the value "Loading" — the counterpart of the web's `aria-busy`.
struct QeetrixBusyAccessibility: ViewModifier {
    let isLoading: Bool
    let loadingLabel: Text?

    func body(content: Content) -> some View {
        if isLoading, let loadingLabel {
            content.accessibilityLabel(loadingLabel)
        } else if isLoading {
            content.accessibilityValue(QeetrixStrings.loading)
        } else {
            content
        }
    }
}
