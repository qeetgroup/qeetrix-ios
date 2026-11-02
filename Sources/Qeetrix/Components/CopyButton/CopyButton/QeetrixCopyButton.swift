import SwiftUI

/// Copies text to the clipboard — `@qeetrix/react`'s CopyButton: a ghost, neutral icon button with the
/// `copy` icon, or with a title a button with the icon in its zone.
///
/// ```swift
/// QeetrixCopyButton(value: client.id, label: Text("Copy client ID"), toast: $toast)
/// QeetrixCopyButton("Copy link", value: inviteLink, variant: .soft, toast: $toast)
/// QeetrixCopyButton(label: Text("Copy API key"), isSensitive: true, toast: $toast) { try await keys.reveal(key.id) }
/// ```
///
/// - **After a copy** the icon is a sharp `check` — in `color.icon.success` on a ghost button — for
///   `resetAfter` (2 s), and the tooltip says "Copied". If the value can't be read (its closure threw) it
///   is a `circle-alert`, in `color.icon.danger` on a ghost button, and "Couldn't copy": never silent.
///   Another tap copies again and restarts the time.
/// - **Confirmation.** A light haptic. Pass the binding your screen's `qeetrixToast(_:)` hosts as `toast`,
///   and a "Copied" toast confirms the copy — for a secret, with when it leaves the clipboard; without
///   one, VoiceOver announces "Copied". A failure is announced, and plays the error haptic.
/// - **Secrets.** `isSensitive` keeps the entry on this device — never on the universal clipboard — and
///   has the system remove it after 60 seconds. Use it for one-time codes, keys and recovery codes.
///
/// Name an icon-only button by what it copies ("Copy user ID"; "Copy" by default): VoiceOver reads it,
/// and a pointer shows it as a tooltip. The text is read when it's tapped, so the closure form can fetch
/// a fresh token; the text is never logged.
public struct QeetrixCopyButton: View {
    let value: @MainActor () async throws -> String
    let label: Text?
    let title: Text?
    let isSensitive: Bool
    let variant: QeetrixButtonVariant
    let tone: QeetrixButtonTone
    let size: QeetrixControlSize
    let resetAfter: Duration
    let toast: Binding<QeetrixToast?>?
    let onCopied: (@MainActor (String) -> Void)?

    init(
        value: @escaping @MainActor () async throws -> String, label: Text?, title: Text?, isSensitive: Bool, variant: QeetrixButtonVariant,
        tone: QeetrixButtonTone, size: QeetrixControlSize, resetAfter: Duration, toast: Binding<QeetrixToast?>?,
        onCopied: (@MainActor (String) -> Void)?
    ) {
        self.value = value
        self.label = label
        self.title = title
        self.isSensitive = isSensitive
        self.variant = variant
        self.tone = tone
        self.size = size
        self.resetAfter = resetAfter
        self.toast = toast
        self.onCopied = onCopied
    }

    /// An icon-only copy button.
    ///
    /// - Parameters:
    ///   - value: The text to copy.
    ///   - label: What it copies, as its VoiceOver name and tooltip: "Copy user ID". "Copy" by default.
    ///   - isSensitive: Keeps the entry on this device and has it removed after 60 seconds, for a secret.
    ///   - variant: `ghost` by default; the success and danger icons are a ghost button's.
    ///   - tone: `neutral` by default, as most copy buttons are a utility action.
    ///   - size: The control height; `md` by default.
    ///   - resetAfter: How long "Copied", or the failure, shows; 2 seconds by default.
    ///   - toast: The binding the screen's `qeetrixToast(_:)` hosts, to confirm the copy with a toast.
    ///   - onCopied: Runs with the text once it is on the clipboard.
    public init(
        value: String,
        label: Text? = nil,
        isSensitive: Bool = false,
        variant: QeetrixButtonVariant = .ghost,
        tone: QeetrixButtonTone = .neutral,
        size: QeetrixControlSize = .md,
        resetAfter: Duration = .seconds(2),
        toast: Binding<QeetrixToast?>? = nil,
        onCopied: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            value: { value }, label: label, title: nil, isSensitive: isSensitive, variant: variant, tone: tone, size: size,
            resetAfter: resetAfter, toast: toast, onCopied: onCopied)
    }

    /// An icon-only copy button whose text is read when it's tapped — a fresh token, a key fetched on
    /// demand. If `value` throws, the button shows the failure and copies nothing.
    public init(
        label: Text? = nil,
        isSensitive: Bool = false,
        variant: QeetrixButtonVariant = .ghost,
        tone: QeetrixButtonTone = .neutral,
        size: QeetrixControlSize = .md,
        resetAfter: Duration = .seconds(2),
        toast: Binding<QeetrixToast?>? = nil,
        onCopied: (@MainActor (String) -> Void)? = nil,
        value: @escaping @MainActor () async throws -> String
    ) {
        self.init(
            value: value, label: label, title: nil, isSensitive: isSensitive, variant: variant, tone: tone, size: size,
            resetAfter: resetAfter, toast: toast, onCopied: onCopied)
    }

    /// A copy button with a localised title, which names it: the title first, the icon in its zone.
    public init(
        _ titleKey: LocalizedStringKey,
        value: String,
        isSensitive: Bool = false,
        variant: QeetrixButtonVariant = .ghost,
        tone: QeetrixButtonTone = .neutral,
        size: QeetrixControlSize = .md,
        resetAfter: Duration = .seconds(2),
        toast: Binding<QeetrixToast?>? = nil,
        onCopied: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            value: { value }, label: nil, title: Text(titleKey), isSensitive: isSensitive, variant: variant, tone: tone, size: size,
            resetAfter: resetAfter, toast: toast, onCopied: onCopied)
    }

    /// A copy button with a title shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        value: String,
        isSensitive: Bool = false,
        variant: QeetrixButtonVariant = .ghost,
        tone: QeetrixButtonTone = .neutral,
        size: QeetrixControlSize = .md,
        resetAfter: Duration = .seconds(2),
        toast: Binding<QeetrixToast?>? = nil,
        onCopied: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            value: { value }, label: nil, title: Text(title), isSensitive: isSensitive, variant: variant, tone: tone, size: size,
            resetAfter: resetAfter, toast: toast, onCopied: onCopied)
    }

    /// A copy button with a `Text` title.
    public init(
        title: Text,
        value: String,
        isSensitive: Bool = false,
        variant: QeetrixButtonVariant = .ghost,
        tone: QeetrixButtonTone = .neutral,
        size: QeetrixControlSize = .md,
        resetAfter: Duration = .seconds(2),
        toast: Binding<QeetrixToast?>? = nil,
        onCopied: (@MainActor (String) -> Void)? = nil
    ) {
        self.init(
            value: { value }, label: nil, title: title, isSensitive: isSensitive, variant: variant, tone: tone, size: size,
            resetAfter: resetAfter, toast: toast, onCopied: onCopied)
    }

    public var body: some View {
        QeetrixCopyControl(
            value: value, isSensitive: isSensitive, resetAfter: resetAfter, toast: toast, onCopied: onCopied
        ) { state, copy in
            QeetrixCopyButtonFace(state: state, label: label, title: title, variant: variant, tone: tone, size: size, action: copy)
        }
    }
}

