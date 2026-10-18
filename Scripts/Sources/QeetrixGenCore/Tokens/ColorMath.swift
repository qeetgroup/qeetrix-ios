import Foundation

/// Colour conversion, following the CSS Color 4 sample code (https://www.w3.org/TR/css-color-4/#color-conversion-code)
/// so a token converts to the same colour a browser paints.
public enum ColorMath {
    /// A colour in OKLab with straight (non-premultiplied) alpha.
    public struct OKLab: Equatable, Sendable {
        public var l: Double
        public var a: Double
        public var b: Double
        public var alpha: Double

        public init(l: Double, a: Double, b: Double, alpha: Double = 1) {
            self.l = l
            self.a = a
            self.b = b
            self.alpha = alpha
        }
    }

    public enum Space: String, Sendable {
        case sRGB
        case displayP3
    }

    /// A gamma-encoded RGB colour ready for SwiftUI's `Color(_:red:green:blue:opacity:)`.
    public struct EncodedColor: Equatable, Sendable {
        public var space: Space
        public var red: Double
        public var green: Double
        public var blue: Double
        public var alpha: Double
        /// True when the colour lay outside Display P3 and was gamut-mapped (CSS Color 4 §13.2).
        public var gamutMapped: Bool

        /// `#RRGGBB` (with `AA` when translucent) of the sRGB rendition, clipped — for doc comments.
        public var hex: String {
            let srgb = space == .sRGB ? [red, green, blue] : ColorMath.p3ToSRGB([red, green, blue])
            let channels = srgb + (alpha < 1 ? [alpha] : [])
            return "#" + channels.map { String(format: "%02X", Int((min(max($0, 0), 1) * 255).rounded())) }.joined()
        }
    }

    // MARK: OKLCH / OKLab

    public static func oklch(l: Double, c: Double, h: Double, alpha: Double = 1) -> OKLab {
        let radians = h * .pi / 180
        return OKLab(l: l, a: c * cos(radians), b: c * sin(radians), alpha: alpha)
    }

    static let okLabToLMS: [[Double]] = [
        [1.0000000000000000, 0.3963377773761749, 0.2158037573099136],
        [1.0000000000000000, -0.1055613458156586, -0.0638541728258133],
        [1.0000000000000000, -0.0894841775298119, -1.2914855480194092],
    ]
    static let lmsToXYZ: [[Double]] = [
        [1.2268798758459243, -0.5578149944602171, 0.2813910456659647],
        [-0.0405757452148008, 1.1122868032803170, -0.0717110580655164],
        [-0.0763729366746601, -0.4214933324022432, 1.5869240198367816],
    ]
    static let xyzToLMS: [[Double]] = [
        [0.8190224379967030, 0.3619062600528904, -0.1288737815209879],
        [0.0329836539323885, 0.9292868615863434, 0.0361446663506424],
        [0.0481771893596242, 0.2642395317527308, 0.6335478284694309],
    ]
    static let lmsToOKLab: [[Double]] = [
        [0.2104542683093140, 0.7936177747023054, -0.0040720430116193],
        [1.9779985324311684, -2.4285922420485799, 0.4505937096174110],
        [0.0259040424655478, 0.7827717124575296, -0.8086757660832500],
    ]
    static let xyzToLinearSRGB: [[Double]] = [
        [12831 / 3959, -329 / 214, -1974 / 3959],
        [-851781 / 878810, 1648619 / 878810, 36519 / 878810],
        [705 / 12673, -2585 / 12673, 705 / 667],
    ]
    static let linearSRGBToXYZ: [[Double]] = [
        [506752 / 1228815, 87881 / 245763, 12673 / 70218],
        [87098 / 409605, 175762 / 245763, 12673 / 175545],
        [7918 / 409605, 87881 / 737289, 1001167 / 1053270],
    ]
    static let xyzToLinearP3: [[Double]] = [
        [446124 / 178915, -333277 / 357830, -72051 / 178915],
        [-14852 / 17905, 63121 / 35810, 423 / 17905],
        [11844 / 330415, -50337 / 660830, 316169 / 330415],
    ]
    static let linearP3ToXYZ: [[Double]] = [
        [608311 / 1250200, 189793 / 714400, 198249 / 1000160],
        [35783 / 156275, 247089 / 357200, 198249 / 2500400],
        [0 / 1, 32229 / 714400, 5220557 / 5000800],
    ]

