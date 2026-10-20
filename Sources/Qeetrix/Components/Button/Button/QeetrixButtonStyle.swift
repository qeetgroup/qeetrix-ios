import SwiftUI

/// The styles of a Qeetrix button, as on the web.
public enum QeetrixButtonVariant: String, CaseIterable, Sendable {
    /// The primary action: the one Qeet-orange button on a surface.
    case `default`
    /// The workhorse beside a primary action — dialog footers, forms, toolbars.
    case outline
    /// A neutral filled action.
    case secondary
    /// Chrome-less, for toolbars, rows and dense headers.
    case ghost
    /// Quiet at rest — danger text on the error surface — and solid danger on press.
    case destructive
    /// Looks like a link.
    case link
}

/// The sizes of a Qeetrix button, as on the web. `default` follows the density
/// (`qeetrixDensity(_:)`); the others are fixed heights.
public enum QeetrixButtonSize: String, CaseIterable, Sendable {
    /// 24 pt.
    case xs
    /// 28 pt.
    case sm
    /// The density's control height: 28, 32 or 36 pt.
    case `default`
    /// 36 pt.
    case lg
}

/// The Qeetrix button treatment for any SwiftUI `Button`, `NavigationLink`, `ShareLink` or other
/// control that takes a button style.
///
/// ```swift
/// Button("Continue", action: submit)
///     .buttonStyle(.qeetrix())
///
/// NavigationLink("Billing", value: Route.billing)
///     .buttonStyle(.qeetrix(.outline, size: .sm))
/// ```
///
/// The label takes the size's text style; size icons in a custom label with
/// ``QeetrixButtonStyle/iconSize(for:)``. ``QeetrixButton`` adds icons and a loading state on top of
/// this style.
public struct QeetrixButtonStyle: ButtonStyle {
    let variant: QeetrixButtonVariant
    let size: QeetrixButtonSize
    var layout = Layout.text(leadingIcon: false, trailingIcon: false)
    var isLoading = false

    enum Layout: Hashable {
        /// A text label, with an icon or the busy indicator at either end tightening that side's padding.
        case text(leadingIcon: Bool, trailingIcon: Bool)
        /// A square holding one icon.
        case icon
    }

    public init(_ variant: QeetrixButtonVariant = .default, size: QeetrixButtonSize = .default) {
        self.variant = variant
        self.size = size
    }

    init(_ variant: QeetrixButtonVariant, size: QeetrixButtonSize, layout: Layout, isLoading: Bool) {
        self.variant = variant
        self.size = size
        self.layout = layout
        self.isLoading = isLoading
    }

    public func makeBody(configuration: Configuration) -> some View {
        QeetrixButtonStyleBody(style: self, configuration: configuration)
    }

    /// The icon size for a button size: 12 pt at `xs`, 14 pt at `sm`, 16 pt otherwise.
    public static func iconSize(for size: QeetrixButtonSize) -> QeetrixIconSize {
        QeetrixButtonMetrics(size: size, density: .default).iconSize
    }
}

extension ButtonStyle where Self == QeetrixButtonStyle {
    /// The Qeetrix button style.
    public static func qeetrix(_ variant: QeetrixButtonVariant = .default, size: QeetrixButtonSize = .default) -> QeetrixButtonStyle {
        QeetrixButtonStyle(variant, size: size)
    }
}

/// The interaction states the button colours follow.
enum QeetrixButtonState: Hashable {
    case resting
    case hovered
    case pressed
    case disabled
}

/// Size metrics: web classes, and the button's component tokens where it has them.
struct QeetrixButtonMetrics {
    let height: CGFloat
    /// `px-*`.
    let padding: CGFloat
    /// `ps-*` / `pe-*` on the side that holds an icon.
    let iconSidePadding: CGFloat
    /// `gap-*`.
    let gap: CGFloat
    let corner: CGFloat
    let type: QeetrixTypeSpec
    let iconSize: QeetrixIconSize