/// The button in one copy state: an icon button, or with a title a button with the icon in its zone.
struct QeetrixCopyButtonFace: View {
    let state: QeetrixCopyState
    let label: Text?
    let title: Text?
    let variant: QeetrixButtonVariant
    let tone: QeetrixButtonTone
    let size: QeetrixControlSize
    let action: @MainActor () -> Void

    var body: some View {
        let status = QeetrixCopy.status(state)
        let icon = QeetrixCopyButtonIcon(state: state, variant: variant, size: size)
        if let title {
            Button(action: action) {
                QeetrixCopyButtonLabel(title: title, icon: icon, size: size)
            }
            .buttonStyle(QeetrixButtonStyle(variant, tone: tone, size: size, layout: .textWithZone, isLoading: false))
            .accessibilityValue(status.map { Text(verbatim: $0) } ?? Text(verbatim: ""))
            // The title names it; the tooltip shows only what happened (copy-button.tsx's `tip`).
            .modifier(QeetrixCopyButtonTooltip(text: status.map { Text(verbatim: $0) }))
        } else {
            let name = label ?? QeetrixCopyStrings.copy
            Button(action: action) {
                icon
            }
            .buttonStyle(QeetrixButtonStyle(variant, tone: tone, size: size, layout: .icon, isLoading: false))
            .accessibilityLabel(name)
            .accessibilityValue(status.map { Text(verbatim: $0) } ?? Text(verbatim: ""))
            .modifier(QeetrixCopyButtonTooltip(text: status.map { Text(verbatim: $0) } ?? name))
        }
    }
}

/// The state's icon, sharp, at the button's icon size, tinted on a ghost button after a copy.
struct QeetrixCopyButtonIcon: View {
    let state: QeetrixCopyState
    let variant: QeetrixButtonVariant
    let size: QeetrixControlSize

    var body: some View {
        let icon = QeetrixIcon(QeetrixCopy.icon(state), size: QeetrixButtonStyle.iconSize(for: size), shape: .sharp)
        if let tint = QeetrixCopy.iconTint(state, variant: variant) {
            icon.foregroundStyle(tint)
        } else {
            icon
        }
    }
}

/// A titled copy button's label: the title, then the icon zone behind its rule — ``QeetrixButton``'s
/// label, with the icon drawn by the copy state so a ghost button can tint it.
struct QeetrixCopyButtonLabel: View {
    let title: Text
    let icon: QeetrixCopyButtonIcon
    let size: QeetrixControlSize
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixButtonFillsWidth) private var fillsWidth
    @ScaledMetric private var iconSide: CGFloat

    init(title: Text, icon: QeetrixCopyButtonIcon, size: QeetrixControlSize) {
        self.title = title
        self.icon = icon
        self.size = size
        _iconSide = ScaledMetric(wrappedValue: QeetrixButtonStyle.iconSize(for: size).points, relativeTo: .body)
    }

    var body: some View {
        let metrics = QeetrixButtonMetrics(size: size, density: density)
        let scale = iconSide / metrics.iconSize.points
        HStack(spacing: metrics.gap) {
            title
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: fillsWidth ? .infinity : nil, alignment: .leading)
            icon
                .frame(width: iconSide, height: iconSide)
                .padding(.horizontal, metrics.zonePadding)
                .frame(maxHeight: .infinity)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .frame(width: QeetrixBorderWidth.default, height: metrics.ruleHeight * scale)
                        .opacity(QeetrixButtonLabel.ruleOpacity)
                        .accessibilityHidden(true)
                }
        }
    }
}

/// The pointer tooltip: the name, or after a copy what happened.
private struct QeetrixCopyButtonTooltip: ViewModifier {
    let text: Text?

    func body(content: Content) -> some View {
        if let text { content.help(text) } else { content }
    }
}