    static func multiply(_ matrix: [[Double]], _ vector: [Double]) -> [Double] {
        matrix.map { row in zip(row, vector).reduce(0) { $0 + $1.0 * $1.1 } }
    }

    static func xyz(from lab: OKLab) -> [Double] {
        let lms = multiply(okLabToLMS, [lab.l, lab.a, lab.b]).map { $0 * $0 * $0 }
        return multiply(lmsToXYZ, lms)
    }

    static func okLab(fromXYZ xyz: [Double], alpha: Double) -> OKLab {
        let lms = multiply(xyzToLMS, xyz).map { cbrt($0) }
        let lab = multiply(lmsToOKLab, lms)
        return OKLab(l: lab[0], a: lab[1], b: lab[2], alpha: alpha)
    }

    /// sRGB (gamma-encoded, 0…1) → OKLab.
    public static func okLab(sRGB rgb: [Double], alpha: Double = 1) -> OKLab {
        okLab(fromXYZ: multiply(linearSRGBToXYZ, rgb.map(decode)), alpha: alpha)
    }

    /// OKLab → gamma-encoded sRGB, unclamped.
    public static func sRGB(from lab: OKLab) -> [Double] {
        multiply(xyzToLinearSRGB, xyz(from: lab)).map(encode)
    }

    /// OKLab → gamma-encoded Display P3, unclamped.
    public static func displayP3(from lab: OKLab) -> [Double] {
        multiply(xyzToLinearP3, xyz(from: lab)).map(encode)
    }

    static func p3ToSRGB(_ p3: [Double]) -> [Double] {
        multiply(xyzToLinearSRGB, multiply(linearP3ToXYZ, p3.map(decode))).map(encode)
    }

    /// The sRGB transfer function (Display P3 uses the same curve), sign-preserving.
    static func encode(_ linear: Double) -> Double {
        let magnitude = abs(linear)
        let encoded = magnitude > 0.0031308 ? 1.055 * pow(magnitude, 1 / 2.4) - 0.055 : 12.92 * magnitude
        return linear < 0 ? -encoded : encoded
    }

    static func decode(_ encoded: Double) -> Double {
        let magnitude = abs(encoded)
        let linear = magnitude <= 0.04045 ? magnitude / 12.92 : pow((magnitude + 0.055) / 1.055, 2.4)
        return encoded < 0 ? -linear : linear
    }

    // MARK: Gamut

    /// Floating-point slack when testing gamut membership: oklch(1 0 0) converts to
    /// 1.0000000000000004, which is white, not an out-of-gamut colour.
    static let gamutTolerance = 1e-6

    static func inGamut(_ rgb: [Double]) -> Bool {
        rgb.allSatisfy { $0 >= -gamutTolerance && $0 <= 1 + gamutTolerance }
    }

    static func clamp(_ rgb: [Double]) -> [Double] { rgb.map { min(max($0, 0), 1) } }

    /// The colour SwiftUI should draw. sRGB when the colour is inside sRGB (the common case, and
    /// directly comparable with the web's hex values); Display P3 when it is outside sRGB but inside
    /// P3, which is what Safari paints on an iPhone's P3 display; and the CSS Color 4 gamut-mapped P3
    /// colour when it is outside P3 too.
    public static func encode(_ lab: OKLab) -> EncodedColor {
        let srgb = sRGB(from: lab)
        if inGamut(srgb) {
            return rounded(EncodedColor(space: .sRGB, red: srgb[0], green: srgb[1], blue: srgb[2], alpha: lab.alpha, gamutMapped: false))
        }
        let p3 = displayP3(from: lab)
        if inGamut(p3) {
            return rounded(EncodedColor(space: .displayP3, red: p3[0], green: p3[1], blue: p3[2], alpha: lab.alpha, gamutMapped: false))
        }
        let mapped = gamutMapToP3(lab)
        return rounded(
            EncodedColor(space: .displayP3, red: mapped[0], green: mapped[1], blue: mapped[2], alpha: lab.alpha, gamutMapped: true))
    }

