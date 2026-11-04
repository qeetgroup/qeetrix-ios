import CoreText
import SwiftUI
import os

extension QeetrixTextRole {
    /// The Dynamic Type text style this role scales with. Token sizes are the sizes at the default
    /// ("Large") content size; Dynamic Type scales them along the curve of the matching system style.
    ///
    /// This mapping is a platform decision, not a token: it pairs each role with the system style of
    /// the nearest purpose and size (ADR 0018).
    public var textStyle: Font.TextStyle {
        switch self {
        case .displayLg, .displayMd, .displaySm, .headingLg: .largeTitle
        case .headingMd: .title
        case .headingSm: .title2
        case .titleLg: .title3
        case .titleMd, .titleSm: .headline
        case .bodyLg, .bodyMd: .body
        case .bodySm: .footnote
        case .labelLg: .callout
        case .labelMd: .subheadline
        case .labelSm: .footnote
        case .labelCaps: .caption2
        case .codeMd: .body
        case .codeSm: .footnote
        }
    }
}

/// A typography role resolved at a point size: the font and the paragraph metrics
/// `qeetrixTextStyle(_:)` applies.
public struct QeetrixTextMetrics: Hashable, Sendable {
    public let role: QeetrixTextRole
    /// The size after Dynamic Type scaling.
    public let pointSize: CGFloat
    /// The weight drawn — one step heavier than the role's when Bold Text is on (see
    /// ``QeetrixFontWeight/bolder(in:)``).
    public let weight: QeetrixFontWeight
    public let font: Font
    /// Extra space between lines so the line height is the role's multiple of the size. SwiftUI cannot
    /// set lines tighter than the font's natural height, so a smaller multiple yields 0.
    public let lineSpacing: CGFloat
    /// Space above the first line and below the last — CSS's half-leading, half the difference between
    /// the role's line height and the font's natural one — so a single line is the role's line height
    /// tall, as on the web, with the text centred in it. Negative when the line is shorter than the
    /// font's natural height: then the glyphs overflow the line box, as they do in a browser.
    public let halfLeading: CGFloat
    /// Letter spacing in points.
    public let tracking: CGFloat
    /// False when the bundled font is unavailable and the system font stands in.
    public let usesBundledFont: Bool

    /// - Parameters:
    ///   - role: The typography role.
    ///   - size: The point size, typically already scaled by Dynamic Type. Defaults to the token size.
    ///   - legibilityWeight: The environment's Bold Text setting.
    public init(role: QeetrixTextRole, size: CGFloat? = nil, legibilityWeight: LegibilityWeight? = nil) {
        let resolved = QeetrixResolvedType.resolved(tokens: role.tokens, size: size, legibilityWeight: legibilityWeight)
        self.role = role
        pointSize = resolved.pointSize
        weight = resolved.weight
        font = resolved.font
        lineSpacing = resolved.lineSpacing
        halfLeading = resolved.halfLeading
        tracking = resolved.tracking
        usesBundledFont = resolved.usesBundledFont
    }

    static func systemWeight(_ weight: QeetrixFontWeight) -> Font.Weight {
        QeetrixResolvedType.systemWeight(weight)
    }
}