    init(size: QeetrixButtonSize, density: QeetrixDensity) {
        let label = QeetrixComponentType.ui(QeetrixWebScale.textSM, .medium, scalesLike: .body)  // font-ui text-sm font-medium
        switch size {
        case .xs:
            // h-6 gap-1 px-2 text-xs, ps-1.5 / pe-1.5 beside an icon, icons size-3
            height = QeetrixWebScale.spacing(6)
            padding = QeetrixWebScale.spacing(2)
            iconSidePadding = QeetrixWebScale.spacing(1.5)
            gap = QeetrixWebScale.spacing(1)
            corner = QeetrixButtonTokens.cornerXs
            type = QeetrixComponentType.ui(QeetrixWebScale.textXS, .medium, scalesLike: .caption)
            iconSize = QeetrixIconSize(QeetrixWebScale.spacing(3))
        case .sm:
            // h-7 gap-1 px-2.5 at the small font size, ps-1.5 / pe-1.5 beside an icon, icons size-3.5
            height = QeetrixWebScale.spacing(7)
            padding = QeetrixWebScale.spacing(2.5)
            iconSidePadding = QeetrixWebScale.spacing(1.5)
            gap = QeetrixWebScale.spacing(1)
            corner = QeetrixButtonTokens.cornerSm
            type = QeetrixComponentType.ui(
                QeetrixWebScale.TextStep(size: QeetrixButtonTokens.fontSizeSm, lineHeight: QeetrixWebScale.textSM.lineHeight), .medium,
                scalesLike: .footnote)
            iconSize = QeetrixIconSize(QeetrixWebScale.spacing(3.5))
        case .default:
            // h-(button height) gap-1.5 px-2.5, ps-2 / pe-2 beside an icon, icons size-4
            height = QeetrixButtonTokens.height(density)
            padding = QeetrixWebScale.spacing(2.5)
            iconSidePadding = QeetrixWebScale.spacing(2)
            gap = QeetrixWebScale.spacing(1.5)
            corner = QeetrixButtonTokens.corner
            type = label
            iconSize = QeetrixIconSize(QeetrixWebScale.spacing(4))
        case .lg:
            // h-9 gap-1.5 px-3, ps-2.5 / pe-2.5 beside an icon, icons size-4
            height = QeetrixWebScale.spacing(9)
            padding = QeetrixWebScale.spacing(3)
            iconSidePadding = QeetrixWebScale.spacing(2.5)
            gap = QeetrixWebScale.spacing(1.5)
            corner = QeetrixButtonTokens.corner
            type = label
            iconSize = QeetrixIconSize(QeetrixWebScale.spacing(4))
        }
    }
}

/// A variant's colours in one state.
struct QeetrixButtonColors {
    var background = QeetrixComponentColor(light: .rgba(.clear), dark: .rgba(.clear))
    var foreground = QeetrixComponentColor(.textPrimary)
    var border = QeetrixComponentColor(light: .rgba(.clear), dark: .rgba(.clear))
    /// `shadow-xs` at rest on the filled variants; `active:shadow-none`.
    var elevation = QeetrixElevation.flat
    var opacity = 1.0
    var isUnderlined = false