    /// CSS Color 4 §13.2.2, binary search on OKLCH chroma with a ΔE_OK JND of 0.02.
    static func gamutMapToP3(_ lab: OKLab) -> [Double] {
        if lab.l >= 1 { return [1, 1, 1] }
        if lab.l <= 0 { return [0, 0, 0] }
        let jnd = 0.02
        let epsilon = 0.0001
        let hue = atan2(lab.b, lab.a)
        func atChroma(_ chroma: Double) -> OKLab {
            OKLab(l: lab.l, a: chroma * cos(hue), b: chroma * sin(hue), alpha: lab.alpha)
        }
        func deltaE(_ clipped: [Double], _ current: OKLab) -> Double {
            let back = okLab(fromXYZ: multiply(linearP3ToXYZ, clipped.map(decode)), alpha: current.alpha)
            return sqrt(pow(back.l - current.l, 2) + pow(back.a - current.a, 2) + pow(back.b - current.b, 2))
        }
        var current = lab
        var clipped = clamp(displayP3(from: current))
        if deltaE(clipped, current) < jnd { return clipped }
        var low = 0.0
        var high = sqrt(lab.a * lab.a + lab.b * lab.b)
        var lowInGamut = true
        while high - low > epsilon {
            let chroma = (low + high) / 2
            current = atChroma(chroma)
            let candidate = displayP3(from: current)
            if lowInGamut, inGamut(candidate) {
                low = chroma
                continue
            }
            clipped = clamp(candidate)
            let error = deltaE(clipped, current)
            if error < jnd {
                if jnd - error < epsilon { return clipped }
                lowInGamut = false
                low = chroma
            } else {
                high = chroma
            }
        }
        return clipped
    }

    /// Six decimals, clamped into 0…1 once the gamut decision is made, and `-0` normalised, so the
    /// generated source is byte-stable across runs and machines.
    static func rounded(_ color: EncodedColor) -> EncodedColor {
        func round6(_ value: Double) -> Double {
            let clamped = min(max(value, 0), 1)
            let rounded = (clamped * 1_000_000).rounded() / 1_000_000
            return rounded == 0 ? 0 : rounded
        }
        var copy = color
        copy.red = round6(color.red)
        copy.green = round6(color.green)
        copy.blue = round6(color.blue)
        copy.alpha = round6(color.alpha)
        return copy
    }

    // MARK: color-mix()

    /// `color-mix(in oklab, first p1, second p2)` per CSS Color 5 §2: percentages normalised to sum to
    /// 100% (a smaller sum scales the result's alpha), then a premultiplied-alpha mix in OKLab.
    public static func mix(_ first: OKLab, _ p1: Double?, _ second: OKLab, _ p2: Double?) throws -> OKLab {
        var weight1: Double
        var weight2: Double
        switch (p1, p2) {
        case (nil, nil): (weight1, weight2) = (50, 50)
        case let (.some(a), nil): (weight1, weight2) = (a, 100 - a)
        case let (nil, .some(b)): (weight1, weight2) = (100 - b, b)
        case let (.some(a), .some(b)): (weight1, weight2) = (a, b)
        }
        let total = weight1 + weight2
        guard weight1 >= 0, weight2 >= 0, total > 0 else {
            throw GeneratorError("color-mix() percentages must be non-negative and not both zero.")
        }
        let alphaMultiplier = total < 100 ? total / 100 : 1
        weight1 /= total
        weight2 /= total

        let alpha = first.alpha * weight1 + second.alpha * weight2
        guard alpha > 0 else { return OKLab(l: 0, a: 0, b: 0, alpha: 0) }
        func channel(_ x: Double, _ y: Double) -> Double {
            (x * first.alpha * weight1 + y * second.alpha * weight2) / alpha
        }
        return OKLab(
            l: channel(first.l, second.l), a: channel(first.a, second.a), b: channel(first.b, second.b),
            alpha: alpha * alphaMultiplier)
    }
}

