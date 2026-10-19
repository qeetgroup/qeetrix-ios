import SwiftUI

/// The surface treatments of ``QeetrixCard``, as on the web.
public enum QeetrixCardVariant: String, CaseIterable, Sendable {
    /// The resting card: a boundary and the faintest shadow.
    case `default`
    /// The boundary without a shadow, for dense layouts and repeated tiles.
    case outline
    /// One step forward. Use it for the one surface on a screen that should stand out, not as a default.
    case elevated
}

/// The padding and gap scale of ``QeetrixCard`` — not its width.
public enum QeetrixCardSize: String, CaseIterable, Sendable {
    /// 16 pt padding and gap.
    case `default`
    /// 12 pt padding and gap.
    case sm
}

/// A surface that groups related content: an optional ``QeetrixCardHeader``, the content, and an
/// optional footer band.
///
/// ```swift
/// QeetrixCard {
///     QeetrixCardHeader("Team plan", description: "Billed monthly")
///     QeetrixText("Up to 25 members, with audit logs and SSO.")
/// } footer: {
///     QeetrixButton("Upgrade") { upgrade() }
/// }
/// ```
///
/// A card inside a card keeps its boundary and drops its shadow, so nesting never stacks elevation.
/// `isSelected` paints the selected boundary; it is visual, so carry the state in the control that
/// owns it. For a card that is itself the control, use ``QeetrixCardButtonStyle``.
public struct QeetrixCard<Content: View, Footer: View>: View {
    let variant: QeetrixCardVariant
    let size: QeetrixCardSize
    let isSelected: Bool
    let content: Content
    let footer: Footer?

    public init(
        variant: QeetrixCardVariant = .default,
        size: QeetrixCardSize = .default,
        isSelected: Bool = false,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.variant = variant
        self.size = size
        self.isSelected = isSelected
        self.content = content()
        self.footer = footer()
    }

    public var body: some View {
        QeetrixCardSurface(variant: variant, size: size, isSelected: isSelected, interaction: .none) {
            content
        } footer: {
            footer
        }
    }
}

extension QeetrixCard where Footer == EmptyView {
    /// A card without a footer.
    public init(
        variant: QeetrixCardVariant = .default,
        size: QeetrixCardSize = .default,
        isSelected: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.size = size
        self.isSelected = isSelected
        self.content = content()
        footer = nil
    }
}

/// A card's title, an optional description beneath it, and an optional action at the trailing edge.
public struct QeetrixCardHeader<Action: View>: View {
    let title: Text
    let description: Text?
    let action: Action
    @Environment(\.qeetrixCardSize) private var size

    public init(title: Text, description: Text? = nil, @ViewBuilder action: () -> Action) {
        self.title = title
        self.description = description
        self.action = action()
    }

    /// A localised title and description, with an action.
    public init(_ titleKey: LocalizedStringKey, description: LocalizedStringKey? = nil, @ViewBuilder action: () -> Action) {
        self.init(title: Text(titleKey), description: description.map { Text($0) }, action: action)
    }

    /// A title and description shown as given, without localisation, with an action.
    public init<S: StringProtocol>(_ title: S, description: S? = nil, @ViewBuilder action: () -> Action) {
        self.init(title: Text(title), description: description.map { Text($0) }, action: action)
    }

    public var body: some View {
        HStack(alignment: .top, spacing: QeetrixWebScale.spacing(2)) {  // gap-x-2
            VStack(alignment: .leading, spacing: QeetrixWebScale.spacing(1)) {  // gap-1
                title
                    .qeetrixType(Self.titleType(size))
                    .accessibilityAddTraits(.isHeader)
                if let description {
                    description
                        .qeetrixType(QeetrixCardMetrics.textType)
                        .foregroundStyle(QeetrixColor.textTertiary)  // text-muted-foreground
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            action
        }
    }

    /// `font-heading text-base leading-snug font-medium`, `text-sm` in a small card.
    static func titleType(_ size: QeetrixCardSize) -> QeetrixTypeSpec {
        QeetrixComponentType.heading(
            size == .sm ? QeetrixWebScale.textSM : QeetrixWebScale.textBase, .medium, lineHeight: QeetrixWebScale.leadingSnug,
            scalesLike: size == .sm ? .subheadline : .headline)
    }
}

extension QeetrixCardHeader where Action == EmptyView {
    public init(title: Text, description: Text? = nil) {
        self.init(title: title, description: description) { EmptyView() }
    }

    /// A localised title and description.
    public init(_ titleKey: LocalizedStringKey, description: LocalizedStringKey? = nil) {
        self.init(title: Text(titleKey), description: description.map { Text($0) })
    }

    /// A title and description shown as given, without localisation.
    public init<S: StringProtocol>(_ title: S, description: S? = nil) {
        self.init(title: Text(title), description: description.map { Text($0) })
    }
}

/// A card that is itself the control: the card surface as a button style, with the web's
/// interactive treatment — the hover elevation and boundary under a pointer, the resting shadow
/// while pressed — and the disabled opacity.
///
/// ```swift
/// Button { open(plan) } label: {
///     QeetrixCardHeader("Team plan", description: "Billed monthly")
/// }
/// .buttonStyle(.qeetrixCard(isSelected: plan == selected))
/// ```
///
/// Put only the card's content in the label — a header and short copy, never other controls. When
/// `isSelected` is true VoiceOver reads the button as selected.
public struct QeetrixCardButtonStyle: ButtonStyle {
    let variant: QeetrixCardVariant
    let size: QeetrixCardSize
    let isSelected: Bool

    public init(_ variant: QeetrixCardVariant = .default, size: QeetrixCardSize = .default, isSelected: Bool = false) {
        self.variant = variant
        self.size = size
        self.isSelected = isSelected
    }

    public func makeBody(configuration: Configuration) -> some View {
        QeetrixCardButtonBody(style: self, configuration: configuration)
    }
}

extension ButtonStyle where Self == QeetrixCardButtonStyle {
    /// The Qeetrix card as a button style.
    public static func qeetrixCard(
        _ variant: QeetrixCardVariant = .default, size: QeetrixCardSize = .default, isSelected: Bool = false
    )
        -> QeetrixCardButtonStyle
    {
        QeetrixCardButtonStyle(variant, size: size, isSelected: isSelected)
    }
}

private struct QeetrixCardButtonBody: View {
    let style: QeetrixCardButtonStyle
    let configuration: ButtonStyleConfiguration
    @State private var isHovered = false
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        QeetrixCardSurface(
            variant: style.variant, size: style.size, isSelected: style.isSelected,
            interaction: configuration.isPressed ? .pressed : isHovered ? .hovered : .resting
        ) {
            configuration.label
        } footer: {
            EmptyView?.none
        }
        .opacity(isEnabled ? 1 : QeetrixOpacity.disabled)
        .contentShape(RoundedRectangle(cornerRadius: QeetrixCardTokens.corner))
        .onHover { isHovered = $0 }
        .qeetrixAnimation(.standard, .fast, value: configuration.isPressed)
        .qeetrixAnimation(.standard, .fast, value: isHovered)
        .accessibilityAddTraits(style.isSelected ? .isSelected : [])
    }
}

/// Card metrics that are web classes rather than card tokens.
enum QeetrixCardMetrics {
    /// The card's body text, `text-sm`.
    static let textType = QeetrixComponentType.sans(QeetrixWebScale.textSM, .regular, scalesLike: .body)

