import CoreText
import SwiftUI

extension QeetrixTextRole {
    /// The Dynamic Type text style this role scales with. Token sizes are the sizes at the default
    /// ("Large") content size; Dynamic Type scales them along the curve of the matching system style.
    ///
    /// This mapping is a platform decision, not a token: it pairs each role with the system style of
    /// the nearest purpose and size.
    public var textStyle: Font.TextStyle {
        switch self {
        case .display: .largeTitle
        case .title: .title
        case .heading: .title3
        case .body: .body
        case .label: .subheadline
        case .labelCompact: .footnote
        case .caption: .caption
        case .micro: .caption2
        case .code: .body
        }
    }
}

/// A typography role resolved at a point size: the font and the paragraph metrics
/// `qeetrixTextStyle(_:)` applies.
public struct QeetrixTextMetrics: Hashable, Sendable {
    public let role: QeetrixTextRole
    /// The size after Dynamic Type scaling.
    public let pointSize: CGFloat
    /// The weight drawn — one step heavier than the role's when Bold Text is on.
    public let weight: QeetrixFontWeight
    public let font: Font
    /// Extra space between lines so the line height is the role's multiple of the size. SwiftUI cannot
    /// set lines tighter than the font's natural height, so a smaller multiple yields 0.
    public let lineSpacing: CGFloat
    /// Letter spacing in points.
    public let tracking: CGFloat
    /// False when the bundled font is unavailable and the system font stands in.
    public let usesBundledFont: Bool

    /// - Parameters:
    ///   - role: The typography role.
    ///   - size: The point size, typically already scaled by Dynamic Type. Defaults to the token size.
    ///   - legibilityWeight: The environment's Bold Text setting.
    public init(role: QeetrixTextRole, size: CGFloat? = nil, legibilityWeight: LegibilityWeight? = nil) {
        let resolved = QeetrixResolvedType(tokens: role.tokens, size: size, legibilityWeight: legibilityWeight)
        self.role = role
        pointSize = resolved.pointSize
        weight = resolved.weight
        font = resolved.font
        lineSpacing = resolved.lineSpacing
        tracking = resolved.tracking
        usesBundledFont = resolved.usesBundledFont
    }

    static func systemWeight(_ weight: QeetrixFontWeight) -> Font.Weight {
        QeetrixResolvedType.systemWeight(weight)
    }
}

/// A type specification — the typography values plus the Dynamic Type curve it scales along. Roles
/// are specifications; so are the component text styles the web sets with utility classes rather
/// than a role (`QeetrixComponentType`).
struct QeetrixTypeSpec: Hashable, Sendable {
    let tokens: QeetrixTextRoleTokens
    /// The curve the size scales along; `nil` for text inside a fixed-size graphic (avatar
    /// initials), which must not outgrow its frame.
    let textStyle: Font.TextStyle?

    init(_ tokens: QeetrixTextRoleTokens, scalesLike textStyle: Font.TextStyle?) {
        self.tokens = tokens
        self.textStyle = textStyle
    }

    init(_ role: QeetrixTextRole) {
        self.init(role.tokens, scalesLike: role.textStyle)
    }

    /// The same style at its token size whatever the Dynamic Type setting.
    var fixedSize: QeetrixTypeSpec {
        QeetrixTypeSpec(tokens, scalesLike: nil)
    }
}

/// A specification resolved at a point size: the one place fonts, line spacing and tracking are
/// computed, for roles and component text alike.
struct QeetrixResolvedType: Sendable {
    let pointSize: CGFloat
    let weight: QeetrixFontWeight
    let font: Font
    let lineSpacing: CGFloat
    let tracking: CGFloat
    let usesBundledFont: Bool

    init(tokens: QeetrixTextRoleTokens, size: CGFloat?, legibilityWeight: LegibilityWeight?) {
        let pointSize = size ?? tokens.size
        var weight = tokens.weight
        if legibilityWeight == .bold, let heavier = QeetrixFontWeight.scale.first(where: { $0 > tokens.weight }) {
            weight = heavier
        }
        self.pointSize = pointSize
        self.weight = weight
        tracking = tokens.letterSpacing * pointSize

        let metricsFont: CTFont
        if let bundled = QeetrixFontRegistry.font(tokens.family, size: pointSize, weight: weight, geometry: tokens.geometry) {
            font = Font(bundled)
            metricsFont = bundled
            usesBundledFont = true
        } else {
            let design: Font.Design = tokens.family == .mono ? .monospaced : .default
            font = .system(size: pointSize, weight: Self.systemWeight(weight), design: design)
            metricsFont =
                CTFontCreateUIFontForLanguage(.system, pointSize, nil) ?? CTFontCreateWithName("Helvetica" as CFString, pointSize, nil)
            usesBundledFont = false
        }
        let natural = CTFontGetAscent(metricsFont) + CTFontGetDescent(metricsFont) + CTFontGetLeading(metricsFont)
        lineSpacing = max(0, tokens.lineHeight * pointSize - natural)
    }

    static func systemWeight(_ weight: QeetrixFontWeight) -> Font.Weight {
        switch weight.value {
        case ..<350: .light
        case ..<450: .regular
        case ..<550: .medium
        case ..<650: .semibold
        default: .bold
        }
    }
}

struct QeetrixTextStyleModifier: ViewModifier {
    let spec: QeetrixTypeSpec
    @ScaledMetric private var size: CGFloat
    @Environment(\.legibilityWeight) private var legibilityWeight

    init(spec: QeetrixTypeSpec) {
        self.spec = spec
        _size = ScaledMetric(wrappedValue: spec.tokens.size, relativeTo: spec.textStyle ?? .body)
    }

    func body(content: Content) -> some View {
        let resolved = QeetrixResolvedType(
            tokens: spec.tokens, size: spec.textStyle == nil ? spec.tokens.size : size, legibilityWeight: legibilityWeight)
        content
            .font(resolved.font)
            .lineSpacing(resolved.lineSpacing)
            .tracking(resolved.tracking)
    }
}

extension View {
    /// Sets text in a Qeetrix typography role: the role's family, weight, letter style, line height and
    /// tracking, scaled with Dynamic Type along the role's ``QeetrixTextRole/textStyle`` and one weight
    /// step heavier when Bold Text is on.
    ///
    /// ```swift
    /// Text("Welcome back").qeetrixTextStyle(.title)
    /// ```
    public func qeetrixTextStyle(_ role: QeetrixTextRole) -> some View {
        modifier(QeetrixTextStyleModifier(spec: QeetrixTypeSpec(role)))
    }

    /// Sets text in a type specification — a role, or a component text style.
    func qeetrixType(_ spec: QeetrixTypeSpec) -> some View {
        modifier(QeetrixTextStyleModifier(spec: spec))
    }
}