/// Parsing of the colour syntaxes the Qeetrix token build emits.
public enum ColorValues {
    public static func color(_ components: [CSSComponent], context: String) throws -> ColorMath.OKLab {
        guard components.count == 1 else { throw GeneratorError("\(context): expected one colour.") }
        switch components[0] {
        case .ident(let name) where name.lowercased() == "transparent":
            return ColorMath.OKLab(l: 0, a: 0, b: 0, alpha: 0)
        case let .function("oklch", arguments):
            let (channels, alpha) = try channelsAndAlpha(arguments, context: context)
            guard channels.count == 3 else { throw GeneratorError("\(context): oklch() needs L C H.") }
            let lightness = try channel(channels[0], percentScale: 1, context: context)
            let chroma = try channel(channels[1], percentScale: 0.4, context: context)
            guard case let .number(hue, unit) = channels[2], unit.isEmpty || unit == "deg" else {
                throw GeneratorError("\(context): unsupported oklch() hue.")
            }
            return ColorMath.oklch(l: lightness, c: chroma, h: hue, alpha: alpha)
        case let .function("rgb", arguments), let .function("rgba", arguments):
            let (channels, alpha) = try channelsAndAlpha(arguments, context: context)
            guard channels.count == 3 else { throw GeneratorError("\(context): rgb() needs three channels.") }
            let rgb = try channels.map { try channel($0, percentScale: 255, context: context) / 255 }
            return ColorMath.okLab(sRGB: rgb, alpha: alpha)
        case let .function("color-mix", arguments):
            return try colorMix(arguments, context: context)
        default:
            throw GeneratorError("\(context): unsupported colour syntax \(components[0]).")
        }
    }

    /// `L C H [/ A]` or legacy `r, g, b[, a]`.
    static func channelsAndAlpha(_ arguments: [CSSComponent], context: String) throws -> ([CSSComponent], Double) {
        if arguments.contains(.delimiter(",")) {
            let groups = splitOnCommas(arguments)
            let channels = groups.prefix(3).map { $0.first ?? .ident("") }
            let alpha = groups.count == 4 ? try channel(groups[3].first ?? .ident(""), percentScale: 1, context: context) : 1
            return (Array(channels), alpha)
        }
        if let slash = arguments.firstIndex(of: .delimiter("/")) {
            let alphaPart = Array(arguments[arguments.index(after: slash)...])
            guard alphaPart.count == 1 else { throw GeneratorError("\(context): bad alpha.") }
            return (Array(arguments[..<slash]), try channel(alphaPart[0], percentScale: 1, context: context))
        }
        return (arguments, 1)
    }

    static func channel(_ component: CSSComponent, percentScale: Double, context: String) throws -> Double {
        guard case let .number(value, unit) = component else {
            throw GeneratorError("\(context): unsupported colour channel \(component).")
        }
        switch unit {
        case "": return value
        case "%": return value / 100 * percentScale
        default: throw GeneratorError("\(context): unsupported colour channel unit \"\(unit)\".")
        }
    }

    static func colorMix(_ arguments: [CSSComponent], context: String) throws -> ColorMath.OKLab {
        let groups = splitOnCommas(arguments)
        guard groups.count == 3, groups[0] == [.ident("in"), .ident("oklab")] else {
            throw GeneratorError("\(context): only color-mix(in oklab, …, …) is supported.")
        }
        func operand(_ group: [CSSComponent]) throws -> (ColorMath.OKLab, Double?) {
            var percentage: Double?
            var colour: [CSSComponent] = []
            for component in group {
                if case let .number(value, "%") = component {
                    percentage = value
                } else {
                    colour.append(component)
                }
            }
            return (try color(colour, context: context), percentage)
        }
        let (first, p1) = try operand(groups[1])
        let (second, p2) = try operand(groups[2])
        do {
            return try ColorMath.mix(first, p1, second, p2)
        } catch let error as GeneratorError {
            throw GeneratorError("\(context): \(error.message)")
        }
    }
}
