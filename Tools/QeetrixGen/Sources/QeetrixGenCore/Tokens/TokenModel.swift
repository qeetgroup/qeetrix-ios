import Foundation

public enum TokenValue: Equatable, Sendable {
    case color(ColorMath.EncodedColor)
    case dimension(Double)
    case em(Double)
    case number(Double)
    case duration(Double)
    case easing([Double])
    case shadow([CSSValues.ShadowLayer])
    case fontFamily(String)
    /// A component token that is exactly `var(--qx-color-…)`: the semantic colour's path.
    case colorReference([String])
    /// A component token that is exactly `var(--qx-elevation-…)`: the elevation's path.
    case elevationReference([String])
    /// A component token that follows the active density: the `density.<metric>` name.
    case densityReference(String)
    /// A percentage, as a fraction (25% → 0.25).
    case fraction(Double)
}

public struct ResolvedToken: Equatable, Sendable {
    public let path: [String]
    public let kind: TokenKind
    /// Whether the token is in tokens.css's consumable layer (false for the allow-listed primitives).
    public let consumable: Bool
    /// Value per theme, in registry order.
    public let values: [String: TokenValue]

    public var dotted: String { path.joined(separator: ".") }
    public var cssName: String { TokenSource.cssName(for: path) }
    public var isThemeInvariant: Bool { Set(values.values.map { "\($0)" }).count == 1 }
}

public struct ExcludedToken: Equatable, Sendable {
    public let path: [String]
    public let reason: String
}

/// Every upstream token, either resolved into a typed value or excluded with a reason.
public struct TokenModel: Sendable {
    public let themes: [String]
    public let included: [ResolvedToken]
    public let excluded: [ExcludedToken]

    public init(source: TokenSource, adoptedComponents: Set<String> = []) throws {
        themes = source.themes
        var included: [ResolvedToken] = []
        var excluded: [ExcludedToken] = []
        let pathsByCSSName = Dictionary(uniqueKeysWithValues: source.paths.map { (TokenSource.cssName(for: $0), $0) })
        for path in source.paths {
            let consumable = source.consumableNames.contains(TokenSource.cssName(for: path))
            switch try Scope.decide(path: path, consumable: consumable, adoptedComponents: adoptedComponents) {
            case let .exclude(reason):
                excluded.append(ExcludedToken(path: path, reason: reason))
            case let .include(kind):
                var values: [String: TokenValue] = [:]
                for theme in source.themes {
                    let context = "\(path.joined(separator: ".")) (\(theme))"
                    guard let raw = source.values[path.joined(separator: ".")]?[theme],
                        let resolver = source.resolvers[theme]
                    else { throw GeneratorError("\(context): missing value.") }
                    if kind == .component {
                        values[theme] = try Self.componentValue(
                            raw, resolver: resolver, pathsByCSSName: pathsByCSSName, context: context)
                        continue
                    }
                    let substituted = try resolver.substitute(raw, context: context)
                    let components = try CSSParser.parse(substituted, context: context)
                    values[theme] = try Self.value(kind, components, context: context)
                }
                included.append(ResolvedToken(path: path, kind: kind, consumable: consumable, values: values))
            }
        }
        self.included = included
        self.excluded = excluded
    }

    /// A component token keeps a reference when upstream writes one — `var(--qx-color-…)`, an
    /// elevation, a density metric — so the component follows the semantic token (and any future
    /// theme of it). Anything else is resolved to a concrete colour, length, fraction or duration.
    static func componentValue(
        _ raw: String, resolver: CSSVariableResolver, pathsByCSSName: [String: [String]], context: String
    ) throws -> TokenValue {
        let value = raw.trimmingCharacters(in: .whitespaces)
        if let name = Self.capture(#"^var\((--qx-color-[a-z0-9-]+)\)$"#, in: value), let path = pathsByCSSName[name] {
            return .colorReference(path)
        }
        if let name = Self.capture(#"^var\((--qx-elevation-[a-z0-9-]+)\)$"#, in: value), let path = pathsByCSSName[name] {
            return .elevationReference(path)
        }
        if let metric = Self.capture(#"^var\(--qx-density-([a-z-]+), var\(--qx-density-[a-z-]+-default\)\)$"#, in: value) {
            return .densityReference(metric)
        }
        let components = try CSSParser.parse(try resolver.substitute(value, context: context), context: context)
        guard components.count == 1 else { throw GeneratorError("\(context): unsupported component token value \(raw).") }
        switch components[0] {
        case let .number(fraction, "%"):
            return .fraction(fraction / 100)
        case .number(_, "em"):
            return .em(try CSSValues.em(components, context: context))
        case .number(_, "ms"), .number(_, "s"):
            return .duration(try CSSValues.duration(components, context: context))
        case .function("oklch", _), .function("rgb", _), .function("rgba", _), .function("color-mix", _), .ident("transparent"):
            return .color(ColorMath.encode(try ColorValues.color(components, context: context)))
        default:
            return .dimension(try CSSValues.dimension(components, context: context))
        }
    }

    static func capture(_ pattern: String, in text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern),
            let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
            let range = Range(match.range(at: 1), in: text)
        else { return nil }
        return String(text[range])
    }

    static func value(_ kind: TokenKind, _ components: [CSSComponent], context: String) throws -> TokenValue {
        switch kind {
        case .component: throw GeneratorError("\(context): component tokens are resolved by componentValue.")
        case .color: .color(ColorMath.encode(try ColorValues.color(components, context: context)))
        case .dimension: .dimension(try CSSValues.dimension(components, context: context))
        case .em: .em(try CSSValues.em(components, context: context))
        case .number: .number(try CSSValues.number(components, context: context))
        case .duration: .duration(try CSSValues.duration(components, context: context))
        case .easing: .easing(try CSSValues.easing(components, context: context))
        case .shadow: .shadow(try CSSValues.shadows(components, context: context))
        case .fontFamily: .fontFamily(try CSSValues.primaryFontFamily(components, context: context))
        }
    }

    /// Included tokens whose path starts with `prefix`.
    public func tokens(under prefix: [String]) -> [ResolvedToken] {
        included.filter { Array($0.path.prefix(prefix.count)) == prefix }
    }
}
