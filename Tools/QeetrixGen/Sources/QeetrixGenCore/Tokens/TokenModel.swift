import Foundation

/// A typography role's composite value, in points.
public struct TypographyValue: Equatable, Sendable {
    /// The first family of the stack: the face the web loads.
    public let family: String
    public let size: Double
    public let weight: Double
    /// A multiple of the size: `lineHeightLength / size`, the ratio the DTCG value carries.
    public let lineHeight: Double
    /// In points: the length the role's line height is authored as, on the 4 pt grid
    /// (`$extensions["in.qeet.qeetrix"].lineHeight`).
    public let lineHeightLength: Double
    /// In points at `size`.
    public let letterSpacing: Double
    /// The `font.geometry.*` token the role names for its letter style
    /// (`$extensions["in.qeet.qeetrix"].fontGeometry`), and its position on the `GEOM` axis.
    public let geometry: String
    public let geometryPosition: Double
}

public enum TokenValue: Equatable, Sendable {
    case color(ColorMath.EncodedColor)
    /// In points (1 CSS px = 1 pt, 1 rem = 16 pt).
    case dimension(Double)
    case number(Double)
    /// In seconds.
    case duration(Double)
    case easing([Double])
    case shadow([CSSValues.ShadowLayer])
    case typography(TypographyValue)
}

public struct ResolvedToken: Equatable, Sendable {
    public let path: [String]
    public let group: TokenGroup
    /// The member name inside the group's Swift type, before escaping.
    public let name: String
    /// The value in every context.
    public let values: [TokenContext: TokenValue]
    /// The resolved DTCG token in every context, for provenance.
    public let sources: [TokenContext: DTCGToken]
    /// Which modifier the value follows; `none` when it is the same everywhere.
    public let variation: TokenVariation

    public var dotted: String { path.joined(separator: ".") }
    public var cssName: String { "--qx-" + path.joined(separator: "-") }

    public func value(_ context: TokenContext) -> TokenValue { values[context]! }
}

public struct ExcludedToken: Equatable, Sendable {
    public let path: [String]
    public let reason: String

    public var dotted: String { path.joined(separator: ".") }
}

/// Every token of the build, either typed for Swift or excluded with a reason.
public struct TokenModel: Sendable {
    public let source: DTCGSource
    public let included: [ResolvedToken]
    public let excluded: [ExcludedToken]

    public init(source: DTCGSource) throws {
        self.source = source
        var included: [ResolvedToken] = []
        var excluded: [ExcludedToken] = []
        for path in source.paths {
            let dotted = path.joined(separator: ".")
            switch try Scope.decide(path: path) {
            case let .exclude(reason):
                excluded.append(ExcludedToken(path: path, reason: reason))
            case let .include(group, drop):
                var values: [TokenContext: TokenValue] = [:]
                var sources: [TokenContext: DTCGToken] = [:]
                var converted: [String: TokenValue] = [:]
                for context in source.contexts {
                    guard let token = source.tokens[context]?[dotted] else { throw GeneratorError("\(dotted) (\(context)): missing.") }
                    guard group.dtcgTypes.contains(token.type) else {
                        throw GeneratorError("\(dotted): $type \(token.type), but \(group.swiftType) takes \(group.dtcgTypes.sorted()).")
                    }
                    let key = DTCGSource.canonical(token.value) + (token.qeetrix.map(DTCGSource.canonical) ?? "")
                    if converted[key] == nil {
                        converted[key] = try Self.value(token, in: source.tokens[context] ?? [:], context: "\(dotted) (\(context))")
                    }
                    values[context] = converted[key]
                    sources[context] = token
                }
                let variation = try Self.variation(values, source: source, dotted: dotted)
                if variation != .none, variation != group.variesWith {
                    throw GeneratorError(
                        "\(dotted) follows the \(variation.rawValue) modifier, but \(group.swiftType) is read as \(group.variesWith == .none ? "a fixed value" : "following \(group.variesWith.rawValue)")."
                    )
                }
                let name = try SwiftNames.identifier(Array(path.dropFirst(drop)), context: dotted)
                included.append(
                    ResolvedToken(path: path, group: group, name: name, values: values, sources: sources, variation: variation))
            }
        }
        for group in TokenGroup.allCases {
            let members = included.filter { $0.group == group }
            try SwiftNames.requireUnique(members.map { ($0.name, $0.dotted) }, scope: group.swiftType)
        }
        self.included = included
        self.excluded = excluded
    }

