import SwiftUI

/// A button's emphasis, as `@qeetrix/react`'s `ButtonVariant` (design rules §7).
public enum QeetrixButtonVariant: String, CaseIterable, Sendable {
    /// Primary: the Ember fill. The one main action in a region.
    case solid
    /// Secondary: the warm graphite fill. The main alternative, such as Export or Save draft.
    case soft
    /// Tertiary: no fill, Ember text, an Ember tint when pressed. Everything else: Cancel, Back.
    case ghost
}

/// A button's meaning, as `@qeetrix/react`'s `ButtonTone`.
public enum QeetrixButtonTone: String, CaseIterable, Sendable {
    /// The default.
    case brand
    /// The confirming action of a destructive flow; it replaces the primary, never sits beside it.
    case danger
    /// Utility actions in toolbars and headers, whose icons stay neutral. A solid or soft neutral
    /// button looks like a soft one.
    case neutral
}

/// The Qeetrix button treatment for any SwiftUI `Button`, `NavigationLink`, `ShareLink` or other
/// control that takes a button style.
///
/// ```swift
/// Button("Continue", action: submit)
///     .buttonStyle(.qeetrix())
///
/// NavigationLink("Billing", value: Route.billing)
///     .buttonStyle(.qeetrix(.ghost, size: .sm))
/// ```
///
/// The label takes the size's text style and is laid out label first, with no icon zone. Use
/// ``QeetrixButton`` for the trailing icon, its zone and the loading state.
public struct QeetrixButtonStyle: ButtonStyle {
    let variant: QeetrixButtonVariant
    let tone: QeetrixButtonTone
    let size: QeetrixControlSize
    var layout = Layout.text
    var isLoading = false

    enum Layout: Hashable {
        /// A label, followed by the icon zone when the button has an icon or is loading.
        case text
        case textWithZone
        /// A square holding one icon.
        case icon
    }

    public init(_ variant: QeetrixButtonVariant = .solid, tone: QeetrixButtonTone = .brand, size: QeetrixControlSize = .md) {
        self.variant = variant
        self.tone = tone
        self.size = size
    }

    init(_ variant: QeetrixButtonVariant, tone: QeetrixButtonTone, size: QeetrixControlSize, layout: Layout, isLoading: Bool) {
        self.variant = variant
        self.tone = tone
        self.size = size
        self.layout = layout
        self.isLoading = isLoading
    }

    public func makeBody(configuration: Configuration) -> some View {
        QeetrixButtonStyleBody(style: self, configuration: configuration)
    }

    /// The icon size inside a button of `size`: 16 pt, or 20 pt at `lg`.
    nonisolated public static func iconSize(for size: QeetrixControlSize) -> QeetrixIconSize {
        size == .lg ? .md : .sm
    }
}

extension ButtonStyle where Self == QeetrixButtonStyle {
    /// The Qeetrix button style.
    public static func qeetrix(
        _ variant: QeetrixButtonVariant = .solid, tone: QeetrixButtonTone = .brand, size: QeetrixControlSize = .md
    ) -> QeetrixButtonStyle {
        QeetrixButtonStyle(variant, tone: tone, size: size)
    }
}

/// The interaction states the button colours follow.
enum QeetrixButtonState: Hashable {
    case resting
    case hovered
    case pressed
    case disabled
}

/// Size metrics (button.css): the height from the density, the inline padding, the gap to the icon
/// zone, the zone's padding either side of the icon, and the rule's height.
struct QeetrixButtonMetrics {
    let height: CGFloat
    /// `padding-inline` before the label (and after it, without a zone).
    let padding: CGFloat
    /// `gap` between the label and the zone.
    let gap: CGFloat
    /// The zone's `padding-inline`, each side of the icon.
    let zonePadding: CGFloat
    /// The rule: `size.icon.xs` / `sm` / `md`.
    let ruleHeight: CGFloat
    let type: QeetrixTypeSpec
    let iconSize: QeetrixIconSize
    let spinnerSize: QeetrixSpinnerSize

    init(size: QeetrixControlSize, density: QeetrixDensity) {
        height = density.controlHeight(size)
        iconSize = QeetrixButtonStyle.iconSize(for: size)
        spinnerSize = size == .lg ? .lg : .md
        switch size {
        case .sm:
            padding = 10
            gap = 8
            zonePadding = 8
            ruleHeight = QeetrixIconSize.xs.points
            // font-size and line-height of label.sm, weight of label.md (both 500)
            type = QeetrixComponentType.role(.labelSm, QeetrixTextRole.labelMd.tokens.weight)
        case .md:
            padding = 14
            gap = 12
            zonePadding = 10
            ruleHeight = QeetrixIconSize.sm.points
            type = QeetrixComponentType.role(.labelMd)
        case .lg:
            padding = 16
            gap = 14
            zonePadding = 12
            ruleHeight = QeetrixIconSize.md.points
            type = QeetrixComponentType.role(.labelMd)
        }
    }
}

/// A variant and tone's colours in one state (button.css).
struct QeetrixButtonColors: Equatable {
    var background: QeetrixColor?
    var foreground: QeetrixColor

