import SwiftUI

/// What a badge means, as `@qeetrix/react`'s `BadgeTone`. The word carries the meaning; the tone only
/// reinforces it.
public enum QeetrixBadgeTone: String, CaseIterable, Sendable {
    case neutral
    case brand
    case info
    case success
    case warning
    case danger
}

/// How loud a badge is, as `@qeetrix/react`'s `BadgeVariant`.
public enum QeetrixBadgeVariant: String, CaseIterable, Sendable {
    /// The tone's tint with the tone's text, for most statuses.
    case subtle
    /// The tone's bold fill, for the one status in a view that must stand out ("Overdue").
    case solid
}

/// A badge's height, as `@qeetrix/react`'s `BadgeSize`.
public enum QeetrixBadgeSize: String, CaseIterable, Sendable {
    /// 16 pt, for tight rows and beside small text.
    case sm
    /// 20 pt, the default.
    case md
}

/// A short, static status or count — one or two words — on a pill (design rules §14).
///
/// ```swift
/// QeetrixBadge("Paid", tone: .success)
/// QeetrixBadge("Overdue", tone: .danger, variant: .solid, icon: .circleAlert)
/// ```
///
/// It stays on one line and truncates with an ellipsis where it has less room than its text needs, as
/// at the largest text sizes. VoiceOver reads it as one piece of static text; its icon is decorative,
/// so the text must carry the meaning. A badge is not interactive: a removable or tappable tag is a
/// different component.
public struct QeetrixBadge: View {
    let label: Text
    let tone: QeetrixBadgeTone
    let variant: QeetrixBadgeVariant
    let size: QeetrixBadgeSize
    let icon: QeetrixIconName?

    /// A localised badge.
    public init(
        _ titleKey: LocalizedStringKey, tone: QeetrixBadgeTone = .neutral, variant: QeetrixBadgeVariant = .subtle,
        size: QeetrixBadgeSize = .md, icon: QeetrixIconName? = nil
    ) {
        self.init(label: Text(titleKey), tone: tone, variant: variant, size: size, icon: icon)
    }

    /// A badge showing its text as given, without localisation.
    public init<S: StringProtocol>(
        _ title: S, tone: QeetrixBadgeTone = .neutral, variant: QeetrixBadgeVariant = .subtle, size: QeetrixBadgeSize = .md,
        icon: QeetrixIconName? = nil
    ) {
        self.init(label: Text(title), tone: tone, variant: variant, size: size, icon: icon)
    }

    /// A badge with a `Text` label.
    public init(
        label: Text, tone: QeetrixBadgeTone = .neutral, variant: QeetrixBadgeVariant = .subtle, size: QeetrixBadgeSize = .md,
        icon: QeetrixIconName? = nil
    ) {
        self.label = label
        self.tone = tone
        self.variant = variant
        self.size = size
        self.icon = icon
    }

    public var body: some View {
        let colors = Self.colors(tone, variant)
        HStack(spacing: size == .sm ? 2 : QeetrixSpace.gapXs) {
            if let icon {
                QeetrixIcon(icon, size: .xs2, shape: .sharp, relativeTo: .caption)
            }
            label
                .qeetrixType(Self.labelType)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(.horizontal, size == .sm ? 6 : 8)
        .padding(.vertical, size == .sm ? 0 : 2)
        .foregroundStyle(colors.foreground)
        .background(colors.background, in: Capsule())
        .accessibilityElement(children: .combine)
    }

    /// `label.sm`.
    static let labelType = QeetrixComponentType.role(.labelSm)

    /// The fill and text of a tone and variant (badge.css).
    static func colors(_ tone: QeetrixBadgeTone, _ variant: QeetrixBadgeVariant) -> (background: QeetrixColor, foreground: QeetrixColor) {
        switch (variant, tone) {
        case (.subtle, .neutral): (.bgNeutralSubtlePressed, .textDefault)
        case (.subtle, .brand): (.bgBrandSubtle, .textBrand)
        case (.subtle, .info): (.bgInfoSubtle, .textInfo)
        case (.subtle, .success): (.bgSuccessSubtle, .textSuccess)
        case (.subtle, .warning): (.bgWarningSubtle, .textWarning)
        case (.subtle, .danger): (.bgDangerSubtle, .textDanger)
        case (.solid, .neutral): (.bgNeutralBold, .textInverse)
        case (.solid, .brand): (.bgBrandBold, .textOnBrand)
        case (.solid, .info): (.bgInfoBold, .textOnBold)
        case (.solid, .success): (.bgSuccessBold, .textOnBold)
        case (.solid, .warning): (.bgWarningBold, .textOnWarning)
        case (.solid, .danger): (.bgDangerBold, .textOnBold)
        }
    }
}