    static func colors(_ variant: QeetrixButtonVariant, _ state: QeetrixButtonState) -> QeetrixButtonColors {
        var colors = QeetrixButtonColors()
        let engaged = state == .hovered || state == .pressed
        let resting: QeetrixElevation = state == .pressed ? .flat : .rampXs
        switch variant {
        case .default:
            if state == .disabled {
                // An unavailable action carries no brand emphasis: the neutral fill at full opacity.
                colors.background = QeetrixComponentColor(.surfaceInteractive)
                colors.foreground = QeetrixComponentColor(.textDisabled)
                return colors
            }
            colors.background =
                switch state {
                case .hovered: QeetrixButtonTokens.primaryBackgroundHover
                case .pressed: QeetrixButtonTokens.primaryBackgroundActive
                default: QeetrixButtonTokens.primaryBackground
                }
            colors.foreground = QeetrixButtonTokens.primaryForeground
            colors.elevation = resting
        case .outline:
            colors.border = QeetrixButtonTokens.outlineBorder
            colors.background =
                switch state {
                case .hovered: QeetrixComponentColor(.surfaceInteractiveHover)
                case .pressed: QeetrixComponentColor(.surfaceInteractiveActive)
                default: QeetrixButtonTokens.outlineBackground
                }
            colors.elevation = resting
        case .secondary:
            colors.background =
                switch state {
                case .hovered: QeetrixComponentColor(.surfaceInteractiveHover)
                case .pressed: QeetrixComponentColor(.surfaceInteractiveActive)
                default: QeetrixComponentColor(.surfaceInteractive)
                }
            colors.foreground = QeetrixComponentColor(.textOnSubtle)
            colors.elevation = resting
        case .ghost:
            switch state {
            case .hovered: colors.background = QeetrixComponentColor(.surfaceInteractiveHover)
            case .pressed: colors.background = QeetrixComponentColor(.surfaceInteractiveActive)
            default: break
            }
        case .destructive:
            colors.background = QeetrixComponentColor(engaged ? .feedbackErrorStrong : .feedbackErrorSubtle)
            colors.foreground = QeetrixComponentColor(engaged ? .textOnFeedbackStrong : .textDanger)
        case .link:
            // Touch has no hover, so a press shows the hover treatment.
            colors.foreground = QeetrixComponentColor(engaged ? .textLinkHover : .textLink)
            colors.isUnderlined = engaged
        }
        if state == .disabled {
            colors.opacity = QeetrixOpacity.disabled
        }
        return colors
    }
}

struct QeetrixButtonStyleBody: View {
    let style: QeetrixButtonStyle
    let configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixButtonFillsWidth) private var fillsWidth
    @State private var isHovered = false

    var body: some View {
        let metrics = QeetrixButtonMetrics(size: style.size, density: density)
        let state = Self.state(isEnabled: isEnabled, isPressed: configuration.isPressed, isHovered: isHovered, isLoading: style.isLoading)
        let colors = QeetrixButtonColors.colors(style.variant, state)
        let shape = RoundedRectangle(cornerRadius: metrics.corner)
        sized(configuration.label.qeetrixType(metrics.type), metrics: metrics)
            .foregroundStyle(colors.foreground)
            .underline(colors.isUnderlined)
            .qeetrixElevation(colors.elevation, fill: colors.background, in: shape)
            .overlay { shape.strokeBorder(colors.border, lineWidth: QeetrixStroke.hairline) }
            .opacity(colors.opacity)
            .qeetrixHitArea()
            .onHover { isHovered = $0 }
            .qeetrixAnimation(.standard, .fast, value: state)
    }

    @ViewBuilder
    private func sized(_ label: some View, metrics: QeetrixButtonMetrics) -> some View {
        switch style.layout {
        case .icon:
            label.qeetrixIconSquare(metrics.height, icon: QeetrixIconButton.iconSize(style.size).points)  // size-*
        case .text(let leadingIcon, let trailingIcon):
            label
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, leadingIcon ? metrics.iconSidePadding : metrics.padding)
                .padding(.trailing, trailingIcon ? metrics.iconSidePadding : metrics.padding)
                // The web height is fixed; here it is a minimum, so larger text grows the button.
                .padding(.vertical, QeetrixWebScale.spacing(1))
                .frame(maxWidth: fillsWidth ? .infinity : nil, minHeight: metrics.height)
        }
    }

    /// A busy button keeps its colours — busy is not unavailable — and ignores the pointer; a disabled
    /// one fades.
    static func state(isEnabled: Bool, isPressed: Bool, isHovered: Bool, isLoading: Bool) -> QeetrixButtonState {
        if isLoading { return .resting }
        if !isEnabled { return .disabled }
        if isPressed { return .pressed }
        return isHovered ? .hovered : .resting
    }
}

private struct QeetrixButtonFillsWidthKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// Text buttons stretch to the width they are offered — set by ``QeetrixFormActions`` on compact
    /// width, where actions stack full-width.
    var qeetrixButtonFillsWidth: Bool {
        get { self[QeetrixButtonFillsWidthKey.self] }
        set { self[QeetrixButtonFillsWidthKey.self] = newValue }
    }
}