    /// `py-4 gap-4` and the parts' `px-4` / `p-4`; 12 pt (`-3`) in a small card.
    static func padding(_ size: QeetrixCardSize) -> CGFloat {
        size == .sm ? QeetrixWebScale.spacing(3) : QeetrixWebScale.spacing(4)
    }
}

/// The card surface the view and the button style share.
struct QeetrixCardSurface<Content: View, Footer: View>: View {
    enum Interaction {
        /// A static card.
        case none
        case resting
        case hovered
        case pressed
    }

    let variant: QeetrixCardVariant
    let size: QeetrixCardSize
    let isSelected: Bool
    let interaction: Interaction
    let content: Content
    let footer: Footer?
    @Environment(\.qeetrixIsInsideCard) private var isInsideCard

    init(
        variant: QeetrixCardVariant, size: QeetrixCardSize, isSelected: Bool, interaction: Interaction, @ViewBuilder content: () -> Content,
        footer: () -> Footer?
    ) {
        self.variant = variant
        self.size = size
        self.isSelected = isSelected
        self.interaction = interaction
        self.content = content()
        self.footer = footer()
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: QeetrixCardTokens.corner)
        let padding = QeetrixCardMetrics.padding(size)
        VStack(alignment: .leading, spacing: padding) {  // gap-4 / gap-3
            VStack(alignment: .leading, spacing: padding) {
                content
            }
            .padding(.horizontal, padding)  // px-4 on the header and content
            if let footer {
                HStack(spacing: QeetrixWebScale.spacing(2)) {  // gap-2
                    footer
                }
                .padding(padding)  // p-4
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(QeetrixCardTokens.footerBackground)
                .overlay(alignment: .top) {
                    Rectangle().fill(QeetrixCardTokens.ring).frame(height: QeetrixStroke.hairline)  // border-t
                }
            }
        }
        .padding(.top, padding)  // py-4, and pb-0 above a footer
        .padding(.bottom, footer == nil ? padding : 0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .qeetrixType(QeetrixCardMetrics.textType)
        .foregroundStyle(QeetrixCardTokens.foreground)
        .environment(\.qeetrixCardSize, size)
        .environment(\.qeetrixIsInsideCard, true)
        .clipShape(shape)
        .qeetrixElevation(isInsideCard ? .flat : elevation, fill: background, in: shape)
        .overlay {
            shape.strokeBorder(border, lineWidth: QeetrixStroke.hairline)
            if isSelected {
                // The brand boundary doubled to 2 pt by a 1 pt ring outside it, so nothing moves.
                shape.inset(by: -QeetrixStroke.hairline).strokeBorder(
                    QeetrixCardTokens.borderSelected, lineWidth: 2 * QeetrixStroke.hairline)
            }
        }
    }

    var background: QeetrixComponentColor {
        variant == .elevated ? QeetrixCardTokens.backgroundElevated : QeetrixCardTokens.background
    }

    var elevation: QeetrixElevation {
        if interaction == .hovered { return QeetrixCardTokens.elevationHover }
        switch variant {
        case .default: return QeetrixCardTokens.elevation
        case .outline: return .flat
        case .elevated: return QeetrixCardTokens.elevationElevated
        }
    }

    var border: QeetrixComponentColor {
        interaction == .hovered || interaction == .pressed ? QeetrixCardTokens.borderHover : QeetrixCardTokens.ring
    }
}

private struct QeetrixCardSizeKey: EnvironmentKey {
    static let defaultValue: QeetrixCardSize = .default
}

private struct QeetrixIsInsideCardKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var qeetrixCardSize: QeetrixCardSize {
        get { self[QeetrixCardSizeKey.self] }
        set { self[QeetrixCardSizeKey.self] = newValue }
    }

    var qeetrixIsInsideCard: Bool {
        get { self[QeetrixIsInsideCardKey.self] }
        set { self[QeetrixIsInsideCardKey.self] = newValue }
    }
}
