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
    ///   - size: The point size, typically already scaled by Dynamic Type. Defaults to the token size.
    ///   - legibilityWeight: The environment's Bold Text setting.
    public init(role: QeetrixTextRole, size: CGFloat? = nil, legibilityWeight: LegibilityWeight? = nil) {
        let tokens = role.tokens
        let pointSize = size ?? tokens.size
        var weight = tokens.weight
        if legibilityWeight == .bold, let heavier = QeetrixFontWeight.scale.first(where: { $0 > tokens.weight }) {
            weight = heavier
        }
        self.role = role
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
    let role: QeetrixTextRole
    @ScaledMetric private var size: CGFloat
    @Environment(\.legibilityWeight) private var legibilityWeight

    init(role: QeetrixTextRole) {
        self.role = role
        _size = ScaledMetric(wrappedValue: role.tokens.size, relativeTo: role.textStyle)
    }

    func body(content: Content) -> some View {
        let metrics = QeetrixTextMetrics(role: role, size: size, legibilityWeight: legibilityWeight)
        content
            .font(metrics.font)
            .lineSpacing(metrics.lineSpacing)
            .tracking(metrics.tracking)
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
        modifier(QeetrixTextStyleModifier(role: role))
    }
}
