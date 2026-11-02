import CoreGraphics
import Foundation
import SwiftUI

// The value types Qeetrix tokens are expressed in. The values themselves are generated into
// Tokens/Generated from the published @qeetrix/tokens DTCG build; these types only give them a native
// shape. Behaviour (resolving a colour, building an Animation, drawing a shadow) lives in Foundations.

/// One layer of a shadow (`shadow.*`), as the web's `box-shadow` describes it.
public struct QeetrixShadowLayer: Hashable, Sendable {
    /// Horizontal offset, in points.
    public let x: CGFloat
    /// Vertical offset, in points.
    public let y: CGFloat
    /// CSS blur radius, in points. The Gaussian's standard deviation is half of it.
    public let blur: CGFloat
    /// CSS spread: positive grows the shadow shape, negative shrinks it.
    public let spread: CGFloat
    /// Drawn inside the shape (`inset`) rather than outside it.
    public let isInset: Bool
    let rgba: QeetrixRGBA

    /// The shadow colour, alpha included.
    public var color: Color { rgba.color }

    init(x: CGFloat, y: CGFloat, blur: CGFloat, spread: CGFloat, isInset: Bool, rgba: QeetrixRGBA) {
        self.x = x
        self.y = y
        self.blur = blur
        self.spread = spread
        self.isInset = isInset
        self.rgba = rgba
    }
}

/// A motion duration (`motion.duration.*`).
public struct QeetrixDuration: Hashable, Comparable, Sendable {
    public let seconds: TimeInterval

    public init(seconds: TimeInterval) {
        self.seconds = seconds
    }

    public static func < (lhs: QeetrixDuration, rhs: QeetrixDuration) -> Bool {
        lhs.seconds < rhs.seconds
    }
}

/// A motion easing curve (`motion.easing.*`): the CSS `cubic-bezier(x1, y1, x2, y2)` control points.
/// CSS `linear` is `cubic-bezier(0, 0, 1, 1)`.
public struct QeetrixEasing: Hashable, Sendable {
    public let x1: Double
    public let y1: Double
    public let x2: Double
    public let y2: Double

    public init(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }

    /// Whether the curve is the identity — CSS `linear`.
    public var isLinear: Bool { x1 == y1 && x2 == y2 }
}

/// A spring for native motion (`motion.spring.*`): stiffness and damping ratio, with a mass of 1.
public struct QeetrixSpring: Hashable, Sendable {
    public let stiffness: Double
    /// 1 is critically damped (no overshoot); below 1 the motion overshoots slightly.
    public let dampingRatio: Double

    public init(stiffness: Double, dampingRatio: Double) {
        self.stiffness = stiffness
        self.dampingRatio = dampingRatio
    }
}

/// Motion values that are not a single duration, easing or spring.
public enum QeetrixMotion {}

/// A position on a font's `wght` axis (`font.weight.*`).
public struct QeetrixFontWeight: Hashable, Comparable, Sendable {
    public let value: Double

    public init(_ value: Double) {
        self.value = value
    }

    public static func < (lhs: QeetrixFontWeight, rhs: QeetrixFontWeight) -> Bool {
        lhs.value < rhs.value
    }
}

/// A position on Qeet Sans's `GEOM` axis (`font.geometry.*`): the letter style, from the A11y forms
/// (0) through Base (50) to Geo (100).
public struct QeetrixFontGeometry: Hashable, Sendable {
    public let value: Double

    public init(_ value: Double) {
        self.value = value
    }
}

/// A typography role's token values (`typography.<role>`), and its letter style.
public struct QeetrixTextRoleTokens: Hashable, Sendable {
    public let family: QeetrixFontFamily
    /// Font size in points at the default Dynamic Type size.
    public let size: CGFloat
    public let weight: QeetrixFontWeight
    /// Line height as a multiple of the font size: the role's exact length (on the 4 pt grid) over
    /// ``size``, so `size * lineHeight` is that length.
    public let lineHeight: Double
    /// Letter spacing in points at ``size``; it scales with the size. Only `label.caps` is tracked.
    public let letterSpacing: Double
    /// The letter style the role's token names (`font.geometry.*`), for families with a `GEOM` axis;
    /// `nil` otherwise, as Fira Code has none.
    public let geometry: QeetrixFontGeometry?

    /// The same values at another weight: a role the web sets with a different `font-weight`.
    func weighted(_ weight: QeetrixFontWeight) -> QeetrixTextRoleTokens {
        QeetrixTextRoleTokens(
            family: family, size: size, weight: weight, lineHeight: lineHeight, letterSpacing: letterSpacing, geometry: geometry)
    }
}

/// One variation axis of a bundled font.
public struct QeetrixFontAxis: Hashable, Sendable {
    /// The four-character OpenType axis tag, e.g. `wght`.
    public let tag: String
    public let minimum: Double
    public let defaultValue: Double
    public let maximum: Double

    func clamped(_ value: Double) -> Double {
        min(max(value, minimum), maximum)
    }
}

/// A bundled font file, as read from the file when the package was generated.
public struct QeetrixFontFace: Hashable, Sendable {
    /// The file name in the package's `Fonts` resource folder, without the `.ttf` extension.
    public let resourceName: String
    /// The PostScript name CoreText resolves the font by.
    public let postScriptName: String
    /// The family name inside the font file.
    public let familyName: String
    /// The family name the web's CSS uses for the same font.
    public let webFamily: String
    public let axes: [QeetrixFontAxis]

    public func axis(_ tag: String) -> QeetrixFontAxis? {
        axes.first { $0.tag == tag }
    }
}

/// An icon size (`size.icon.*`), in points.
public struct QeetrixIconSize: Hashable, Sendable {
    public let points: CGFloat

    public init(_ points: CGFloat) {
        self.points = points
    }
}

/// An icon stroke width (`icon.stroke.*`), in units of the 24-unit icon grid — it scales with the icon,
/// as on the web.
public struct QeetrixIconStroke: Hashable, Sendable {
    public let width: CGFloat

    public init(_ width: CGFloat) {
        self.width = width
    }
}