    /// Included tokens of one group, in document order.
    public func tokens(_ group: TokenGroup) -> [ResolvedToken] {
        included.filter { $0.group == group }
    }

    public func token(_ dotted: String) -> ResolvedToken? {
        included.first { $0.dotted == dotted }
    }

    static func variation(_ values: [TokenContext: TokenValue], source: DTCGSource, dotted: String) throws -> TokenVariation {
        var bySchemes = false
        var byDensity = false
        for scheme in source.colorSchemes {
            for density in source.densities {
                let value = values[TokenContext(colorScheme: scheme, density: density)]
                if value != values[TokenContext(colorScheme: source.colorSchemes[0], density: density)] { bySchemes = true }
                if value != values[TokenContext(colorScheme: scheme, density: source.densities[0])] { byDensity = true }
            }
        }
        switch (bySchemes, byDensity) {
        case (true, true): throw GeneratorError("\(dotted) follows both the colour scheme and the density; iOS maps neither combination.")
        case (true, false): return .colorScheme
        case (false, true): return .density
        case (false, false): return .none
        }
    }

    // MARK: DTCG values

    /// - Parameter tokens: the context's resolved tokens, for the ones a token's extension names.
    static func value(_ token: DTCGToken, in tokens: [String: DTCGToken], context: String) throws -> TokenValue {
        switch token.type {
        case "color": return .color(try color(token.value, context: context))
        case "dimension": return .dimension(try dimension(token.value, context: context))
        case "number", "fontWeight":
            guard let number = token.value.doubleValue else { throw GeneratorError("\(context): expected a number.") }
            return .number(number)
        case "duration":
            guard let amount = token.value["value"]?.doubleValue, let unit = token.value["unit"]?.stringValue else {
                throw GeneratorError("\(context): expected a duration.")
            }
            switch unit {
            case "ms": return .duration(amount / 1000)
            case "s": return .duration(amount)
            default: throw GeneratorError("\(context): unsupported duration unit \(unit).")
            }
        case "cubicBezier":
            guard let points = token.value.arrayValue?.compactMap(\.doubleValue), points.count == 4, (0...1).contains(points[0]),
                (0...1).contains(points[2])
            else { throw GeneratorError("\(context): a cubicBezier needs four numbers with x in 0…1.") }
            return .easing(points)
        case "shadow":
            let layers = token.value.arrayValue ?? [token.value]
            return .shadow(
                try layers.map { layer in
                    func length(_ key: String) throws -> Double {
                        guard let value = layer[key] else { return 0 }
                        return try dimension(value, context: "\(context) \(key)")
                    }
                    guard let colour = layer["color"] else { throw GeneratorError("\(context): a shadow layer has no colour.") }
                    return CSSValues.ShadowLayer(
                        inset: layer["inset"] == .bool(true), x: try length("offsetX"), y: try length("offsetY"), blur: try length("blur"),
                        spread: try length("spread"), color: try color(colour, context: context))
                })
        case "typography":
            let value = token.value
            guard let family = try fontFamily(value["fontFamily"], context: context), let sizeValue = value["fontSize"],
                let weight = value["fontWeight"]?.doubleValue, let lineHeight = value["lineHeight"]?.doubleValue
            else { throw GeneratorError("\(context): a typography value needs fontFamily, fontSize, fontWeight and lineHeight.") }
            let size = try dimension(sizeValue, context: "\(context) fontSize")
            let spacing = try value["letterSpacing"].map { try dimension($0, context: "\(context) letterSpacing") } ?? 0
            // The exact line height and the letter style are in the role's extension; the DTCG ratio
            // must be the length over the size, exactly.
            let namespace = "$extensions[\"\(DTCGToken.extensionNamespace)\"]"
            guard let length = try token.qeetrix?["lineHeight"].map({ try dimension($0, context: "\(context) \(namespace).lineHeight") }),
                let geometry = token.qeetrix?["fontGeometry"].flatMap(DTCGSource.reference)
            else { throw GeneratorError("\(context): a typography role needs \(namespace).lineHeight and .fontGeometry.") }
            guard length / size == lineHeight else {
                throw GeneratorError(
                    "\(context): lineHeight \(swiftNumber(lineHeight)) is not \(namespace).lineHeight \(swiftNumber(length)) pt over the size \(swiftNumber(size)) pt."
                )
            }
            guard let target = tokens[geometry], target.type == "number", let position = target.value.doubleValue,
                geometry.hasPrefix("font.geometry.")
            else { throw GeneratorError("\(context): \(namespace).fontGeometry {\(geometry)} is not a font.geometry number.") }
            return .typography(
                TypographyValue(
                    family: family, size: size, weight: weight, lineHeight: length / size, lineHeightLength: length,
                    letterSpacing: spacing, geometry: geometry, geometryPosition: position))
        default:
            throw GeneratorError("\(context): no Swift mapping for $type \(token.type).")
        }
    }

