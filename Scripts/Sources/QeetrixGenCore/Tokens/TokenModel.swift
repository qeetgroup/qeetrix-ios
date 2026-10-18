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

    public init(source: TokenSource) throws {
        themes = source.themes
        var included: [ResolvedToken] = []
        var excluded: [ExcludedToken] = []
        for path in source.paths {
            let consumable = source.consumableNames.contains(TokenSource.cssName(for: path))
            switch try Scope.decide(path: path, consumable: consumable) {
            case let .exclude(reason):
                excluded.append(ExcludedToken(path: path, reason: reason))
            case let .include(kind):
                var values: [String: TokenValue] = [:]
                for theme in source.themes {
                    let context = "\(path.joined(separator: ".")) (\(theme))"
                    guard let raw = source.values[path.joined(separator: ".")]?[theme],
                        let resolver = source.resolvers[theme]
                    else { throw GeneratorError("\(context): missing value.") }
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

    static func value(_ kind: TokenKind, _ components: [CSSComponent], context: String) throws -> TokenValue {
        switch kind {
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
