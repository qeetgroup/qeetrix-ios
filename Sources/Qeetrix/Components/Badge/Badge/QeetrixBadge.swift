import SwiftUI

/// The styles of ``QeetrixBadge``, as on the web.
public enum QeetrixBadgeVariant: String, CaseIterable, Sendable {
    /// The one solid Qeet fill, for counts and "New". The loudest thing a badge can be; use it sparingly.
    case `default`
    /// Graphite, for metadata that should not compete.
    case secondary
    /// A boundary and no fill.
    case outline
    /// A quiet brand tint.
    case brand
    /// A quiet information tint.
    case info
    /// A quiet success tint.
    case success
    /// A quiet warning tint.
    case warning
    /// A quiet error tint.
    case destructive
    /// The quietest neutral.
    case muted
}

/// A small label for a count, a status or a category.
///
/// ```swift
/// QeetrixBadge("Beta", variant: .brand)
/// QeetrixBadge("Paid", variant: .success, icon: .circleCheck)
/// ```
///
/// A badge stays on one line, as on the web: keep its text short. Where it has less room than its
/// text needs, at the largest text sizes, it truncates rather than overflowing the screen. VoiceOver reads it as one piece of static text; its
/// icon is decorative, so the text must carry the meaning on its own.
public struct QeetrixBadge: View {
    let label: Text
    let variant: QeetrixBadgeVariant
    let icon: QeetrixIconName?
    @Environment(\.colorScheme) private var colorScheme

    /// A localised badge.
    public init(_ titleKey: LocalizedStringKey, variant: QeetrixBadgeVariant = .default, icon: QeetrixIconName? = nil) {
        self.init(label: Text(titleKey), variant: variant, icon: icon)
    }

    /// A badge showing its text as given, without localisation.
    public init<S: StringProtocol>(_ title: S, variant: QeetrixBadgeVariant = .default, icon: QeetrixIconName? = nil) {
        self.init(label: Text(title), variant: variant, icon: icon)
    }

    /// A badge with a `Text` label.
    public init(label: Text, variant: QeetrixBadgeVariant = .default, icon: QeetrixIconName? = nil) {
        self.label = label
        self.variant = variant
        self.icon = icon
    }

    public var body: some View {
        let colors = Self.colors(variant, colorScheme: colorScheme)
        let shape = RoundedRectangle(cornerRadius: QeetrixBadgeTokens.corner)
        HStack(spacing: QeetrixWebScale.spacing(1)) {  // gap-1
            if let icon {
                QeetrixIcon(icon, size: Self.iconSize)
            }
            label
                .qeetrixType(Self.labelType)
                .lineLimit(1)  // whitespace-nowrap
        }
        .padding(.horizontal, QeetrixWebScale.spacing(2))  // px-2
        .padding(.vertical, QeetrixWebScale.spacing(0.5))  // py-0.5
        .foregroundStyle(colors.foreground)
        .background(colors.background, in: shape)
        .overlay { shape.strokeBorder(colors.border, lineWidth: QeetrixStroke.hairline) }
        .accessibilityElement(children: .combine)
    }

    /// `font-ui text-xs font-medium`.
    static let labelType = QeetrixComponentType.ui(QeetrixWebScale.textXS, .medium, scalesLike: .caption)

    /// `[&>svg]:size-3`.
    static let iconSize = QeetrixIconSize(QeetrixWebScale.spacing(3))

    struct Colors {
        let background: QeetrixComponentColor
        let foreground: QeetrixComponentColor
        let border: QeetrixComponentColor
    }

    static func colors(_ variant: QeetrixBadgeVariant, colorScheme: ColorScheme) -> Colors {
        let clear = QeetrixComponentColor(light: .rgba(.clear), dark: .rgba(.clear))
        func semantic(_ color: QeetrixColor) -> QeetrixComponentColor { QeetrixComponentColor(color) }
        switch variant {
        case .default:
            return Colors(background: QeetrixBadgeTokens.defaultBackground, foreground: QeetrixBadgeTokens.defaultForeground, border: clear)
        case .secondary:
            return Colors(background: semantic(.surfaceInteractive), foreground: semantic(.textOnSubtle), border: clear)
        case .outline:
            // border-border, dark:border-border-strong
            return Colors(
                background: clear, foreground: semantic(.textPrimary),
                border: semantic(colorScheme == .dark ? .borderStrong : .borderDefault))
        case .brand:
            return Colors(
                background: semantic(.surfaceBrandSubtle), foreground: semantic(.textBrand), border: QeetrixBadgeTokens.borderBrand)
        case .info:
            return Colors(background: semantic(.feedbackInfoSubtle), foreground: semantic(.textInfo), border: QeetrixBadgeTokens.borderInfo)
        case .success:
            return Colors(
                background: semantic(.feedbackSuccessSubtle), foreground: semantic(.textSuccess), border: QeetrixBadgeTokens.borderSuccess)
        case .warning:
            return Colors(
                background: semantic(.feedbackWarningSubtle), foreground: semantic(.textWarning), border: QeetrixBadgeTokens.borderWarning)
        case .destructive:
            return Colors(
                background: semantic(.feedbackErrorSubtle), foreground: semantic(.textDanger), border: QeetrixBadgeTokens.borderDanger)
        case .muted:
            return Colors(background: semantic(.surfaceSubtle), foreground: semantic(.textTertiary), border: clear)
        }
    }
}
