import Foundation

/// The CSS root font size `rem` is measured against. qeetrix-ui never sets `html { font-size }`,
/// so browsers use their default, 16px; ARCHITECTURE.md records the assumption.
public let remInPoints: Double = 16

/// One CSS px is one iOS point — both are the 1/96-inch reference pixel at 1×.
public enum CSSValues {
    // MARK: Dimensions

    /// A length in points: `14px`, `0.8rem`, `0`, `calc(0.45rem * 1.4)`, `min(a, b)`.
    public static func dimension(_ components: [CSSComponent], context: String) throws -> Double {
        guard components.count == 1 else {
            throw GeneratorError("\(context): expected one length, found \(components.count) components.")
        }
        let quantity = try evaluate(components[0], context: context)
        guard quantity.isLength || quantity.value == 0 else {
            throw GeneratorError("\(context): expected a length, found a unitless number.")
        }
        return quantity.value
    }

    /// An `em` multiple (letter-spacing). `0` is accepted unitless, as CSS does.
    public static func em(_ components: [CSSComponent], context: String) throws -> Double {
        guard components.count == 1, case let .number(value, unit) = components[0], unit == "em" || (unit.isEmpty && value == 0) else {
            throw GeneratorError("\(context): expected an em value.")
        }
        return value
    }

    /// A plain number: a font weight, a line-height multiple, an opacity, an axis position.
    public static func number(_ components: [CSSComponent], context: String) throws -> Double {
        guard components.count == 1, case let .number(value, unit) = components[0], unit.isEmpty else {
            throw GeneratorError("\(context): expected a unitless number.")
        }
        return value
    }

    /// A duration in seconds.
    public static func duration(_ components: [CSSComponent], context: String) throws -> Double {
        guard components.count == 1, case let .number(value, unit) = components[0] else {
            throw GeneratorError("\(context): expected a duration.")
        }
        switch unit {
        case "ms": return value / 1000
        case "s": return value
        default: throw GeneratorError("\(context): unsupported duration unit \"\(unit)\".")
        }
    }

    /// A cubic Bézier easing. `linear` is `cubic-bezier(0, 0, 1, 1)`, which is what CSS defines it as.
    public static func easing(_ components: [CSSComponent], context: String) throws -> [Double] {
        guard components.count == 1 else { throw GeneratorError("\(context): expected one easing.") }
        switch components[0] {
        case .ident("linear"):
            return [0, 0, 1, 1]
        case let .function("cubic-bezier", arguments):
            let points = try splitOnCommas(arguments).map { try number($0, context: context) }
            guard points.count == 4, (0...1).contains(points[0]), (0...1).contains(points[2]) else {
                throw GeneratorError("\(context): cubic-bezier() needs four numbers with x in 0…1.")
            }
            return points
        default:
            throw GeneratorError("\(context): unsupported easing \(components[0]).")
        }
    }

    /// The first family in a font stack: `"Qeet Sans", ui-sans-serif, …` → `Qeet Sans`.
    public static func primaryFontFamily(_ components: [CSSComponent], context: String) throws -> String {
        guard let first = splitOnCommas(components).first, !first.isEmpty else {
            throw GeneratorError("\(context): empty font stack.")
        }
        if first.count == 1, case let .string(name) = first[0] { return name }
        let words = try first.map { component -> String in
            guard case let .ident(word) = component else {
                throw GeneratorError("\(context): unsupported font family syntax.")
            }
            return word
        }
        return words.joined(separator: " ")
    }

    // MARK: Shadows

    public struct ShadowLayer: Equatable, Sendable {
        public var inset: Bool
        public var x: Double
        public var y: Double
        public var blur: Double
        public var spread: Double
        public var color: ColorMath.EncodedColor
    }