    static func colors(_ variant: QeetrixButtonVariant, _ tone: QeetrixButtonTone, _ state: QeetrixButtonState) -> QeetrixButtonColors {
        if state == .disabled {
            return QeetrixButtonColors(background: variant == .ghost ? nil : .bgDisabled, foreground: .textDisabled)
        }
        switch (variant, tone) {
        case (.solid, .brand):
            return QeetrixButtonColors(
                background: state == .pressed ? .bgBrandBoldPressed : state == .hovered ? .bgBrandBoldHover : .bgBrandBold,
                foreground: .textOnBrand)
        case (.soft, .brand), (.solid, .neutral), (.soft, .neutral):
            // A solid or soft neutral button looks like soft, in every state:
            // `.qx-button[data-tone="neutral"]:not([data-variant="ghost"])` and its `:hover` and
            // `:active` rules.
            return QeetrixButtonColors(
                background: state == .pressed ? .bgNeutralBoldPressed : state == .hovered ? .bgNeutralBoldHover : .bgNeutralBold,
                foreground: .textInverse)
        case (.solid, .danger), (.soft, .danger):
            return QeetrixButtonColors(
                background: state == .pressed ? .bgDangerBoldPressed : state == .hovered ? .bgDangerBoldHover : .bgDangerBold,
                foreground: .textOnBold)
        case (.ghost, .brand):
            return QeetrixButtonColors(
                background: state == .pressed ? .bgBrandSubtlePressed : state == .hovered ? .bgBrandSubtle : nil, foreground: .textBrand)
        case (.ghost, .danger):
            // `.qx-button[data-tone="danger"][data-variant="ghost"]:is(:hover, :active)`: the danger
            // tint, never the brand's; the tokens have no `bg.danger.subtle-pressed`.
            return QeetrixButtonColors(background: state == .resting ? nil : .bgDangerSubtle, foreground: .textDanger)
        case (.ghost, .neutral):
            switch state {
            case .pressed: return QeetrixButtonColors(background: .bgNeutralSubtlePressed, foreground: .textDefault)
            case .hovered: return QeetrixButtonColors(background: .bgNeutralSubtle, foreground: .textDefault)
            default: return QeetrixButtonColors(background: nil, foreground: .textSubtle)
            }
        }
    }
}

struct QeetrixButtonStyleBody: View {
    let style: QeetrixButtonStyle
    let configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.qeetrixDensity) private var density
    @Environment(\.qeetrixButtonFillsWidth) private var fillsWidth
    /// An icon button's square grows with its icon, which scales with Dynamic Type.
    @ScaledMetric(relativeTo: .body) private var iconScale: CGFloat = 100
    @State private var isHovered = false

    var body: some View {
        let metrics = QeetrixButtonMetrics(size: style.size, density: density)
        let state = Self.state(isEnabled: isEnabled, isPressed: configuration.isPressed, isHovered: isHovered, isLoading: style.isLoading)
        let colors = QeetrixButtonColors.colors(style.variant, style.tone, state)
        let shape = RoundedRectangle(cornerRadius: QeetrixRadius.control)
        sized(configuration.label.qeetrixTypeEnvironment(metrics.type), metrics: metrics)
            .foregroundStyle(colors.foreground)
            .background { if let background = colors.background { shape.fill(background) } }
            .overlay { if isFocused { QeetrixInnerFocusFrame(shape: shape) } }
            .qeetrixHitArea()
            .onHover { isHovered = $0 }
            .qeetrixAnimation(.standard, .fast, value: state)
    }

    @ViewBuilder
    private func sized(_ label: some View, metrics: QeetrixButtonMetrics) -> some View {
        switch style.layout {
        case .icon:
            label.frame(width: metrics.height * iconScale / 100, height: metrics.height * iconScale / 100)
        case .text, .textWithZone:
            label
                .padding(.leading, metrics.padding)
                .padding(.trailing, style.layout == .text ? metrics.padding : 0)
                // The web height is fixed; here larger text grows the button, keeping its room above
                // and below the label.
                .qeetrixControlBlockSize(metrics.height, type: metrics.type)
                // Full width centres the label on the button (design rules §7).
                .frame(maxWidth: fillsWidth ? .infinity : nil, alignment: fillsWidth ? .center : .leading)
        }
    }

    /// A busy button keeps its colours — busy is not unavailable — and ignores the pointer.
    static func state(isEnabled: Bool, isPressed: Bool, isHovered: Bool, isLoading: Bool) -> QeetrixButtonState {
        if isLoading { return .resting }
        if !isEnabled { return .disabled }
        if isPressed { return .pressed }
        return isHovered ? .hovered : .resting
    }
}

/// Keyboard focus on a button: the 2 pt Ember frame inside its edge, with a 1 pt surface-coloured gap
/// between it and the fill (design rules §10; button.css `:focus-visible`).
struct QeetrixInnerFocusFrame<S: InsettableShape>: View {
    let shape: S

    var body: some View {
        ZStack {
            shape.strokeBorder(QeetrixColor.surfaceDefault, lineWidth: QeetrixFocus.ringWidth + QeetrixBorderWidth.default)
            shape.strokeBorder(QeetrixColor.borderFocus, lineWidth: QeetrixFocus.ringWidth)
        }
        .accessibilityHidden(true)
    }
}

private struct QeetrixButtonFillsWidthKey: EnvironmentKey {
    static let defaultValue = false
}

private struct QeetrixButtonIconMirrorsKey: EnvironmentKey {
    static let defaultValue: Bool? = nil
}

extension EnvironmentValues {
    /// Text buttons stretch to the width they are offered — set by `isFullWidth`, and by
    /// ``QeetrixFormActions`` on compact width, where actions stack full width.
    var qeetrixButtonFillsWidth: Bool {
        get { self[QeetrixButtonFillsWidthKey.self] }
        set { self[QeetrixButtonFillsWidthKey.self] = newValue }
    }

    /// Whether a button's icon mirrors in right-to-left layouts, where its use gives it a direction — the
    /// arrow on a "Continue"; `nil` leaves it to the icon's name.
    var qeetrixButtonIconMirrors: Bool? {
        get { self[QeetrixButtonIconMirrorsKey.self] }
        set { self[QeetrixButtonIconMirrorsKey.self] = newValue }
    }
}
