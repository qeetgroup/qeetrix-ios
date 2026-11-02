/// Which `@qeetrix/tokens` tokens become Swift, as what, and why every other token does not.
///
/// The rule follows the package's own boundary: the semantic layer (everything outside
/// `primitive.*`) is what products consume, so primitives are never generated and product code
/// cannot reach a raw palette or scale value. The one exception is the font weight scale the type
/// roles are built from (`primitive.font.weight.*`), which iOS needs to name a role's weight and
/// step it for Bold Text.
///
/// Every token must match a rule here; an unmatched one fails generation, so a new upstream group is
/// a decision, not an accident.
public enum TokenGroup: String, CaseIterable, Sendable {
    case color
    case shadow
    case textRole
    case fontWeight
    case fontGeometry
    case space
    case size
    case iconSize
    case radius
    case borderWidth
    case focus
    case duration
    case easing
    case spring
    case opacity
    case iconStroke
    /// A token the density modifier sets: a property of `QeetrixDensity`.
    case density

    /// The Swift type the group's tokens are members of.
    public var swiftType: String {
        switch self {
        case .color: "QeetrixColor"
        case .shadow: "QeetrixShadow"
        case .textRole: "QeetrixTextRole"
        case .fontWeight: "QeetrixFontWeight"
        case .fontGeometry: "QeetrixFontGeometry"
        case .space: "QeetrixSpace"
        case .size: "QeetrixSize"
        case .iconSize: "QeetrixIconSize"
        case .radius: "QeetrixRadius"
        case .borderWidth: "QeetrixBorderWidth"
        case .focus: "QeetrixFocus"
        case .duration: "QeetrixDuration"
        case .easing: "QeetrixEasing"
        case .spring: "QeetrixSpring"
        case .opacity: "QeetrixOpacity"
        case .iconStroke: "QeetrixIconStroke"
        case .density: "QeetrixDensity"
        }
    }

    /// The DTCG `$type`s the group accepts. Anything else under its paths fails generation.
    var dtcgTypes: Set<String> {
        switch self {
        case .color: ["color"]
        case .shadow: ["shadow"]
        case .textRole: ["typography"]
        case .fontWeight: ["fontWeight"]
        case .fontGeometry, .spring, .opacity, .iconStroke: ["number"]
        case .space, .size, .iconSize, .radius, .borderWidth, .focus, .density: ["dimension"]
        case .duration: ["duration"]
        case .easing: ["cubicBezier"]
        }
    }

    /// The modifier the group's values may follow. Every other group must be the same in every context.
    var variesWith: TokenVariation {
        switch self {
        case .color, .shadow: .colorScheme
        case .density: .density
        default: .none
        }
    }
}

/// Which modifier a token's value follows.
public enum TokenVariation: String, Sendable {
    case none
    case colorScheme
    case density
}

public enum ScopeDecision: Equatable, Sendable {
    /// Generated into `group`; the member name is the path after its first `drop` segments.
    case include(TokenGroup, drop: Int)
    case exclude(String)
}

public enum Scope {
    struct Rule {
        let pattern: [String]  // "*" matches one segment, "**" the rest
        let decision: ScopeDecision
    }

    public static let primitiveReason =
        "Primitive — not exposed. The semantic tokens carry the decision; product code never reads a raw palette or scale value."

    static let rules: [Rule] = [
        Rule(pattern: ["primitive", "font", "weight", "*"], decision: .include(.fontWeight, drop: 3)),
        Rule(pattern: ["primitive", "**"], decision: .exclude(primitiveReason)),
        Rule(pattern: ["color", "**"], decision: .include(.color, drop: 1)),
        Rule(pattern: ["shadow", "*"], decision: .include(.shadow, drop: 1)),
        Rule(pattern: ["typography", "*", "*"], decision: .include(.textRole, drop: 1)),
        Rule(
            pattern: ["font", "family", "*"],
            decision: .exclude(
                "Resolved into each typography role; the bundled faces are QeetrixFontFamily. Indic scripts fall back through CoreText's system cascade, as on the web without Noto Sans."
            )),
        Rule(pattern: ["font", "geometry", "*"], decision: .include(.fontGeometry, drop: 2)),
        Rule(pattern: ["space", "form", "gap"], decision: .include(.density, drop: 0)),
        Rule(pattern: ["space", "*", "*"], decision: .include(.space, drop: 1)),
        Rule(pattern: ["size", "control", "*"], decision: .include(.density, drop: 0)),
        Rule(pattern: ["size", "row"], decision: .include(.density, drop: 0)),
        Rule(pattern: ["size", "icon", "*"], decision: .include(.iconSize, drop: 2)),
        Rule(pattern: ["size", "target", "*"], decision: .include(.size, drop: 1)),
        Rule(pattern: ["radius", "*"], decision: .include(.radius, drop: 1)),
        Rule(pattern: ["border", "width", "*"], decision: .include(.borderWidth, drop: 2)),
        Rule(pattern: ["focus", "ring", "*"], decision: .include(.focus, drop: 1)),
        Rule(pattern: ["motion", "duration", "*"], decision: .include(.duration, drop: 2)),
        Rule(pattern: ["motion", "easing", "*"], decision: .include(.easing, drop: 2)),
        Rule(pattern: ["motion", "spring", "*", "*"], decision: .include(.spring, drop: 2)),
        Rule(pattern: ["opacity", "*"], decision: .include(.opacity, drop: 1)),
        Rule(pattern: ["icon", "stroke", "*"], decision: .include(.iconStroke, drop: 2)),
        Rule(
            pattern: ["z", "**"],
            decision: .exclude(
                "Web stacking order. SwiftUI zIndex only orders siblings, and the system presents overlays, so a global scale has no meaning."
            )),
        Rule(
            pattern: ["breakpoint", "*"],
            decision: .exclude(
                "Web window size classes. iOS lays out by its own size classes (horizontalSizeClass), which the system sets.")),
        Rule(
            pattern: ["component", "**"],
            decision: .exclude("Geometry of a component iOS does not implement (sidebar, tour, command palette, timeline).")),
    ]

    public static func decide(path: [String]) throws -> ScopeDecision {
        if let rule = rules.first(where: { matches($0.pattern, path) }) {
            return rule.decision
        }
        throw GeneratorError(
            "\(path.joined(separator: ".")): no scope rule. Decide whether iOS consumes it and add a rule to Scope.swift.")
    }

    static func matches(_ pattern: [String], _ path: [String]) -> Bool {
        for (index, segment) in pattern.enumerated() {
            if segment == "**" { return path.count > index }
            guard index < path.count, segment == "*" || segment == path[index] else { return false }
        }
        return pattern.count == path.count
    }
}