    /// `{ value, unit }` in px or rem, in points.
    static func dimension(_ value: OrderedJSON, context: String) throws -> Double {
        guard let amount = value["value"]?.doubleValue, let unit = value["unit"]?.stringValue else {
            throw GeneratorError("\(context): expected a { value, unit } dimension.")
        }
        switch unit {
        case "px": return amount
        case "rem": return amount * remInPoints
        default: throw GeneratorError("\(context): unsupported unit \(unit).")
        }
    }

    static func fontFamily(_ value: OrderedJSON?, context: String) throws -> String? {
        switch value {
        case let .string(name)?: return name
        case let .array(names)?: return names.first?.stringValue
        default: return nil
        }
    }

    /// A DTCG colour: `{ colorSpace, components, alpha, hex }`. OKLCH is converted with the CSS Color 4
    /// matrices (ColorMath); when the result is inside sRGB it must round to the package's own `hex`.
    static func color(_ value: OrderedJSON, context: String) throws -> ColorMath.EncodedColor {
        guard let space = value["colorSpace"]?.stringValue, let components = value["components"]?.arrayValue, components.count == 3 else {
            throw GeneratorError("\(context): expected a DTCG colour with colorSpace and three components.")
        }
        let channels = try components.map { component -> Double in
            if case .string("none") = component { return 0 }  // a powerless hue
            guard let number = component.doubleValue else { throw GeneratorError("\(context): a colour component is not a number.") }
            return number
        }
        let alpha = value["alpha"]?.doubleValue ?? 1
        let lab: ColorMath.OKLab
        switch space {
        case "oklch": lab = ColorMath.oklch(l: channels[0], c: channels[1], h: channels[2], alpha: alpha)
        case "srgb": lab = ColorMath.okLab(sRGB: channels, alpha: alpha)
        default: throw GeneratorError("\(context): unsupported colour space \(space).")
        }
        let encoded = ColorMath.encode(lab)
        if encoded.space == .sRGB, let hex = value["hex"]?.stringValue {
            let ours = Self.bytes(encoded.hex)
            let theirs = Self.bytes(hex)
            guard ours.count >= 3, theirs.count >= 3, zip(ours.prefix(3), theirs.prefix(3)).allSatisfy({ abs($0 - $1) <= 1 }) else {
                throw GeneratorError("\(context): converts to \(encoded.hex), but the package's hex is \(hex).")
            }
        }
        return encoded
    }

    static func bytes(_ hex: String) -> [Int] {
        let digits = Array(hex.dropFirst())
        return stride(from: 0, to: digits.count - 1, by: 2).compactMap { Int(String(digits[$0...$0 + 1]), radix: 16) }
    }
}