    /// A `box-shadow` list. `none` is the empty list.
    public static func shadows(_ components: [CSSComponent], context: String) throws -> [ShadowLayer] {
        if components == [.ident("none")] { return [] }
        return try splitOnCommas(components).map { layer in
            var inset = false
            var lengths: [Double] = []
            var color: ColorMath.EncodedColor?
            for component in layer {
                switch component {
                case .ident("inset"):
                    inset = true
                case .number:
                    lengths.append(try dimension([component], context: context))
                default:
                    guard color == nil else { throw GeneratorError("\(context): a shadow layer has two colours.") }
                    color = ColorMath.encode(try ColorValues.color([component], context: context))
                }
            }
            guard (2...4).contains(lengths.count), let color else {
                throw GeneratorError("\(context): a shadow layer needs 2–4 lengths and a colour.")
            }
            return ShadowLayer(
                inset: inset, x: lengths[0], y: lengths[1],
                blur: lengths.count > 2 ? lengths[2] : 0,
                spread: lengths.count > 3 ? lengths[3] : 0,
                color: color)
        }
    }

    // MARK: calc()

    struct Quantity {
        var value: Double
        var isLength: Bool
    }

    static func evaluate(_ component: CSSComponent, context: String) throws -> Quantity {
        switch component {
        case let .number(value, unit):
            switch unit {
            case "": return Quantity(value: value, isLength: false)
            case "px": return Quantity(value: value, isLength: true)
            case "rem": return Quantity(value: value * remInPoints, isLength: true)
            default: throw GeneratorError("\(context): unsupported length unit \"\(unit)\".")
            }
        case let .function("calc", arguments):
            return try sum(arguments, context: context)
        case let .function("min", arguments), let .function("max", arguments):
            let values = try splitOnCommas(arguments).map { try sum($0, context: context) }
            guard let first = values.first, values.allSatisfy({ $0.isLength == first.isLength }) else {
                throw GeneratorError("\(context): min()/max() mixes lengths and numbers.")
            }
            let isMin = component == .function("min", arguments)
            let picked = isMin ? values.map(\.value).min()! : values.map(\.value).max()!
            return Quantity(value: picked, isLength: first.isLength)
        default:
            throw GeneratorError("\(context): unsupported value \(component).")
        }
    }

    private static func sum(_ components: [CSSComponent], context: String) throws -> Quantity {
        var terms: [[CSSComponent]] = [[]]
        var signs: [Double] = [1]
        for component in components {
            if component == .delimiter("+") || component == .delimiter("-") {
                terms.append([])
                signs.append(component == .delimiter("+") ? 1 : -1)
            } else {
                terms[terms.count - 1].append(component)
            }
        }
        var total: Quantity?
        for (term, sign) in zip(terms, signs) {
            let quantity = try product(term, context: context)
            if let running = total {
                guard running.isLength == quantity.isLength else {
                    throw GeneratorError("\(context): calc() adds a length to a number.")
                }
                total = Quantity(value: running.value + sign * quantity.value, isLength: running.isLength)
            } else {
                total = Quantity(value: sign * quantity.value, isLength: quantity.isLength)
            }
        }
        guard let total else { throw GeneratorError("\(context): empty calc().") }
        return total
    }

    private static func product(_ components: [CSSComponent], context: String) throws -> Quantity {
        var result: Quantity?
        var pendingDivide = false
        for component in components {
            if component == .delimiter("*") { continue }
            if component == .delimiter("/") {
                pendingDivide = true
                continue
            }
            let quantity = try evaluate(component, context: context)
            guard let running = result else {
                result = quantity
                continue
            }
            if pendingDivide {
                guard !quantity.isLength, quantity.value != 0 else {
                    throw GeneratorError("\(context): calc() divides by a length or by zero.")
                }
                result = Quantity(value: running.value / quantity.value, isLength: running.isLength)
                pendingDivide = false
            } else {
                guard !(running.isLength && quantity.isLength) else {
                    throw GeneratorError("\(context): calc() multiplies two lengths.")
                }
                result = Quantity(value: running.value * quantity.value, isLength: running.isLength || quantity.isLength)
            }
        }
        guard let result else { throw GeneratorError("\(context): empty calc() term.") }
        return result
    }
}
