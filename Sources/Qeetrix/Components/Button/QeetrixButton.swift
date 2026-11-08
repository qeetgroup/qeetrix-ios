import SwiftUI

/// An action, as `@qeetrix/react`'s Button: the label first and, when there is one, a trailing icon in
/// its own zone behind a short rule (design rules §7).
///
/// ```swift
/// QeetrixButton("Create invoice") { create() }
/// QeetrixButton("Export", icon: .share2, variant: .soft) { export() }
/// QeetrixButton("Revoke key", tone: .danger, isLoading: isRevoking) { revoke() }
/// ```
///
/// A region has at most one `solid` and one `soft` button; everything else is `ghost`. A destructive
/// confirmation (`tone: .danger`) replaces the primary rather than sitting beside it. Write labels as
/// verbs. For a label that is not text, give any `Button` the ``QeetrixButtonStyle``.
///
/// While `isLoading` is true a spinner takes the icon's place in the zone — a button without an icon
/// gains the zone — the label and colours stay, taps are ignored, and VoiceOver reads the button as
/// busy ("Loading"). `isFullWidth` stretches it to its container (forms, compact width) and centres
/// the label on the whole button; an icon keeps its zone at the end, and the leading side keeps as much
/// room as the zone takes, so the label is centred with or without one.
public struct QeetrixButton: View {
    let title: Text
    let icon: QeetrixIconName?
    let variant: QeetrixButtonVariant
    let tone: QeetrixButtonTone
    let size: QeetrixControlSize
    let isLoading: Bool
    let isFullWidth: Bool
    let action: @MainActor () -> Void

    /// A button with a localised title.
    public init(
        _ titleKey: LocalizedStringKey,
        icon: QeetrixIconName? = nil,
        variant: QeetrixButtonVariant = .solid,
        tone: QeetrixButtonTone = .brand,
        size: QeetrixControlSize = .md,
        isLoading: Bool = false,
        isFullWidth: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(
            title: Text(titleKey), icon: icon, variant: variant, tone: tone, size: size, isLoading: isLoading, isFullWidth: isFullWidth,
            action: action)
    }

    /// A button with a title shown as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S,
        icon: QeetrixIconName? = nil,
        variant: QeetrixButtonVariant = .solid,
        tone: QeetrixButtonTone = .brand,
        size: QeetrixControlSize = .md,
        isLoading: Bool = false,
        isFullWidth: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(
            title: Text(title), icon: icon, variant: variant, tone: tone, size: size, isLoading: isLoading, isFullWidth: isFullWidth,
            action: action)
    }

    /// A button with a `Text` title.
    public init(
        title: Text,
        icon: QeetrixIconName? = nil,
        variant: QeetrixButtonVariant = .solid,
        tone: QeetrixButtonTone = .brand,
        size: QeetrixControlSize = .md,
        isLoading: Bool = false,
        isFullWidth: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.tone = tone
        self.size = size
        self.isLoading = isLoading
        self.isFullWidth = isFullWidth
        self.action = action
    }

    public var body: some View {
        let hasZone = icon != nil || isLoading
        Button {
            if !isLoading { action() }
        } label: {
            QeetrixButtonLabel(title: title, icon: icon, size: size, isLoading: isLoading)
        }
        .buttonStyle(QeetrixButtonStyle(variant, tone: tone, size: size, layout: hasZone ? .textWithZone : .text, isLoading: isLoading))
        .transformEnvironment(\.qeetrixButtonFillsWidth) { if isFullWidth { $0 = true } }
        .modifier(QeetrixBusyAccessibility(isLoading: isLoading))
    }
}