/// A type specification — the typography values plus the Dynamic Type curve it scales along. Roles
/// are specifications; so is a role at another weight, which components use where `@qeetrix/react`
/// sets a role and changes its `font-weight` (a selected tab, a chosen option).
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

    /// A role at another weight.
    init(_ role: QeetrixTextRole, weight: QeetrixFontWeight) {
        self.init(role.tokens.weighted(weight), scalesLike: role.textStyle)
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
    let halfLeading: CGFloat
    let tracking: CGFloat
    let usesBundledFont: Bool

    init(tokens: QeetrixTextRoleTokens, size: CGFloat?, legibilityWeight: LegibilityWeight?) {
        let pointSize = size ?? tokens.size
        let weight = legibilityWeight == .bold ? tokens.weight.bolder(in: tokens.family) : tokens.weight
        self.pointSize = pointSize
        self.weight = weight
        // label.caps is tracked in points at its token size; the tracking scales with the text.
        tracking = tokens.size > 0 ? tokens.letterSpacing * pointSize / tokens.size : 0

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
        let leading = tokens.lineHeight * pointSize - natural
        lineSpacing = max(0, leading)
        halfLeading = leading / 2
    }

    /// The resolved type for these values, built once and then reused. Every text in the library resolves
    /// its style on each update, and building a variable font and measuring it costs about 0.1 ms — five
    /// milliseconds for a screen of list rows (docs/quality.md). The cache is
    /// bounded: roles, Dynamic Type sizes and Bold Text give a few hundred entries in practice, and
    /// reaching the capacity empties it.
    static func resolved(tokens: QeetrixTextRoleTokens, size: CGFloat?, legibilityWeight: LegibilityWeight?) -> QeetrixResolvedType {
        let key = CacheKey(tokens: tokens, size: size ?? tokens.size, isBold: legibilityWeight == .bold)
        if let hit = cache.withLock({ $0[key] }) { return hit }
        let resolved = QeetrixResolvedType(tokens: tokens, size: size, legibilityWeight: legibilityWeight)
        cache.withLock { entries in
            if entries.count >= cacheCapacity { entries.removeAll() }
            entries[key] = resolved
        }
        return resolved
    }

    struct CacheKey: Hashable, Sendable {
        let tokens: QeetrixTextRoleTokens
        let size: CGFloat
        let isBold: Bool
    }

    static let cacheCapacity = 512
    static let cache = OSAllocatedUnfairLock(initialState: [CacheKey: QeetrixResolvedType]())

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

extension QeetrixFontWeight {
    /// The weight Bold Text draws instead: the next step of the token scale (regular → medium →
    /// semibold) and, past its top, 100 heavier on the font's `wght` axis (Qeet Sans and Fira Code
    /// reach 700). A platform rule: the web has no Bold Text setting.
    public func bolder(in family: QeetrixFontFamily) -> QeetrixFontWeight {
        if let next = Self.scale.first(where: { $0 > self }) { return next }
        let maximum = family.face.axis("wght")?.maximum ?? value
        return QeetrixFontWeight(min(value + 100, maximum))
    }
}

struct QeetrixTextStyleModifier: ViewModifier {
    let spec: QeetrixTypeSpec
    /// Whether the view is the text itself, and takes the half-leading; a container that only sets its
    /// descendants' type doesn't.
    var isText = true
    @ScaledMetric private var size: CGFloat
    @Environment(\.legibilityWeight) private var legibilityWeight

    init(spec: QeetrixTypeSpec, isText: Bool = true) {
        self.spec = spec
        self.isText = isText
        _size = ScaledMetric(wrappedValue: spec.tokens.size, relativeTo: spec.textStyle ?? .body)
    }

    func body(content: Content) -> some View {
        let resolved = QeetrixResolvedType.resolved(
            tokens: spec.tokens, size: spec.textStyle == nil ? spec.tokens.size : size, legibilityWeight: legibilityWeight)
        content
            .font(resolved.font)
            .lineSpacing(resolved.lineSpacing)
            .tracking(resolved.tracking)
            // CSS half-leading: a line is the role's line height tall, one line included.
            .padding(.vertical, isText ? resolved.halfLeading : 0)
    }
}

extension View {
    /// Sets text in a Qeetrix typography role: the role's family, weight, letter style, line height and
    /// tracking, scaled with Dynamic Type along the role's ``QeetrixTextRole/textStyle`` and one weight
    /// step heavier when Bold Text is on.
    ///
    /// ```swift
    /// Text("Welcome back").qeetrixTextStyle(.headingSm)
    /// ```
    public func qeetrixTextStyle(_ role: QeetrixTextRole) -> some View {
        modifier(QeetrixTextStyleModifier(spec: QeetrixTypeSpec(role)))
    }

    /// Sets text in a type specification — a role, or a role at another weight.
    func qeetrixType(_ spec: QeetrixTypeSpec) -> some View {
        modifier(QeetrixTextStyleModifier(spec: spec))
    }

    /// Sets the type a container's text inherits — the font, line spacing and tracking — without the
    /// half-leading, which belongs to the text itself.
    func qeetrixTypeEnvironment(_ spec: QeetrixTypeSpec) -> some View {
        modifier(QeetrixTextStyleModifier(spec: spec, isText: false))
    }
}
