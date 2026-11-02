import Foundation

/// `tokens.css` from `@qeetrix/tokens`: the stylesheet the web runs on. iOS generates from the DTCG
/// build, and reads the stylesheet for two things:
///
/// - **Agreement.** Every generated token that the stylesheet declares must have the same value in
///   every context (`:root`, `[data-qx-color-scheme]`, `[data-qx-density]`), evaluated by the strict
///   CSS reader. One build, two artifacts: if they disagree, generation fails.
/// - **Reduced motion.** The `@media (prefers-reduced-motion: reduce)` block, which the DTCG build has
///   no modifier for: it sets the durations Reduce Motion uses.
public struct Stylesheet: Sendable {
    /// `:root`'s declarations, outside any at-rule.
    let root: [String: String]
    /// Declarations per `[data-qx-color-scheme="…"]` and `[data-qx-density="…"]` block.
    let schemes: [String: [String: String]]
    let densities: [String: [String: String]]
    /// `@media (prefers-reduced-motion: reduce) { :root { … } }`.
    public let reducedMotion: [String: String]

    static let reducedMotionQuery = "@media (prefers-reduced-motion: reduce)"

    public init(_ css: String) throws {
        var root: [String: String] = [:]
        var schemes: [String: [String: String]] = [:]
        var densities: [String: [String: String]] = [:]
        var reduced: [String: String] = [:]
        func attribute(_ selector: String, _ name: String) -> String? {
            let prefix = "[\(name)=\""
            guard selector.hasPrefix(prefix), selector.hasSuffix("\"]") else { return nil }
            return String(selector.dropFirst(prefix.count).dropLast(2))
        }
        for declaration in CSSDeclarations.parse(css) {
            switch declaration.blocks {
            case [":root"]:
                root[declaration.name] = declaration.value
            case [Self.reducedMotionQuery, ":root"]:
                reduced[declaration.name] = declaration.value
            case let blocks where blocks.count == 1:
                if let scheme = attribute(blocks[0], "data-qx-color-scheme") {
                    schemes[scheme, default: [:]][declaration.name] = declaration.value
                } else if let density = attribute(blocks[0], "data-qx-density") {
                    densities[density, default: [:]][declaration.name] = declaration.value
                } else {
                    throw GeneratorError("tokens.css: unexpected block \(blocks[0]) — a new scope needs an iOS mapping.")
                }
            default:
                throw GeneratorError(
                    "tokens.css: unexpected nesting \(declaration.blocks.joined(separator: " › ")) for \(declaration.name).")
            }
        }
        self.root = root
        self.schemes = schemes
        self.densities = densities
        reducedMotion = reduced
    }

    func resolver(_ context: TokenContext) -> CSSVariableResolver {
        var table = root
        table.merge(schemes[context.colorScheme] ?? [:]) { $1 }
        table.merge(densities[context.density] ?? [:]) { $1 }
        return CSSVariableResolver(variables: table)
    }

    /// The CSS custom properties a token is published as, with the part of its value each holds.
    static func properties(_ token: ResolvedToken) -> [(name: String, part: String?)] {
        if token.group == .textRole {
            return ["font-size", "font-weight", "line-height", "letter-spacing", "font-geometry"].map { (token.cssName + "-" + $0, $0) }
        }
        return [(token.cssName, nil)]
    }

    /// Generated tokens the stylesheet does not declare (the font weight scale, springs).
    public func undeclared(in model: TokenModel) -> [ResolvedToken] {
        model.included.filter { token in Self.properties(token).allSatisfy { root[$0.name] == nil } }
    }

    /// Every disagreement between the stylesheet and the DTCG build.
    public func disagreements(with model: TokenModel) throws -> [String] {
        var problems: [String] = []
        for context in model.source.contexts {
            let resolver = resolver(context)
            for token in model.included {
                for (name, part) in Self.properties(token) where resolver.variables[name] != nil {
                    let label = "\(name) (\(context))"
                    let raw = try resolver.substitute(resolver.variables[name]!, context: label)
                    let components = try CSSParser.parse(raw, context: label)
                    if !(try Self.agrees(token.value(context), part: part, components, context: label)) {
                        problems.append("\(token.dotted) (\(context)): tokens.css says \(raw), the DTCG build \(token.value(context)).")
                    }
                }
            }
        }
        return problems
    }

    static func agrees(_ value: TokenValue, part: String?, _ css: [CSSComponent], context: String) throws -> Bool {
        func near(_ a: Double, _ b: Double, _ tolerance: Double = 1e-6) -> Bool { abs(a - b) <= tolerance }
        func sameColor(_ a: ColorMath.EncodedColor, _ b: ColorMath.EncodedColor) -> Bool {
            a.space == b.space && near(a.red, b.red, 1e-4) && near(a.green, b.green, 1e-4) && near(a.blue, b.blue, 1e-4)
                && near(a.alpha, b.alpha, 1e-4)
        }
        switch value {
        case let .color(color):
            return sameColor(color, ColorMath.encode(try ColorValues.color(css, context: context)))
        case let .dimension(points):
            return near(points, try CSSValues.dimension(css, context: context))
        case let .number(number):
            return near(number, try CSSValues.number(css, context: context))
        case let .duration(seconds):
            return near(seconds, try CSSValues.duration(css, context: context))
        case let .easing(points):
            return zip(points, try CSSValues.easing(css, context: context)).allSatisfy { near($0, $1) }
        case let .shadow(layers):
            let theirs = try CSSValues.shadows(css, context: context)
            return layers.count == theirs.count
                && zip(layers, theirs).allSatisfy {
                    $0.inset == $1.inset && near($0.x, $1.x) && near($0.y, $1.y) && near($0.blur, $1.blur) && near($0.spread, $1.spread)
                        && sameColor($0.color, $1.color)
                }
        case let .typography(type):
            switch part {
            case "font-size": return near(type.size, try CSSValues.dimension(css, context: context))
            case "font-weight": return near(type.weight, try CSSValues.number(css, context: context))
            // tokens.css rounds the ratio up at the sixth decimal, so browsers never lay a line out short.
            case "line-height": return near(type.lineHeight, try CSSValues.number(css, context: context))
            case "letter-spacing": return near(type.letterSpacing, try CSSValues.dimension(css, context: context))
            case "font-geometry": return near(type.geometryPosition, try CSSValues.number(css, context: context))
            default: return false
            }
        }
    }
}
