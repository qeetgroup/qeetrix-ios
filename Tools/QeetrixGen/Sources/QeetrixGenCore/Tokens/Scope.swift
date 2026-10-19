/// Which upstream tokens become Swift, and why every other token does not.
///
/// The rule mirrors qeetrix-ui's own runtime boundary: what `tokens.css` publishes as `--qx-*` (the
/// semantic and component layers) is consumable, and primitives are not — so product code cannot
/// reach a palette value. The one exception is the short list of non-colour primitive scales that
/// qeetrix-ui itself hands to code in `src/lib/token-values.ts` (spacing, icon size and stroke,
/// stroke width) plus the font weight and geometry scales the typography roles are built from.
///
/// Every consumable token must match a rule here; an unmatched one fails generation, so a new
/// upstream group is a decision, not an accident.
public enum TokenKind: String, Sendable {
    case color
    case dimension
    case em
    case number
    case duration
    case easing
    case shadow
    case fontFamily
    /// A `component.<group>.*` token: a reference to a semantic colour, elevation or density
    /// metric where upstream writes one, otherwise a resolved colour, length or fraction.
    case component
}

public enum ScopeDecision: Equatable, Sendable {
    case include(TokenKind)
    case exclude(String)
}

public enum Scope {
    struct Rule {
        let pattern: [String]  // "*" matches one segment, "**" the rest
        let decision: ScopeDecision
    }

    static let consumableRules: [Rule] = [
        Rule(pattern: ["color", "**"], decision: .include(.color)),
        Rule(pattern: ["typography", "*", "font-family"], decision: .include(.fontFamily)),
        Rule(pattern: ["typography", "*", "font-size"], decision: .include(.dimension)),
        Rule(pattern: ["typography", "*", "font-weight"], decision: .include(.number)),
        Rule(pattern: ["typography", "*", "line-height"], decision: .include(.number)),
        Rule(pattern: ["typography", "*", "letter-spacing"], decision: .include(.em)),
        Rule(pattern: ["typography", "*", "font-geometry"], decision: .include(.number)),
        Rule(
            pattern: ["corner", "circle"],
            decision: .exclude("50% is a shape, not a length — use Circle or Capsule.")),
        Rule(pattern: ["corner", "*"], decision: .include(.dimension)),
        Rule(
            pattern: ["control", "*"],
            decision: .exclude("Resolves through the active density — read QeetrixDensity instead.")),
        Rule(pattern: ["density", "*", "*"], decision: .include(.dimension)),
        Rule(
            pattern: ["focus", "ring-style"],
            decision: .exclude("A CSS border-style keyword; SwiftUI strokes are solid unless dashed explicitly.")),
        Rule(pattern: ["focus", "*"], decision: .include(.dimension)),
        Rule(pattern: ["motion", "duration", "*"], decision: .include(.duration)),
        Rule(pattern: ["motion", "easing", "*"], decision: .include(.easing)),
        Rule(pattern: ["motion", "reduced", "duration"], decision: .include(.duration)),
        Rule(pattern: ["motion", "reduced", "easing"], decision: .include(.easing)),
        Rule(pattern: ["elevation", "**"], decision: .include(.shadow)),
        Rule(pattern: ["state", "opacity", "*"], decision: .include(.number)),
        Rule(
            pattern: ["z", "**"],
            decision: .exclude("Web stacking order. SwiftUI zIndex only orders siblings, so a global scale has no meaning.")),
        Rule(
            pattern: ["gradient", "**"],
            decision: .exclude("Not in the Phase 1 foundation set.")),
    ]

    static let primitiveAllowList: [Rule] = [
        Rule(pattern: ["space", "*"], decision: .include(.dimension)),
        Rule(pattern: ["icon", "size", "*"], decision: .include(.dimension)),
        Rule(pattern: ["icon", "stroke", "*"], decision: .include(.number)),
        Rule(pattern: ["stroke", "width", "*"], decision: .include(.dimension)),
        Rule(pattern: ["font", "weight", "*"], decision: .include(.number)),
        Rule(pattern: ["font", "geometry", "*"], decision: .include(.number)),
    ]

    public static let primitiveReason =
        "Primitive — not exposed. Semantic tokens carry the decision; product code never reads a raw scale or palette value."

    public static let unadoptedComponentReason =
        "Component tokens for a component iOS does not implement yet. Adopted groups are listed in Upstream/pins.json."

    /// - Parameter adoptedComponents: the `component.<group>` names iOS implements
    ///   (`qeetrixUI.componentTokens` in Upstream/pins.json).
    public static func decide(path: [String], consumable: Bool, adoptedComponents: Set<String> = []) throws -> ScopeDecision {
        if consumable, path.first == "component", path.count > 2 {
            return adoptedComponents.contains(path[1]) ? .include(.component) : .exclude(unadoptedComponentReason)
        }
        let rules = consumable ? consumableRules : primitiveAllowList
        if let rule = rules.first(where: { matches($0.pattern, path) }) {
            return rule.decision
        }
        if consumable {
            throw GeneratorError(
                "\(path.joined(separator: ".")): no scope rule. Decide whether iOS consumes it and add a rule to Scope.swift.")
        }
        return .exclude(primitiveReason)
    }

    static func matches(_ pattern: [String], _ path: [String]) -> Bool {
        for (index, segment) in pattern.enumerated() {
            if segment == "**" { return path.count > index }
            guard index < path.count, segment == "*" || segment == path[index] else { return false }
        }
        return pattern.count == path.count
    }
}