/// The label, then — with an icon or while loading — the zone: the icon (or spinner) with equal
/// space either side, behind a 1 pt rule as tall as the icon in the label's colour at 55%. The icon,
/// its zone and the rule scale together with Dynamic Type; the label wraps rather than truncating at
/// the accessibility sizes (the web keeps one line).
struct QeetrixButtonLabel: View {
    let title: Text
    let icon: QeetrixIconName?
    let size: QeetrixControlSize
    let isLoading: Bool
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixButtonFillsWidth) private var fillsWidth
    @Environment(\.qeetrixButtonIconMirrors) private var iconMirrors
    @ScaledMetric private var iconSide: CGFloat

    /// The rule's opacity: the label colour at 55% (button.css `.qx-button-zone::before`).
    static let ruleOpacity = 0.55

    init(title: Text, icon: QeetrixIconName?, size: QeetrixControlSize, isLoading: Bool) {
        self.title = title
        self.icon = icon
        self.size = size
        self.isLoading = isLoading
        _iconSide = ScaledMetric(wrappedValue: QeetrixButtonStyle.iconSize(for: size).points, relativeTo: .body)
    }

    var body: some View {
        let metrics = QeetrixButtonMetrics(size: size, density: density)
        let hasZone = icon != nil || isLoading
        Group {
            if fillsWidth {
                // Full width: the label is centred on the whole button. The zone's span (the gap, its
                // padding on both sides and the icon) beyond the button's own leading padding is what
                // the label's room is off-centre by (button.css `[data-full-width]`).
                let span = metrics.gap + iconSide + 2 * metrics.zonePadding
                QeetrixCentredLabelLayout(gap: metrics.gap, shift: hasZone ? (span - metrics.padding) / 2 : 0) {
                    title
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    if hasZone {
                        zone(metrics)
                    }
                }
            } else {
                HStack(spacing: metrics.gap) {
                    title
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    if hasZone {
                        zone(metrics)
                    }
                }
            }
        }
        // The zone fills the label's height; the label itself keeps its own, so a button with an icon
        // doesn't stretch to share the spare height of a stack it sits in.
        .fixedSize(horizontal: false, vertical: true)
    }

    private func zone(_ metrics: QeetrixButtonMetrics) -> some View {
        let scale = iconSide / metrics.iconSize.points
        return ZStack {
            if isLoading {
                // The spinner is drawn at its token size; it grows with the icon box it stands in for.
                QeetrixSpinner(size: metrics.spinnerSize, isDecorative: true)
                    .scaleEffect(scale)
            } else if let icon {
                QeetrixIcon(
                    icon, size: metrics.iconSize, shape: .sharp, mirrorsInRightToLeft: iconMirrors ?? icon.mirrorsInRightToLeft)
            }
        }
        // The spinner keeps the icon's box, so a button with an icon keeps its width.
        .frame(width: iconSide, height: iconSide)
        .padding(.horizontal, metrics.zonePadding)
        .frame(maxHeight: .infinity)
        .overlay(alignment: .leading) {
            Rectangle()
                .frame(width: QeetrixBorderWidth.default, height: metrics.ruleHeight * scale)
                .opacity(Self.ruleOpacity)
                .accessibilityHidden(true)
        }
    }
}

/// A full-width button's label and zone: the zone at the trailing end, and the label centred on the
/// whole button — `shift` towards the trailing end of the room the zone leaves — as far as that room
/// allows. Where it's tight the leading side gives way first. The ideal width is the label's, the gap
/// and the zone's, as a plain button's, so a full-width button never needs more room. SwiftUI mirrors
/// it right to left.
struct QeetrixCentredLabelLayout: Layout {
    let gap: CGFloat
    let shift: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let parts = measure(width: proposal.width, subviews: subviews)
        let ideal = parts.label.width + parts.trailing
        let width = proposal.width.flatMap { $0.isFinite ? $0 : nil } ?? ideal
        return CGSize(width: width, height: max(parts.label.height, parts.zone.height))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let parts = measure(width: bounds.width, subviews: subviews)
        let room = max(0, bounds.width - parts.trailing)
        let label = CGSize(width: min(parts.label.width, room), height: parts.label.height)
        let free = room - label.width
        let x = min(max(free / 2 + shift, 0), free)
        subviews.first?.place(
            at: CGPoint(x: bounds.minX + x, y: bounds.midY), anchor: .leading, proposal: ProposedViewSize(label))
        if subviews.count > 1 {
            subviews[1].place(
                at: CGPoint(x: bounds.maxX, y: bounds.midY), anchor: .trailing,
                proposal: ProposedViewSize(width: parts.zone.width, height: bounds.height))
        }
    }

    /// The label in the room the zone leaves, the zone at its own size, and what the zone and gap take.
    private func measure(width: CGFloat?, subviews: Subviews) -> (label: CGSize, zone: CGSize, trailing: CGFloat) {
        let zone = subviews.count > 1 ? subviews[1].sizeThatFits(.unspecified) : .zero
        let trailing = subviews.count > 1 ? zone.width + gap : 0
        let room = width.flatMap { $0.isFinite ? max(0, $0 - trailing) : nil }
        let label = subviews.first?.sizeThatFits(ProposedViewSize(width: room, height: nil)) ?? .zero
        return (label, zone, trailing)
    }
}

/// What VoiceOver reads for a busy button: its name with the value "Loading" — the counterpart of the
/// web's `aria-busy`.
struct QeetrixBusyAccessibility: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        if isLoading {
            content.accessibilityValue(QeetrixStrings.loading)
        } else {
            content
        }
    }
}
